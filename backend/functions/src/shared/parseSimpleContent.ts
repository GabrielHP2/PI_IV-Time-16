// Autor: Gabriel Henrique Pacagnelli Pagliato

import { SimpleContentType } from "../api/types/simpleContentType";

export function parseSimpleContent(rawJson: any, resultsQuantity: number): SimpleContentType[] {

    let parsedContent: SimpleContentType[] = [];

    for (let i = 0; i < resultsQuantity; i++) {

        const {id, backdrop_path: banner_path, poster_path} = rawJson.results[i];

        if (!banner_path || !poster_path) continue;

        parsedContent.push({id, banner_path, poster_path});
    }

    return parsedContent;
}