// Autor: Gabriel Henrique Pacagnelli Pagliato

import { PlatformType } from "./platformType"
import { SimpleContentType } from "./simpleContentType"

export interface DetailedContentType {

    id: number,
    title: string,
    synopsis?: string,
    release_date?: string,
    rating: number,
    genre: string[],
    platform?: PlatformType[],
    similar: SimpleContentType[],
    banner_path: string,
    poster_path: string
}   