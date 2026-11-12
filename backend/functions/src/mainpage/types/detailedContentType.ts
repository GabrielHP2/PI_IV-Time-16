// Autor: Gabriel Henrique Pacagnelli Pagliato

export interface DetailedContentType {

    id: number,
    title: string,
    synopsis?: string,
    release_date?: string,
    rating: number,
    genre: string[],
    platforms: string[],
    banner_path?: string,
    poster_path?: string
}   