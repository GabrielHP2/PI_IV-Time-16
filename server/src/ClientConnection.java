package src;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.EOFException;
import java.io.IOException;
import java.net.Socket;

import components.JsonBuilder;
import models.ResponseStatus;
import utils.InvalidJsonContentException;

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

    public String getClientAddress() {

        return this.socket.getInetAddress().getCanonicalHostName();
    }

    public String receiveJson() throws IOException, EOFException, InvalidJsonContentException  {

        String jsonContent = "";
        jsonContent = this.bufferedReader.readLine();

        if (jsonContent == null) throw new EOFException("Client disconnected");

        if (jsonContent.isBlank()) throw new InvalidJsonContentException("Request JSON content is missing");
        
        return jsonContent;
    }

    public void sendJson(ResponseStatus responseCode, String responseContent) throws IOException, InvalidJsonContentException, IllegalArgumentException {

        if (responseCode == null) throw new IllegalArgumentException("Response code is missing");
        if (responseContent == null || responseContent.isBlank()) throw new InvalidJsonContentException("Response JSON content is missing");

        String json = JsonBuilder.buildJson(responseCode, responseContent);

        this.bufferedWriter.write(json);
        this.bufferedWriter.flush();
    }

    public void shutDown() throws IOException {

        this.bufferedReader.close();
        this.bufferedWriter.close();
        this.socket.close();
    }
}