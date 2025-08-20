package ut.JAR.CPEN410;

import java.sql.ResultSet;

/**
 * AdminConn
 * ---------------------------------------------------------------------------
 * Minimal admin data access using MySQLCompleteConnector (Statement-based).
 *  • listUsers(): returns all users with basic profile fields
 *  • close():     closes the underlying DB connection
 *
 * Design constraints:
 *  • No PreparedStatement (per course rule)
 *  • DB access is encapsulated (Rule C.a)
 */
public class AdminConn {

    /** Shared connector for this admin session. */
    private final MySQLCompleteConnector db;

    /**
     * Opens a connection on creation.
     */
    public AdminConn() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    /* ________________________________ Queries ________________________________ */

    /**
     * Lists all users for the admin table.
     * Columns: id, name, email, birth_date, gender, profile_picture
     *
     * @return ResultSet for iteration in JSP (caller should close the ResultSet)
     */
    public ResultSet listUsers() {
        return db.doSelect(
            "id, name, email, birth_date, gender, profile_picture",
            "users"
        );
    }

    /* __________________________________ Close ________________________________ */

    /**
     * Closes the underlying Statement and Connection.
     * Call this when the JSP finishes rendering.
     */
    public void close() {
        db.closeConnection();
    }

    /**
     * (Optional) expose the connector if other DAOs need to share it.
     */
    public MySQLCompleteConnector getConnector() {
        return db;
    }
}
