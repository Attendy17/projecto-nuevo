package ut.JAR.CPEN410;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;

/**
 * Profile
 *
 * DAO to manage the signed-in user's profile and photo posts.
 *   - Read own profile (users + addresses)
 *   - Update profile picture (users.profile_picture)
 *   - Add photo posts (images table)
 *   - List user's photo posts (images)
 *   - [Optional] Delete a photo post (images ownership)
 *
 * Constraints:
 *   - Statement-based access via MySQLCompleteConnector (NO PreparedStatement)
 *   - No SQL in JSP (all DB access is encapsulated here)
 *   - Manual single-quote escaping for string literals
 *
 * Schema used (as provided):
 *   CREATE TABLE images (
 *     id BIGINT AUTO_INCREMENT PRIMARY KEY,
 *     user_id BIGINT NOT NULL,
 *     image_url VARCHAR(255) NOT NULL,
 *     upload_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 *     FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
 *   );
 */
public class Profile {

    private final MySQLCompleteConnector db;

    public Profile() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

/* Helpers 
 * Escapes single quotes for safe SQL string literals.
 * Example:  O'Neil -> O''Neil
 */
    private String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char ch : s.toCharArray()) {
            if (ch == '\'') sb.append("''"); else sb.append(ch);
        }
        return sb.toString();
    }

/* Read-only Profile 
 * Returns a single row (if found) with:
 *   name, email, profile_picture, birth_date, town
 *
 * FROM:
 *   users u LEFT JOIN addresses a ON a.user_id = u.id
 *
 * @param userId current session user id (numeric)
 * @return ResultSet positioned before the first row. Call rs.next().
 */
    public ResultSet getOwnProfile(long userId) {
        String fields = "u.name, u.email, u.profile_picture, u.birth_date, a.town";
        String tables = "users u LEFT JOIN addresses a ON a.user_id = u.id";
        String where  = "u.id=" + userId + " LIMIT 1";
        return db.doSelect(fields, tables, where);
    }

/* Profile Picture (UPD) 
     * Updates the user's profile picture path (relative path stored in DB).
     * Example relativePath: cpen410/imagesjson/profile/12345_pic.png
     *
     * @param userId       the owner user id
     * @param relativePath a web-relative path to serve via Tomcat
     * @return true if one or more rows were updated; false otherwise
     */
    public boolean updateProfilePicture(long userId, String relativePath) {
        String rel = esc(relativePath);
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "UPDATE users SET profile_picture='" + rel + "' WHERE id=" + userId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore) {}
        }
    }

    /* Photo Posts (INS)
     * Adds a new user photo post.
     *
     * Writes into the 'images' table (per your schema). The upload_date
     * is filled by MySQL (DEFAULT CURRENT_TIMESTAMP).
     *
     * @param userId     owner user id
     * @param imagePath  relative path to the stored image
     *                   e.g., "cpen410/imagesjson/userpost/123_...jpg"
     * @return true if the photo row was inserted; false otherwise
     */
    public boolean addUserPost(long userId, String imagePath) {
        String img = esc(imagePath);
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "INSERT INTO images(user_id, image_url) " +
                "VALUES (" + userId + ", '" + img + "');"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore) {}
        }
    }

    /* Photo Posts (SEL)
     * Lists the current user's photo posts, newest first.
     * Returns columns:
     *   id, image_url, upload_date
     *
     * @param userId owner user id
     * @return ResultSet of rows (call rs.next())
     */
    public ResultSet getUserPhotos(long userId) {
        String fields = "id, image_url, upload_date";
        String where  = "user_id=" + userId + " ORDER BY upload_date DESC";
        return db.doSelect(fields, "images", where);
    }

    /* Delete Post
     * Deletes one photo by id ensuring ownership (user_id match).
     *
     * @param userId owner user id (must match row owner)
     * @param photoId images.id primary key
     * @return true if a row was deleted; false otherwise
     */
    public boolean deleteUserPost(long userId, long photoId) {
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "DELETE FROM images WHERE id=" + photoId + " AND user_id=" + userId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore) {}
        }
    }

    /* Lifecycle 
     *Close the underlying connection (call this when you're done). 
     */
    public void close() {
        db.closeConnection();
    }
}


