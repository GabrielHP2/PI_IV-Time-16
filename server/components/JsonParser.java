package components;

import java.util.HashMap;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import utils.InvalidJsonContentException;
import utils.UnknownOperationException;

public class JsonParser {

    public static HashMap<String, String> parse(String json) throws InvalidJsonContentException, UnknownOperationException {

        Pattern operationRegex = Pattern.compile("\"(operation)\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = operationRegex.matcher(json);
        
        if (!matcher.find()) throw new InvalidJsonContentException("Couldn't find the operation inside the JSON");
        
        HashMap<String, String> formattedBody = null;

        switch (matcher.group(2)) {

            case "login" -> formattedBody = JsonParser.parseLogin(json);

            case "register" -> formattedBody = JsonParser.parseRegister(json);

            case "reset" -> formattedBody = JsonParser.parseResetPassword(json);

            case "change" -> formattedBody = JsonParser.parseChangePassword(json);

            case "ping", "close" -> formattedBody = new HashMap<String, String>(1);
            
            default -> throw new UnknownOperationException("Operation provided is not supported");
        }

        formattedBody.put(matcher.group(1), matcher.group(2));

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
    
    private static HashMap<String, String> parseResetPassword(String json) throws InvalidJsonContentException {
        
        HashMap<String, String> formattedBody = new HashMap<String, String>(2);

        Pattern resetPasswordRegex = Pattern.compile("\"email\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = resetPasswordRegex.matcher(json);
        
        if (matcher.find()) formattedBody.put("email", matcher.group(1));

        if (!formattedBody.containsKey("email")) throw new InvalidJsonContentException("Email field is missing");

        return formattedBody;
    }
    
    private static HashMap<String, String> parseChangePassword(String json) throws InvalidJsonContentException {
        
        HashMap<String, String> formattedBody = new HashMap<String, String>(3);
    
        Pattern changePasswordRegex = Pattern.compile("\"(password|confirmPassword)\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = changePasswordRegex.matcher(json);

        while (matcher.find()) formattedBody.put(matcher.group(1), matcher.group(2));

        if (!formattedBody.containsKey("password")) throw new InvalidJsonContentException("");
        if (!formattedBody.containsKey("confirmPassword")) throw new InvalidJsonContentException("");

        return formattedBody;
    }
}