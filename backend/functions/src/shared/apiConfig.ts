import * as dotenv from "dotenv";

dotenv.config({path: "../.env"});

// Essa URL usa as funções v3 do TMDB, caso queira/precise
// usar as v4, é necessário alterar o '3' por '4'
export const BASE_URL = "https://api.themoviedb.org/3/";
export const BASE_IMG_URL = "";
export const API_TOKEN = process.env.API_TOKEN;

export const LANGUAGE = "pt-BR";
export const REGION = "BR";