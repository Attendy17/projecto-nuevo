package ut.JAR.CPEN410;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * applicationDBAuthenticationGoodComplete
 * ---------------------------------------------------------------------------
 * Single entry-point (facade) for:
 *   User authentication with password hashing (MySQL SHA2(...,256))
 *   Role lookup (returns role CODE: "ADMIN" or "USER")
 *   Page-access validation (role  page via rolewebpagegood + webPageGood)
 *  Tracking last visited page (updates users.last_page_id)
 *
 * Design constraints (per course rules):
 *   All DB access is encapsulated here via MySQLCompleteConnector (Rule C.a)
 *   Uses Statement-based SQL only (NO PreparedStatement)
 *   Minimal string sanitation: escape single quotes using a manual helper
 */
public class applicationDBAuthenticationGoodComplete {

    /** Shared DB connector (kept open for this facade lifetime). */
    private final MySQLCompleteConnector myDBConn;

    /**
     * Constructor.
     * Opens the database connection and prepares an internal Statement.
     */
    public applicationDBAuthenticationGoodComplete() {
        System.out.println("applicationDBAuthenticationGoodComplete loaded.");
        myDBConn = new MySQLCompleteConnector();
        myDBConn.doConnection();
    }

    /* ________________________________ Helpers ________________________________ */

    /**
     * Escapes single quotes to make a safe SQL string literal
     * without using String.replace() (to match your coding constraints).
     * Example:  O'Neil  ->  O''Neil
     *
     * @param s input text
     * @return the same text with single quotes doubled
     */
    private String escapeQuotes(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char ch : s.toCharArray()) {
            if (ch == '\'') sb.append("''"); else sb.append(ch);
        }
        return sb.toString();
    }

    /* _____________________________ Authentication ____________________________ */

    /**
     * Authenticates a user by email and password.
     * The comparison is done in MySQL using SHA2(<plain>, 256).
     *
     * @param email    user email (plain text)
     * @param userPass user password (plain text)
     * @return ResultSet with columns (id, email, name) if a match exists; otherwise empty
     */
    public ResultSet authenticate(String email, String userPass) {
        String em = escapeQuotes(email);
        String pw = escapeQuotes(userPass);
        String fields = "id, email, name";
        String table  = "users";
        String where  = "email='" + em + "' AND password=SHA2('" + pw + "',256)";
        System.out.println("authenticate ? " + where);
        return myDBConn.doSelect(fields, table, where);
    }

    /* _______________________________ Role Lookup _____________________________ */

    /**
     * Returns the user's role CODE (e.g., "ADMIN", "USER") as stored in roles.code.
     * IMPORTANT: This method uses roles.code, not roles.name.
     *
     * @param userId database id of the user
     * @return role code string (ADMIN/USER) or empty string if none
     */
    public String getUserRoleCode(long userId) {
        String roleCode = "";
        try {
            String fields = "r.code";
            String tables = "roles r, user_roles ur";
            String where  = "r.id=ur.role_id AND ur.user_id=" + userId;

            ResultSet rs = myDBConn.doSelect(fields, tables, where);
            if (rs != null && rs.next()) {
                roleCode = rs.getString(1);
                rs.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return roleCode == null ? "" : roleCode;
    }

    /* __________________________________ Sign-up ______________________________ */

    /**
     * Inserts a new user and ensures the USER role is assigned.
     * Expects birthDate as 'YYYY-MM-DD' and gender  {'Male','Female','Other'}.
     *
     * @param email        user email
     * @param completeName full name
     * @param userPass     plain password (will be hashed in SQL)
     * @param birthDate    YYYY-MM-DD
     * @param gender       Male/Female/Other
     * @return true if the user exists after the operation; false otherwise
     */
    public boolean addUser(String email,
                           String completeName,
                           String userPass,
                           String birthDate,
                           String gender) {
        String em = escapeQuotes(email);
        String nm = escapeQuotes(completeName);
        String pw = escapeQuotes(userPass);
        String bd = escapeQuotes(birthDate);
        String gd = escapeQuotes(gender);

        // (1) Insert the user with SHA2 hash
        String tableCols = "users(name,email,password,birth_date,gender,profile_picture,last_page_id)";
        String values    = "'" + nm + "', '" + em + "', SHA2('" + pw + "',256), '" + bd + "', '" + gd + "', NULL, NULL";
        boolean executed = myDBConn.doInsert(tableCols, values);

        // Statement.execute() (used by your connector overload) can return false even if it succeeded.
        // Re-select the user id to confirm persistence:
        long userId = getUserIdByEmail(em);
        if (userId <= 0) {
            System.out.println("addUser: user insert may have failed.");
            return false;
        }

        // (2) Ensure USER role exists and link it to this user
        long roleUserId = getRoleIdByCode("USER");
        if (roleUserId <= 0) {
            // Create USER role if absent
            myDBConn.doInsert("roles(code,name)", "'USER','User'");
            roleUserId = getRoleIdByCode("USER");
        }
        if (roleUserId > 0) {
            // Link if not already present
            String existsWhere = "user_id=" + userId + " AND role_id=" + roleUserId;
            ResultSet rs = myDBConn.doSelect("COUNT(*)", "user_roles", existsWhere);
            long c = 0;
            try {
                if (rs.next()) c = rs.getLong(1);
                rs.getStatement().close();
            } catch (SQLException e) { e.printStackTrace(); }

            if (c == 0) {
                myDBConn.doInsert("user_roles(user_id, role_id, dateAssign)",
                                  userId + "," + roleUserId + ", CURRENT_DATE()");
            }
        }
        return true;
    }

    /**
     * Helper: returns user id by email, or -1 if not found.
     *
     * @param email user email
     * @return database id or -1
     */
    private long getUserIdByEmail(String email) {
        ResultSet rs = myDBConn.doSelect("id", "users", "email='" + email + "'");
        try {
            if (rs != null && rs.next()) {
                long id = rs.getLong(1);
                rs.close();
                return id;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    /**
     * Helper: returns role id by role code (e.g., "USER"), or -1 if not found.
     *
     * @param code role code string
     * @return role id or -1
     */
    private long getRoleIdByCode(String code) {
        ResultSet rs = myDBConn.doSelect("id", "roles", "code='" + code + "'");
        try {
            if (rs != null && rs.next()) {
                long id = rs.getLong(1);
                rs.close();
                return id;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    /* ________________________ Page Access & Last Page ________________________ */

    /**
     * Checks whether the given user can access the provided pageURL.
     * The rule is enforced through rolewebpagegood (role-page mapping) and webPageGood.
     *
     * @param userId  database id of the user
     * @param pageURL exact URL name as stored in webPageGood.pageURL (e.g., "welcomeMenu.jsp")
     * @return true if the user's role grants access to this page; false otherwise
     */
    public boolean canUserAccessPage(long userId, String pageURL) {
        String url = escapeQuotes(pageURL);

        String fields = "COUNT(*)";
        String tables = "user_roles ur, roles r, rolewebpagegood rw, webPageGood w";
        String where  = "ur.role_id=r.id AND rw.role_id=r.id AND rw.page_id=w.id " +
                        "AND ur.user_id=" + userId + " AND w.pageURL='" + url + "'";

        long c = 0;
        try {
            ResultSet rs = myDBConn.doSelect(fields, tables, where);
            if (rs != null && rs.next()) c = rs.getLong(1);
            if (rs != null) rs.close();
        } catch (SQLException e) { e.printStackTrace(); }
        return c > 0;
    }

    /**
     * Updates users.last_page_id to the id of the provided pageURL (if found).
     * If no page record exists for the given URL, no action is taken.
     *
     * @param userId  database id of the user
     * @param pageURL exact URL name as stored in webPageGood.pageURL
     */
    public void setLastPage(long userId, String pageURL) {
        String url = escapeQuotes(pageURL);

        // (1) Resolve page id by URL
        ResultSet rs = myDBConn.doSelect("id", "webPageGood", "pageURL='" + url + "'");
        long pid = -1;
        try {
            if (rs != null && rs.next()) pid = rs.getLong(1);
            if (rs != null) rs.close();
        } catch (SQLException e) { e.printStackTrace(); }

        // (2) Update users.last_page_id if a valid page id exists
        if (pid > 0) {
            try {
                // Direct UPDATE via the underlying Statement (your connector exposes it)
                myDBConn.getStatement().executeUpdate(
                    "UPDATE users SET last_page_id=" + pid + " WHERE id=" + userId + ";"
                );
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /* ____________________________________ Misc __________________________________ */

    /**
     * Returns auxiliary user data (currently last_page_id) for the given email.
     *
     * @param email user email
     * @return ResultSet with column last_page_id (or empty if not found)
     */
    public ResultSet getUserData(String email) {
        String em = escapeQuotes(email);
        return myDBConn.doSelect("last_page_id", "users", "email='" + em + "'");
    }

    /**
     * Closes the underlying Statement and Connection.
     * Call this at the end of each JSP/Servlet using this facade.
     */
    public void close() {
        myDBConn.closeConnection();
    }
}
