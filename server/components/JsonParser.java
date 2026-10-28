package components;

import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JsonParser {

    // TODO
    public static HashMap<String, String> parseLogin(String requestBody) {

        HashMap<String, String> formattedBody = new HashMap<String, String>(3);
        
        // Usar REGEX
        Pattern loginRegex = Pattern.compile("");
        Matcher matcher = loginRegex.matcher(requestBody);


        return formattedBody;
    }

    public static HashMap<String, String> parseRegister(String requestBody) {

        HashMap<String, String> formattedBody = new HashMap<String, String>(4);
 
        // Usar REGEX
        Pattern registerRegex = Pattern.compile("");
        Matcher matcher = registerRegex.matcher(requestBody);
        

        return formattedBody;
    }
    
    public static HashMap<String, String> parseResetPassword(String requestBody) {
        
        // TODO: alterar o tamanho do hashmap
        HashMap<String, String> formattedBody = new HashMap<String, String>(1);
    
        // Usar REGEX
        Pattern resetPassowordRegex = Pattern.compile("");
        Matcher matcher = resetPassowordRegex.matcher(requestBody);
        
    
        return formattedBody;
    }
}