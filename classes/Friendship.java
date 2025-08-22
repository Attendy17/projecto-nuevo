package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Friendship
 * ---------------------------------------------------------------------------
 * DAO de amistades usando el esquema real:
 *   friendships(user_low, user_high, created_at)  con user_low < user_high
 *   y la vista friendship_list(owner_id, friend_id, created_at)
 *
 * Funciones:
 *   • addFriend(meId, friendId): inserta arista (min,max), idempotente
 *   • listFriends(meId): lista amigos del usuario vía la vista friendship_list
 *
 * Reglas:
 *   • Solo Statement, usando MySQLCompleteConnector
 *   • Sin SQL en JSP
 */
public class Friendship {

    private final MySQLCompleteConnector db;

    public Friendship() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    /** Devuelve true si ya existe amistad entre a y b (sin importar orden). */
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
     * Agrega amistad (idempotente). Si ya existe, devuelve true.
     * La tabla tiene CHECK(user_low < user_high), por eso forzamos orden.
     */
    public boolean addFriend(long meId, long friendId) {
        if (meId == friendId) return false; // No te puedes agregar a ti mismo

        long u1 = Math.min(meId, friendId);
        long u2 = Math.max(meId, friendId);

        if (isFriends(meId, friendId)) return true;

        // Insertar arista (min,max)
        db.doInsert(
            "friendships(user_low, user_high, created_at)",
            u1 + "," + u2 + ", CURRENT_TIMESTAMP"
        );
        // Confirmar
        return isFriends(meId, friendId);
    }

     /**
     * Retorna las ltimas 'max' fotos publicadas por los amigos de 'ownerId'.
     * Columnas: image_url, upload_date, user_id, name
     */
    public ResultSet getFriendsPhotos(long ownerId, int max) {
        if (max <= 0) max = 30;

        String fields =
            "i.image_url, i.upload_date, u.id AS user_id, u.name";
        String tables =
            "friendship_list fl " +
            "JOIN images i ON i.user_id = fl.friend_id " +
            "JOIN users  u ON u.id = fl.friend_id";
        // Como tu conector arma: SELECT fields FROM tables WHERE <where>;
        // agregamos ORDER BY y LIMIT al final del "where".
        String where =
            "fl.owner_id=" + ownerId + " " +
            "ORDER BY i.upload_date DESC " +
            "LIMIT " + max;

        return db.doSelect(fields, tables, where);
    }
    /**
     * Lista los amigos del usuario meId usando la vista friendship_list.
     * Devuelve: u.id, u.name, u.email, u.profile_picture, u.gender, age
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

    public void close() {
        db.closeConnection();
    }
}
