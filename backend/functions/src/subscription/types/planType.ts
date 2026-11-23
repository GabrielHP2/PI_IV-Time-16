// Autor: Gabriel Henrique Pacagnelli Pagliato

import { MonthType } from "./monthType";

export interface PlanType {

    status: string;
    months: MonthType[];
    currentMonthlyExpense: number;
    desiredMonthlyExpense: number;
    subscribedPlatformIds: number[];
}