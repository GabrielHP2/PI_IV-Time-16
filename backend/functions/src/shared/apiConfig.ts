// Autor: Gabriel Henrique Pacagnelli Pagliato

import { defineSecret } from "firebase-functions/params";

// Essa URL usa as funções v3 do TMDB, caso queira/precise
// usar as v4, é necessário alterar o '3' por '4'
export const BASE_URL = "https://api.themoviedb.org/3/";
export const BASE_IMG_URL = "https://image.tmdb.org/t/p/";
export const API_TOKEN = defineSecret("API_TOKEN");

export const LANGUAGE = "pt-BR";
export const REGION = "BR";