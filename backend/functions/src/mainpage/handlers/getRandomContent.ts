import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { BASE_URL, BASE_IMG_URL, API_TOKEN, LANGUAGE, REGION } from "../../shared/apiConfig";

export const getRandomContent = onCall(async (request) => {

    
    const moviesUrl = `${BASE_URL}discover/movie?include_adult=false&include_video=false&language=${LANGUAGE}&page=1&region=${REGION}&sort_by=popularity.desc&watch_region=${REGION}&with_watch_monetization_types=flatrate%7Cfree%7Cads`;
    const seriesURL = `${BASE_URL}discover/tv?include_adult=false&include_null_first_air_dates=false&language=${LANGUAGE}&page=1&sort_by=popularity.desc&watch_region=${REGION}&with_watch_monetization_types=flatrate%7Cfree%7Cads`;
    
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