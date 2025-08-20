package ut.JAR.CPEN410;

import java.sql.ResultSet;

/**
 * Profile
 * ---------------------------------------------------------------------------
 * Minimal DAO to read the signed-in user's own profile (read-only):
 *   - name, email, profile_picture, birth_date from users
 *   - town from addresses (LEFT JOIN on user_id)
 *
 * Constraints:
 *   - Statement-based access via MySQLCompleteConnector (NO PreparedStatement)
 *   - No SQL in JSP (all DB access is encapsulated here)
 */
public class Profile {

    private final MySQLCompleteConnector db;

    public Profile() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    /**
     * Returns a single row (if found) with:
     *   name, email, profile_picture, birth_date, town
     *
     * @param userId current session user id (numeric)
     * @return ResultSet pointing to 0 or 1 row. Call rs.next() to read it.
     *
     * NOTE: This uses your connector's doSelect(fields, tables, where).
     * We include "LIMIT 1" at the end of the WHERE clause to keep it a single row.
     */
    public ResultSet getOwnProfile(long userId) {
        String fields = "u.name, u.email, u.profile_picture, u.birth_date, a.town";
        String tables = "users u LEFT JOIN addresses a ON a.user_id = u.id";
        String where  = "u.id=" + userId + " LIMIT 1";
        return db.doSelect(fields, tables, where);
    }

    /** Close the underlying connection (call this when you're done). */
    public void close() {
        db.closeConnection();
    }
}
