package utils;

public class InvalidJsonContentException extends Exception {
    
    public InvalidJsonContentException() {
        super();
    }

    public InvalidJsonContentException(String message) {
        super(message);
    }
}
