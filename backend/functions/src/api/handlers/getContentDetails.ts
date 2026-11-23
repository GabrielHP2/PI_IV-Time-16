// Autor: Gabriel Henrique Pacagnelli Pagliato

import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { BASE_URL, API_TOKEN, LANGUAGE } from "../../shared/apiConfig";
import { parseDetailedContent } from "../../shared/parseDetailedContent";

export const getContentDetails = onCall({secrets: [API_TOKEN]}, async (request) => {

    // Decodifica o token do usuário e verifica se ele está autenticado
    if (!request.auth) {

        logger.error("Error from getContentDetails: User not authenticated");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    const { id: contentId, category } = request.data ?? {};
 
    if (!contentId || !category) {

        logger.error("Error from getContentDetails: Content ID or category is missing");
        throw new HttpsError("invalid-argument", "Falha ao identificar conteúdo");
    }
    
    if (!Number.isInteger(contentId) || contentId < 1) {
        
        logger.error("Error from getContentDetails: Invalid content ID");
        throw new HttpsError("invalid-argument", "Falha ao identificar conteúdo");
    }

    let contentCategory: string = category;

    if (contentCategory !== "movie" && contentCategory !== "tv") {

        logger.error("Error from getContentDetails: Invalid content category");
        throw new HttpsError("invalid-argument", "Falha ao identificar conteúdo");
    }
    
    let url: string;

    // Define as opções de requisição, incluindo o token de autenticação
    const options = {

        method: "GET",
        headers: {
            accept: "application/json",
            Authorization: `Bearer ${API_TOKEN.value()}`
        }
    };

    let parsedDetails;

    // Usa uma rota diferente no TMDB conforme o tipo de conteúdo
    switch(contentCategory) {

        // Busca detalhes do filme, recomendações e provedores de streaming
        case "movie":
            
            url = `${BASE_URL}/movie/${contentId}?append_to_response=recommendations%2Cwatch%2Fproviders&language=${LANGUAGE}`;

            const rawMovieDetails = await fetch(url, options)
            .then((res) => {

                if (!res.ok) {

                    logger.error("Error from getContentDetails: Failed to get movie details");
                    throw new HttpsError("internal", "Falha ao buscar detalhes do conteúdo");
                }

                return res.json();
            })
            .catch((err) => {

                logger.error(`Error from getContentDetails: Failed to get movie details - ${err}`);
                throw new HttpsError("unknown", "Algo deu errado ao buscar detalhes do conteúdo");
            });

            logger.info("Info from getContentDetails: Movie details fetched");

            // Converte os dados pegando apenas os campos necessários
            parsedDetails = parseDetailedContent(rawMovieDetails); 

        break;


        // Busca os mesmos dados pela rota de séries
        case "tv":

            url = `${BASE_URL}/tv/${contentId}?append_to_response=recommendations%2Cwatch%2Fproviders&language=${LANGUAGE}`;    
            
            const rawSeriesDetails = await fetch(url, options)
            .then((res) => {

                if (!res.ok) {

                    logger.error("Error from getContentDetails: Failed to get series details");
                    throw new HttpsError("internal", "Falha ao buscar detalhes do conteúdo");
                }

                return res.json();

            })
            .catch((err) => {

                logger.error(`Error from getContentDetails: Failed to get series details - ${err}`);
                throw new HttpsError("unknown", "Algo deu errado ao buscar detalhes do conteúdo");
            });

            logger.info("Info from getContentDetails: Series details fetched");

            // Converte os dados pegando apenas os campos necessários
            parsedDetails = parseDetailedContent(rawSeriesDetails);

        break;
    }

    logger.info("Info from getContentDetails: OK");
    
    return parsedDetails;
});