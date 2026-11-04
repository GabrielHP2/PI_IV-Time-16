package components;

public class JsonBuilder {

    public static String buildJson(short code, String content) {

        String formattedJson = "{\"code\": "+ code +", \"message\": \"" + content + "\"}";

        return formattedJson;
    }
}
