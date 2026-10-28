import java.io.IOException;
import java.util.ArrayList;

public class Server {

    private static final int DEFAULT_PORT = 8080;
    private static ArrayList<ClientConnection> connectedUsers;

    public static void main(String[] args) {

        int port = Server.DEFAULT_PORT;

        if (args.length > 1) throw new IllegalArgumentException("Only the port value should be provided");

        try {

            if (args.length == 0) port = Integer.parseInt(args[0]);

        } catch (NumberFormatException err) {

            System.out.println("Invalid port value: " + err.getMessage());
        }

        connectedUsers = new ArrayList<ClientConnection>();
        ConnectionAcceptor connectionAcceptor = null;
        
        try {

            connectionAcceptor = new ConnectionAcceptor(port, connectedUsers);
            connectionAcceptor.start();

        } catch (IOException err) {

            System.err.println("Server initialization failed: " + err.getMessage());

        } catch (Exception err) {

            System.err.println("Something went wrong: " + err.getStackTrace());
        }

        /* 
        WIP
        
        while (true) {


            for (ClientConnection client : Server.connectedUsers) {

                try {

                    client.shutDown();

                } catch (IOException err) {

                    System.err.println("Failed to close client's " + client.getClientAddress() + " connection: " + err.getMessage());
                }
            }
        } 
        */
    }
}
