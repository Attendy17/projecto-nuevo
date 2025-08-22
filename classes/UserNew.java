package ut.JAR.CPEN410;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * UserNew
 * ---------------------------------------------------------------------------
 * DAO para registrar un nuevo usuario y datos relacionados:
 *   - createUser(name, email, passPlain, birthDate, gender) -> devuelve userId
 *   - ensureUserRole(userId) -> asegura rol USER y lo asigna al usuario
 *   - upsertAddress(userId, street, town, state, country)
 *   - addEducation(userId, degree, school)
 *
 * Restricciones:
 *   - Solo Statement (sin PreparedStatement) via MySQLCompleteConnector.
 *   - Hash de password en MySQL: SHA2('<plain>', 256).
 *   - SQL encapsulado, no en los JSPs.
 */
public class UserNew {

    private final MySQLCompleteConnector db;

    public UserNew() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    private String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char ch : s.toCharArray()) {
            if (ch == '\'') sb.append("''"); else sb.append(ch);
        }
        return sb.toString();
    }

    /** Crea al usuario. Devuelve su id (>0) o -1 si falla/duplicado. */
    public long createUser(String name, String email, String passPlain, String birthDate, String gender) {
        String nm = esc(name);
        String em = esc(email);
        String pw = esc(passPlain);
        String bd = esc(birthDate);
        String gd = esc(gender);

        Statement s = null;
        ResultSet rs = null;

        try {
            Connection c = db.getConnection();
            s = c.createStatement();

            // Unicidad de email
            rs = s.executeQuery("SELECT COUNT(*) FROM users WHERE email='" + em + "'");
            long cnt = 0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs = null; }
            if (cnt > 0) {
                return -1; // email duplicado
            }

            // INSERT con hash
            int rows = s.executeUpdate(
                "INSERT INTO users(name,email,password,birth_date,gender,profile_picture,last_page_id) VALUES (" +
                "'" + nm + "'," +
                "'" + em + "'," +
                "SHA2('" + pw + "',256)," +
                "'" + bd + "'," +
                "'" + gd + "'," +
                "NULL," +
                "NULL" +
                ");"
            );
            if (rows <= 0) return -1;

            // Obtener id por email
            rs = s.executeQuery("SELECT id FROM users WHERE email='" + em + "' LIMIT 1");
            if (rs != null && rs.next()) {
                long newId = rs.getLong(1);
                rs.close();
                return newId;
            }
            return -1;
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore){}
            try { if (s != null)  s.close(); }  catch (Exception ignore){}
        }
    }

    /** Asegura que rol USER exista y asigna el rol al usuario (si no lo tiene). */
    public void ensureUserRole(long userId) {
        Statement s = null;
        ResultSet rs = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();

            // Asegura rol USER
            rs = s.executeQuery("SELECT id FROM roles WHERE code='USER' LIMIT 1");
            long ridUser = -1;
            if (rs != null && rs.next()) {
                ridUser = rs.getLong(1);
                rs.close(); rs=null;
            } else {
                s.executeUpdate("INSERT INTO roles(code,name) VALUES('USER','User');");
                rs = s.executeQuery("SELECT id FROM roles WHERE code='USER' LIMIT 1");
                if (rs != null && rs.next()) ridUser = rs.getLong(1);
                if (rs != null) { rs.close(); rs=null; }
            }
            if (ridUser <= 0) return;

            // Asignar si no lo tiene
            rs = s.executeQuery("SELECT COUNT(*) FROM user_roles WHERE user_id=" + userId + " AND role_id=" + ridUser);
            long cnt=0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs=null; }
            if (cnt == 0) {
                s.executeUpdate(
                    "INSERT INTO user_roles(user_id, role_id, dateAssign) VALUES (" +
                    userId + "," + ridUser + ", CURRENT_DATE())"
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore){}
            try { if (s != null)  s.close(); }  catch (Exception ignore){}
        }
    }

    /** Upsert en addresses (1:1). */
    public boolean upsertAddress(long userId, String street, String town, String state, String country) {
        String st = esc(street);
        String tw = esc(town);
        String stt= esc(state);
        String co = esc(country);

        Statement s = null;
        ResultSet rs = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();

            rs = s.executeQuery("SELECT COUNT(*) FROM addresses WHERE user_id=" + userId);
            long cnt=0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs=null; }

            int rows;
            if (cnt > 0) {
                rows = s.executeUpdate(
                    "UPDATE addresses SET " +
                    "street='" + st + "', town='" + tw + "', state='" + stt + "', country='" + co + "' " +
                    "WHERE user_id=" + userId
                );
            } else {
                rows = s.executeUpdate(
                    "INSERT INTO addresses(user_id, street, town, state, country) VALUES (" +
                    userId + ", '" + st + "', '" + tw + "', '" + stt + "', '" + co + "')"
                );
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore){}
            try { if (s != null)  s.close(); }  catch (Exception ignore){}
        }
    }

    /** Insert en education (1:N). */
    public boolean addEducation(long userId, String degree, String school) {
        String dg = esc(degree==null?"":degree);
        String sc = esc(school==null?"":school);

        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "INSERT INTO education(user_id, degree, school) VALUES (" +
                userId + ", '" + dg + "', '" + sc + "')"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    public void close() {
        db.closeConnection();
    }
}
