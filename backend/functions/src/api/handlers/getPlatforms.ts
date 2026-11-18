import { HttpsError, onCall } from "firebase-functions/https";
import { API_TOKEN, BASE_URL, LANGUAGE, REGION } from "../../shared/apiConfig";
import * as logger from "firebase-functions/logger";
import { parsePlatforms } from "../../shared/parsePlatforms";
import { PlatformType } from "../types/platformType";

export const getPlatforms = onCall({secrets: [API_TOKEN]}, async (request) => {
    
    if (!request.auth) {

        logger.error("Error from getPlatforms: User unauthenticated");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    
    const url = `${BASE_URL}/watch/providers/movie?language=${LANGUAGE}&watch_region=${REGION}`;

    const options = {

        method: "GET",
        headers: {
            accept: "application/json",
            Authorization: `Bearer ${API_TOKEN.value()}`
        }
    }

    const rawPlatformsInfo = await fetch(url, options)
    .then((res) => {

        if (!res.ok) {

            logger.error("Error from getPlatforms: Failed to get platforms info");
            throw new HttpsError("internal", "Falha ao buscar plataformas");
        }

        return res.json();

    })
    .catch((err) => {

        logger.error(`Error from getPlatforms: Something went wrong while fetching for the platforms - ${err}`);
        throw new HttpsError("internal", "Algo deu errado ao buscar pelas plataformas");
    });

    logger.info("Info from getPlatforms: Platforms infos fetched");

    const parsedPlatforms: PlatformType[] = parsePlatforms(rawPlatformsInfo.results);

    logger.info("Info from getPlatforms: OK");

    return parsedPlatforms;
});