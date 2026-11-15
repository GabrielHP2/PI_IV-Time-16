// Autor: Gabriel Henrique Pacagnelli Pagliato

package services;

import java.util.regex.Pattern;

public class ChangePasswordService {

    public static boolean isValid(String password, String confirmPassword) {

        return ChangePasswordService.isPasswordValid(password, confirmPassword);
    }

    private static boolean isPasswordValid(String password, String confirmPassword) {

        if (password == null || password.isBlank()) return false;
        if (confirmPassword == null || confirmPassword.isBlank()) return false;

        if (!password.equals(confirmPassword)) return false;

        Pattern passwordRegex = Pattern.compile("\"^(?=.{6,126}$)(?=.*[a-z])(?=.*[A-Z])(?=.*\\\\d)(?=.*[^A-Za-z0-9]).+$\"");

        return passwordRegex.matcher(password).matches();
    }
}