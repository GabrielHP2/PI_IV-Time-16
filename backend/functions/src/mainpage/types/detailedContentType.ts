export interface DetailedContentType {

    id: number,
    title: string,
    synopsis: string | null,
    release_date: string,
    rating: number,
    genre: string[],
    platforms: string[],
    banner_url: string | null,
    poster_url: string | null
}   