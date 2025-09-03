/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez    s01433872
 * Idaliedes Vergara
 * Project 2
 *
 * Multithreaded server that manages genres and books using a BST.
 * Each client is handled in a separate thread.
 */
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    private final GenreTree tree;

    public Server() {
        tree = new GenreTree();
        loadDemoData();
    }

    /**
     * Run the server.
     * Usage: java Server <port>
     */
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: java Server <port>");
            return;
        }

        final int port;
        try {
            port = Integer.parseInt(args[0]);
        } catch (NumberFormatException e) {
            System.err.println("Port must be an integer.");
            return;
        }

        Server server = new Server();
        System.out.println("Server running on port " + port);
        System.out.println("Genres loaded:");
        for (String genre : server.getAllGenres()) {
            System.out.println(" - " + genre);
        }

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            while (true) {
                Socket client = serverSocket.accept();
                System.out.println("Client: " + client.getRemoteSocketAddress());
                new Thread(new ClientHandler(client, server)).start();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ===== API methods used by ClientHandler =====

    /* Add a new genre */
    public synchronized boolean createGenre(String genreName) {
        return tree.insertGenre(genreName);
    }

    /* List all genres (in-order) */
    public synchronized String[] getAllGenres() {
        return tree.listGenres();
    }

    /* Add a new book */
    public synchronized boolean createBook(String genre, String title, String plot, int year, AuthorList authors) {
        return tree.addBook(genre, title, plot, year, authors);
    }

    /* Update book  */
    public synchronized boolean updateBook(
            String oldTitle,
            String newTitle,
            String newPlot,
            int newYear,
            AuthorList authors) {

        GenreNode genreNode = tree.findGenreNodeOfBook(oldTitle);
        if (genreNode == null) return false;

        if (!genreNode.books.removeBook(oldTitle)) return false;

        return genreNode.books.insertBook(newTitle, newPlot, newYear, authors);
    }

    /* List all books across all genres */
    public synchronized String[] getAllBooks() {
        return tree.listAllBooks();
    }

    /* List all books of one genre */
    public synchronized String[] getBooksByGenre(String genre) {
        return tree.listBooksByGenre(genre);
    }

    /* Search a book by title */
    public synchronized String[] getBookByTitle(String title) {
        return tree.getBookInfo(title);
    }

    // ===== Demo data =====

    private void loadDemoData() {
        tree.insertGenre("Action");
        tree.insertGenre("Comedy");
        tree.insertGenre("Thriller");

        addDemoBook("Action", "The Bourne Identity",
                "An amnesiac discovers he's a trained operative and is hunted across Europe.",
                1980,
                new String[]{"Ludlum", "Robert"});

        addDemoBook("Action", "The Hunger Games",
                "Katniss Everdeen fights to survive a televised battle to the death.",
                2008,
                new String[]{"Collins", "Suzanne"});

        addDemoBook("Action", "The Martian",
                "An astronaut is stranded on Mars and must engineer his survival.",
                2011,
                new String[]{"Weir", "Andy"});

        addDemoBook("Action", "King Solomon's Mines",
                "Adventurers seek a lost expedition and a legendary diamond mine.",
                1885,
                new String[]{"Haggard", "H. Rider"});

        addDemoBook("Action", "The Call of the Wild",
                "A dog is thrust into the harsh life of the Alaskan Yukon trail.",
                1903,
                new String[]{"London", "Jack"});
        
        addDemoBook("Comedy", "Three Men in a Boat",
                "A humorous boating holiday up the Thames goes delightfully wrong.",
                1889,
                new String[]{"Jerome", "Jerome K."});

        addDemoBook("Comedy", "The Importance of Being Earnest",
                "A witty farce about mistaken identities and social satire.",
                1895,
                new String[]{"Wilde", "Oscar"});

        addDemoBook("Comedy", "Diary of a Nobody",
                "A middle-class clerk chronicles everyday mishaps with dry humor.",
                1892,
                new String[]{"Grossmith", "George"},
                new String[]{"Grossmith", "Weedon"});

        addDemoBook("Comedy", "Bridget Jones's Diary",
                "A single woman navigates work, love, and self-improvement with candor.",
                1996,
                new String[]{"Fielding", "Helen"});

        addDemoBook("Comedy", "A Confederacy of Dunces",
                "Ignatius J. Reilly blunders through New Orleans in chaotic escapades.",
                1980,
                new String[]{"Toole", "John Kennedy"});

        addDemoBook("Thriller", "The Day of the Jackal",
                "A hired assassin plans to kill the French president; police race to stop him.",
                1971,
                new String[]{"Forsyth", "Frederick"});

        addDemoBook("Thriller", "The Firm",
                "A young lawyer uncovers his law firm's deadly secrets.",
                1991,
                new String[]{"Grisham", "John"});

        addDemoBook("Thriller", "Shutter Island",
                "U.S. Marshals investigate a disappearance at a remote asylum.",
                2003,
                new String[]{"Lehane", "Dennis"});

        addDemoBook("Thriller", "Red Dragon",
                "An FBI profiler hunts a serial killer with help from Hannibal Lecter.",
                1981,
                new String[]{"Harris", "Thomas"});

        addDemoBook("Thriller", "The Girl on the Train",
                "An unreliable witness becomes entangled in a missing-person case.",
                2015,
                new String[]{"Hawkins", "Paula"});
    }
    
    private void addDemoBook(
            String genre,
            String title,
            String plot,
            int year,
            String[]... authors) {

        AuthorList authorList = new AuthorList();
        for (String[] a : authors) {
            authorList.insertAuthor(a[0], a[1]);
        }
        tree.addBook(genre, title, plot, year, authorList);
    }

}
