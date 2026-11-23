// Autor: Gabriel Henrique Pacagnelli Pagliato

package src;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

public class Server {

    private static final int DEFAULT_PORT = 8080;
    private static ArrayList<ClientConnection> connectedUsers;

    public static void main(String[] args) {

        int port = Server.DEFAULT_PORT;

        if (args.length > 1) throw new IllegalArgumentException("Only the port value should be provided");

        try {

            if (args.length == 1) port = Integer.parseInt(args[0]);

        } catch (NumberFormatException err) {

            System.out.println("Invalid port value: " + err.getMessage());
            System.exit(1);
        }

        connectedUsers = new ArrayList<ClientConnection>();
        ConnectionAcceptor connectionAcceptor = null;
        
        try {

            connectionAcceptor = new ConnectionAcceptor(port, connectedUsers);
            connectionAcceptor.start();

            System.out.println("Server listening on port " + port);

        } catch (IOException err) {

            System.err.println("Server initialization failed: " + err.getMessage());
            System.exit(1);

        } catch (Exception err) {

            System.err.println("Something went wrong:\n");
            err.printStackTrace();
        }

        
        Scanner scanner = new Scanner(System.in);
        String command = "";
        
        while (true) {
            
            while (true) {
                
                System.out.println("\nType EXIT to shutdown the server");
                System.out.println();
                command = scanner.nextLine();
                
                if (command.toUpperCase().equals("EXIT")) {

                    System.out.println("\nInitiating server shutdown...");
                    scanner.close();
                    break;
                }
                
                System.out.println("\nInvalid command");
            } 

            synchronized(connectedUsers) {

                for (ClientConnection client : Server.connectedUsers) {
    
                    try {
    
                        client.shutDown();
                        
                    } catch (IOException err) {
                        
                        System.err.println("Failed to close client's " + client.getClientAddress() + " connection: " + err.getMessage());
                    }
                }
            }

            System.out.println("\nServer closed");
            System.exit(0);
        } 
    }
}