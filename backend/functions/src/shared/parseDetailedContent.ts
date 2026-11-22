// Autor: Gabriel Henrique Pacagnelli Pagliato

import { DetailedContentType } from "../api/types/detailedContentType";
import { PlatformType } from "../api/types/platformType";
import { SimpleContentType } from "../api/types/simpleContentType";
import { parsePlatforms } from "./parsePlatforms";
import { parseSimpleContent } from "./parseSimpleContent";

// Converte os detalhes recebidos do TMDB para o formato usado pela API
export function parseDetailedContent(rawJson: any): DetailedContentType {

    // Desestrutura os campos necessários do resultado
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

    // Pega o id, banner e poster dos conteúdos similares
    const similarTitles: SimpleContentType[] = parseSimpleContent(rawJson.recommendations, rawJson.recommendations.results.length);

    let genres: string[] = [];

    // Percorre todos os gêneros do conteúdo e guarda apenas o nome de cada um
    for (let i = 0; i < rawJson.genres.length; i++) {

        genres.push(rawJson.genres[i].name);
    }

    // Pega os provedores disponíveis no Brasil e filtra os que o app permite exibir
    const platforms: PlatformType[] = parsePlatforms(watchProviders?.results?.BR?.flatrate);

    // Junta todos os dados
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