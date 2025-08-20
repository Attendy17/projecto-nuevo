package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Friendship
 * ---------------------------------------------------------------------------
 * Minimal DAO for friendship features with an undirected, simplified model:
 *  • addFriend(meId, friendId): stores a single symmetric edge (min,max)
 *  • listFriends(meId): lists all friends of a user
 *
 * Assumptions:
 *  • Table friendships has UNIQUE(user1_id, user2_id)
 *  • Undirected edge stored as (min(meId, friendId), max(meId, friendId))
 *  • Optional created_at column (TIMESTAMP/CURRENT_TIMESTAMP default is fine)
 *
 * Constraints (course rules):
 *  • Statement-based via MySQLCompleteConnector (NO PreparedStatement)
 *  • SQL access is encapsulated in Java (no SQL in JSPs)
 */
public class Friendship {

    private final MySQLCompleteConnector db;

    public Friendship() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    /* ___________________________ Helpers ___________________________ */

    /** Returns true if a friendship already exists between A and B. */
    public boolean isFriends(long a, long b) {
        long u1 = Math.min(a, b);
        long u2 = Math.max(a, b);
        ResultSet rs = db.doSelect("COUNT(*)", "friendships", "user1_id=" + u1 + " AND user2_id=" + u2);
        try {
            if (rs != null && rs.next()) {
                long c = rs.getLong(1);
                rs.close();
                return c > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Adds a friendship. Idempotent: if it already exists, returns true.
     */
    public boolean addFriend(long meId, long friendId) {
        if (meId == friendId) return false; // prevent self friendship

        long u1 = Math.min(meId, friendId);
        long u2 = Math.max(meId, friendId);

        if (isFriends(meId, friendId)) return true;

        // Insert symmetric edge
        db.doInsert("friendships(user1_id, user2_id, created_at)", u1 + "," + u2 + ", CURRENT_TIMESTAMP");
        // Confirm
        return isFriends(meId, friendId);
    }

    /**
     * Lists all friends of the user.
     * Returns: u.id, u.name, u.email, u.profile_picture, u.gender, age
     */
    public ResultSet listFriends(long meId) {
        String fields =
              "u.id, u.name, u.email, u.profile_picture, u.gender, "
            + "TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) AS age";
        String tables =
              "friendships f "
            + "JOIN users u ON u.id = CASE WHEN f.user1_id=" + meId + " THEN f.user2_id ELSE f.user1_id END";
        String where =
              meId + " IN (f.user1_id, f.user2_id)";
        return db.doSelect(fields, tables, where);
    }

    public void close() {
        db.closeConnection();
    }
}
