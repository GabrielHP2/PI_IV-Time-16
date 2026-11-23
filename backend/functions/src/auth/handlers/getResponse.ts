// Autor: Gabriel Henrique Pacagnelli Pagliato

// Converte a resposta recebida do servidor em um objeto com código e mensagem
export function getResponse(responseContent: Buffer): {code: number, message: string} {

    if (!responseContent) throw new Error("Response content is missing");

    // Lê o buffer como texto e transforma o JSON recebido em objeto
    const responseText = responseContent.toString("utf-8");
    const convertedResponse = JSON.parse(responseText);

    // Separa os campos usados pelos handlers
    const { code, message } = convertedResponse;

    return { code, message };
}
