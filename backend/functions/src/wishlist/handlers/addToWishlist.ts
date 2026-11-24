//Autor: Gabriel Batista Bastos

import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getDatabase, mongoUri } from "../../shared/mongodb";

// Define as categorias de conteúdo permitidas na lista de desejos.
type ContentCategory = "movie" | "tv";

// Define a estrutura de um documento armazenado na coleção wishlists do MongoDB.
interface WishlistDocument {
    userId: string;
    contentId: number;
    category: ContentCategory;
    createdAt: Date;
}

// Cria uma Cloud Function que pode ser chamada diretamente pelo aplicativo.
// A variável de ambiente mongoUri é disponibilizada como segredo para a conexão com o banco.
export const addToWishlist = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        // Verifica se existe um usuário autenticado na requisição.
        // Caso contrário, impede que o conteúdo seja adicionado à lista de desejos.
        if (!request.auth) {

            logger.error("Error from addToWishlist: User not authenticated");

            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado"
            );
        }

        // Obtém os dados enviados pelo aplicativo.
        // Caso nenhum dado seja recebido, utiliza um objeto vazio para evitar erros.
        const data = request.data ?? {};

        // Extrai o identificador e a categoria do conteúdo enviado na requisição.
        const contentId = data.id;
        const category = data.category;

        // Verifica se o ID recebido é um número inteiro positivo.
        // IDs inválidos são rejeitados antes de qualquer operação no banco de dados.
        if (
            typeof contentId !== "number" ||
            !Number.isInteger(contentId) ||
            contentId < 1
        ) {

            throw new HttpsError(
                "invalid-argument",
                "ID do conteúdo inválido"
            );
        }
        
         // Verifica se a categoria corresponde a um filme ("movie") ou série ("tv").
        // Qualquer outro valor é considerado inválido.
        if (category !== "movie" && category !== "tv") {

            throw new HttpsError(
                "invalid-argument",
                "Categoria do conteúdo inválida"
            );
        }

        // Obtém o UID do usuário autenticado pelo Firebase.
        // Esse identificador será utilizado para associar o conteúdo ao usuário correto.
        const userId = request.auth.uid;

        try {
            
            // Estabelece a conexão com o banco de dados MongoDB.
            const database = await getDatabase();
                        
            // Seleciona a coleção "wishlists" e define o tipo dos documentos armazenados nela.
            const wishlist = database.collection<WishlistDocument>(
                "wishlists"
            );

             // Procura um registro que corresponda ao usuário, ao conteúdo e à categoria.
            // Se o registro não existir, cria um novo documento.
            const result = await wishlist.updateOne(
                {
                    userId,
                    contentId,
                    category
                },
                {
                    // $setOnInsert define os valores somente quando um novo documento é inserido.
                    // Assim, se o conteúdo já existir, os dados existentes não serão modificados.
                    $setOnInsert: {
                        userId,
                        contentId,
                        category,
                        createdAt: new Date()
                    }
                },
                {
                    // Permite inserir um novo documento caso nenhum registro correspondente seja encontrado.
                    upsert: true
                }
            );
            
            // Verifica se um novo documento foi inserido.
            // Se upsertedCount for igual a 1, significa que o conteúdo foi adicionado.
            const added = result.upsertedCount === 1;

            // Registra no sistema se o conteúdo foi adicionado ou se já estava na lista.
            logger.info(
                added
                    ? "Info from addToWishlist: Content added"
                    : "Info from addToWishlist: Content already exists"
            );

            // Retorna uma resposta indicando o resultado da operação.
            return {
                code: 200,
                added,
                message: added
                    ? "Conteúdo adicionado à lista de desejos"
                    : "Conteúdo já está na lista de desejos"
            };

        } catch (err) {

            // Caso o erro já seja um HttpsError, mantém seu tipo e sua mensagem original.
            if (err instanceof HttpsError) {
                throw err;
            }

            // Registra erros inesperados ocorridos durante a operação no MongoDB.
            logger.error(
                "Error from addToWishlist: Failed to add content",
                err
            );

            // Retorna um erro interno caso a operação não possa ser concluída.
            throw new HttpsError(
                "internal",
                "Falha ao adicionar conteúdo à lista de desejos"
            );
        }
    }
);