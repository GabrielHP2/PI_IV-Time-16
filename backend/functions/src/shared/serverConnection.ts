import * as net from "net";
import * as logger from "firebase-functions/logger";
import { sendRequest } from "./sendRequest";
import { getResponse } from "./getResponse";

const HOST: string = "localhost";
const PORT: number = 8080;

export async function serverConnection(operationType: string, requestContent: {}): Promise<{code: number, message: string}> {

    const connection = new net.Socket();
    connection.setTimeout(10000);
    
    let userAddress: string;

    return new Promise((resolve, reject) => {

        connection.connect(PORT, HOST, () => {
            
            console.log("Trying to connect to the server...");
        });

        connection.on('connect', () => {
            
            userAddress = connection.localAddress ?? "UNKNOWN";

            logger.info(`Info from serverConnection: User ${userAddress} connected to the server successfully`);
            console.log(`User ${userAddress} connected to the server successfully`);

            connection.setKeepAlive(true);
            
            try {

                sendRequest(connection, operationType, requestContent);

            } catch (err) {

                logger.error(`Error from serverConnection: Failed to prepare request content - ${err}`);
                console.error(`Failed to prepare request content: ${err}`);
                
                reject(err);
                connection.destroy();
            }
        });

        connection.on('jsonReady', (data: string) => {

            connection._write(data, "utf8", () => {

                logger.info(`Info from serverConnection: User ${userAddress} sent a request`);
                console.log(`User ${userAddress} sent a request`);
            });
        });

        connection.on('data', (data: Buffer) => {
            
            logger.info(`Info from serverConnection: User ${userAddress} received response from server`);
            console.log(`User ${userAddress} received response from server`);
            
            try {

                resolve(getResponse(data));

                connection.destroy();

            } catch (err) {

                logger.error(`Error from serverConnection: Failed to manage response - ${err}`);
                console.error(`Failed to manage response: ${err}`);

                reject(err);
                connection.destroy();
            }
        });
    
        connection.on('timeout', () => {

            logger.info(`Info from serverConnection: User ${userAddress} connection timed out`);
            console.log(`User ${userAddress} connection timed out`)

            reject(new Error("Connection timed out"));
            connection.destroy();
        });

        connection.on('end', () => {

            logger.info("Info from serverConnection: Server connection ended");
            console.log("Server connection ended...");

            connection.destroy();
        });

        connection.on('error', (err) => {

            logger.error(`Error from serverConnection: Something went wrong - ${err}`);
            console.error(`Something went wrong: ${err}`);

            reject(err);
            connection.destroy();
        });
        
        connection.on('close', () => {

            logger.info(`Info from serverConnection: User ${userAddress} disconnected from the server`);
            console.log(`User ${userAddress} disconnected from the server`);
        });
    });
}