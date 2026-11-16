// Autor: Gabriel Henrique Pacagnelli Pagliato

import * as net from "net";
import * as logger from "firebase-functions/logger";
import { sendRequest } from "./sendRequest";
import { getResponse } from "./getResponse";
import { OperationType } from "../types/operationType";
import { StatusType } from "../types/statusType";

const HOST: string = "localhost";
const PORT: number = 8080;

export async function serverConnection(operationType: OperationType, requestContent: {}): Promise<{code: number, message: string}> {

    const connection = new net.Socket();
    connection.setTimeout(10000);
    
    let userAddress: string = "UNKNOWN";

    return new Promise((resolve, reject) => {

        connection.connect(PORT, HOST, () => {
            
            logger.info("Info from serverConnection: A user is trying to connect to the server");
        });

        connection.on('connect', () => {
            
            userAddress = connection.localAddress ?? "UNKNOWN";

            logger.info(`Info from serverConnection: User ${userAddress} connected to the server successfully`);

            connection.setKeepAlive(true);
            
            try {

                sendRequest(connection, operationType, requestContent);

            } catch (err) {

                logger.error(`Error from serverConnection: Failed to prepare request content - ${err}`);
                
                reject(err);
                connection.emit("stop");
            }
        });

        connection.on('jsonReady', (data: string) => {

            connection.write(data, "utf8", () => {

                logger.info(`Info from serverConnection: User ${userAddress} sent a request`);
            });
        });

        connection.on('data', (data: Buffer) => {
            
            logger.info(`Info from serverConnection: User ${userAddress} received a response from the server`);
            
            try {

                const res = getResponse(data);

                if (res.code === StatusType.ACCEPTED) logger.info(`Info from serverConnection: Server accepted User ${userAddress} close request`);

                else {

                    resolve(res);
                    connection.emit("stop");
                }

            } catch (err) {

                logger.error(`Error from serverConnection: Failed to manage response - ${err}`);

                reject(err);

                connection.emit("stop");
            }
        });

        connection.on('stop', () => {

            const data = {operation: OperationType.CLOSE};

            connection.end(JSON.stringify(data) + "\n", "utf-8", () => {

                logger.info(`Info from serverConnection: User ${userAddress} is trying to cease connection`);
            });
        });
    
        connection.on('timeout', () => {

            logger.info(`Info from serverConnection: User ${userAddress} connection timed out`);

            reject(new Error("Connection timed out"));
            connection.destroy();
        });

        connection.on('error', (err) => {

            logger.error(`Error from serverConnection: Something went wrong - ${err}`);

            reject(err);
            connection.destroy();
        });
        
        connection.on('close', () => {

            logger.info(`Info from serverConnection: User ${userAddress} disconnected from the server`);
        });
    });
}