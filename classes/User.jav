package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * User
 * 
 * Utility class to handle basic user data,
 * especially to retrieve the profile picture from the images table.
 */
public class User {

    private final MySQLCompleteConnector connector;

    public User() {
        connector = new MySQLCompleteConnector();
        connector.doConnection();
    }

    /**
     * Retrieves the URL of the latest profile picture for the given user from the images table.
     * If the user has no picture, returns the default path.
     *
     * @param userId User ID
     * @return String with the picture path
     */
    public String getProfilePicture(long userId) {
        String defaultPic = "cpen410/imagesjson/default-profile.png";
        try {
            // Fetch the latest photo uploaded by the user
            String query = "SELECT image_url FROM images WHERE user_id=" + userId + " ORDER BY upload_date DESC LIMIT 1";
            ResultSet rs = connector.doQuery(query);
            if (rs.next()) {
                String pic = rs.getString("image_url");
                rs.close();
                if (pic != null && !pic.trim().isEmpty()) {
                    return pic;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return defaultPic;
    }

    /**
     * Retrieves the user's name from the users table.
     */
    public String getUserName(long userId) {
        try {
            ResultSet rs = connector.doSelect(
                "name",
                "users",
                "id=" + userId
            );
            if (rs.next()) {
                String name = rs.getString("name");
                rs.close();
                return name;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * Closes the connection.
     */
    public void close() {
        connector.closeConnection();
    }
}
