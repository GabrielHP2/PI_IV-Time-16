// Autor: Gabriel Henrique Pacagnelli Pagliato

import { HttpsError, onCall } from "firebase-functions/https";
import { API_TOKEN, BASE_URL, LANGUAGE, REGION } from "../../shared/apiConfig";
import * as logger from "firebase-functions/logger";
import { parseSimpleContent } from "../../shared/parseSimpleContent";
import { ResponseContentType } from "../types/responseContentType";

export const getLaunchingContent = onCall({secrets: [API_TOKEN]}, async (request) => {

    if (request.auth) {

        logger.error("Error from getPopularContent: User unauthenticated");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    const { page: pageNumber = 1 } = request.data ?? {};
    
    if (!Number.isInteger(pageNumber) || pageNumber < 1) {
    
        logger.error("Error from getRandomContent: Invalid page number");
        throw new HttpsError("invalid-argument", "Página inválida");
    }
    
    const url = `${BASE_URL}/movie/now_playing?language=${LANGUAGE}&page=${pageNumber}&region=${REGION}`;

    const options = {

        method: "GET",
        headers: {
            accept: "application/json",
            Authorization: `Bearer ${API_TOKEN.value()}`
        }
    };

    const rawMoviesJson = await fetch(url, options)
    .then((res) => {

        if (!res.ok) {

            logger.error(`Error from getLaunchingContent: Failed to get movies in theatres - ${res.statusText}`);
            throw new HttpsError("internal", "Falha ao buscar lançamentos");
        }

        return res.json();
    })
    .catch((err) => {

        logger.error(`Error from getLaunchingContent: Something went wrong while fetching for movies in theatres - ${err}`);
        throw new HttpsError("unknown", "Algo deu errado ao buscar por lançamentos");
    });

    logger.info("Info from getLaunchingContent: Launching content fetched");


    const response: ResponseContentType = {

        page: pageNumber,
        total_pages: rawMoviesJson.total_pages,
        results: parseSimpleContent(rawMoviesJson, rawMoviesJson.results.length),
        category: "movie"
    };

    logger.info("Info from getLaunchingContent: OK");

    return response;
});