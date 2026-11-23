
import { randomBytes, scrypt } from "node:crypto";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

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

function hashPassword(password: string): Promise<string> {

    const salt = randomBytes(16).toString("hex");

    return new Promise((resolve, reject) => {

        scrypt(password, salt, 64, (error, derivedKey) => {

            if (error) {
                reject(error);
                return;
            }

            resolve(`scrypt$${salt}$${derivedKey.toString("hex")}`);
        });
    });
}

function isDuplicateKeyError(error: unknown): boolean {

    return (
        typeof error === "object" &&
        error !== null &&
        "code" in error &&
        error.code === 11000
    );
}

export const signUp = onCall(
    { secrets: [mongoUri] },
    async (request) => {

        const data = request.data ?? {};

        const userName =
            typeof data.name === "string" ? data.name.trim() : "";

        const userEmail =
            typeof data.email === "string"
                ? data.email.trim().toLowerCase()
                : "";

        const userPassword =
            typeof data.password === "string" ? data.password : "";

        const userPhoneNumber =
            typeof data.phoneNumber === "string"
                ? data.phoneNumber.trim()
                : "";

        if (!userName || !userEmail || !userPassword || !userPhoneNumber) {

            logger.error("Error from signUp: Fields missing");

            throw new HttpsError(
                "invalid-argument",
                "Todos os campos são obrigatórios"
            );
        }

        try {

            const requestContent = {
                name: userName,
                email: userEmail,
                password: userPassword,
                phoneNumber: userPhoneNumber
            };

            const serverResponse = await serverConnection(
                OperationType.REGISTER,
                requestContent
            );

            if (serverResponse.code === StatusType.BAD_REQUEST) {

                throw new HttpsError(
                    "invalid-argument",
                    serverResponse.message || "Dados de cadastro inválidos"
                );
            }

            if (serverResponse.code !== StatusType.OK) {

                logger.error(
                    "Error from signUp: Java server validation failed"
                );

                throw new HttpsError(
                    "internal",
                    "Falha ao validar os dados do cadastro"
                );
            }

            const database = await getDatabase();

            const users = database.collection<UserDocument>("users");

            await users.createIndex(
                { email: 1 },
                { unique: true }
            );

            const existingUser = await users.findOne({
                email: userEmail
            });

            if (existingUser) {

                throw new HttpsError(
                    "already-exists",
                    "Este e-mail já está cadastrado"
                );
            }

            const passwordHash = await hashPassword(userPassword);

            const result = await users.insertOne({

                name: userName,
                email: userEmail,
                phoneNumber: userPhoneNumber,
                passwordHash: passwordHash,
                createdAt: new Date()
            });

            logger.info("Info from signUp: User registered successfully");

            return {
                code: StatusType.OK,
                message: "Cadastro realizado com sucesso",
                user: {
                    id: result.insertedId.toString(),
                    name: userName,
                    email: userEmail,
                    phoneNumber: userPhoneNumber
                }
            };

        } catch (err) {

            if (err instanceof HttpsError) {
                throw err;
            }

            if (isDuplicateKeyError(err)) {

                throw new HttpsError(
                    "already-exists",
                    "Este e-mail já está cadastrado"
                );
            }

            logger.error(
                "Error from signUp: Failed to process registration",
                err
            );

            throw new HttpsError(
                "internal",
                "Falha ao processar requisição de cadastro"
            );
        }
    }
);
