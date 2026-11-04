package src;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;

import components.JsonParser;
import models.ResponseStatus;
import utils.InvalidJsonContentException;
import utils.UnknownOperationException;


public class ConnectionHandler extends Thread {
    
    private Socket socket;
    private ClientConnection user;
    private ArrayList<ClientConnection> connectedUsers;

    public ConnectionHandler(Socket socket, ArrayList<ClientConnection> connectedUsers) throws IllegalArgumentException { 

        if (socket == null) throw new IllegalArgumentException("Connection is missing");
        if (connectedUsers == null) throw new IllegalArgumentException("User list is missing");

        this.socket = socket;
        this.connectedUsers = connectedUsers;
    }
    
    @Override 
    public void run() {

        BufferedReader bufferedReader = null;
        BufferedWriter bufferedWriter = null;

        try {

            bufferedWriter = new BufferedWriter(
                new OutputStreamWriter(this.socket.getOutputStream(), StandardCharsets.UTF_8));

        } catch (IOException err) {
            
            System.err.println("Failed to establish IO connection: " + err.getMessage());
        }

        try {
            
            bufferedReader = new BufferedReader(
                new InputStreamReader(this.socket.getInputStream(), StandardCharsets.UTF_8));
                            
            this.user = new ClientConnection(this.socket, bufferedReader, bufferedWriter);

            synchronized(this.connectedUsers) {
                
                this.connectedUsers.add(this.user);
            }

            System.out.println("User " + this.user.getClientAddress() + " has connected");

        } catch (IOException err) {
            
            System.err.println("Failed to establish IO connection: " + err.getMessage());

            try {

                bufferedWriter.close();

            } catch (IOException e) {

                System.err.println("Failed to close IO connection: " + e.getMessage());
            }

        } catch (IllegalArgumentException err) {

            System.err.println("Failed to create client: " + err.getMessage());

        } catch (Exception err) {

            System.err.println("Something went wrong:\n");
            err.printStackTrace();
        }
        
        // WIP
        try {
            
            while (true) {

                String json = this.user.receiveJson();

                HashMap<String, String> formattedBody = JsonParser.parse(json);

                switch (formattedBody.get("operation")) {
                    
                    case "ping" -> this.user.sendJson(ResponseStatus.OK ,"pong");

                    case "close" -> {
                        
                        this.user.sendJson(ResponseStatus.ACCEPTED ,"connection closed");

                        this.user.shutDown();

                        synchronized(this.connectedUsers) {

                            this.connectedUsers.remove(this.user);
                        }

                        return;
                    }
                }
            }
                
        } catch (EOFException err) {
            
            System.err.println("Failed to read the JSON: " + err.getMessage());

        } catch (InvalidJsonContentException err)  {

            System.err.println(err.getMessage());

            try {   

                this.user.sendJson(err.getMessage());

            } catch(Exception e) {

                System.err.println("Failed to send error message: " + e.getMessage());
            }
            
        } catch (IOException err)  {

            System.err.println(err.getMessage());

        } catch (UnknownOperationException err) {
            
            System.err.println("Failed to read the JSON: " + err.getMessage());

            try {

                this.user.sendJson(err.getMessage());

            } catch(Exception e) {

                System.err.println("Failed to send error message: " + e.getMessage());
            }

        } catch (Exception err) {
            
            System.err.println("Something went wrong:\n");
            err.printStackTrace();

        } finally {

            String clientAddress = this.user.getClientAddress();

            try {

                this.user.shutDown();
                
            } catch (IOException e) {
                
                System.err.println("Failed to disconnect user " + clientAddress + ": " + e.getMessage());
            }
            
            synchronized(this.connectedUsers) {
                
                this.connectedUsers.remove(this.user);
            }
            
            System.out.println("User " + clientAddress + " has disconnected");
        }
    }
}
