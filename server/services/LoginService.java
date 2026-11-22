// Autor: Gabriel Batista Bastos

package services;

public class LoginService {

    private String email;
    private String password;

    public LoginService(String email, String password)
            throws IllegalArgumentException {

        if (email == null || email.isBlank())
            throw new IllegalArgumentException("Email is missing");

        if (password == null || password.isBlank())
            throw new IllegalArgumentException("Password is missing");

        this.email = email.trim();
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    private boolean isEmailValid() {
        return ResetPasswordService.isValid(this.email);
    }

    private boolean isPasswordValid() {
        return ChangePasswordService.isValid(
            this.password,
            this.password
        );
    }

    public boolean isValid() {
        return this.isEmailValid() && this.isPasswordValid();
    }
}