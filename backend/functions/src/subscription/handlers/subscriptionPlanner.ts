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
    currentPlatforms: number[][],
    currentCategories: ("movie" | "tv")[],
    desiredPlatforms: number[][],
    platformsPrice: PlatformPriceType[],
    platformsId: number[],
    currentEx: number,
    desiredEx: number): PlanType {

    const budgetTolerance = 0.20;
    const adjustedBudget =
        desiredEx + (desiredEx * budgetTolerance);

    // Cria um array para marcar os conteúdos desejados que já foram cobertos
    const coveredDesiredContents: boolean[] = [];
    
    // Deixa cada conteúdo como pendente antes de começar a montar os meses
    for (let i = 0; i < desiredPlatforms.length; i++) {

        coveredDesiredContents.push(false);
    }

    // Filmes em andamento podem sair da próxima combinação depois de serem cobertos
    // Séries em andamento são consideradas necessárias por três meses no planejamento
    const coveredCurrentMovies: boolean[] = [];

    for (let i = 0; i < currentPlatforms.length; i++) {

        coveredCurrentMovies.push(false);
    }

    let repeatedPlatforms: number[] = [];

    // Define três meses de duração para cada série em andamento
    const remainingTvMonths: number[] = [];

    for (let i = 0; i < currentPlatforms.length; i++) {

        if (currentCategories[i] === "tv") remainingTvMonths.push(3);

        else remainingTvMonths.push(0);
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

        const repeatMonth = repeatedPlatforms.length > 0;
        let bestCombination: CombinationType | null = null;

        // Compara todas as combinações possíveis para encontrar a melhor opção deste mês
        for (const selectedPlatforms of combinations) {

            // Ignora combinações sem plataformas
            if (selectedPlatforms.length === 0) continue;

            if (repeatedPlatforms.length > 0) {

                if (selectedPlatforms.length !== repeatedPlatforms.length) continue;

                let hasEveryRepeatedPlatform = true;

                for (const platformId of repeatedPlatforms) {

                    let platformWasSelected = false;

                    for (const selectedPlatform of selectedPlatforms) {

                        if (selectedPlatform.tmdbId === platformId) {

                            platformWasSelected = true;
                            break;
                        }
                    }

                    if (!platformWasSelected) {

                        hasEveryRepeatedPlatform = false;
                        break;
                    }
                }

                if (!hasEveryRepeatedPlatform) continue;
            }

            let monthlyExpense = 0;
            let currentCoverage = 0;
            let desiredCoverage = 0;
            let subscribedCoverage = 0;

            // Calcula o preço da combinação
            for (const platform of selectedPlatforms) {

                monthlyExpense += platform.price;

                if (platformsId.includes(platform.tmdbId)) subscribedCoverage++;
            }

            // Conta filmes pendentes e séries em andamento cobertos pela combinação
            for (let i = 0; i < currentPlatforms.length; i++) {

                if (currentCategories[i] === "movie" && coveredCurrentMovies[i]) continue;

                if (currentCategories[i] === "tv" && remainingTvMonths[i] <= 0) continue;

                const contentPlatformIds = currentPlatforms[i];

                for (const selectedPlatform of selectedPlatforms) {

                    if (contentPlatformIds.includes(selectedPlatform.tmdbId)) {

                        currentCoverage++;
                        break;
                    }
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

            // Não recomenda uma plataforma que não cobre nenhum conteúdo
            // atual ou desejado ainda pendente
            if (currentCoverage === 0 && desiredCoverage === 0) continue;

            // Junta as plataformas e os valores calculados para facilitar a comparação
            const combination: CombinationType = {

                platformIds: selectedPlatforms.map((platform) => platform.tmdbId),
                platformNames: selectedPlatforms.map((platform) => platform.name),
                monthlyExpense: monthlyExpense,
                currentCoverage: currentCoverage,
                desiredCoverage: desiredCoverage,
                subscribedCoverage: subscribedCoverage
            };

            const combinationIsInsideBudget = combination.monthlyExpense <= adjustedBudget;

            const bestCombinationIsInsideBudget =
                bestCombination !== null &&
                bestCombination.monthlyExpense <= adjustedBudget;

            if (bestCombination === null) bestCombination = combination;

            else if (combinationIsInsideBudget && !bestCombinationIsInsideBudget) {

                bestCombination = combination;
            }

            else if (combinationIsInsideBudget === bestCombinationIsInsideBudget) {

                // Compara as combinações dentro do mesmo grupo:
                // cobertura atual, conteúdos desejados, menor preço,
                // plataformas já assinadas e menor quantidade de plataformas
                if (
                    combination.currentCoverage >
                        bestCombination.currentCoverage ||
                    (
                        combination.currentCoverage ===
                            bestCombination.currentCoverage &&
                        combination.desiredCoverage >
                            bestCombination.desiredCoverage
                    ) ||
                    (
                        combination.currentCoverage ===
                            bestCombination.currentCoverage &&
                        combination.desiredCoverage ===
                            bestCombination.desiredCoverage &&
                        combination.monthlyExpense <
                            bestCombination.monthlyExpense
                    ) ||
                    (
                        combination.currentCoverage ===
                            bestCombination.currentCoverage &&
                        combination.desiredCoverage ===
                            bestCombination.desiredCoverage &&
                        combination.monthlyExpense ===
                            bestCombination.monthlyExpense &&
                        (
                            combination.subscribedCoverage >
                                bestCombination.subscribedCoverage ||
                            (
                                combination.subscribedCoverage ===
                                    bestCombination.subscribedCoverage &&
                                combination.platformIds.length <
                                    bestCombination.platformIds.length
                            )
                        )
                    )
                ) {

                    bestCombination = combination;
                }
            }
        }

        // Fallback para escolher uma combinação quando a seleção normal não encontra opção
        // O placeholder ignora o tempo restante das séries, a repetição de plataformas e o limite de gasto
        if (bestCombination === null) {

            let placeholder: CombinationType | null = null;

            for (const selectedPlatforms of combinations) {

                if (selectedPlatforms.length === 0) continue;

                let monthlyExpense = 0;
                let currentCoverage = 0;
                let desiredCoverage = 0;
                let subscribedCoverage = 0;

                for (const platform of selectedPlatforms) {

                    monthlyExpense += platform.price;

                    if (platformsId.includes(platform.tmdbId)) subscribedCoverage++;
                }

                // Conteúdos atuais pendentes são usados para o placeholder
                for (let i = 0; i < currentPlatforms.length; i++) {

                    if (currentCategories[i] === "movie" && coveredCurrentMovies[i]) continue;

                    const contentPlatformIds = currentPlatforms[i];

                    for (const selectedPlatform of selectedPlatforms) {

                        if (contentPlatformIds.includes(selectedPlatform.tmdbId)) {

                            currentCoverage++;
                            break;
                        }
                    }
                }

                // Conteúdos desejados pendentes são usados para o placeholder
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

                const combination: CombinationType = {

                    platformIds: selectedPlatforms.map((platform) => platform.tmdbId),
                    platformNames: selectedPlatforms.map((platform) => platform.name),
                    monthlyExpense: monthlyExpense,
                    currentCoverage: currentCoverage,
                    desiredCoverage: desiredCoverage,
                    subscribedCoverage: subscribedCoverage
                };

                if (placeholder === null) placeholder = combination;
                
                else if (
                    combination.currentCoverage >
                        placeholder.currentCoverage ||
                    (
                        combination.currentCoverage ===
                            placeholder.currentCoverage &&
                        combination.desiredCoverage >
                            placeholder.desiredCoverage
                    ) ||
                    (
                        combination.currentCoverage ===
                            placeholder.currentCoverage &&
                        combination.desiredCoverage ===
                            placeholder.desiredCoverage &&
                        combination.monthlyExpense <
                            placeholder.monthlyExpense
                    ) ||
                    (
                        combination.currentCoverage ===
                            placeholder.currentCoverage &&
                        combination.desiredCoverage ===
                            placeholder.desiredCoverage &&
                        combination.monthlyExpense ===
                            placeholder.monthlyExpense &&
                        (
                            combination.subscribedCoverage >
                                placeholder.subscribedCoverage ||
                            (
                                combination.subscribedCoverage ===
                                    placeholder.subscribedCoverage &&
                                combination.platformIds.length <
                                    placeholder.platformIds.length
                            )
                        )
                    )
                ) {

                    placeholder = combination;
                }
            }

            if (placeholder === null) {

                logger.error("Error from subscriptionPlanner: Platforms are missing");
                throw new HttpsError("failed-precondition", "Não há plataformas cadastradas");
            }

            bestCombination = placeholder;
        }

        if (repeatMonth) repeatedPlatforms = [];

        // Marca filmes cobertos neste mês como atendidos
        // Séries continuam contando enquanto houver meses restantes
        for (let i = 0; i < currentPlatforms.length; i++) {

            if (currentCategories[i] !== "movie" || coveredCurrentMovies[i]) continue;

            const contentPlatformIds = currentPlatforms[i];

            for (const platformId of bestCombination.platformIds) {

                if (contentPlatformIds.includes(platformId)) {

                    coveredCurrentMovies[i] = true;
                    break;
                }
            }
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

        // Se houver pelo menos quatro conteúdos cobertos no mês,
        // mantém todas as plataformas da combinação por mais um mês
        if (!repeatMonth && bestCombination.currentCoverage + desiredCoverageInMonth >= 4) {

            repeatedPlatforms = bestCombination.platformIds.slice();
        }

        // Reduz o tempo restante das séries depois de cada mês
        for (let i = 0; i < remainingTvMonths.length; i++) {

            if (currentCategories[i] === "tv" && remainingTvMonths[i] > 0) {

                remainingTvMonths[i] = remainingTvMonths[i] - 1;
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
                bestCombination.monthlyExpense <= adjustedBudget
                    ? "ok"
                    : "budget_exceeded"
        });
    }

    let planStatus = "ok";

    for (const month of months) {

        if (month.status === "budget_exceeded") planStatus = "budget_exceeded";
    }

    const result = {
        
        status: planStatus,
        months: months,
        currentMonthlyExpense: currentEx,
        desiredMonthlyExpense: desiredEx,
        subscribedPlatformIds: platformsId
    };

    logger.info("Info from setSubscriptionPlan: Subscription plan generated");
    
    return result;
}