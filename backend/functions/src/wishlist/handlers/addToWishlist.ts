import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getDatabase, mongoUri } from "../../shared/mongodb";

type ContentCategory = "movie" | "tv";

interface WishlistDocument {
    userId: string;
    contentId: number;
    category: ContentCategory;
    createdAt: Date;
    banner_path: string;
    poster_path: string;
}

export const addToWishlist = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        if (!request.auth) {

            logger.error("Error from addToWishlist: User not authenticated");

            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado"
            );
        }

        const data = request.data ?? {};

        const contentId = data.id;
        const category = data.category;

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

        if (category !== "movie" && category !== "tv") {

            throw new HttpsError(
                "invalid-argument",
                "Categoria do conteúdo inválida"
            );
        }
        const bannerPath = data.banner_path;
        const posterPath = data.poster_path;

        if (
            typeof bannerPath !== "string" ||
            !bannerPath.trim() ||
            typeof posterPath !== "string" ||
            !posterPath.trim()
        ) {

            throw new HttpsError(
                "invalid-argument",
                "Caminhos das imagens são obrigatórios"
            );
        }

        const userId = request.auth.uid;

        try {

            const database = await getDatabase();

            const wishlist = database.collection<WishlistDocument>(
                "wishlists"
            );

            const result = await wishlist.updateOne(
                {
                    userId,
                    contentId,
                    category
                },
                {
                    $set: {
                        banner_path: bannerPath.trim(),
                        poster_path: posterPath.trim()
                    },
                    $setOnInsert: {
                        userId,
                        contentId,
                        category,
                        createdAt: new Date()
                    }
                },
                {
                    upsert: true
                }
            );
            

            const added = result.upsertedCount === 1;

            logger.info(
                added
                    ? "Info from addToWishlist: Content added"
                    : "Info from addToWishlist: Content already exists"
            );

            return {
                code: 200,
                added,
                message: added
                    ? "Conteúdo adicionado à lista de desejos"
                    : "Conteúdo já está na lista de desejos"
            };

        } catch (err) {

            if (err instanceof HttpsError) {
                throw err;
            }

            logger.error(
                "Error from addToWishlist: Failed to add content",
                err
            );

            throw new HttpsError(
                "internal",
                "Falha ao adicionar conteúdo à lista de desejos"
            );
        }
    }
);