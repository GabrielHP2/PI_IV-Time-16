// Autor: Gabriel Henrique Pacagnelli Pagliato

import { ALLOWED_PROVIDERS } from "../api/types/allowedProviders";
import { PlatformType } from "../api/types/platformType";

export function parsePlatforms(rawJson: any[]): PlatformType[] {

    if (!rawJson || rawJson.length === 0) return [];

    const platforms: PlatformType[] = rawJson
    .filter((provider) => ALLOWED_PROVIDERS.has(provider.provider_id))
    .map(({provider_id, provider_name, logo_path}) => ({

        platform_id: provider_id,
        name: provider_name,
        logo_path: logo_path
    }));

    return platforms;
}