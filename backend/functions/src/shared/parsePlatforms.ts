// Autor: Gabriel Henrique Pacagnelli Pagliato

import { ALLOWED_PROVIDERS } from "../api/types/allowedProviders";
import { PlatformType } from "../api/types/platformType";

// Converte os provedores do TMDB para o formato de plataforma usado pela API
export function parsePlatforms(rawJson: any[]): PlatformType[] {

    // Caso não haja provedores, um array vazio é retornado
    if (!rawJson || rawJson.length === 0) return [];

    // Filtra apenas por provedores permitidos e atribui os campos de cada plataforma
    const platforms: PlatformType[] = rawJson
    .filter((provider) => ALLOWED_PROVIDERS.has(provider.provider_id))
    .map(({provider_id, provider_name, logo_path}) => ({

        platform_id: provider_id,
        name: provider_name,
        logo_path: logo_path
    }));

    return platforms;
}