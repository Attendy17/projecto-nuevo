/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez    s01433872
 * Idaliedes Vergara
 * Project 2
 * 
 * AuthorNode.java
 * 
 * One node in the singly linked AuthorList.
 * Stores an author's name and the next pointer.
 */
public class AuthorNode {
    /** Author last name. */
    String lastName;
    /** Author first name. */
    String firstName;
    /** Next node in the list. */
    AuthorNode next;

    /** Create a node with last/first name. */
    public AuthorNode(String lastName, String firstName) {
        this.lastName = lastName;
        this.firstName = firstName;
        this.next = null;
    }
}

