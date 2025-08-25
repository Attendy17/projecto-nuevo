/**
 * Louiz A. Inostroza Ruiz s01397648
 * Anais Ortiz Montanez
 * Idaliedes Vergara
 * Project 2
 * 
 * 
 * BookNode.java
 * A node in the circular doubly-linked BookList. Holds one book’s data
 * and links to previous/next books.
 */
public class BookNode {
 /** Book title. */
 String title;
 /** Plot / synopsis. */
 String plot;
 /** Publication year. */
 int releaseYear;
 /** Authors (singly linked list, sorted by last name; listAuthors() => "Last:First;..."). */
 AuthorList authors;
 /** Previous node in the circle. */
 BookNode prev;
 /** Next node in the circle. */
 BookNode next;

 /** Create node; prev/next point to self. */
 public BookNode(String title, String plot, int releaseYear, AuthorList authors) {
     this.title = title;
     this.plot = plot;
     this.releaseYear = releaseYear;
     this.authors = authors;
     this.prev = this;
     this.next = this;
 }
}
