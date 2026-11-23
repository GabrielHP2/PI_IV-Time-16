// Autor: Gabriel Henrique Pacagnelli Pagliato

package components;

import models.ResponseStatus;

public class JsonBuilder {

    public static String buildJson(ResponseStatus code, String content) {

        // Formata o JSON de acordo com o código e a mensagem recebidos
        String formattedJson = "{\"code\": "+ code.getCode() +", \"message\": \"" + content + "\"}";

        return formattedJson;
    }
}