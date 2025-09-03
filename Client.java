/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez    s01433872
 * Idaliedes Vergara
 * Project 2
 * 
 * Client.java
 * 
 * Console client for the server.
 * Text protocol over DataInput/DataOutput streams (UTF).
 */

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage: java Client <host> <port>");
            return;
        }
        String host = args[0];
        final int port;
        try {
            port = Integer.parseInt(args[1]);
        } catch (NumberFormatException e) {
            System.out.println("Port must be an integer.");
            return;
        }

        try (Socket socket = new Socket(host, port);
             DataOutputStream out = new DataOutputStream(socket.getOutputStream());
             DataInputStream  in  = new DataInputStream(socket.getInputStream());
             Scanner sc = new Scanner(System.in)) {

            // Server greeting
            System.out.println(in.readUTF());

            while (true) {
                // ===== Menu =====
                System.out.println("\n--- MENU ---");
                System.out.println("1) Add a genre");
                System.out.println("2) Add a book");
                System.out.println("3) Modify a book");
                System.out.println("4) List all genres");
                System.out.println("5) List all books by genre (all genres)");
                System.out.println("6) List books of a specific genre");
                System.out.println("7) Search for a book");
                System.out.println("8) Exit");
                System.out.print("Option: ");
                String opt = sc.nextLine().trim();

                switch (opt) {
                    case "1": {
                        // ADD_GENRE
                        System.out.print("Genre title: ");
                        send(out, "ADD_GENRE|" + sc.nextLine().trim());
                        System.out.println(in.readUTF());
                        break;
                    }

                    case "2": {
                        // ADD_BOOK
                        // fetch genres to select one
                        send(out, "LIST_GENRES");
                        String genresLine = in.readUTF();
                        if (genresLine.isEmpty()) {
                            System.out.println("No genres available. Add one first.");
                            break;
                        }
                        String[] genres = genresLine.split("\\|", -1);
                        for (int i = 0; i < genres.length; i++) {
                            System.out.printf("%d) %s%n", i + 1, genres[i]);
                        }

                        int idx;
                        while (true) {
                            System.out.print("Select genre number: ");
                            try {
                                idx = Integer.parseInt(sc.nextLine()) - 1;
                                if (idx >= 0 && idx < genres.length) break;
                            } catch (Exception ignored) {}
                            System.out.println("Invalid selection.");
                        }
                        String genre = genres[idx];

                        // book fields
                        System.out.print("Title: ");
                        String title = sc.nextLine().trim();
                        System.out.print("Plot: ");
                        String plot = sc.nextLine().trim();

                        String year;
                        while (true) {
                            System.out.print("Year: ");
                            year = sc.nextLine().trim();
                            try {
                                Integer.parseInt(year);
                                break;
                            } catch (NumberFormatException e) {
                                System.out.println("Enter a valid integer year.");
                            }
                        }

                        int na;
                        while (true) {
                            System.out.print("Number of authors: ");
                            try {
                                na = Integer.parseInt(sc.nextLine());
                                if (na >= 0) break;
                            } catch (Exception ignored) {}
                            System.out.println("Enter a non-negative integer.");
                        }

                        // authors: "last:first;last:first;..."
                        StringBuilder sb = new StringBuilder();
                        for (int i = 0; i < na; i++) {
                            System.out.print("  Author " + (i + 1) + " last name: ");
                            String last = sc.nextLine().trim();
                            System.out.print("  Author " + (i + 1) + " first name: ");
                            String first = sc.nextLine().trim();
                            if (i > 0) sb.append(";");
                            sb.append(last).append(":").append(first);
                        }

                        send(out, String.join("|",
                                "ADD_BOOK",
                                genre,
                                title,
                                plot,
                                year,
                                sb.toString()
                        ));
                        System.out.println(in.readUTF());
                        break;
                    }

                    case "3": {
                        // MODIFY_BOOK
                        System.out.print("Current book title: ");
                        String oldTitle = sc.nextLine().trim();
                        send(out, "SEARCH_BOOK|" + oldTitle);
                        String resp = in.readUTF();
                        if (resp.startsWith("ERR")) {
                            System.out.println(resp);
                            break;
                        }

                        // INFO|genre|title|plot|year|authorsText
                        String[] parts = resp.split("\\|", 6);
                        System.out.println("Genre  : " + parts[1]);
                        System.out.println("Title  : " + parts[2]);
                        System.out.println("Plot   : " + parts[3]);
                        System.out.println("Year   : " + parts[4]);
                        System.out.println("Authors: " + parts[5].replace(";", "; "));
                        System.out.print("Modify? (y/n): ");
                        if (!sc.nextLine().equalsIgnoreCase("y")) {
                            System.out.println("Canceled.");
                            break;
                        }

                        System.out.print("New title: ");
                        String newTitle = sc.nextLine().trim();
                        System.out.print("New plot: ");
                        String newPlot = sc.nextLine().trim();

                        String newYear;
                        while (true) {
                            System.out.print("New year: ");
                            newYear = sc.nextLine().trim();
                            try {
                                Integer.parseInt(newYear);
                                break;
                            } catch (NumberFormatException e) {
                                System.out.println("Enter a valid integer year.");
                            }
                        }

                        int na2;
                        while (true) {
                            System.out.print("Number of authors: ");
                            try {
                                na2 = Integer.parseInt(sc.nextLine());
                                if (na2 >= 0) break;
                            } catch (Exception ignored) {}
                            System.out.println("Enter a non-negative integer.");
                        }

                        StringBuilder sb2 = new StringBuilder();
                        for (int i = 0; i < na2; i++) {
                            System.out.print("  Author last name: ");
                            String last = sc.nextLine().trim();
                            System.out.print("  Author first name: ");
                            String first = sc.nextLine().trim();
                            if (i > 0) sb2.append(";");
                            sb2.append(last).append(":").append(first); // colon format
                        }

                        send(out, String.join("|",
                                "MODIFY_BOOK",
                                oldTitle,
                                newTitle,
                                newPlot,
                                newYear,
                                sb2.toString()
                        ));
                        System.out.println(in.readUTF());
                        break;
                    }

                    case "4": {
                        // LIST_GENRES
                        send(out, "LIST_GENRES");
                        String line = in.readUTF();
                        if (line.isEmpty()) {
                            System.out.println("(no genres)");
                        } else {
                            System.out.println("Genres:");
                            for (String g : line.split("\\|", -1)) {
                                System.out.println(" - " + g);
                            }
                        }
                        break;
                    }

                    case "5": {
                        // LIST_ALL (grouped by genre)
                        send(out, "LIST_ALL");
                        readUntilEnd(in);
                        break;
                    }

                    case "6": {
                        // LIST_GENRE (specific)
                        System.out.print("Genre: ");
                        send(out, "LIST_GENRE|" + sc.nextLine().trim());
                        readUntilEnd(in);
                        break;
                    }

                    case "7": {
                        // SEARCH_BOOK
                        System.out.print("Title to search: ");
                        String query = sc.nextLine().trim();
                        send(out, "SEARCH_BOOK|" + query);
                        String searchResp = in.readUTF();
                        if (searchResp.startsWith("ERR")) {
                            System.out.println(searchResp);
                        } else if (searchResp.startsWith("INFO|")) {
                            String[] infoFields = searchResp.split("\\|", 6);
                            System.out.println("\n=== Book Details ===");
                            System.out.println("Genre  : " + infoFields[1]);
                            System.out.println("Title  : " + infoFields[2]);
                            System.out.println("Plot   : " + infoFields[3]);
                            System.out.println("Year   : " + infoFields[4]);
                            System.out.println("Authors: " + infoFields[5].replace(";", "; "));
                        } else {
                            System.out.println("Unexpected response: " + searchResp);
                        }
                        break;
                    }

                    case "8": {
                        // EXIT
                        send(out, "EXIT");
                        System.out.println(in.readUTF());
                        return;
                    }

                    default:
                        System.out.println("Invalid option.");
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /** Send a command and flush. */
    private static void send(DataOutputStream out, String msg) throws IOException {
        out.writeUTF(msg);
        out.flush();
    }

    /** Read lines until "END". */
    private static void readUntilEnd(DataInputStream in) throws IOException {
        String line;
        while (!(line = in.readUTF()).equals("END")) {
            System.out.println(line);
        }
    }

}
