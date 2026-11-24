//Autor: Gabriel Batista Bastos

import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getDatabase, mongoUri } from "../../shared/mongodb";

// Cria uma Cloud Function que pode ser chamada diretamente pelo aplicativo.
// O segredo mongoUri é utilizado para estabelecer a conexão com o MongoDB.
export const removeFromWishlist = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        // Verifica se existe um usuário autenticado na requisição.
        // Somente usuários autenticados podem remover conteúdos da lista de desejos.
        if (!request.auth) {

            // Registra no log uma tentativa de acesso sem autenticação.
            logger.error("Error from removeFromWishlist: User not authenticated");

            // Interrompe a execução e retorna um erro de autenticação.
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

            // Retorna um erro indicando que o identificador do conteúdo é inválido.
            throw new HttpsError(
                "invalid-argument",
                "ID do conteúdo inválido"
            );
        }

        // Verifica se a categoria corresponde a um filme ("movie") ou série ("tv").
        // Qualquer outro valor é considerado inválido.
        if (category !== "movie" && category !== "tv") {

            // Retorna um erro indicando que a categoria informada não é permitida.
            throw new HttpsError(
                "invalid-argument",
                "Categoria do conteúdo inválida"
            );
        }

        // Obtém o UID do usuário autenticado pelo Firebase.
        // Esse identificador garante que a remoção seja feita na lista do usuário correto.
        const userId = request.auth.uid;

        try {

            // Estabelece a conexão com o banco de dados MongoDB.
            const database = await getDatabase();

            // Seleciona a coleção "wishlists", onde os conteúdos da lista de desejos são armazenados.
            const wishlist = database.collection("wishlists");

            // Procura e exclui um documento que corresponda simultaneamente:
            // ao usuário autenticado, ao ID do conteúdo e à sua categoria.
            const result = await wishlist.deleteOne({
                userId,
                contentId,
                category
            });

            // Verifica se exatamente um documento foi removido.
            // deletedCount informa a quantidade de documentos excluídos pelo MongoDB.
            const removed = result.deletedCount === 1;

            // Registra no log o resultado da tentativa de remoção.
            logger.info("Info from removeFromWishlist: Removal processed", {
                removed
            });

            // Retorna uma resposta informando se o conteúdo foi removido
            // ou se não foi encontrado na lista de desejos.
            return {
                code: 200,
                removed,
                message: removed
                    ? "Conteúdo removido da lista de desejos"
                    : "Conteúdo não encontrado na lista de desejos"
            };

        } catch (err) {

            // Registra no log qualquer erro inesperado ocorrido durante a remoção.
            logger.error(
                "Error from removeFromWishlist: Failed to remove content",
                err
            );

            // Retorna um erro interno caso não seja possível concluir a operação.
            throw new HttpsError(
                "internal",
                "Falha ao remover conteúdo da lista de desejos"
            );
        }
    }
);