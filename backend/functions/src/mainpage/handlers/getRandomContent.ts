// Autor: Gabriel Henrique Pacagnelli Pagliato

import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { BASE_URL, API_TOKEN, LANGUAGE, REGION } from "../../shared/apiConfig";
import { parseSimpleContent } from "../../shared/parseSimpleContent";
import { ResponseContentType } from "../types/responseContentType";

export const getRandomContent = onCall(async (request) => {

    if (!request.auth) {
    
        logger.error("Error from getRandomContent: User not authenticated");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }
    
    const { page: pageNumber = 1 } = request.data ?? {};

    if (!Number.isInteger(pageNumber) || pageNumber < 1) {
    
        logger.error("Error from getRandomContent: Invalid page number");
        throw new HttpsError("invalid-argument", "Página inválida");
    }

    const moviesUrl = `${BASE_URL}discover/movie?include_adult=false&include_video=false&language=${LANGUAGE}&page=${pageNumber}&region=${REGION}&sort_by=popularity.desc&watch_region=${REGION}&with_watch_monetization_types=flatrate`;
    const seriesURL = `${BASE_URL}discover/tv?include_adult=false&include_null_first_air_dates=false&language=${LANGUAGE}&page=${pageNumber}&sort_by=popularity.desc&watch_region=${REGION}&with_watch_monetization_types=flatrate`;
    
    const options = {

        method: "GET",
        headers: {
            accept: "application/json",
            Authorization: `Bearer ${API_TOKEN}`
        }
    };

    const rawMoviesJson = await fetch(moviesUrl, options)
    .then((res) => {

        if (!res.ok) {

            logger.error(`Error from getRandomContent: Failed to get movies content - ${res.statusText}`);
            throw new HttpsError("internal", "Falha ao buscar filmes");
        }

        return res.json();
    })
    .catch((err) => {

        logger.error(`Error from getRandomContent: Failed to get movies content - ${err}`);
        throw new HttpsError("unknown", "Algo deu errado ao buscar por filmes");
    });
    
    logger.info("Info from getRandomContent: Movies content fetched");
    

    const rawSeriesJson = await fetch(seriesURL, options)
    .then((res) => {

        if (!res.ok) {

            logger.error(`Error from getRandomContent: Failed to get series content - ${res.statusText}`);
            throw new HttpsError("internal", "Falha ao buscar séries");
        }

        return res.json();
    })
    .catch((err) => {
        
        logger.error(`Error from getRandomContent: Failed to get series content - ${err}`);
        throw new HttpsError("unknown", "Algo deu errado ao buscar por séries");
    });

    logger.info("Info from getRandomContent: Series content fetched");

    const parsedMovies: ResponseContentType = {
        page: rawMoviesJson.page, 
        total_pages: rawMoviesJson.total_pages, 
        results: parseSimpleContent(rawMoviesJson, rawMoviesJson.results.length), 
        category: "movie"
    };

    const parsedSeries: ResponseContentType = {

        page: rawSeriesJson.page,
        total_pages: rawSeriesJson.total_pages,
        results: parseSimpleContent(rawSeriesJson, rawSeriesJson.results.length),
        category: "tv"
    };

    const response: ResponseContentType[] = [parsedMovies, parsedSeries];

    logger.info("Info from getRandomContent: OK");

    return response;
});