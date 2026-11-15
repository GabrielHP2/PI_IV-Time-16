// Autor: Gabriel Henrique Pacagnelli Pagliato

package models;

public enum ResponseStatus {
    
    
    OK(200),                        // Usado quando esta tudo certo com a requisição
    ACCEPTED(202),                  // Usado somente para indicar o encerramento de conexão entre back e server

    BAD_REQUEST(400),               // Usado para parâmetros/dados inválidos
    METHOD_NOT_ALLOWED(405),        // Usado quando o server recebe algum tipo de operação que não foi implementada

    INTERNAL_SERVER_ERROR(500);     // Usado quando o server emite algum erro não tratado

    private final int CODE;

    private ResponseStatus(int code) {

        this.CODE = code;
    }

    public int getCode() {

        return this.CODE;
    }
}