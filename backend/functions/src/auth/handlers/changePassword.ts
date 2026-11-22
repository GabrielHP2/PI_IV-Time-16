// Autor: Gabriel Henrique Pacagnelli Pagliato

import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { serverConnection } from "./serverConnection";
import { OperationType } from "../types/operationType";
import { StatusType } from "../types/statusType";
import { getAuth } from "firebase-admin/auth";

// Troca a senha depois que o servidor valida os dados e o Firebase encontra a conta
export const changePassword = onCall(async (request) => {

    const { uid, password, confirmPassword } = request.data ?? {}
    
    if (!uid) {

        logger.error("Error from changePassword: Failed to identify the user");
        throw new HttpsError("internal", "Falha ao identificar o usuÃ¡rio");
    }

    if (!password || !confirmPassword) {

        logger.error("Error from changePassword: Fields missing");
        throw new HttpsError("invalid-argument", "Todos os campos sÃ£o obrigatÃ³rios");
    }

    // Monta os dados que serão enviados ao servidor de autenticação
    const requestContent = {password: password, confirmPassword};

    try {

        // Pede ao servidor que valide a senha nova e a confirmação
        const serverResponse = await serverConnection(OperationType.CHANGE, requestContent);

        if (!serverResponse) {

            logger.error("Error from changePassword: Failed to obtain response from server");
            throw new HttpsError("internal", "Falha ao obter resposta do servidor");
        }


        if (serverResponse.code === StatusType.BAD_REQUEST) {

            logger.error(`Error from changePassword: Invalid password or confirm password- ${serverResponse.message}`);
            throw new HttpsError("invalid-argument", "Senha ou confirmar senha invÃ¡lido");
        }

        if (serverResponse.code === StatusType.METHOD_NOT_ALLOWED || serverResponse.code === StatusType.INTERNAL_SERVER_ERROR) {

            throw new Error(serverResponse.message);
        }

    } catch (err) {

        if (err instanceof HttpsError) throw err;

        logger.error(`Error from changePassword: Something went wrong - ${err}`);
        throw new HttpsError("internal", "Falha ao processar requisiÃ§Ã£o de troca de senha");
    }


    try {

        // Com a senha validada, atualiza a conta no Firebase Auth
        await getAuth().updateUser(uid, {password: password, emailVerified: true})
        .then(() => {

            logger.info(`Info from changePassword: User's ${uid} password changed successfully`);
        })
        .catch((err) => {

            logger.error(`Error from changePassword: Failed to change User's ${uid} - ${err}`);
            throw new HttpsError("internal", "Falha ao tentar redefinir a senha");
        });

        logger.info("Info from changePassword: OK");

        return {code: 200, message: "Senha atualizada"};

    } catch (err) {

        if (err instanceof HttpsError) throw err;

        logger.error(`Error from changePassword: Something went wrong - ${err}`);
        throw new HttpsError("internal", "Falha ao processar requisiÃ§Ã£o de trocar a senha");
    }
});