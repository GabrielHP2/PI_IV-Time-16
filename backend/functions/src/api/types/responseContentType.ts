// Autor: Gabriel Henrique Pacagnelli Pagliato

import { SimpleContentType } from "./simpleContentType";

export interface ResponseContentType {

    page: number,
    total_pages: number,
    results: SimpleContentType[],
    category: "movie" | "tv"
}