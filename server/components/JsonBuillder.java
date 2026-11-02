package components;

public class JsonBuillder {

    public static String buildJson(String content) {

        String formattedJson = "{\"message\": \"" + content + "\"}";

        return formattedJson;
    }
}
