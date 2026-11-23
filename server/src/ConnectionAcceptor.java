// Autor: Gabriel Henrique Pacagnelli Pagliato

package src;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

public class ConnectionAcceptor extends Thread {

    private ServerSocket serverSocket;
    private ArrayList<ClientConnection> connectedUsers;

    public ConnectionAcceptor(int port, ArrayList<ClientConnection> connectedUsers) throws IOException {
        
        this.serverSocket = new ServerSocket(port);
        this.connectedUsers = connectedUsers;
    }

    @Override
    public void run() {
        
        while (this.serverSocket.isBound() && !this.serverSocket.isClosed()) {

            try {
            
                Socket socket = this.serverSocket.accept();
                
                ConnectionHandler connectionHandler = new ConnectionHandler(socket, this.connectedUsers);
                connectionHandler.start();
                
            } catch (IOException err) {

                System.err.println("Failed to establish connection: " + err.getMessage());

            } catch (IllegalArgumentException err) {

                System.err.println("Handler initialization failed: " + err.getMessage());

            } catch (Exception err) {

                System.err.println("Something went wrong:\n");
                err.printStackTrace();
            }
        }
    }
}