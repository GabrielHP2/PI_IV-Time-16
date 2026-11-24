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
// O segredo mongoUri é utilizado para estabelecer a conexão com o MongoDB.
export const getWishlist = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        // Verifica se existe um usuário autenticado na requisição.
        // Somente usuários autenticados podem consultar sua lista de desejos.
        if (!request.auth) {

            // Registra no log uma tentativa de acesso sem autenticação.
            logger.error("Error from getWishlist: User not authenticated");

            // Interrompe a execução e retorna um erro de autenticação.
            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado"
            );
        }

        // Obtém o UID do usuário autenticado pelo Firebase.
        // Esse identificador permite buscar somente os conteúdos pertencentes a ele.
        const userId = request.auth.uid;

        try {

            // Estabelece a conexão com o banco de dados MongoDB.
            const database = await getDatabase();

            // Seleciona a coleção "wishlists" e define o tipo dos documentos armazenados.
            const wishlist = database.collection<WishlistDocument>(
                "wishlists"
            );

            // Busca todos os documentos da lista de desejos pertencentes ao usuário autenticado.
            // O método sort organiza os resultados pela data de criação, do mais recente para o mais antigo.
            // O método toArray transforma os resultados da consulta em um array.
            const contents = await wishlist
                .find({ userId })
                .sort({ createdAt: -1 })
                .toArray();

            // Registra no log que a consulta foi realizada com sucesso.
            // Também informa a quantidade de conteúdos encontrados.
            logger.info("Info from getWishlist: Wishlist retrieved", {
                quantity: contents.length
            });

            // Retorna os dados encontrados para o aplicativo.
            // O map percorre os documentos e seleciona apenas os campos necessários.
            // A data de criação é convertida para o formato ISO antes de ser enviada.
            return {
                code: 200,
                wishlist: contents.map((content) => ({
                    contentId: content.contentId,
                    category: content.category,
                    createdAt: content.createdAt.toISOString()
                }))
            };

        } catch (err) {

            // Registra no log qualquer erro inesperado ocorrido durante a consulta.
            logger.error(
                "Error from getWishlist: Failed to retrieve wishlist",
                err
            );

            // Retorna um erro interno caso não seja possível buscar a lista de desejos.
            throw new HttpsError(
                "internal",
                "Falha ao buscar lista de desejos"
            );
        }
    }
);