// Autor: Gabriel Henrique Pacagnelli Pagliato

package services;

import java.util.regex.Pattern;

public class ResetPasswordService {
    
    public static boolean isValid(String email) {

        return ResetPasswordService.isEmailValid(email);
    }

    private static boolean isEmailValid(String email) {

        if (email == null || email.isBlank()) return false;

        Pattern emailRegex = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

        return emailRegex.matcher(email).matches();
    }
}