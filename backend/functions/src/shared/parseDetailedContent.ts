// Autor: Gabriel Henrique Pacagnelli Pagliato

import { ALLOWED_PROVIDERS } from "../mainpage/types/allowedProviders";
import { DetailedContentType } from "../mainpage/types/detailedContentType";
import { PlatformType } from "../mainpage/types/platformType";
import { SimpleContentType } from "../mainpage/types/simpleContentType";
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


    const localPlatforms: any[] = watchProviders?.results?.BR?.flatrate ?? [];

    const platforms: PlatformType[] = localPlatforms
    .filter((provider) => ALLOWED_PROVIDERS.has(provider.provider_id))
    .map(({provider_id, provider_name, logo_path}) => ({

        platform_id: provider_id,
        name: provider_name,
        logo_path: logo_path
    }));

    
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