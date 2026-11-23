// Autor: Gabriel Henrique Pacagnelli Pagliato

export function getResponse(responseContent: Buffer): {code: number, message: string} {

    if (!responseContent) throw new Error("Response content is missing");

    const responseText = responseContent.toString("utf-8");
    const convertedResponse = JSON.parse(responseText);

    const { code, message } = convertedResponse;

    return { code, message };
}