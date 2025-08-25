/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez
 * Idaliedes Vergara
 * Project 2
 * 
 * Thread-safe BST of genres.
 * Each node stores a genre title and its BookList.
 */
public class GenreTree {
    private GenreNode root;

    /** Empty tree. */
    public GenreTree() {
        this.root = null;
        }

    /** Insert a genre (case-insensitive). Returns false if it exists. */
    public synchronized boolean insertGenre(String title) {
        if (root == null) {
            root = new GenreNode(title);
            return true;
        }
        GenreNode curr = root, parent = null;
        int cmp = 0;
        while (curr != null) {
            cmp = title.compareToIgnoreCase(curr.title);
            if (cmp == 0) return false; // exists
            parent = curr;
            curr = (cmp < 0) ? curr.left : curr.right;
        }
        GenreNode node = new GenreNode(title);
        if (cmp < 0) parent.left = node;
        else parent.right = node;
        return true;
    }

    /** Return all genres in alphabetical order (in-order). */
    public synchronized String[] listGenres() {
        int count = countNodes(root);
        String[] out = new String[count];
        fillInOrder(root, out, new int[]{0});
        return out;
    }

    private int countNodes(GenreNode n) {
        if (n == null) return 0;
        return 1 + countNodes(n.left) + countNodes(n.right);
    }

    private void fillInOrder(GenreNode n, String[] arr, int[] idx) {
        if (n == null) return;
        fillInOrder(n.left, arr, idx);
        arr[idx[0]++] = n.title;
        fillInOrder(n.right, arr, idx);
    }

    /** Find a genre node by exact title (case-insensitive). */
    public synchronized GenreNode findGenreNode(String title) {
        GenreNode curr = root;
        while (curr != null) {
            int cmp = title.compareToIgnoreCase(curr.title);
            if (cmp == 0) return curr;
            curr = (cmp < 0) ? curr.left : curr.right;
        }
        return null;
    }

    /** Add a book into a genre. Returns false if genre missing or duplicate title. */
    public synchronized boolean addBook(String genreTitle,
                                        String bookTitle,
                                        String plot,
                                        int releaseYear,
                                        AuthorList authors) {
        GenreNode g = findGenreNode(genreTitle);
        if (g == null) return false;
        return g.books.insertBook(bookTitle, plot, releaseYear, authors);
    }

    /** Find the genre node that contains a book by title. */
    public synchronized GenreNode findGenreNodeOfBook(String title) {
        return findGenreNodeOfBookRec(root, title);
    }

    private GenreNode findGenreNodeOfBookRec(GenreNode node, String title) {
        if (node == null) return null;
        if (node.books.findBook(title) != null) return node;
        GenreNode left = findGenreNodeOfBookRec(node.left, title);
        if (left != null) return left;
        return findGenreNodeOfBookRec(node.right, title);
    }

    /**
     * Get full info for a book title.
     * Returns: {genre, title, plot, year, authorsText}
     * authorsText format: "Last:First;Last:First;..."
     */
    public synchronized String[] getBookInfo(String title) {
        GenreNode g = findGenreNodeOfBook(title);
        if (g == null) return null;
        BookNode bn = g.books.findBook(title);
        if (bn == null) return null;
        return new String[] {
            g.title,
            bn.title,
            bn.plot,
            Integer.toString(bn.releaseYear),
            bn.authors.listAuthors() // expected "Last:First;Last:First;..."
        };
    }

    /**
     * List all books grouped by genre.
     * Output lines: "GENRE: X" then "  <book line>"
     */
    public synchronized String[] listAllBooks() {
        String[] genres = listGenres();

        // count total lines
        int total = 0;
        for (String g : genres) {
            total++; // header
            GenreNode gn = findGenreNode(g);
            String list = gn.books.listBooks(); // multi-line or empty
            if (!list.isEmpty()) {
                total += list.split("\n", -1).length;
            }
        }

        String[] out = new String[total];
        int pos = 0;
        for (String g : genres) {
            out[pos++] = "GENRE: " + g;
            GenreNode gn = findGenreNode(g);
            String list = gn.books.listBooks();
            if (!list.isEmpty()) {
                for (String line : list.split("\n", -1)) {
                    out[pos++] = "  " + line;
                }
            }
        }
        return out;
    }

    /**
     * List books for one genre.
     * First line: "GENRE: <name>", followed by indented book lines.
     * Returns empty array if genre is missing.
     */
    public synchronized String[] listBooksByGenre(String genre) {
        GenreNode g = findGenreNode(genre);
        if (g == null) return new String[0];

        String list = g.books.listBooks();
        if (list.isEmpty()) {
            return new String[] { "GENRE: " + g.title };
        }

        String[] blines = list.split("\n", -1);
        String[] out = new String[1 + blines.length];
        out[0] = "GENRE: " + g.title;
        for (int i = 0; i < blines.length; i++) {
            out[i + 1] = "  " + blines[i];
        }
        return out;
    }
}