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
    
    private boolean isNameValid() {
    return this.name.trim().length() >= 2
        && this.name.trim().length() <= 100;
}

    private boolean isEmailValid() {
    return ResetPasswordService.isValid(this.email);
}

    private boolean isPasswordValid() {
    return ChangePasswordService.isValid(this.password, this.password);
}

    private boolean isPhoneNumberValid() {

    String normalizedPhone = this.phoneNumber.replaceAll("\\D", "");

    return normalizedPhone.length() >= 10
        && normalizedPhone.length() <= 15;
}

    public boolean isValid() {

        if (this.isNameValid() &&
            this.isEmailValid() &&
            this.isPasswordValid() &&
            this.isPhoneNumberValid()) 
            return true;

        return false;
    }
}