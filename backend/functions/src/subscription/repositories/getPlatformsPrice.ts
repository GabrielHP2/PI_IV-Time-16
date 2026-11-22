// Autor: Gabriel Henrique Pacagnelli Pagliato

import { getDatabase } from "../../shared/mongodb";
import { PlatformPriceType } from "../types/platformPriceType";

export async function getPlatformsPrice() {

    const db = await getDatabase();

    // Cria uma referência a coleção 'platforms'
    const platformsCol = db.collection("platforms");

    // Busca por todas os documentos das plataformas, ignorando o ID gerado pelo Mongo
    const platformsDocs = await platformsCol.find({}, {projection: {_id: 0}}).toArray();

    // Pega os valores de cada documento e atribui ao array
    const formattedPlatformsPrice: PlatformPriceType[] = platformsDocs.map((fields) => ({

        tmdbId: fields.tmdbId,
        name: fields.name,
        price: fields.price
    }));

    return formattedPlatformsPrice;
}