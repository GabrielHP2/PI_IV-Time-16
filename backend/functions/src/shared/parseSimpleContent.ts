// Autor: Gabriel Henrique Pacagnelli Pagliato

import { SimpleContentType } from "../api/types/simpleContentType";

// Converte os resultados do TMDB para a versão resumida de um conteúdo
export function parseSimpleContent(rawJson: any, resultsQuantity: number): SimpleContentType[] {

    let parsedContent: SimpleContentType[] = [];

    // Percorre a quantidade de resultados solicitada
    for (let i = 0; i < resultsQuantity; i++) {

        // Desestrutura os campos necessários do resultado
        const {id, backdrop_path: banner_path, poster_path} = rawJson.results[i];

        // Só inclui conteúdos que tenham posters e banners
        if (!banner_path || !poster_path) continue;

        parsedContent.push({id, banner_path, poster_path});
    }

    return parsedContent;
}