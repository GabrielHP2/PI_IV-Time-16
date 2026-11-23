// Autor: Gabriel Henrique Pacagnelli Pagliato

package services;

import java.util.regex.Pattern;

public class ChangePasswordService {

    public static boolean isValid(String password, String confirmPassword) {

        return ChangePasswordService.isPasswordValid(password, confirmPassword);
    }

    // Veririfica se a senha é válida usando regex
    private static boolean isPasswordValid(String password, String confirmPassword) {

        if (password == null || password.isBlank()) return false;
        if (confirmPassword == null || confirmPassword.isBlank()) return false;

        if (!password.equals(confirmPassword)) return false;

        Pattern passwordRegex = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!*_?-])\\S{6,126}$");

        return passwordRegex.matcher(password).matches();
    }
}