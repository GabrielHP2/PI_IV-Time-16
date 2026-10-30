package services;

public class LoginService {
    
    private String name;
    private String email;
    private String password;

    public LoginService(String name, String email, String password, String phoneNumber) throws IllegalArgumentException {

        if (name == null || name.isBlank()) throw new IllegalArgumentException("Name is missing");
        if (email == null || email.isBlank()) throw new IllegalArgumentException("Email is missing");
        if (password == null || password.isBlank()) throw new IllegalArgumentException("Password is missing");

        this.name = name;
        this.email = email;
        this.password = password;
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

    // TODO: Fazer td a lógica de validação
    private boolean isNameValid() {
        return null;
    }

    private boolean isEmailValid() {
        return null;
    }

    private boolean isPasswordValid() {
        return null;
    }

    public boolean isValid() {

        if (this.isNameValid() &&
            this.isEmailValid() &&
            this.isPasswordValid())
            return true;

        return false;
    }
}