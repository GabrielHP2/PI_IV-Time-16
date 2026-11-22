import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getDatabase, mongoUri } from "../../shared/mongodb";

type ContentCategory = "movie" | "tv";

interface WishlistDocument {
    userId: string;
    contentId: number;
    category: ContentCategory;
    createdAt: Date;
}

export const getWishlist = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        if (!request.auth) {

            logger.error("Error from getWishlist: User not authenticated");

            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado"
            );
        }

        const userId = request.auth.uid;

        try {

            const database = await getDatabase();

            const wishlist = database.collection<WishlistDocument>(
                "wishlists"
            );

            const contents = await wishlist
                .find({ userId })
                .sort({ createdAt: -1 })
                .toArray();

            logger.info("Info from getWishlist: Wishlist retrieved", {
                quantity: contents.length
            });

            return {
                code: 200,
                wishlist: contents.map((content) => ({
                    contentId: content.contentId,
                    category: content.category,
                    createdAt: content.createdAt.toISOString()
                }))
            };

        } catch (err) {

            logger.error(
                "Error from getWishlist: Failed to retrieve wishlist",
                err
            );

            throw new HttpsError(
                "internal",
                "Falha ao buscar lista de desejos"
            );
        }
    }
);