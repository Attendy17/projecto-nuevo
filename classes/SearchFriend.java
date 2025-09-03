package ut.JAR.CPEN410;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * SearchFriend
 *
 * Single search-bar friend search:
 *   Matches by name / email / town / state / country (LIKE %keyword%)
 *   If keyword is "male"/"female"/"other" (any case), matches gender exactly
 *   If keyword is an integer (e.g., 25), matches exact age using TIMESTAMPDIFF
 *
 * Constraints:
 *   Uses MySQLCompleteConnector (Statement-based; NO PreparedStatement)
 *   Escapes single quotes manually to form safe string literals
 *   Returns a ResultSet; caller should iterate and close it, then call close()
 */
public class SearchFriend {

    private final MySQLCompleteConnector dbConn;

    public SearchFriend() {
        dbConn = new MySQLCompleteConnector();
        dbConn.doConnection();
    }

    /* Escape single quotes without using replace(), matching your style. */
    private String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char ch : s.toCharArray()) sb.append(ch == '\'' ? "''" : ch);
        return sb.toString();
    }

    /**
     * Executes a single-keyword search. The WHERE clause groups OR conditions to
     * ensure correct precedence across fields and optional gender/age matches.
     *
     * Columns returned:
     *  id, name, email, profile_picture, gender,
     *  town, state, country, age (computed)
     */
    public ResultSet searchFriend(String keyword) {
        try {
            if (keyword == null) keyword = "";
            String kwRaw = keyword.trim();
            String kw    = esc(kwRaw); // escaped for SQL literal

            // Try to interpret keyword as a gender
            String kwLower = kwRaw.toLowerCase();
            String genderValue = null;
            if ("male".equals(kwLower) || "female".equals(kwLower) || "other".equals(kwLower)) {
                genderValue = Character.toUpperCase(kwLower.charAt(0)) + kwLower.substring(1);
            }

            // Try to interpret keyword as an exact age
            Integer ageSearch = null;
            try {
                ageSearch = Integer.valueOf(kwRaw);
                if (ageSearch < 0) ageSearch = null;
            } catch (NumberFormatException ignore) {}

            Connection conn = dbConn.getConnection();
            Statement stmt  = conn.createStatement();

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT ");
            sql.append("  u.id, u.name, u.email, u.profile_picture, u.gender, ");
            sql.append("  a.town, a.state, a.country, ");
            sql.append("  TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) AS age ");
            sql.append("FROM users u ");
            sql.append("LEFT JOIN addresses a ON u.id = a.user_id ");
            sql.append("WHERE (");
            sql.append("  u.name LIKE '%").append(kw).append("%' ");
            sql.append("  OR u.email LIKE '%").append(kw).append("%' ");
            sql.append("  OR a.town LIKE '%").append(kw).append("%' ");
            sql.append("  OR a.state LIKE '%").append(kw).append("%' ");
            sql.append("  OR a.country LIKE '%").append(kw).append("%' ");
            if (genderValue != null) {
                sql.append("  OR u.gender='").append(genderValue).append("' ");
            }
            if (ageSearch != null) {
                sql.append("  OR TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) = ").append(ageSearch).append(" ");
            }
            sql.append(") ");
            sql.append("ORDER BY u.name ASC ");
            sql.append("LIMIT 50;");

            System.out.println("Executing query: " + sql);
            // Do NOT close stmt here; ResultSet depends on it. We close via close()
            return stmt.executeQuery(sql.toString());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /* Closes the underlying connector (which closes connection & statement). */
    public void close() {
        dbConn.closeConnection();
    }
}
