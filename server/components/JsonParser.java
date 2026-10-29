package components;

import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JsonParser {

    public static HashMap<String, String> parse(String json) throws OperationMissingException {

        HashMap<String, String> operationHash = new HashMap<String, String>(1);
        
        // Fazer o REGEX
        Pattern operationRegex = Pattern.compile("");
        Matcher matcher = operationRegex.matcher(json);
        
        HashMap<String, String> formattedBody = null;

        // Testar se o regex vai deixar a chave como 'operation'
        switch (operationHash.get("operation")) {

            case "login" -> {

                formattedBody = JsonParser.parseLogin(json);
                break;
            }

            case "register" -> {

                formattedBody = JsonParser.parseRegister(json);
                break;
            }
            
            default -> {

                throw new OperationMissingException("Couldn't find the operation inside the JSON");
                break;
            }
        }

        formattedBody.put("operation", operationHash.get("operation"));

        return formattedBody;
    }

    // TODO
    private static HashMap<String, String> parseLogin(String json) {

        HashMap<String, String> formattedBody = new HashMap<String, String>(4);

        // Fazer o REGEX
        Pattern loginRegex = Pattern.compile("");
        Matcher matcher = loginRegex.matcher(json);


        return formattedBody;
    }

    private static HashMap<String, String> parseRegister(String json) {
        
        HashMap<String, String> formattedBody = new HashMap<String, String>(5);

        // Fazer o REGEX
        Pattern registerRegex = Pattern.compile("");
        Matcher matcher = registerRegex.matcher(json);
        

        return formattedBody;
    }
    
    private static HashMap<String, String> parseResetPassword(String json) {
        
        // TODO: alterar o tamanho do hashmap
        HashMap<String, String> formattedBody = new HashMap<String, String>(2);

        // Fazer o REGEX
        Pattern resetPassowordRegex = Pattern.compile("");
        Matcher matcher = resetPassowordRegex.matcher(json);
        
    
        return formattedBody;
    }
}