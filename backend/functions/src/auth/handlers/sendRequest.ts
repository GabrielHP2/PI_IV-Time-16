// Autor: Gabriel Henrique Pacagnelli Pagliato

import { Socket } from "net";

// Prepara uma mensagem JSON com a operação e os dados para o servidor Java
export function sendRequest(connection: Socket, operationType: string, requestContent: {}): void {

    // Confere se a conexão e os dados mínimos foram informados
    if (!connection) throw new Error("Connection is missing");
    if (!operationType) throw new Error("Operation type is missing");
    if (!requestContent) throw new Error("Request content is missing");

    // Monta o json que vai ser enviado, adicionando o conteúdo da requisição e o tipo da operação
    const json = {...requestContent, operation: `${operationType}`};

    // Emite um sinal indicando que o json ja foi criado
    connection.emit('jsonReady', (JSON.stringify(json) + "\n"));
}
