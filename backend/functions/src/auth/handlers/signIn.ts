// Autor: Gabriel Batista Bastos

import { timingSafeEqual, scrypt } from "node:crypto";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getAuth } from "firebase-admin/auth";
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

// Verifica se a senha informada corresponde ao hash armazenado no banco de dados.
// A função recebe a senha original e o hash salvo durante o cadastro.
function verifyPassword(
    password: string,
    storedHash: string
): Promise<boolean> {

    // Separa o hash em três partes: algoritmo utilizado, salt e hash da senha.
    const [algorithm, salt, hash] = storedHash.split("$");

    // Verifica se o algoritmo é scrypt e se o salt e o hash possuem formatos válidos.
    // Caso alguma dessas condições não seja atendida, a senha é considerada inválida.
    if (
        algorithm !== "scrypt" ||
        !/^[0-9a-f]{32}$/i.test(salt) ||
        !/^[0-9a-f]{128}$/i.test(hash)
    ) {
        return Promise.resolve(false);
    }

    return new Promise((resolve, reject) => {

        // Utiliza scrypt para gerar novamente o hash a partir da senha informada
        // e do mesmo salt utilizado quando a senha foi cadastrada.
        scrypt(password, salt, 64, (error, derivedKey) => {

            // Caso ocorra um erro durante a geração do hash, rejeita a Promise.
            if (error) {
                reject(error);
                return;
            }

            // Converte o hash armazenado, que está em formato hexadecimal, para Buffer.
            const storedKey = Buffer.from(hash, "hex");

            // Compara os dois hashes utilizando timingSafeEqual.
            // Essa comparação ajuda a evitar ataques que analisam o tempo de execução
            // para tentar descobrir informações sobre a senha.
            resolve(
                storedKey.length === derivedKey.length &&
                timingSafeEqual(storedKey, derivedKey)
            );
        });
    });
}

// Cria a Cloud Function responsável por realizar o login do usuário.
// A função pode ser chamada diretamente pelo aplicativo e utiliza mongoUri
// como segredo para acessar o banco de dados.
export const signIn = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        // Obtém os dados enviados pelo aplicativo.
        // Caso nenhum dado seja recebido, utiliza um objeto vazio.
        const data = request.data ?? {};

        // Obtém o e-mail informado, garantindo que seja uma string.
        // Remove espaços desnecessários e converte o texto para letras minúsculas.
        const userEmail =
            typeof data.email === "string"
                ? data.email.trim().toLowerCase()
                : "";

        // Obtém a senha informada, garantindo que seja uma string.
        const userPassword =
            typeof data.password === "string"
                ? data.password
                : "";

        // Verifica se o e-mail e a senha foram preenchidos.
        // Caso algum dos campos esteja vazio, interrompe a execução.
        if (!userEmail || !userPassword) {

            logger.error("Error from signIn: Fields missing");

            throw new HttpsError(
                "invalid-argument",
                "E-mail e senha são obrigatórios"
            );
        }

        try {

            // Organiza os dados de login que serão enviados ao servidor Java.
            const requestContent = {
                email: userEmail,
                password: userPassword
            };

            // Envia uma requisição ao servidor Java utilizando a operação LOGIN.
            // Aguarda a resposta do servidor antes de continuar o processo.
            const serverResponse = await serverConnection(
                OperationType.LOGIN,
                requestContent
            );

            // Verifica se o servidor retornou um erro de requisição.
            // Nesse caso, informa que os dados de login são inválidos.
            if (serverResponse.code === StatusType.BAD_REQUEST) {

                throw new HttpsError(
                    "invalid-argument",
                    serverResponse.message || "Dados de login inválidos"
                );
            }

            // Verifica se a resposta do servidor foi diferente de OK.
            // Caso tenha ocorrido uma falha, interrompe o processo de login.
            if (serverResponse.code !== StatusType.OK) {

                throw new HttpsError(
                    "internal",
                    "Falha ao validar os dados do login"
                );
            }

            // Estabelece a conexão com o banco de dados MongoDB.
            const database = await getDatabase();

            // Seleciona a coleção "users", que armazena os dados dos usuários.
            const users = database.collection<UserDocument>("users");

            // Procura no MongoDB um usuário que possua o e-mail informado.
            const user = await users.findOne({
                email: userEmail
            });

            // Verifica se o usuário foi encontrado no banco de dados.
            // Caso contrário, retorna um erro de autenticação.
           if (!user) {
                logger.warn("SignIn diagnostic: User not found in MongoDB");

                throw new HttpsError(
                    "unauthenticated",
                    "E-mail ou senha incorretos"
                );
            }

            // Compara a senha informada durante o login com o hash armazenado no MongoDB.
            // A função verifyPassword gera novamente o hash e verifica se os valores correspondem.
            const passwordMatches = await verifyPassword(
                userPassword,
                user.passwordHash
            );

            // Registra no log o resultado da verificação da senha.
            // Não registra a senha original nem o hash armazenado.
            logger.info("SignIn diagnostic: Password verification", {
                passwordMatches
            });

            // Se a senha informada não corresponder ao hash armazenado,
            // interrompe o processo e retorna um erro de autenticação.
            if (!passwordMatches) {
                throw new HttpsError(
                    "unauthenticated",
                    "E-mail ou senha incorretos"
                );
            }

            // Gera um token personalizado do Firebase Authentication.
            // O ID do usuário no MongoDB é utilizado como identificador (UID) do token.
            const customToken = await getAuth().createCustomToken(
                user._id.toString()
            );

            // Registra que o login foi realizado com sucesso.
            logger.info("Info from signIn: User logged in successfully");

            // Retorna os dados necessários para o aplicativo concluir o processo de login.
            // O token permite realizar a autenticação no Firebase.
            return {
                code: StatusType.OK,
                message: "Login realizado com sucesso",
                token:customToken,
                user: {
                    id: user._id.toString(),
                    name: user.name,
                    email: user.email,
                    phoneNumber: user.phoneNumber
                }
            };

        } catch (err) {

            // Verifica se o erro já é um HttpsError.
            // Se for, mantém o tipo e a mensagem originais.
            if (err instanceof HttpsError) {
                throw err;
            }

            // Registra erros inesperados ocorridos durante o processamento do login.
            logger.error(
                "Error from signIn: Failed to process login",
                err
            );

            // Retorna um erro interno caso não seja possível concluir o login.
            throw new HttpsError(
                "internal",
                "Falha ao processar requisição de login"
            );
        }
    }
); 