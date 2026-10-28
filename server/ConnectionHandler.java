import java.net.Socket;
import java.util.ArrayList;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.io.IOException;

public class ConnectionHandler extends Thread {
    
    private Socket socket;
    private ClientConnection user;
    private ArrayList<ClientConnection> connectedUsers;

    public ConnectionHandler(Socket socket, ArrayList<ClientConnection> connectedUsers) throws IllegalArgumentException { 

        if (socket == null) throw new IllegalArgumentException("Connection is missing");
        if (connectedUsers == null) throw new IllegalArgumentException("Connected users is missing");

        this.socket = socket;
        this.connectedUsers = connectedUsers;
    }
    
    @Override 
    public void run() {

        BufferedReader bufferedReader = null;
        BufferedWriter bufferedWriter = null;

        // WIP
        try {

            bufferedWriter = new BufferedWriter(
                new OutputStreamWriter(this.socket.getOutputStream(), StandardCharsets.UTF_8));
            
            bufferedReader = new BufferedReader(
                new InputStreamReader(this.socket.getInputStream(), StandardCharsets.UTF_8));
                            
            this.user = new ClientConnection(this.socket, bufferedReader, bufferedWriter);


        } catch (IOException err) {

            System.err.println("Failed to stablish IO connection: " + err.getMessage());

        } catch (IllegalArgumentException err) {

            // TODO
            System.err.println("" + err.getMessage());

        } catch (Exception err) {

            System.err.println("Something went wrong: " + err.getStackTrace());
        }
        
        // WIP
        try {
            
            synchronized(this.connectedUsers) {
                
                this.connectedUsers.add(this.user);
            }
            
            
            while (true) {
                
                this.user.sendJson(getName());
            }
                
        } catch (IOException err) {
            
            System.err.println("" + err.getMessage());

        } catch (Exception err) {
            
            System.err.println("Something went wrong: " + err.getStackTrace());
        }
    }
}
