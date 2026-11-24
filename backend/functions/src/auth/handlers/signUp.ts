// Autor: Gabriel Batista Bastos

import { randomBytes, scrypt } from "node:crypto";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { serverConnection } from "./serverConnection";
import { OperationType } from "../types/operationType";
import { StatusType } from "../types/statusType";
import { getDatabase, mongoUri } from "../../shared/mongodb";

// Define a estrutura dos documentos de usuários armazenados no MongoDB.
interface UserDocument {
    name: string;
    email: string;
    phoneNumber: string;
    passwordHash: string;
    createdAt: Date;
}

// Gera um hash seguro para a senha antes de armazená-la no banco de dados.
// O processo utiliza o algoritmo scrypt e um salt aleatório.
function hashPassword(password: string): Promise<string> {

    // Gera 16 bytes aleatórios e os converte para hexadecimal.
    // O salt é utilizado para tornar o hash diferente mesmo quando duas senhas são iguais.
    const salt = randomBytes(16).toString("hex");

    return new Promise((resolve, reject) => {

        // Utiliza o algoritmo scrypt para gerar um hash de 64 bytes
        // a partir da senha informada e do salt gerado.
        scrypt(password, salt, 64, (error, derivedKey) => {

            // Caso ocorra algum erro durante a geração do hash, rejeita a Promise.
            if (error) {
                reject(error);
                return;
            }

            // Retorna o resultado contendo o nome do algoritmo, o salt e o hash,
            // separados por "$", para permitir a verificação posterior da senha.
            resolve(`scrypt$${salt}$${derivedKey.toString("hex")}`);
        });
    });
}

// Verifica se o erro recebido corresponde a uma violação de chave duplicada do MongoDB.
function isDuplicateKeyError(error: unknown): boolean {

    // O código 11000 é retornado pelo MongoDB quando uma operação
    // tenta inserir um valor que viola uma restrição de unicidade.
    return (
        typeof error === "object" &&
        error !== null &&
        "code" in error &&
        error.code === 11000
    );
}

// Cria a Cloud Function responsável pelo cadastro de novos usuários.
// Ela pode ser chamada diretamente pelo aplicativo e utiliza mongoUri
// como segredo para acessar o banco de dados.
export const signUp = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        // Obtém os dados enviados pelo aplicativo.
        // Caso nenhum dado seja recebido, utiliza um objeto vazio.
        const data = request.data ?? {};

        // Obtém o nome informado e remove espaços desnecessários no início e no final.
        const userName =
            typeof data.name === "string" ? data.name.trim() : "";

        // Obtém o e-mail, remove espaços desnecessários e converte para letras minúsculas.
        // Isso ajuda a manter um padrão na forma como os e-mails são armazenados.
        const userEmail =
            typeof data.email === "string"
                ? data.email.trim().toLowerCase()
                : "";

        // Obtém a senha informada pelo usuário.
        const userPassword =
            typeof data.password === "string" ? data.password : "";

        // Obtém o telefone informado e remove espaços desnecessários.
        const userPhoneNumber =
            typeof data.phoneNumber === "string"
                ? data.phoneNumber.trim()
                : "";

        // Verifica se todos os campos obrigatórios foram preenchidos.
        // Caso algum esteja vazio, interrompe o cadastro.
        if (!userName || !userEmail || !userPassword || !userPhoneNumber) {

            // Registra no log que a requisição foi recebida sem todos os campos necessários.
            logger.error("Error from signUp: Fields missing");

            // Retorna um erro indicando que todos os campos são obrigatórios.
            throw new HttpsError(
                "invalid-argument",
                "Todos os campos são obrigatórios"
            );
        }

        try {

            // Organiza os dados do usuário que serão enviados ao servidor Java
            // para a validação das informações do cadastro.
            const requestContent = {
                name: userName,
                email: userEmail,
                password: userPassword,
                phoneNumber: userPhoneNumber
            };

            // Envia uma requisição ao servidor Java utilizando a operação REGISTER.
            // Aguarda a resposta antes de continuar o processo de cadastro.
            const serverResponse = await serverConnection(
                OperationType.REGISTER,
                requestContent
            );

            // Verifica se o servidor Java identificou dados inválidos.
            // Nesse caso, retorna a mensagem de validação recebida do servidor.
            if (serverResponse.code === StatusType.BAD_REQUEST) {

                throw new HttpsError(
                    "invalid-argument",
                    serverResponse.message || "Dados de cadastro inválidos"
                );
            }

            // Verifica se a resposta do servidor foi diferente de OK.
            // Caso tenha ocorrido uma falha, registra o erro e interrompe o cadastro.
            if (serverResponse.code !== StatusType.OK) {

                logger.error(
                    "Error from signUp: Java server validation failed"
                );

                throw new HttpsError(
                    "internal",
                    "Falha ao validar os dados do cadastro"
                );
            }

            // Estabelece a conexão com o banco de dados MongoDB.
            const database = await getDatabase();

            // Seleciona a coleção "users", responsável por armazenar os dados dos usuários.
            const users = database.collection<UserDocument>("users");

            // Cria um índice único para o campo email.
            // Essa restrição impede que dois usuários sejam cadastrados com o mesmo e-mail.
            await users.createIndex(
                { email: 1 },
                { unique: true }
            );

            // Consulta o MongoDB para verificar se já existe um usuário
            // cadastrado com o e-mail informado.
            const existingUser = await users.findOne({
                email: userEmail
            });

            // Se o e-mail já estiver cadastrado, interrompe a operação
            // e informa que não é possível criar outro usuário com ele.
            if (existingUser) {

                throw new HttpsError(
                    "already-exists",
                    "Este e-mail já está cadastrado"
                );
            }

            // Gera o hash da senha utilizando a função hashPassword.
            // A senha original não é armazenada diretamente no MongoDB.
            const passwordHash = await hashPassword(userPassword);

            // Insere um novo documento na coleção "users".
            // São armazenados os dados pessoais, o hash da senha e a data do cadastro.
            const result = await users.insertOne({

                name: userName,
                email: userEmail,
                phoneNumber: userPhoneNumber,
                passwordHash: passwordHash,
                createdAt: new Date()
            });

            // Registra no log que o cadastro foi concluído com sucesso.
            logger.info("Info from signUp: User registered successfully");

            // Retorna uma resposta de sucesso para o aplicativo.
            // O ID do documento inserido é convertido para string.
            // A senha e seu hash não são incluídos na resposta.
            return {
                code: StatusType.OK,
                message: "Cadastro realizado com sucesso",
                user: {
                    id: result.insertedId.toString(),
                    name: userName,
                    email: userEmail,
                    phoneNumber: userPhoneNumber
                }
            };

        } catch (err) {

            // Verifica se o erro já é um HttpsError.
            // Caso seja, mantém o tipo e a mensagem originais.
            if (err instanceof HttpsError) {
                throw err;
            }

            // Verifica se ocorreu uma violação de chave duplicada no MongoDB.
            // Essa verificação também protege contra tentativas simultâneas
            // de cadastro com o mesmo e-mail.
            if (isDuplicateKeyError(err)) {

                throw new HttpsError(
                    "already-exists",
                    "Este e-mail já está cadastrado"
                );
            }

            // Registra erros inesperados ocorridos durante o processamento do cadastro.
            logger.error(
                "Error from signUp: Failed to process registration",
                err
            );

            // Retorna um erro interno caso não seja possível concluir o cadastro.
            throw new HttpsError(
                "internal",
                "Falha ao processar requisição de cadastro"
            );
        }
    }
);