import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.net.Socket;

import utils.EmptyJsonException;

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

    public String receiveJson() throws IOException, EmptyJsonException {

        String jsonContent = "";

        jsonContent = this.bufferedReader.readLine();

        if (jsonContent == null || jsonContent.isBlank()) throw new EmptyJsonException("JSON content is missing");

        return jsonContent;
    }

    public void sendJson(String responseContent) throws IOException, EmptyJsonException {

        if (responseContent == null || responseContent.isBlank()) throw new EmptyJsonException("Response JSON content is missing");

        this.bufferedWriter.write(responseContent);
        this.bufferedWriter.flush();
    }

    public void shutDown() throws IOException {

        this.bufferedReader.close();
        this.bufferedWriter.close();
        this.socket.close();
    }
}