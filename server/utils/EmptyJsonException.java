package utils;

public class EmptyJsonException extends Exception {

    public EmptyJsonException() {
        super();
    }

    public EmptyJsonException(String message) {
        super(message);
    }
}
