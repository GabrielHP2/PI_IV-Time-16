import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getDatabase, mongoUri } from "../../shared/mongodb";

export const removeFromWishlist = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        if (!request.auth) {

            logger.error("Error from removeFromWishlist: User not authenticated");

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

        const userId = request.auth.uid;

        try {

            const database = await getDatabase();

            const wishlist = database.collection("wishlists");

            const result = await wishlist.deleteOne({
                userId,
                contentId,
                category
            });

            const removed = result.deletedCount === 1;

            logger.info("Info from removeFromWishlist: Removal processed", {
                removed
            });

            return {
                code: 200,
                removed,
                message: removed
                    ? "Conteúdo removido da lista de desejos"
                    : "Conteúdo não encontrado na lista de desejos"
            };

        } catch (err) {

            logger.error(
                "Error from removeFromWishlist: Failed to remove content",
                err
            );

            throw new HttpsError(
                "internal",
                "Falha ao remover conteúdo da lista de desejos"
            );
        }
    }
);