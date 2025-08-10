package ut.JAR.CPEN410;

import java.sql.*;

public class SearchFriend {
    private MySQLCompleteConnector connector;

    public SearchFriend() {
        connector = new MySQLCompleteConnector();
        connector.doConnection();
    }

    /**
     * Busca amigos según username, town, gender, edad mínima y máxima.
     * Si un campo está vacío o es null, se omite del filtro.
     * Usa LIKE para username y town, y BETWEEN para la edad.
     */
    public ResultSet searchFriend(String username, String town, String gender, int minAge, int maxAge) throws SQLException {
        String usernameCondition = "";
        if (username != null && !username.trim().isEmpty()) {
            usernameCondition = " AND users.username LIKE '%" + username.trim() + "%' ";
        }

        String townCondition = "";
        if (town != null && !town.trim().isEmpty()) {
            townCondition = " AND addresses.town LIKE '%" + town.trim() + "%' ";
        }

        String genderCondition = "";
        if (gender != null && !gender.trim().isEmpty()) {
            genderCondition = " AND users.gender = '" + gender.trim() + "' ";
        }

        String sql = "SELECT users.id, users.username, users.name, addresses.street, addresses.town, " +
                     "TIMESTAMPDIFF(YEAR, users.birth_date, CURDATE()) AS age, " +
                     "users.profile_picture " +
                     "FROM users " +
                     "JOIN addresses ON users.id = addresses.user_id " +
                     "WHERE 1=1 " +
                     usernameCondition +
                     townCondition +
                     genderCondition +
                     "AND TIMESTAMPDIFF(YEAR, users.birth_date, CURDATE()) BETWEEN " + minAge + " AND " + maxAge;

        System.out.println("Friend search query: " + sql);

        Statement stmt = connector.getConnection().createStatement();
        return stmt.executeQuery(sql);
    }

    public void close() {
        connector.closeConnection();
    }
}
