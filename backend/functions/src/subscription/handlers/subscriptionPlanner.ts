// Autor: Gabriel Henrique Pacagnelli Pagliato

import { HttpsError } from "firebase-functions/https";
import { CombinationType } from "../types/combinationType";
import { MonthType } from "../types/monthType";
import { PlatformPriceType } from "../types/platformPriceType";
import { PlanType } from "../types/planType";
import * as logger from "firebase-functions/logger";

/* 
    Monta um plano de assinatura para os próximos oito meses usando os conteúdos atuais e desejados,
    as plataformas disponíveis, os preços e as assinaturas que o usuário já tem
    
    Primeiro cria todas as combinações possíveis de plataformas e, em cada mês,
    escolhe a combinação que cobre mais conteúdos atuais e desejados, usando preço e assinaturas existentes para desempatar

    Depois marca os conteúdos desejados atendidos para não contá-los de novo nos meses seguintes
    No fim, retorna as plataformas escolhidas e o gasto de cada mês, indicando se o valor passa do orçamento desejado
*/

export function subscriptionPlanner(
    currentPlat: Map<number, number>,
    desiredPlatforms: number[][],
    platformsPrice: PlatformPriceType[],
    platformsId: number[],
    currentEx: number,
    desiredEx: number): PlanType {

    // Cria um array para marcar os conteúdos desejados que já foram cobertos
    const coveredDesiredContents: boolean[] = [];
    
    // Deixa cada conteúdo como pendente antes de começar a montar os meses
    for (let i = 0; i < desiredPlatforms.length; i++) {

        coveredDesiredContents.push(false);
    }

    const months: MonthType[] = [];

    // Gera todas as combinações possíveis de plataformas
    const combinations: PlatformPriceType[][] = [[]];

    // A cada iteração, inclui uma plataforma nova nas combinações que já foram criadas
    for (const platform of platformsPrice) {

        // Salva o tamanho atual para percorrer só as combinações que já existiam
        const combinationsQuantity = combinations.length;

        // Cria uma cópia de cada combinação anterior e adiciona a plataforma atual
        for (let i = 0; i < combinationsQuantity; i++) {

            const newCombination = combinations[i].slice();
            newCombination.push(platform);
            combinations.push(newCombination);
        }
    }

    // Escolhe as plataformas de cada mês do planejamento
    for (let monthNumber = 1; monthNumber <= 8; monthNumber++) {

        let bestCombination: CombinationType | null = null;

        // Compara todas as combinações possíveis para encontrar a melhor opção deste mês
        for (const selectedPlatforms of combinations) {

            // Ignora combinações sem plataformas
            if (selectedPlatforms.length === 0) continue;

            let monthlyExpense = 0;
            let currentCoverage = 0;
            let desiredCoverage = 0;
            let subscribedCoverage = 0;

            // Calcula o preço e a cobertura atual da combinação
            for (const platform of selectedPlatforms) {

                monthlyExpense += platform.price;
                currentCoverage += currentPlat.get(platform.tmdbId) ?? 0;

                if (platformsId.includes(platform.tmdbId)) {

                    subscribedCoverage++;
                }
            }

            // Conta quantos conteúdos desejados ainda não cobertos 
            // estão disponíveis nas plataformas selecionadas
            for (let i = 0; i < desiredPlatforms.length; i++) {

                if (coveredDesiredContents[i]) continue;

                const contentPlatformIds = desiredPlatforms[i];

                for (const selectedPlatform of selectedPlatforms) {

                    if (contentPlatformIds.includes(selectedPlatform.tmdbId)) {

                        desiredCoverage++;
                        break;
                    }
                }
            }

            // Junta as plataformas e os valores calculados para facilitar a comparação
            const combination: CombinationType = {
                platformIds: selectedPlatforms.map((platform) => platform.tmdbId),
                platformNames: selectedPlatforms.map((platform) => platform.name),
                monthlyExpense: monthlyExpense,
                currentCoverage: currentCoverage,
                desiredCoverage: desiredCoverage,
                subscribedCoverage: subscribedCoverage
            };

            // A primeira opção vira a referência para comparar as próximas
            if (bestCombination === null) {

                bestCombination = combination;
                continue;
            }

            // Compara as combinações priorizando cobertura atual, conteúdos desejados,
            // menor preço, plataformas já assinadas e menor quantidade de plataformas
            if (combination.currentCoverage > bestCombination.currentCoverage ||
                (combination.currentCoverage === bestCombination.currentCoverage &&

                combination.desiredCoverage > bestCombination.desiredCoverage) ||
                (combination.currentCoverage === bestCombination.currentCoverage &&

                combination.desiredCoverage === bestCombination.desiredCoverage &&
                combination.monthlyExpense < bestCombination.monthlyExpense) ||

                (combination.currentCoverage === bestCombination.currentCoverage &&
                combination.desiredCoverage === bestCombination.desiredCoverage &&

                combination.monthlyExpense === bestCombination.monthlyExpense &&
                (combination.subscribedCoverage > bestCombination.subscribedCoverage ||

                (combination.subscribedCoverage === bestCombination.subscribedCoverage &&
                combination.platformIds.length < bestCombination.platformIds.length)))) {

                bestCombination = combination;
            }
        }

        // Lança um erro caso nenhuma combinação possa ser selecionada
        if (bestCombination === null) {

            logger.error("Error from subscriptionPlanner: Platforms ares missing");
            throw new HttpsError("failed-precondition", "Não há plataformas cadastradas");
        }

        let desiredCoverageInMonth = 0;

        // Marca os conteúdos atendidos neste mês para não contá-los novamente
        for (let i = 0; i < desiredPlatforms.length; i++) {

            if (coveredDesiredContents[i]) continue;

            const contentPlatformIds = desiredPlatforms[i];

            for (const platformId of bestCombination.platformIds) {

                if (contentPlatformIds.includes(platformId)) {

                    coveredDesiredContents[i] = true;
                    desiredCoverageInMonth++;
                    break;
                }
            }
        }

        // Adiciona o resultado do mês e verifica se o gasto está dentro do limite
        months.push({
            month: monthNumber,
            platformIds: bestCombination.platformIds,
            platformNames: bestCombination.platformNames,
            monthlyExpense: bestCombination.monthlyExpense,
            currentCoverage: bestCombination.currentCoverage,
            desiredCoverage: desiredCoverageInMonth,
            status:
                bestCombination.monthlyExpense <= desiredEx
                    ? "ok"
                    : "budget_exceeded"
        });
    }

    const result = {
        // Define o status geral com base no status do primeiro mês
        status:
            months[0].status === "ok"
                ? "ok"
                : "budget_exceeded",
        months: months,
        currentMonthlyExpense: currentEx,
        desiredMonthlyExpense: desiredEx,
        subscribedPlatformIds: platformsId
    };

    logger.info("Info from setSubscriptionPlan: Subscription plan generated");

    return result;
}