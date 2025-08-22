package ut.JAR.CPEN410;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;

/**
 * AdminConn
 * ---------------------------------------------------------------------------
 * Admin DAO (Statement-based, sin PreparedStatement)
 * + Crear usuario y asignar rol (ADMIN/USER).
 */
public class AdminConn {

    private final MySQLCompleteConnector db;

    public AdminConn() {
        db = new MySQLCompleteConnector();
        db.doConnection();
    }

    /* ------------------------------ Helpers ------------------------------ */

    /** Escapa comillas simples para literales SQL. */
    private String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 8);
        for (char ch : s.toCharArray()) {
            if (ch == '\'') sb.append("''"); else sb.append(ch);
        }
        return sb.toString();
    }

    /* ===== NUEVO: helpers de usuario/rol ===== */

    /** Devuelve id de usuario por email, o -1 si no existe. */
    private long getUserIdByEmail(String email) {
        ResultSet rs = null;
        try {
            rs = db.doSelect("id", "users", "email='" + esc(email) + "' LIMIT 1");
            if (rs != null && rs.next()) return rs.getLong(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore){}
        }
        return -1;
    }

    /** Devuelve id de rol por code (ADMIN/USER), o -1 si no existe. */
    private long getRoleIdByCode(String code) {
        ResultSet rs = null;
        try {
            rs = db.doSelect("id", "roles", "code='" + esc(code) + "' LIMIT 1");
            if (rs != null && rs.next()) return rs.getLong(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore){}
        }
        return -1;
    }

    /** Crea rol si no existe y devuelve su id. */
    private long ensureRole(String code, String name) {
        long rid = getRoleIdByCode(code);
        if (rid > 0) return rid;

        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            s.executeUpdate("INSERT INTO roles(code,name) VALUES('" + esc(code) + "','" + esc(name) + "')");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
        return getRoleIdByCode(code);
    }

    /* ------------------------------- Users ------------------------------- */

    /** Lista simple de usuarios para el dashboard. */
    public ResultSet listUsers() {
        return db.doSelect(
            "id, name, email, birth_date, gender, profile_picture",
            "users"
        );
    }

    /** Obtiene a un usuario por id (básico). */
    public ResultSet getUserById(long userId) {
        String where = "id=" + userId + " LIMIT 1";
        return db.doSelect(
            "id, name, email, birth_date, gender, profile_picture",
            "users",
            where
        );
    }

    /**
     * NUEVO: Crea usuario (name,email,password hash, birth_date, gender).
     * Retorna el nuevo userId (>0) o -1 si email duplicado / error.
     */
    public long createUserBasic(String name, String email, String passwordPlain, String birthDate, String gender) {
        String nm = esc(name);
        String em = esc(email);
        String pw = esc(passwordPlain);
        String bd = esc(birthDate);
        String gd = esc(gender);

        // email único
        ResultSet rs = null;
        Statement s = null;
        try {
            rs = db.doSelect("COUNT(*)", "users", "email='" + em + "'");
            long cnt = 0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs = null; }
            if (cnt > 0) return -1;

            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "INSERT INTO users(name,email,password,birth_date,gender,profile_picture,last_page_id) VALUES (" +
                "'" + nm + "', '" + em + "', SHA2('" + pw + "',256), '" + bd + "', '" + gd + "', NULL, NULL)"
            );
            if (rows <= 0) return -1;

            // reobtén por email (email es único)
            return getUserIdByEmail(email);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            try { if (s  != null) s.close(); } catch (Exception ignore){}
        }
    }

    /**
     * NUEVO: Asigna un rol (ADMIN o USER) al usuario.
     * Crea el rol en 'roles' si no existe y evita duplicados en 'user_roles'.
     */
    public boolean assignRoleToUser(long userId, String roleCode) {
        String code = (roleCode == null ? "USER" : roleCode.trim().toUpperCase());
        String name = "ADMIN".equals(code) ? "Admin" : "User";

        long rid = ensureRole(code, name);
        if (rid <= 0) return false;

        ResultSet rs = null;
        Statement s = null;
        try {
            rs = db.doSelect("COUNT(*)", "user_roles", "user_id=" + userId + " AND role_id=" + rid);
            long cnt = 0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs = null; }
            if (cnt > 0) return true; // ya estaba

            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "INSERT INTO user_roles(user_id, role_id, dateAssign) VALUES (" +
                userId + ", " + rid + ", CURRENT_DATE())"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    /**
     * Actualiza nombre, email, birth_date, gender.
     * Verifica unicidad de email (permite mantener el mismo del usuario).
     */
    public boolean updateUserBasic(long userId, String name, String email, String birthDate, String gender) {
        String nm = esc(name);
        String em = esc(email);
        String bd = esc(birthDate);
        String gd = esc(gender);

        Statement s = null;
        ResultSet rs = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();

            rs = s.executeQuery("SELECT COUNT(*) FROM users WHERE email='" + em + "' AND id<>" + userId);
            long cnt = 0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs = null; }
            if (cnt > 0) {
                return false; // email duplicado
            }

            int rows = s.executeUpdate(
                "UPDATE users SET " +
                "name='" + nm + "', " +
                "email='" + em + "', " +
                "birth_date='" + bd + "', " +
                "gender='" + gd + "' " +
                "WHERE id=" + userId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore){}
            try { if (s != null)  s.close(); }  catch (Exception ignore){}
        }
    }

    /** Cambia la contraseña con SHA2. */
    public boolean changePassword(long userId, String newPlain) {
        String pw = esc(newPlain);
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "UPDATE users SET password=SHA2('" + pw + "',256) WHERE id=" + userId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    /** Actualiza la ruta de la foto de perfil. */
    public boolean updateProfilePicture(long userId, String relativePath) {
        String rp = esc(relativePath);
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "UPDATE users SET profile_picture='" + rp + "' WHERE id=" + userId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    /** Limpia (NULL) la foto de perfil. */
    public boolean clearProfilePicture(long userId) {
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "UPDATE users SET profile_picture=NULL WHERE id=" + userId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    /** Borra un usuario por id. */
    public boolean deleteUser(long userId) {
        Statement st = null;
        try {
            Connection c = db.getConnection();
            st = c.createStatement();
            int rows = st.executeUpdate("DELETE FROM users WHERE id=" + userId + ";");
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (st != null) st.close(); } catch (Exception ignore) {}
        }
    }

    /* ------------------------------ Address ------------------------------ */

    public ResultSet getAddress(long userId) {
        return db.doSelect(
            "street, town, state, country",
            "addresses",
            "user_id=" + userId + " LIMIT 1"
        );
    }

    public boolean upsertAddress(long userId, String street, String town, String state, String country) {
        String st  = esc(street  == null ? "" : street);
        String tw  = esc(town    == null ? "" : town);
        String stt = esc(state   == null ? "" : state);
        String co  = esc(country == null ? "" : country);

        Statement s = null;
        ResultSet rs = null;
        try {
            rs = db.doSelect("COUNT(*)", "addresses", "user_id=" + userId);
            long cnt = 0;
            if (rs != null && rs.next()) cnt = rs.getLong(1);
            if (rs != null) { rs.close(); rs = null; }

            Connection c = db.getConnection();
            s = c.createStatement();
            int rows;
            if (cnt > 0) {
                rows = s.executeUpdate(
                    "UPDATE addresses SET " +
                    "street='" + st + "', " +
                    "town='"   + tw + "', " +
                    "state='"  + stt + "', " +
                    "country='" + co + "' " +
                    "WHERE user_id=" + userId + ";"
                );
            } else {
                rows = s.executeUpdate(
                    "INSERT INTO addresses(user_id, street, town, state, country) VALUES (" +
                    userId + ", '" + st + "', '" + tw + "', '" + stt + "', '" + co + "');"
                );
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore) {}
        }
    }

    /* ------------------------------ Education ---------------------------- */

    public ResultSet listEducation(long userId) {
        String where = "user_id=" + userId + " ORDER BY id DESC";
        return db.doSelect(
            "id, degree, school",
            "education",
            where
        );
    }

    public boolean addEducation(long userId, String degree, String school) {
        String dg = esc(degree == null ? "" : degree);
        String sc = esc(school == null ? "" : school);

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

    public boolean updateEducation(long eduId, String degree, String school) {
        String dg = esc(degree == null ? "" : degree);
        String sc = esc(school == null ? "" : school);

        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "UPDATE education SET degree='" + dg + "', school='" + sc + "' WHERE id=" + eduId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    public boolean deleteEducation(long eduId) {
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "DELETE FROM education WHERE id=" + eduId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    /* ------------------------------- Photos ------------------------------ */

    public ResultSet getUserPhotos(long userId) {
        String where = "user_id=" + userId + " ORDER BY upload_date DESC";
        return db.doSelect(
            "id, image_url, upload_date",
            "images",
            where
        );
    }

    public boolean deletePhoto(long photoId) {
        Statement s = null;
        try {
            Connection c = db.getConnection();
            s = c.createStatement();
            int rows = s.executeUpdate(
                "DELETE FROM images WHERE id=" + photoId + ";"
            );
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (s != null) s.close(); } catch (Exception ignore){}
        }
    }

    /* ------------------------------ Lifecycle ---------------------------- */

    public void close() {
        db.closeConnection();
    }

    public MySQLCompleteConnector getConnector() {
        return db;
    }
}
