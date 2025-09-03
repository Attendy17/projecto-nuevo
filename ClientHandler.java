/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez    s01433872
 * Idaliedes Vergara
 * Project 2
 * 
 * ClientHandler.java
 * 
 * Handles one client connection on its own thread.
 * Protocol: text commands separated by '|'.
 * Authors field uses "last:first;last:first;..." (comma also accepted as legacy).
 */

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

public class ClientHandler implements Runnable {
    private final Socket socket;   // client socket
    private final Server service;  // shared server API

    public ClientHandler(Socket socket, Server service) {
        this.socket = socket;
        this.service = service;
    }

    @Override
    public void run() {
        try (
            DataInputStream  in  = new DataInputStream(socket.getInputStream());
            DataOutputStream out = new DataOutputStream(socket.getOutputStream())
        ) {
            out.writeUTF("WELCOME TO BOOKSTORE");
            out.flush();

            while (true) {
                String line = in.readUTF();           // e.g. "LIST_GENRES" or "ADD_GENRE|Mystery"
                String[] parts = line.split("\\|", -1);
                String cmd = parts[0];

                switch (cmd) {
                    case "ADD_GENRE": {
                        boolean ok = service.createGenre(parts[1]);
                        out.writeUTF(ok ? "OK: Genre added" : "ERR: Genre exists");
                        break;
                    }

                    case "LIST_GENRES": {
                        String[] genres = service.getAllGenres();
                        out.writeUTF(genres.length == 0 ? "" : String.join("|", genres));
                        break;
                    }

                    case "ADD_BOOK": {
                        // parts: [0]=ADD_BOOK, [1]=genre, [2]=title, [3]=plot, [4]=year, [5]=authorsText
                        AuthorList authors = parseAuthorsField(parts, 5);
                        boolean ok = service.createBook(
                                parts[1],                 // genre
                                parts[2],                 // title
                                parts[3],                 // plot
                                Integer.parseInt(parts[4]),
                                authors
                        );
                        out.writeUTF(ok ? "OK: Book added" : "ERR: Genre not found or duplicate");
                        break;
                    }

                    case "MODIFY_BOOK": {
                        // parts: [0]=MODIFY_BOOK, [1]=oldTitle, [2]=newTitle, [3]=newPlot, [4]=newYear, [5]=authorsText
                        AuthorList authorsNew = parseAuthorsField(parts, 5);
                        boolean ok = service.updateBook(
                                parts[1],                 // old title
                                parts[2],                 // new title
                                parts[3],                 // new plot
                                Integer.parseInt(parts[4]),
                                authorsNew
                        );
                        out.writeUTF(ok ? "OK: Book modified" : "ERR: Book not found");
                        break;
                    }

                    case "LIST_ALL": {
                        String[] lines = service.getAllBooks();
                        for (String l : lines) out.writeUTF(l);
                        out.writeUTF("END");
                        break;
                    }

                    case "LIST_GENRE": {
                        String[] lines = service.getBooksByGenre(parts[1]);
                        for (String l : lines) out.writeUTF(l);
                        out.writeUTF("END");
                        break;
                    }

                    case "SEARCH_BOOK": {
                        String[] info = service.getBookByTitle(parts[1]);
                        if (info == null) out.writeUTF("ERR: Book not found");
                        else out.writeUTF("INFO|" + String.join("|", info));
                        break;
                    }

                    case "EXIT": {
                        out.writeUTF("BYE");
                        socket.close();
                        return;
                    }

                    default:
                        out.writeUTF("ERR: Unknown command");
                }
                out.flush();
            }
        } catch (IOException e) {
            // client disconnected or I/O error: exit thread
        }
    }

    /**
     * Parse authors from a simple non-CSV text field.
     * Accepted formats:
     *  - "last:first;last:first;..."
     *  - legacy compatible "last,first;last,first;..."
     */
    private AuthorList parseAuthorsField(String[] parts, int idx) {
        AuthorList authors = new AuthorList();
        if (parts.length <= idx || parts[idx].isEmpty()) return authors;

        String raw = parts[idx];
        String[] items = raw.split(";", -1);
        for (String item : items) {
            if (item.isEmpty()) continue;
            String[] pair = item.contains(":") ? item.split(":", 2) : item.split(",", 2); // colon preferred
            String last = pair.length > 0 ? pair[0].trim() : "";
            String first = pair.length > 1 ? pair[1].trim() : "";
            if (!last.isEmpty() || !first.isEmpty()) {
                authors.insertAuthor(last, first);
            }
        }
        return authors;
    }

}
