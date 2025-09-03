package ut.JAR.CPEN410;

import java.sql.*;

/* MySQLCompleteConnector is a utility class for managing a connection to a MySQL database.
 * It provides methods for establishing a connection, executing SELECT and INSERT queries,
 * and closing the connection.
 *
 * <p>Configure the DB_URL, USER, and PASS fields as needed for your environment.</p>
 */
public class MySQLCompleteConnector {

    // Database URL (schema 'cpen410p1') with parameters to avoid "Public Key Retrieval is not allowed".
    // Adjust host/port if needed.
    private String DB_URL =
        "jdbc:mysql://localhost:3306/cpen410p1"
      + "?useUnicode=true"
      + "&characterEncoding=UTF-8"
      + "&serverTimezone=UTC"
      + "&allowPublicKeyRetrieval=true"
      + "&useSSL=false";

    // Credentials (adjust to your environment)
    private String USER = "root";
    private String PASS = "1234";

    // JDBC Connection and Statement objects.
    private Connection conn;
    private Statement stmt;

    /* Constructor initializes the connection and statement objects to null.
     */
    public MySQLCompleteConnector() {
        conn = null;
        stmt = null;
    }

    /* Establishes a connection to the MySQL database.
     *
     * <p>This method registers the JDBC driver, connects to the database using the specified
     * DB_URL, USER, and PASS, and creates a Statement object for executing queries.</p>
     */
    public void doConnection() {
        try {
            // Load driver (prefer Connector/J 8; fallback to legacy if available)
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
            } catch (ClassNotFoundException e) {
                // Compatibility with older jars
                Class.forName("com.mysql.jdbc.Driver");
            }

            System.out.println("Connecting to database...");
            conn = DriverManager.getConnection(DB_URL, USER, PASS);
            System.out.println("Creating statement...");
            stmt = conn.createStatement();
            System.out.println("Statement OK...");
        } catch(Exception e) {
            // Log stack trace and ensure objects are null
            e.printStackTrace();
            conn = null;
            stmt = null;
        }
    }

    /* Returns the current Connection object.
     *
     * @return the Connection object used by this connector.
     */
    public Connection getConnection() {
        return conn;
    }

    /* Returns the current Statement object.
     * (Some of your classes need this, e.g., setLastPage()).
     *
     * @return the Statement object used by this connector.
     */
    public Statement getStatement() {
        return stmt;
    }

    /* Closes the Statement and Connection objects to free up resources.
     */
    public void closeConnection() {
        try {
            if (stmt != null)
                stmt.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
        try {
            if (conn != null)
                conn.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
        stmt = null;
        conn  = null;
    }

    /* Executes a SELECT query with a WHERE clause.
     *
     * @param fields the fields to select.
     * @param tables the table(s) from which to select.
     * @param where  the WHERE clause to filter results.
     * @return a ResultSet containing the query results.
     */
    public ResultSet doSelect(String fields, String tables, String where) {
        ResultSet result = null;
        String selectionStatement = "SELECT " + fields + " FROM " + tables + " WHERE " + where + ";";
        System.out.println(selectionStatement);
        try {
            if (stmt != null) {
                result = stmt.executeQuery(selectionStatement);
            } else {
                System.err.println("doSelect: Statement is null (no connection).");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /* Executes a SELECT query without a WHERE clause.
     *
     * @param fields the fields to select.
     * @param tables the table(s) from which to select.
     * @return a ResultSet containing the query results.
     */
    public ResultSet doSelect(String fields, String tables) {
        ResultSet result = null;
        String selectionStatement = "SELECT " + fields + " FROM " + tables + ";";
        System.out.println(selectionStatement);
        try {
            if (stmt != null) {
                result = stmt.executeQuery(selectionStatement);
            } else {
                System.err.println("doSelect: Statement is null (no connection).");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /* Executes an INSERT query without specifying column names.
     *
     * <p>This method is less recommended because it relies on the table structure.</p>
     *
     * @param table  the table into which data will be inserted. (You may pass "table(col1,col2,...)")
     * @param values the values to insert.
     * @return true if the insertion executed successfully (execute() returned without exception), false otherwise.
     */
    public boolean doInsert(String table, String values) {
        boolean res = false;
        String insertionStatement = "INSERT INTO " + table + " VALUES (" + values + ");";
        System.out.println(insertionStatement);
        try {
            if (stmt != null) {
                // Note: execute() returns true if there is a ResultSet; for INSERT it usually returns false.
                // Your higher-level logic re-validates with a subsequent SELECT, so we keep this behavior.
                res = stmt.execute(insertionStatement);
                System.out.println("Insertion executed (execute() returned): " + res);
            } else {
                System.err.println("doInsert: Statement is null (no connection).");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return res;
    }

    /* Executes an INSERT query by specifying column names and using executeUpdate().
     *
     * <p>This method is recommended as it explicitly states the columns being inserted.</p>
     *
     * @param table   the table into which data will be inserted.
     * @param columns the columns for which data will be inserted.
     * @param values  the values to insert.
     * @return true if one or more rows were inserted successfully, false otherwise.
     */
    public boolean doInsert(String table, String columns, String values) {
        boolean res = false;
        String insertionStatement = "INSERT INTO " + table + " (" + columns + ") VALUES (" + values + ");";
        System.out.println(insertionStatement);
        try {
            if (stmt != null) {
                int rows = stmt.executeUpdate(insertionStatement);
                System.out.println("Rows inserted: " + rows);
                res = (rows > 0);
            } else {
                System.err.println("doInsert (3-params): Statement is null (no connection).");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return res;
    }
}

