// Autor: Gabriel Batista Bastos

package services;

public class RegisterService {
    
    private String name;
    private String email;
    private String password;
    private String phoneNumber;
    
    public RegisterService(String name, String email, String password, String phoneNumber) throws IllegalArgumentException {

        if (name == null || name.isBlank()) throw new IllegalArgumentException("Name is missing");
        if (email == null || email.isBlank()) throw new IllegalArgumentException("Email is missing");
        if (password == null || password.isBlank()) throw new IllegalArgumentException("Password is missing");
        if (phoneNumber == null || phoneNumber.isBlank()) throw new IllegalArgumentException("Phone number is missing");

        this.name = name;
        this.email = email;
        this.password = password;
        this.phoneNumber = phoneNumber;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    // Verifica se o nome é válido (entre 2 e 100 caracteres)
    private boolean isNameValid() {
        return this.name.trim().length() >= 2
        && this.name.trim().length() <= 100;
    }
    
    // Verifica se o email é válido usando o serviço ResetPasswordService
    private boolean isEmailValid() {
        return ResetPasswordService.isValid(this.email);
    }

    // Verifica se a senha é válida usando o serviço ChangePasswordService
    private boolean isPasswordValid() {
        return ChangePasswordService.isValid(this.password, this.password);
    }

    // Verifica se o número de telefone é válido (entre 10 e 15 dígitos)
    private boolean isPhoneNumberValid() {

        // Remove todos os caracteres não numéricos do número de telefone
        String normalizedPhone = this.phoneNumber.replaceAll("\\D", "");

        // Verifica se o número de telefone tem entre 10 e 15 dígitos
        return normalizedPhone.length() >= 10
        && normalizedPhone.length() <= 15;
    }

    // Verifica se todos os campos são válidos
    public boolean isValid() {

        if (this.isNameValid() &&
            this.isEmailValid() &&
            this.isPasswordValid() &&
            this.isPhoneNumberValid()) 
            return true;

        return false;
    }
}