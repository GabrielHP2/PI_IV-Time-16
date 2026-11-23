// Autor: Gabriel Henrique Pacagnelli Pagliato

import * as net from "net";
import * as logger from "firebase-functions/logger";
import { sendRequest } from "./sendRequest";
import { getResponse } from "./getResponse";
import { OperationType } from "../types/operationType";
import { StatusType } from "../types/statusType";

const HOST: string = "localhost";
const PORT: number = 8080;

// Abre uma conexão TCP, envia a operação e espera a resposta do servidor
export async function serverConnection(operationType: OperationType, requestContent: {}): Promise<{code: number, message: string}> {

    // Cria o socket e define um limite de espera por resposta
    const connection = new net.Socket();
    connection.setTimeout(10000);
    
    let userAddress: string = "UNKNOWN";

    return new Promise((resolve, reject) => {

        // Tenta conectar com servidor
        connection.connect(PORT, HOST, () => {
            
            logger.info("Info from serverConnection: A user is trying to connect to the server");
        });

        // Quando conecta, registra o endereço do usuário e envia os dados da operação
        connection.on('connect', () => {
            
            userAddress = connection.localAddress ?? "UNKNOWN";

            logger.info(`Info from serverConnection: User ${userAddress} connected to the server successfully`);

            // Faz com que a conexão permaneça ativa, mesmo que não haja dados sendo enviados
            connection.setKeepAlive(true);
            
            try {

                sendRequest(connection, operationType, requestContent);

            } catch (err) {

                logger.error(`Error from serverConnection: Failed to prepare request content - ${err}`);
                
                reject(err);
                connection.emit("stop");
            }
        });

        // Envia a mensagem para o servidor quando o evento 'jsonReady' é emitido
        connection.on('jsonReady', (data: string) => {

            connection.write(data, "utf8", () => {

                logger.info(`Info from serverConnection: User ${userAddress} sent a request`);
            });
        });

        // Recebe a responsa do servidor, interpreta e resolve a promise com o resultado
        connection.on('data', (data: Buffer) => {
            
            logger.info(`Info from serverConnection: User ${userAddress} received a response from the server`);
            
            try {

                // Interpreta a resposta do servidor
                const res = getResponse(data);

                // Se a resposta for ACCEPTED, quer dizer que o servidor aceitou o pedido de encerramento da conexão
                if (res.code === StatusType.ACCEPTED) logger.info(`Info from serverConnection: Server accepted User ${userAddress} close request`);

                else {

                    // Se a resposta for diferente de ACCEPTED, o resultado da operação é retornado para o usuário
                    resolve(res);
                    connection.emit("stop");
                }

            } catch (err) {

                logger.error(`Error from serverConnection: Failed to manage response - ${err}`);

                reject(err);

                connection.emit("stop");
            }
        });

        // Envia a operação CLOSE ao servidor quando o evento 'stop' é emitido
        connection.on('stop', () => {

            // Monta o json que será enviado ao servidor para encerrar a conexão
            const data = {operation: OperationType.CLOSE};

            connection.end(JSON.stringify(data) + "\n", "utf-8", () => {

                logger.info(`Info from serverConnection: User ${userAddress} is trying to cease connection`);
            });
        });
    
        // Encerra a conexão se o servidor não responder dentro do prazo
        connection.on('timeout', () => {

            logger.info(`Info from serverConnection: User ${userAddress} connection timed out`);

            reject(new Error("Connection timed out"));
            connection.destroy();
        });

        // Rejeita a promessa e fecha o socket quando ocorre um erro de conexão
        connection.on('error', (err) => {

            logger.error(`Error from serverConnection: Something went wrong - ${err}`);

            reject(err);
            connection.destroy();
        });
        
        // Registra quando o socket foi fechado
        connection.on('close', () => {

            logger.info(`Info from serverConnection: User ${userAddress} disconnected from the server`);
        });
    });
}
