package ut.JAR.CPEN410;

import java.sql.*;

/**
 * MySQLCompleteConnector is a utility class for managing a connection to a MySQL database.
 * It provides methods for establishing a connection, executing SELECT and INSERT queries,
 * and closing the connection.
 *
 * <p>Configure the DB_URL, USER, and PASS fields as needed for your environment.</p>
 */
public class MySQLCompleteConnector {

    // Database URL updated to the schema 'cpen410p1'
    private String DB_URL = "jdbc:mysql://localhost/cpen410p1";
    // If you use the root user with password 1234, update these credentials as needed:
    private String USER = "root";
    private String PASS = "1234";

    // JDBC Connection and Statement objects.
    private Connection conn;
    private Statement stmt;

    /**
     * Constructor initializes the connection and statement objects to null.
     */
    public MySQLCompleteConnector() {
        conn = null;
        stmt = null;
    }

    /**
     * Establishes a connection to the MySQL database.
     *
     * <p>This method registers the JDBC driver, connects to the database using the specified
     * DB_URL, USER, and PASS, and creates a Statement object for executing queries.</p>
     */
    public void doConnection() {
        try {
            // Register the JDBC driver.
            // For recent versions, it is recommended to use "com.mysql.cj.jdbc.Driver".
            Class.forName("com.mysql.jdbc.Driver")
                 .getDeclaredConstructor()
                 .newInstance();
            System.out.println("Connecting to database...");
            conn = DriverManager.getConnection(DB_URL, USER, PASS);
            System.out.println("Creating statement...");
            stmt = conn.createStatement();
            System.out.println("Statement OK...");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Returns the current Connection object.
     *
     * @return the Connection object used by this connector.
     */
    public Connection getConnection() {
        return conn;
    }

    /**
     * Closes the Statement and Connection objects to free up resources.
     */
    public void closeConnection() {
        try {
            if (stmt != null)
                stmt.close();
            if (conn != null)
                conn.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Executes a SELECT query with a WHERE clause.
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
            result = stmt.executeQuery(selectionStatement);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Executes a SELECT query without a WHERE clause.
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
            result = stmt.executeQuery(selectionStatement);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Executes an INSERT query without specifying column names.
     *
     * <p>This method is less recommended because it relies on the table structure.</p>
     *
     * @param table  the table into which data will be inserted.
     * @param values the values to insert.
     * @return true if the insertion executed successfully, false otherwise.
     */
    public boolean doInsert(String table, String values) {
        boolean res = false;
        String insertionStatement = "INSERT INTO " + table + " VALUES (" + values + ");";
        System.out.println(insertionStatement);
        try {
            res = stmt.execute(insertionStatement);
            System.out.println("Insertion executed: " + res);
        } catch(Exception e) {
            e.printStackTrace();
        }
        return res;
    }

    /**
     * Executes an INSERT query by specifying column names and using executeUpdate().
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
            int rows = stmt.executeUpdate(insertionStatement);
            System.out.println("Rows inserted: " + rows);
            res = (rows > 0);
        } catch(Exception e) {
            e.printStackTrace();
        }
        return res;
    }
}
