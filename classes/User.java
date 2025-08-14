package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * User
 * ----
 * Clase utilitaria para manejar datos básicos del usuario,
 * especialmente para obtener la foto de perfil.
 */
public class User {

    private final MySQLCompleteConnector connector;

    public User() {
        connector = new MySQLCompleteConnector();
        connector.doConnection();
    }

    /**
     * Obtiene la URL de la foto de perfil de un usuario dado.
     * Si no tiene foto, retorna la ruta por defecto.
     *
     * @param userId ID del usuario
     * @return String con la ruta de la foto
     */
    public String getProfilePicture(long userId) {
        String defaultPic = "cpen410/imagesjson/default-profile.png";
        try {
            ResultSet rs = connector.doSelect(
                "profile_picture",
                "users",
                "id=" + userId
            );
            if (rs.next()) {
                String pic = rs.getString("profile_picture");
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
     * Obtiene el nombre del usuario.
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

