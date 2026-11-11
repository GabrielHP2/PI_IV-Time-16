import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { BASE_URL, BASE_IMG_URL, API_TOKEN, LANGUAGE, REGION } from "../../shared/apiConfig";

export const getSpecificContent = onCall(async (request) => {

    const { contentName } = request.data ?? {};

    if (!contentName) {

        logger.error("Error from getRandomContent: Content name is missing");
        throw new HttpsError("invalid-argument", "Nome do conteúdo ausente");
    }
    
    const moviesUrl = `${BASE_URL}/search/movies?${contentName}&include_adult=false&language=${LANGUAGE}&region=${REGION}`;
    const seriesURL = `${BASE_URL}/search/tv?query=${contentName}&include_adult=false&language=${LANGUAGE}`;

    const options = {

        method: "GET",
        headers: {
            accept: "application/json",
            Authorization: `Bearer ${API_TOKEN}`
        }
    }


    const moviesRes = await fetch(moviesUrl, options)
    .then(res => res.json())
    .catch((err) => {

        logger.error(`Error from getRandomContent: Failed to get movies content - ${err}`);
    });
    
    const seriesRes = await fetch(seriesURL, options)
    .then(res => res.json())
    .catch((err) => {
        
        logger.error(`Error from getRandomContent: Failed to get series content - ${err}`);
    });
 
    if (!moviesRes && !seriesRes) {

        logger.error("Error from getRandomContent: Failed to fetch content");
        throw new HttpsError("internal", "Falha ao buscar conteúdos");
    }

    // WIP
    // const response = mixJsons(moviesRes, seriesRes);
});