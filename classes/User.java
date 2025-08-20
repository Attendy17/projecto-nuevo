package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * User
 * ----
 * Clase utilitaria para manejar datos básicos del usuario,
 * especialmente para obtener la foto de perfil desde la tabla images.
 */
public class User {

    private final MySQLCompleteConnector connector;

    public User() {
        connector = new MySQLCompleteConnector();
        connector.doConnection();
    }

    /**
     * Obtiene la URL de la última foto de perfil de un usuario desde la tabla images.
     * Si no tiene foto, retorna la ruta por defecto.
     *
     * @param userId ID del usuario
     * @return String con la ruta de la foto
     */
    public String getProfilePicture(long userId) {
        String defaultPic = "cpen410/imagesjson/default-profile.png";
        try {
            // Traer la última foto subida por el usuario
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
     * Obtiene el nombre del usuario desde la tabla users.
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
     * Cierra la conexión
     */
    public void close() {
        connector.closeConnection();
    }
}
