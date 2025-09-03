/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez    s01433872
 * Idaliedes Vergara
 * Project 2
 * 
 * AuthorList.java
 * 
 * Singly linked list of authors.
 * Sorted by last name, then first name (case-insensitive).
 */
public class AuthorList {
    /** Head of the list. */
    private AuthorNode head;

    /** Empty list. */
    public AuthorList() {
        head = null;
    }

    /**
     * Build a list from pairs {last, first}.
     */
    public AuthorList(String[]... authors) {
        this();
        for (String[] a : authors) {
            if (a != null && a.length >= 2) {
                insertAuthor(a[0], a[1]);
            }
        }
    }

    /**
     * Insert in sorted order. Ignore exact duplicates (case-insensitive).
     */
    public void insertAuthor(String lastName, String firstName) {
        AuthorNode node = new AuthorNode(
                lastName == null ? "" : lastName,
                firstName == null ? "" : firstName
        );

        if (head == null) { // empty
            head = node;
            return;
        }

        // insert at head
        if (cmp(node, head) < 0) {
            node.next = head;
            head = node;
            return;
        }

        // find position before first >= node
        AuthorNode curr = head;
        while (curr.next != null && cmp(curr.next, node) < 0) {
            curr = curr.next;
        }

        // avoid duplicates (equal to curr or curr.next)
        if (eq(curr, node) || (curr.next != null && eq(curr.next, node))) {
            return;
        }

        // insert
        node.next = curr.next;
        curr.next = node;
    }

    /**
     * Return authors as: "Last:First;Last2:First2;..."
     */
    public String listAuthors() {
        StringBuilder sb = new StringBuilder();
        AuthorNode curr = head;
        while (curr != null) {
            sb.append(curr.lastName).append(":").append(curr.firstName);
            curr = curr.next;
            if (curr != null) sb.append(";");
        }
        return sb.toString();
    }

    // ---- helpers ----

    private int cmp(AuthorNode a, AuthorNode b) {
        int c = a.lastName.compareToIgnoreCase(b.lastName);
        if (c != 0) return c;
        return a.firstName.compareToIgnoreCase(b.firstName);
    }

    private boolean eq(AuthorNode a, AuthorNode b) {
        return a.lastName.equalsIgnoreCase(b.lastName)
            && a.firstName.equalsIgnoreCase(b.firstName);
    }
}

