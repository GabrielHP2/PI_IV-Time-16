// Autor: Gabriel Batista Bastos

package services;

public class LoginService {

    private String email;
    private String password;

    // Construtor da classe LoginService que recebe o email e a senha do usuário
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

    // Verifica se o email é valido usando o serviço ResetPasswordService 
    private boolean isEmailValid() {
        return ResetPasswordService.isValid(this.email);
    }

    // Verifica se a senha é valida usando o serviço ChangePasswordService
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