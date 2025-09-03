package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Friendship
 * Friendships DAO using the real schema:
 *   friendships(user_low, user_high, created_at) with user_low < user_high
 *   and the view friendship_list(owner_id, friend_id, created_at)
 *
 * Functions:
 *   • addFriend(meId, friendId): inserts edge (min,max), idempotent
 *   • listFriends(meId): lists user's friends via the friendship_list view
 *
 * Rules:
 *   • Statement-only, using MySQLCompleteConnector
 *   • No SQL in JSP
 */
public class Friendship {

    private final MySQLCompleteConnector db;

    public Friendship() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    /** Returns true if a and b are already friends (order-independent). */
    public boolean isFriends(long a, long b) {
        long u1 = Math.min(a, b);
        long u2 = Math.max(a, b);
        ResultSet rs = db.doSelect(
            "COUNT(*)",
            "friendships",
            "user_low=" + u1 + " AND user_high=" + u2
        );
        try {
            if (rs != null && rs.next()) {
                long c = rs.getLong(1);
                rs.close();
                return c > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Adds a friendship (idempotent). If it already exists, returns true.
     * Table enforces CHECK(user_low < user_high), hence the enforced order.
     */
    public boolean addFriend(long meId, long friendId) {
        if (meId == friendId) return false; // cannot add yourself

        long u1 = Math.min(meId, friendId);
        long u2 = Math.max(meId, friendId);

        if (isFriends(meId, friendId)) return true;

        // Insert edge (min,max)
        db.doInsert(
            "friendships(user_low, user_high, created_at)",
            u1 + "," + u2 + ", CURRENT_TIMESTAMP"
        );
        // Confirm
        return isFriends(meId, friendId);
    }

    /**
     * Returns the latest 'max' photos posted by 'ownerId' friends.
     * Columns: image_url, upload_date, user_id, name
     */
    public ResultSet getFriendsPhotos(long ownerId, int max) {
        if (max <= 0) max = 30;

        String fields =
            "i.image_url, i.upload_date, u.id AS user_id, u.name";
        String tables =
            "friendship_list fl " +
            "JOIN images i ON i.user_id = fl.friend_id " +
            "JOIN users  u ON u.id = fl.friend_id";
        // The connector builds: SELECT fields FROM tables WHERE <where>;
        // add ORDER BY and LIMIT at the end of the "where".
        String where =
            "fl.owner_id=" + ownerId + " " +
            "ORDER BY i.upload_date DESC " +
            "LIMIT " + max;

        return db.doSelect(fields, tables, where);
    }

    /**
     * Lists user friends (meId) using the friendship_list view.
     * Returns: u.id, u.name, u.email, u.profile_picture, u.gender, age
     */
    public ResultSet listFriends(long meId) {
        String fields =
              "u.id, u.name, u.email, u.profile_picture, u.gender, "
            + "TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) AS age";
        String tables =
              "friendship_list fl "
            + "JOIN users u ON u.id = fl.friend_id";
        String where =
              "fl.owner_id=" + meId;
        return db.doSelect(fields, tables, where);
    }

    /** Closes underlying DB connection. */
    public void close() {
        db.closeConnection();
    }
}

