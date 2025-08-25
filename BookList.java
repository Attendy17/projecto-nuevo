/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez
 * Idaliedes Vergara
 * Project 2
 * 
 * BookList.java
 * 
 * Circular doubly linked list of BookNode.
 * Books are kept in alphabetical order by title.
 */
public class BookList {
    /** Head of the circular list; null when empty. */
    private BookNode head;

    /** Empty list. */
    public BookList() {
        head = null;
    }

    /**
     * Insert a book in-order (by title, case-insensitive).
     * @return false if a book with the same title exists.
     */
    public boolean insertBook(String title, String plot, int releaseYear, AuthorList authors) {
        BookNode newNode = new BookNode(title, plot, releaseYear, authors);
        if (head == null) {
            head = newNode;
            return true;
        }
        BookNode curr = head;
        do {
            int cmp = title.compareToIgnoreCase(curr.title);
            if (cmp == 0) {
                return false; // duplicate
            } else if (cmp < 0) {
                // insert before curr
                BookNode prev = curr.prev;
                prev.next = newNode;
                newNode.prev = prev;
                newNode.next = curr;
                curr.prev = newNode;
                if (curr == head) head = newNode;
                return true;
            }
            curr = curr.next;
        } while (curr != head);

        // insert at end (before head)
        BookNode last = head.prev;
        last.next = newNode;
        newNode.prev = last;
        newNode.next = head;
        head.prev = newNode;
        return true;
    }

    /** Find a book by title (case-insensitive). */
    public BookNode findBook(String title) {
        if (head == null) return null;
        BookNode curr = head;
        do {
            if (curr.title.equalsIgnoreCase(title)) return curr;
            curr = curr.next;
        } while (curr != head);
        return null;
    }

    /** Remove a book by title. */
    public boolean removeBook(String title) {
        BookNode node = findBook(title);
        if (node == null) return false;
        if (node.next == node) {
            head = null;
        } else {
            node.prev.next = node.next;
            node.next.prev = node.prev;
            if (node == head) head = node.next;
        }
        return true;
    }

    /**
     * Return books as multi-line text (no trailing newline).
     * Each line: "Title (Year) - Last:First;Last:First;..."
     * (authors come from AuthorList.listAuthors()).
     * Returns "" when the list is empty.
     */
    public String listBooks() {
        if (head == null) return "";
        StringBuilder sb = new StringBuilder();
        BookNode curr = head;
        do {
            sb.append(curr.title)
              .append(" (").append(curr.releaseYear).append(") - ")
              .append(curr.authors.listAuthors()); // "Last:First;Last:First;..."
            curr = curr.next;
            if (curr != head) sb.append("\n");
        } while (curr != head);
        return sb.toString();
    }
}
