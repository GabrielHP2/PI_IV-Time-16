// Autor: Gabriel Henrique Pacagnelli Pagliato

import { HttpsError } from "firebase-functions/https";
import { API_TOKEN, BASE_URL } from "../../shared/apiConfig";
import { ALLOWED_PROVIDERS } from "../../api/types/allowedProviders";
import * as logger from "firebase-functions/logger";
import { selectedContentType } from "../types/selectedContentType";

export async function getAvailablePlatforms(contentList: selectedContentType[]): Promise<Map<number, number>> {

    const options = {

        method: "GET",
        headers: {

            accept: "application/json",
            Authorization: `Bearer ${API_TOKEN.value()}`
        }
    }

    // Faz uma busca pra obter as plataformas de cada conteúdo dentro da lista
    const request = contentList.map(async (content) => {

        const url = `${BASE_URL}/${content.category}/${content.id}/watch/providers`;
       
        return await fetch(url, options)
        .then((res) => {

            if (!res.ok) {

                logger.error("Error from getAvailablePlatforms: Failed to fetch a content's platforms");
                throw new HttpsError("internal", "Falha ao buscar pelas plataformas de um certo conteúdo");
            }

            return res.json();
        })
        .catch((err) => {

            if (err instanceof HttpsError) throw err;

            logger.error(`Error from getAvailablePlatforms: Something went wrong while fetching for a content's platform - ${err}`);
            throw new HttpsError("internal", "Algo deu errado ao buscar as plataformas de um certo conteúdo");
        });
    });
    
    // Aguarda todas as requisições terminarem
    const rawJson = await Promise.all(request) as any[];

    // Acessa o JSON de cada requisição e separa somente o ID das plataformas presentes em 'ALLOWED_PROVIDERS'
    const rawIds: number[] = rawJson.flatMap((item) => {

        const brProviders = item.results?.BR?.flatrate ?? [];

        return brProviders
        .filter((provider: any) => ALLOWED_PROVIDERS.has(provider.provider_id))
        .map((provider: any) => provider.provider_id);
    });


    let formattedIds: Map<number, number> = new Map<number, number>();

    // Cria um Map com o ID de cada plataforma e com a quantidade de vezes que ele se repete
    rawIds.forEach((id) => {

        if (!formattedIds.has(id)) formattedIds.set(id, 1);

        else {

            const qtd = formattedIds.get(id);

            formattedIds.set(id, (qtd! + 1));
        }
    });

    return formattedIds;
}