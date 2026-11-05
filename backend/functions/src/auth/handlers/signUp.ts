import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { serverConnection } from "../../shared/serverConnection";
import { OperationType } from "../types/operationType";

export const signUp = onCall(async (request) => {

    const {name: userName, 
        email: userEmail, 
        password: userPassword, 
        phoneNumber: userPhoneNumber 
    } = request.data ?? {};

    if (!userName || !userEmail || !userPassword || !userPhoneNumber) {

        logger.error("Error from signUp: Fields missing");
        throw new HttpsError("invalid-argument", "Todos os campos são obrigatórios");
    }

    const requestContent = {name: userName, email: userEmail, password: userPassword, phoneNumber: userPhoneNumber};

    try {

        const serverResponse = await serverConnection(OperationType.REGISTER, requestContent);

        if (!serverResponse) {

            logger.error("Error from signUp: Failed to obtain response from server");
            throw new HttpsError("internal", "Falha ao obter resposta do servidor");
        }

        // ...

    } catch (err) {

        logger.error(`Error from signUp: ${err}`);
        throw new HttpsError("internal", "Falha ao processar requisição de cadastro");
    }
});