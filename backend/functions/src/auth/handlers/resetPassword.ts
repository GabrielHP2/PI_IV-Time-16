// Autor: Gabriel Henrique Pacagnelli Pagliato

import { onCall, HttpsError } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { serverConnection } from "./serverConnection";
import { OperationType } from "../types/operationType";
import { StatusType } from "../types/statusType";
import { getAuth } from "firebase-admin/auth";

// Confere o e-mail com o servidor e procura a conta correspondente no Firebase Auth
export const resetPassword = onCall(async (request) => {

    const { email: userEmail } = request.data ?? {};

    if (!userEmail) {

        logger.error("Error from resetPassword: Email is missing");
        throw new HttpsError("invalid-argument", "Email ausente");
    }

    // Monta o dado que será enviado ao servidor
    const requestContent = {email: userEmail};

    try {   

        // Pede ao servidor que valide o e-mail para redefinição
        const serverResponse = await serverConnection(OperationType.RESET, requestContent);

        if (!serverResponse) {

            logger.error("Error from resetPassword: Failed to obtain response from server");
            throw new HttpsError("internal", "Falha ao obter resposta do servidor");
        }


        if (serverResponse.code === StatusType.BAD_REQUEST) {

            logger.error(`Error from resetPassword: Invalid email provided - ${serverResponse.message}`);
            throw new HttpsError("invalid-argument", "Email invÃ¡lido");
        }

        if (serverResponse.code === StatusType.METHOD_NOT_ALLOWED || serverResponse.code === StatusType.INTERNAL_SERVER_ERROR) {

            throw new Error(serverResponse.message);
        }

    } catch (err) {

        if (err instanceof HttpsError) throw err;

        logger.error(`Error from resetPassword: Something went wrong - ${err}`);
        throw new HttpsError("internal", "Falha ao processar requisiÃ§Ã£o de redefiniÃ§Ã£o");
    }


    try {

        // Depois da validação, procura no Firebase a conta ligada ao e-mail e retorna o uid
        const userId = await getAuth().getUserByEmail(userEmail)
        .then((res) => {

            logger.info(`Info from resetPassword: User ${res.uid} found`);

            return res.uid;
        })
        .catch((err) => {

            logger.error(`Error from resetPassword: Failed to find user - ${err}`);
            throw new HttpsError("invalid-argument", "Nenhuma conta encontrada com este email");
        });

        logger.info("Info from resetPassword: OK");
        
        return {code: 200, uid: userId};

    } catch (err) {

        if (err instanceof HttpsError) throw err;

        logger.error(`Error from resetPassword: Something went wrong - ${err}`);
        throw new HttpsError("internal", "Falha ao processar requisiÃ§Ã£o de redefiniÃ§Ã£o");
    }
});
