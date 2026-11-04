package models;

public enum ResponseStatus {
    
    OK(200),
    ACCEPTED(202),

    BAD_REQUEST(400),
    NOT_FOUND(404),
    METHOD_NOT_ALLOWED(405),

    INTERNAL_SERVER_ERROR(500);

    private final short CODE;

    private ResponseStatus(short code) {

        this.CODE = code;
    }

    public short getCode() {

        return this.CODE;
    }
}
