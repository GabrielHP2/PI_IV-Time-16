// Autor: Gabriel Henrique Pacagnelli Pagliato

package src;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.EOFException;
import java.io.IOException;
import java.net.Socket;

import components.JsonBuilder;
import models.ResponseStatus;
import utils.InvalidJsonContentException;

// Classe que representa a conexão com um cliente, encapsulando o socket e os streams de leitura e escrita
public class ClientConnection {
    
    private Socket socket;
    private BufferedReader bufferedReader;
    private BufferedWriter bufferedWriter;

    public ClientConnection(Socket socket, BufferedReader bufferedReader, BufferedWriter bufferedWriter) throws IllegalArgumentException {
        
        if (socket == null) throw new IllegalArgumentException("Connection is missing");
        if (bufferedReader == null) throw new IllegalArgumentException("Receptor is missing"); 
        if (bufferedWriter == null) throw new IllegalArgumentException("Transmitter is missing"); 

        this.socket = socket;
        this.bufferedReader = bufferedReader;
        this.bufferedWriter = bufferedWriter;
    }

    // Retorna o endereço de IP do cliente conectado
    public String getClientAddress() {

        return this.socket.getInetAddress().getCanonicalHostName();
    }

    // Recebe o JSON enviado pelo cliente
    public String receiveJson() throws IOException, EOFException, InvalidJsonContentException  {

        // Lê o JSON enviado pelo cliente
        String jsonContent = "";
        jsonContent = this.bufferedReader.readLine();

        if (jsonContent == null) throw new EOFException("Client disconnected");

        if (jsonContent.isBlank()) throw new InvalidJsonContentException("Request JSON content is missing");
        
        return jsonContent;
    }

    // Envia o JSON de resposta para o cliente
    public void sendJson(ResponseStatus responseCode, String responseContent)
        throws IOException, InvalidJsonContentException, IllegalArgumentException {

        if (responseCode == null)
            throw new IllegalArgumentException("Response code is missing");

        if (responseContent == null || responseContent.isBlank())
            throw new InvalidJsonContentException("Response JSON content is missing");

        // Chama o método de construção do JSON de resposta
        // mandando o código e o conteúdo da resposta
        String json = JsonBuilder.buildJson(responseCode, responseContent);

        this.bufferedWriter.write(json); // Escreve o JSON de resposta no socket do cliente
        this.bufferedWriter.newLine(); // Adiciona uma nova linha para indicar o fim do JSON
        this.bufferedWriter.flush(); // Força o envio do JSON
    }

    // Encerra a conexão com o cliente, fechando o socket e os streams de leitura e escrita
    public void shutDown() throws IOException {

        this.bufferedReader.close();
        this.bufferedWriter.close();
        this.socket.close();
    }
}