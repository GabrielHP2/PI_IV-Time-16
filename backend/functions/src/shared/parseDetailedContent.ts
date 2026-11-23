// Autor: Gabriel Henrique Pacagnelli Pagliato

import { DetailedContentType } from "../api/types/detailedContentType";
import { PlatformType } from "../api/types/platformType";
import { SimpleContentType } from "../api/types/simpleContentType";
import { parsePlatforms } from "./parsePlatforms";
import { parseSimpleContent } from "./parseSimpleContent";

export function parseDetailedContent(rawJson: any): DetailedContentType {

    const {
        id, 
        title,
        name,
        overview: synopsis, 
        release_date, 
        vote_average: rating, 
        "watch/providers": watchProviders, 
        poster_path, 
        backdrop_path: banner_path
    } = rawJson;

    const similarTitles: SimpleContentType[] = parseSimpleContent(rawJson.recommendations, rawJson.recommendations.results.length);

    let genres: string[] = [];

    for (let i = 0; i < rawJson.genres.length; i++) {

        genres.push(rawJson.genres[i].name);
    }

    const platforms: PlatformType[] = parsePlatforms(watchProviders?.results?.BR?.flatrate);

    const parsedContent: DetailedContentType = {

        id: id,
        title: title ?? name,
        synopsis: synopsis,
        release_date: release_date,
        rating: rating,
        genre: genres,
        platform: platforms,
        similar: similarTitles,
        banner_path: banner_path,
        poster_path: poster_path,
    }

    return parsedContent;
}