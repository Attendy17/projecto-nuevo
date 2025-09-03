/** 
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez    s01433872
 * Idaliedes Vergara
 * Project 2
 * 
 * GenreNode.java
 * 
 * One node in the Genre BST.
 * Stores the genre title, BST links, and its circular BookList.
 */
public class GenreNode {
    /** Genre title (e.g., "Action"). */
    String title;
    /** Left child (titles < this.title). */
    GenreNode left;
    /** Right child (titles > this.title). */
    GenreNode right;
    /** Circular doubly linked list of books for this genre. */
    BookList books;

    /** Create a node with an empty BookList. */
    public GenreNode(String title) {
        this.title = title;
        this.left = null;
        this.right = null;
        this.books = new BookList();
    }

}
