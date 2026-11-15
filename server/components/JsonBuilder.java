// Autor: Gabriel Henrique Pacagnelli Pagliato

package components;

import models.ResponseStatus;

public class JsonBuilder {

    public static String buildJson(ResponseStatus code, String content) {

        String formattedJson = "{\"code\": "+ code.getCode() +", \"message\": \"" + content + "\"}";

        return formattedJson;
    }
}