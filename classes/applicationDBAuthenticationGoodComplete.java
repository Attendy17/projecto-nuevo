package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * applicationDBAuthenticationGoodComplete
 * ---------------------------------------
 * Handles user authentication, role lookup, and user registration.
 * Follows the required pattern of string-concatenated SQL queries
 * using {@link MySQLCompleteConnector}.
 */
public class applicationDBAuthenticationGoodComplete {

    /** Persistent DB connection helper. */
    private final MySQLCompleteConnector myDBConn;

    /** Open connection on creation. */
    public applicationDBAuthenticationGoodComplete() {
        System.out.println("applicationDBAuthenticationGoodComplete loaded.");
        myDBConn = new MySQLCompleteConnector();
        myDBConn.doConnection();
    }

    /* ─────────────────────────── Authentication ─────────────────────────── */

    /**
     * Authenticate user by email and password.
     *
     * @param email user email.
     * @param userPass user password.
     * @return ResultSet with id, email, and name if match is found.
     */
    public ResultSet authenticate(String email, String userPass) {
        String fields = "id, email, name";
        String table = "users";
        String where = "email='" + email + "' AND password=SHA2('" + userPass + "',256)";
        System.out.println("authenticate ? " + where);
        return myDBConn.doSelect(fields, table, where);
    }

    /* ─────────────────────────── Role Lookup ────────────────────────────── */

    /**
     * Get user role (ADMIN or USER) by user ID.
     *
     * @param userId ID of the user.
     * @return Role name or empty string if not found.
     */
    public String getUserRole(long userId) {
        try {
            String fields = "r.name";
            String tables = "roles r, user_roles ur";
            String where = "r.id = ur.role_id AND ur.user_id=" + userId;

            ResultSet rs = myDBConn.doSelect(fields, tables, where);
            if (rs.next()) {
                String role = rs.getString(1);
                rs.close();
                return role;
            }
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "";
    }

    /* ─────────────────────────── Sign-up ────────────────────────────────── */

    /**
     * Adds a new user to the database.
     *
     * @param email Email address.
     * @param completeName Full name (will be escaped manually).
     * @param userPass Password.
     * @param birthDate Birth date.
     * @param gender Gender.
     * @return true if insert succeeds.
     */
    public boolean addUser(String email,
                           String completeName,
                           String userPass,
                           String birthDate,
                           String gender) {
        // Manual sanitization of single quote without using replace
        StringBuilder escapedName = new StringBuilder();
        for (char ch : completeName.toCharArray()) {
            if (ch == '\'') {
                escapedName.append("''");
            } else {
                escapedName.append(ch);
            }
        }

        String fields = "users(name,email,password,birth_date,gender,profile_picture,last_page_id)";
        String values = "'" + escapedName + "', '" + email + "', SHA2('" + userPass + "',256), '"
                      + birthDate + "', '" + gender + "', NULL, NULL";

        boolean failed = myDBConn.doInsert(fields, values);
        System.out.println("Insertion executed: " + failed);
        return !failed;
    }

    /* ─────────────────────────── Misc ───────────────────────────────────── */

    /**
     * Fetch auxiliary user data (e.g., last_page_id) by email.
     */
    public ResultSet getUserData(String email) {
        return myDBConn.doSelect("last_page_id", "users", "email='" + email + "'");
    }

    /** Shutdown connection. */
    public void close() {
        myDBConn.closeConnection();
    }
}
