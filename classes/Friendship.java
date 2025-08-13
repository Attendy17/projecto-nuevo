package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Clase para manejar listas de amigos.
 */
public class Friendship {

    private final MySQLCompleteConnector connector;

    public Friendship() {
        connector = new MySQLCompleteConnector();
        connector.doConnection();
    }

    /**
     * Devuelve la lista de amigos con detalles: id, name, profile_picture, fecha de amistad.
     */
    public ResultSet listFriendsWithDetails(long userId) throws SQLException {
        String query = "SELECT f.id AS friendship_id, " +
                       "CASE WHEN f.user1_id=" + userId + " THEN u2.id ELSE u1.id END AS friend_id, " +
                       "CASE WHEN f.user1_id=" + userId + " THEN u2.name ELSE u1.name END AS friend_name, " +
                       "CASE WHEN f.user1_id=" + userId + " THEN u2.profile_picture ELSE u1.profile_picture END AS profile_picture, " +
                       "f.created_at " +
                       "FROM friendships f " +
                       "LEFT JOIN users u1 ON f.user1_id = u1.id " +
                       "LEFT JOIN users u2 ON f.user2_id = u2.id " +
                       "WHERE f.status='accepted' AND (f.user1_id=" + userId + " OR f.user2_id=" + userId + ") " +
                       "ORDER BY f.created_at DESC";
        return connector.doRawQuery(query);
    }

    public void close() {
        connector.closeConnection();
    }
}
