// Autores: Gabriel Henrique Pacagnelli Pagliato
//          Gabriel Batista Bastos

package components;

import java.util.HashMap;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import utils.InvalidJsonContentException;
import utils.UnknownOperationException;

public class JsonParser {

    public static HashMap<String, String> parse(String json) throws InvalidJsonContentException, UnknownOperationException {

        // Pega a operação do JSON recebido
        Pattern operationRegex = Pattern.compile("\"(operation)\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = operationRegex.matcher(json);
        
        if (!matcher.find()) throw new InvalidJsonContentException("Couldn't find the operation inside the JSON");
        
        HashMap<String, String> formattedBody = null;

        // Chama o método de parsing de acordo com o tipo de operação recebida
        switch (matcher.group(2)) {

            case "login" -> formattedBody = JsonParser.parseLogin(json);

            case "register" -> formattedBody = JsonParser.parseRegister(json);

            case "reset" -> formattedBody = JsonParser.parseResetPassword(json);

            case "change" -> formattedBody = JsonParser.parseChangePassword(json);

            case "ping", "close" -> formattedBody = new HashMap<String, String>(1);
            
            default -> throw new UnknownOperationException("Operation provided is not supported");
        }

        // Adiciona o tipo de operação no hashmap retornado
        formattedBody.put(matcher.group(1), matcher.group(2));

        return formattedBody;
    }

    private static HashMap<String, String> parseLogin(String json)
        throws InvalidJsonContentException {

        HashMap<String, String> formattedBody = new HashMap<>(3);

        // Pega os campos de login do JSON recebido
        Pattern loginRegex = Pattern.compile(
        "\"(email|password)\"\\s*:\\s*\"([^\"]*)\""
        );

        Matcher matcher = loginRegex.matcher(json);

        // Percorre o JSON recebido e adiciona os campos que batem com o regex
        while (matcher.find()) {
            formattedBody.put(matcher.group(1), matcher.group(2));
        }

        // Caso algum campo obrigatório não seja encontrado, lança uma exceção
        if (!formattedBody.containsKey("email"))
        throw new InvalidJsonContentException("Email field is missing");

        if (!formattedBody.containsKey("password"))
        throw new InvalidJsonContentException("Password field is missing");

        return formattedBody;
    }

    private static HashMap<String, String> parseRegister(String json)
        throws InvalidJsonContentException {

        HashMap<String, String> formattedBody = new HashMap<>(5);

        Pattern registerRegex = Pattern.compile(
            "\"(name|email|password|phoneNumber)\"\\s*:\\s*\"([^\"]*)\""
        );

        Matcher matcher = registerRegex.matcher(json);

        // Percorre o JSON recebido e adiciona os campos que batem com o regex
        while (matcher.find()) {
            formattedBody.put(matcher.group(1), matcher.group(2));
        }

        // Caso algum campo obrigatório não seja encontrado, lança uma exceção
        if (!formattedBody.containsKey("name"))
            throw new InvalidJsonContentException("Name field is missing");

        if (!formattedBody.containsKey("email"))
            throw new InvalidJsonContentException("Email field is missing");

        if (!formattedBody.containsKey("password"))
            throw new InvalidJsonContentException("Password field is missing");

        if (!formattedBody.containsKey("phoneNumber"))
            throw new InvalidJsonContentException("Phone number field is missing");

        return formattedBody;
    }
    
    private static HashMap<String, String> parseResetPassword(String json) throws InvalidJsonContentException {
        
        HashMap<String, String> formattedBody = new HashMap<String, String>(2);

        Pattern resetPasswordRegex = Pattern.compile("\"email\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = resetPasswordRegex.matcher(json);
        
        // Percorre o JSON recebido e adiciona os campos que batem com o regex
        if (matcher.find()) formattedBody.put("email", matcher.group(1));

        // Caso algum campo obrigatório não seja encontrado, lança uma exceção
        if (!formattedBody.containsKey("email")) throw new InvalidJsonContentException("Email field is missing");

        return formattedBody;
    }
    
    private static HashMap<String, String> parseChangePassword(String json) throws InvalidJsonContentException {
        
        HashMap<String, String> formattedBody = new HashMap<String, String>(3);
    
        Pattern changePasswordRegex = Pattern.compile("\"(password|confirmPassword)\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = changePasswordRegex.matcher(json);

        // Percorre o JSON recebido e adiciona os campos que batem com o regex
        while (matcher.find()) formattedBody.put(matcher.group(1), matcher.group(2));

        // Caso algum campo obrigatório não seja encontrado, lança uma exceção
        if (!formattedBody.containsKey("password")) throw new InvalidJsonContentException("Password field is missing");
        if (!formattedBody.containsKey("confirmPassword")) throw new InvalidJsonContentException("Confirm password field is missing");

        return formattedBody;
    }
}