import { Socket } from "net";

export function sendRequest(connection: Socket, operationType: string, requestContent: {}): void {

    if (!connection) throw new Error("Connection is missing");
    if (!operationType) throw new Error("Operation type is missing");
    if (!requestContent) throw new Error("Request content is missing");

    const json = {...requestContent, operation: `${operationType}`};

    connection.emit('jsonReady', (JSON.stringify(json) + "\n"));
}