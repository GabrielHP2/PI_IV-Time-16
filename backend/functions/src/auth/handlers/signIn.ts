import { HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { OperationType } from "../types/operationType";
import { serverConnection } from "../../shared/serverConnection";

export const signIn = onCall(async (request) => {
    
    const {email: userEmail, password: userPassword} = request.data ?? {};

    if (!userEmail || !userPassword) {

        logger.error("Error from signIn: Fields missing");
        throw new HttpsError("invalid-argument", "Todos os campos são obrigatórios");
    }

    const requestContent = {email: userEmail, password: userPassword};

    try {
        
        const serverResponse = await serverConnection(OperationType.LOGIN, requestContent);

        if (!serverResponse) {

            logger.error("Error from signIn: Failed to obtain response from server");
            throw new HttpsError("internal", "Falha ao obter resposta do servidor");
        }

        // ...

    } catch (err) {

        logger.error(`Error from signIn: ${err}`);
        throw new HttpsError("internal", "Falha ao processar requisição de login");
    }
});