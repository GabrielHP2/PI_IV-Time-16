// Autor: Gabriel Henrique Pacagnelli Pagliato

export interface MonthType {

    month: number,
    platformIds: number[],
    platformNames: string[],
    monthlyExpense: number,
    currentCoverage: number,
    desiredCoverage: number,
    status: "ok" | "budget_exceeded"
}