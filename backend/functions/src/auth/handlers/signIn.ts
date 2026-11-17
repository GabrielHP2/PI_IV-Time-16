import { timingSafeEqual, scrypt } from "node:crypto";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import { getAuth } from "firebase-admin/auth";
import { serverConnection } from "./serverConnection";
import { OperationType } from "../types/operationType";
import { StatusType } from "../types/statusType";
import { getDatabase, mongoUri } from "../../shared/mongodb";

interface UserDocument {
    name: string;
    email: string;
    phoneNumber: string;
    passwordHash: string;
    createdAt: Date;
}

function verifyPassword(
    password: string,
    storedHash: string
): Promise<boolean> {

    const [algorithm, salt, hash] = storedHash.split("$");

    if (
        algorithm !== "scrypt" ||
        !/^[0-9a-f]{32}$/i.test(salt) ||
        !/^[0-9a-f]{128}$/i.test(hash)
    ) {
        return Promise.resolve(false);
    }

    return new Promise((resolve, reject) => {

        scrypt(password, salt, 64, (error, derivedKey) => {

            if (error) {
                reject(error);
                return;
            }

            const storedKey = Buffer.from(hash, "hex");

            resolve(
                storedKey.length === derivedKey.length &&
                timingSafeEqual(storedKey, derivedKey)
            );
        });
    });
}

export const signIn = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        const data = request.data ?? {};

        const userEmail =
            typeof data.email === "string"
                ? data.email.trim().toLowerCase()
                : "";

        const userPassword =
            typeof data.password === "string"
                ? data.password
                : "";

        if (!userEmail || !userPassword) {

            logger.error("Error from signIn: Fields missing");

            throw new HttpsError(
                "invalid-argument",
                "E-mail e senha são obrigatórios"
            );
        }

        try {

            const requestContent = {
                email: userEmail,
                password: userPassword
            };

            const serverResponse = await serverConnection(
                OperationType.LOGIN,
                requestContent
            );

            if (serverResponse.code === StatusType.BAD_REQUEST) {

                throw new HttpsError(
                    "invalid-argument",
                    serverResponse.message || "Dados de login inválidos"
                );
            }

            if (serverResponse.code !== StatusType.OK) {

                throw new HttpsError(
                    "internal",
                    "Falha ao validar os dados do login"
                );
            }

            const database = await getDatabase();

            const users = database.collection<UserDocument>("users");

            const user = await users.findOne({
                email: userEmail
            });

           if (!user) {
                logger.warn("SignIn diagnostic: User not found in MongoDB");

                throw new HttpsError(
                    "unauthenticated",
                    "E-mail ou senha incorretos"
                );
            }

            const passwordMatches = await verifyPassword(
                userPassword,
                user.passwordHash
            );

            logger.info("SignIn diagnostic: Password verification", {
                passwordMatches
            });

            if (!passwordMatches) {
                throw new HttpsError(
                    "unauthenticated",
                    "E-mail ou senha incorretos"
                );
            }
            const customToken = await getAuth().createCustomToken(
                user._id.toString()
            );

            logger.info("Info from signIn: User logged in successfully");

            return {
                code: StatusType.OK,
                message: "Login realizado com sucesso",
                token:customToken,
                user: {
                    id: user._id.toString(),
                    name: user.name,
                    email: user.email,
                    phoneNumber: user.phoneNumber
                }
            };

        } catch (err) {

            if (err instanceof HttpsError) {
                throw err;
            }

            logger.error(
                "Error from signIn: Failed to process login",
                err
            );

            throw new HttpsError(
                "internal",
                "Falha ao processar requisição de login"
            );
        }
    }
);