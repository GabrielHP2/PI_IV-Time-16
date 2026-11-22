// Autor: Gabriel Henrique Pacagnelli Pagliato

import { onCall, HttpsError } from "firebase-functions/https";
import { API_TOKEN } from "../../shared/apiConfig";
import { mongoUri } from "../../shared/mongodb";
import * as logger from "firebase-functions/logger";
import { ALLOWED_PROVIDERS } from "../../api/types/allowedProviders";
import { getAvailablePlatforms } from "./getAvailablePlatforms";
import { getPlatformsPrice } from "../repositories/getPlatformsPrice";
import { PlatformPriceType } from "../types/platformPriceType";
import { selectedContentType } from "../types/selectedContentType";
import { PlanType } from "../types/planType";
import { subscriptionPlanner } from "./subscriptionPlanner";

export const setSubscriptionPlan = onCall({secrets: [API_TOKEN, mongoUri]}, async (request) => {

    // Decodifica o token do usuário e verifica se ele tem um id válido
    if (!request.auth) {
    
        logger.error("Error from setSubscriptionPlan: User unauthenticated");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    const { platforms, currentContent, desiredContent, currentExpense, desiredExpense } = request.data ?? {};

    if (!platforms || !currentContent || !desiredContent || !currentExpense || !desiredExpense) {
    
        logger.error("Error from setSubscriptionPlan: Fields are missing");
        throw new HttpsError("invalid-argument", "Informações ausentes");
    }
    
    if (currentExpense < 0) {

        logger.error("Error from setSubscriptionPlan: Invalid current expense");
        throw new HttpsError("invalid-argument", "Gasto atual inválido");
    }
    
    if (desiredExpense <= 0) {
    
        logger.error("Error from setSubscriptionPlan: Invalid desired expense");
        throw new HttpsError("invalid-argument", "Gasto desejado inválido");
    }
    
    const rawSubbedPlatforms: number[] = platforms as any[];
    
    // Garante que nenhum ID inválido foi passado filtrando por IDs presentes no Set
    const supportedPlatforms: number[] = rawSubbedPlatforms.filter((platform) => ALLOWED_PROVIDERS.has(platform));

    if (supportedPlatforms.length === 0) {
    
        logger.error("Error from setSubscriptionPlan: Platforms are missing");
        throw new HttpsError("invalid-argument", "Plataformas que assina ausente");
    }
    
    
    // Faz um cast dos conteúdos pra a interface 'selectedContentType'
    const currentContentList = currentContent as selectedContentType[];
    const desiredContentList = desiredContent as selectedContentType[];
    
    // Faz um fetch para obter as plataformas em que cada conteúdo está disponível
    const currentPlatforms = await getAvailablePlatforms(currentContentList);

    // Faz um fetch pra cada conteúdo, separando individualmente no 
    // array as plataformas que o conteúdo esta disponível
    const desiredPlatforms: number[][] = await Promise.all(
        desiredContentList.map(async (content) => {

            const platforms = await getAvailablePlatforms([content]);
            return Array.from(platforms.keys());
        }
    ));

    // Pega o preço das planos de assinatura das plataformas suportadas no BD
    const platformsPrice: PlatformPriceType[] = await getPlatformsPrice();

    // Gera o planejamento de assinatura
    const subscriptionPlan: PlanType = subscriptionPlanner(
        currentPlatforms, desiredPlatforms, 
        platformsPrice, supportedPlatforms, 
        currentExpense, desiredExpense
    );

    logger.info("Info from setSubscriptionPlan: OK");

    return subscriptionPlan;
});