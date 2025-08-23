<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Login - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <style>
    /* grid system for responsive columns */
    * {
      box-sizing: border-box;
    }

    html {
      font-family: "Lucida Sans", sans-serif;
    }

    body {
      background-color: #ffffff;
      margin: 0;
      color: #333333;
    }

    .row::after {
      content: "";
      clear: both;
      display: table;
    }

    /* mobile: 100% width columns */
    [class*="col-"] {
      float: left;
      width: 100%;
      padding: 15px;
    }

    /* desktop widths */
    @media only screen and (min-width: 768px) {
      .col-1  { width: 8.33%; }
      .col-2  { width: 16.66%; }
      .col-3  { width: 25%; }
      .col-4  { width: 33.33%; }
      .col-5  { width: 41.66%; }
      .col-6  { width: 50%; }
      .col-7  { width: 58.33%; }
      .col-8  { width: 66.66%; }
      .col-9  { width: 75%; }
      .col-10 { width: 83.33%; }
      .col-11 { width: 91.66%; }
      .col-12 { width: 100%; }
    }

    /* header */
    .header {
      background-color: #9933cc;
      color: #ffffff;
      padding: 15px;
      text-align: center;
    }

    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
    }

    /* taskbar with hover */
    .taskbar {
      background-color: #33b5e5;
      padding: 10px 15px;
    }

    .taskbar-nav {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      list-style: none;
      margin: 0;
      padding: 0;
      justify-content: center;
    }

    .taskbar-nav li {
      display: inline-block;
    }

    .taskbar-nav a {
      display: inline-block;
      text-decoration: none;
      color: #ffffff;
      padding: 8px 12px;
      border-radius: 4px;
      transition: background-color 0.2s ease, transform 0.1s ease;
    }

    .taskbar-nav a:hover {
      background-color: #0099cc;
      transform: translateY(-1px);
    }

    /* left menu */
    .menu ul {
      list-style-type: none;
      margin: 0;
      padding: 0;
    }

    .menu li {
      padding: 8px;
      margin-bottom: 7px;
      background-color: #33b5e5;
      color: #ffffff;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
      transition: background-color 0.2s ease;
    }

    .menu li:hover {
      background-color: #0099cc;
    }

    .menu li a {
      color: #ffffff;
      text-decoration: none;
      display: block;
    }

    /* right aside */
    .aside {
      background-color: #33b5e5;
      padding: 15px;
      color: #ffffff;
      text-align: center;
      font-size: 14px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
    }

    /* login card */
    .login-card {
      background-color: #f1f1f1;
      padding: 20px;
      border-radius: 8px;
      border: 1px solid #e2e2e2;
      box-shadow: 0 2px 10px rgba(0,0,0,0.10);
    }

    .login-card h2 {
      text-align: center;
      margin: 0 0 16px 0;
      font-size: 22px;
      color: #222222;
    }

    .form-group {
      margin-bottom: 15px;
    }

    .form-group label {
      display: block;
      margin-bottom: 5px;
      font-weight: 700;
      color: #555555;
    }

    .form-group input {
      width: 100%;
      padding: 10px;
      border: 1px solid #cccccc;
      border-radius: 4px;
      font-size: 14px;
      background: #ffffff;
    }

    .form-buttons {
      text-align: center;
      margin-top: 6px;
    }

    .btn-primary {
      background-color: #33b5e5;
      color: #ffffff;
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 700;
    }

    .btn-primary:hover {
      background-color: #0099cc;
    }

    .signup-link {
      text-align: center;
      margin-top: 15px;
    }

    .signup-link a {
      color: #33b5e5;
      text-decoration: none;
      font-weight: 700;
    }

    .signup-link a:hover {
      color: #0099cc;
      text-decoration: underline;
    }

    /* error/info container */
    .error-container {
      background-color: #ffffff;
      border-radius: 8px;
      border: 1px solid #e2e2e2;
      box-shadow: 0 2px 10px rgba(0,0,0,0.10);
      padding: 24px;
      text-align: center;
      margin-top: 8px;
    }

    .error-container h2 {
      color: #333333;
      margin-bottom: 12px;
      font-size: 20px;
    }

    .error-container p {
      color: #6F4E37;
      font-weight: bold;
      font-size: 14px;
    }

    .error-container a {
      text-decoration: none;
      color: #6F4E37;
      font-weight: bold;
    }

    /* footer */
    .footer {
      background-color: #0099cc;
      color: #ffffff;
      text-align: center;
      font-size: 12px;
      padding: 15px;
      margin-top: 10px;
    }
  </style>
</head>
<body>

  <!-- header -->
  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <!-- taskbar with hover -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="friendList.jsp">Friends</a></li>
      <li><a href="searchFriends.jsp">Search</a></li>
      <li><a href="singup.jsp">Register</a></li>
    </ul>
  </nav>

  <!-- three-column layout -->
  <div class="row">

    <!-- left menu (col-3 desktop; full width on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="welcomeMenu.jsp">Welcome</a></li>
        <li><a href="friendList.jsp">Friend List</a></li>
        <li><a href="searchFriends.jsp">Find Friends</a></li>
        <li><a href="singup.jsp">Create Account</a></li>
      </ul>
    </div>

    <!-- main content (col-6 desktop; full width on mobile) -->
    <div class="col-6 content">
      <div class="login-card">
        <h2>Login</h2>

<%
  // Read submitted credentials (if any)
  String userName = request.getParameter("userName");
  String userPass = request.getParameter("userPass");

  if (userName == null || userPass == null) {
%>
        <!-- show login form when no credentials were submitted -->
        <form action="loginHashing.jsp" method="post">
          <div class="form-group">
            <label for="userName">Email / Username</label>
            <input type="text" id="userName" name="userName" required />
          </div>
          <div class="form-group">
            <label for="userPass">Password</label>
            <input type="password" id="userPass" name="userPass" required />
          </div>
          <div class="form-buttons">
            <input type="submit" class="btn-primary" value="Login" />
          </div>
        </form>
        <div class="signup-link">
          <p>Don't have an account? <a href="singup.jsp">Register here</a></p>
        </div>
<%
  } else {
    // Authenticate and route according to role and page access
    applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
    ResultSet rs = null;
    try {
        rs = auth.authenticate(userName, userPass); // DB handles hashing
        if (rs != null && rs.next()) {
            long userId = rs.getLong("id");
            String name = rs.getString("name");

            // basic identity in session
            session.setAttribute("user", userName);
            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);
            session.setAttribute("name", name);

            // role code (ADMIN/USER)
            String role = auth.getUserRoleCode(userId);
            session.setAttribute("role", role);

            String userHome  = "welcomeMenu.jsp";
            String adminHome = "adminDashboard.jsp";

            if ("ADMIN".equalsIgnoreCase(role)) {
                boolean adminAllowed = auth.canUserAccessPage(userId, adminHome);
                if (adminAllowed) {
                    auth.setLastPage(userId, adminHome);
                    auth.close();
                    response.sendRedirect(adminHome);
                } else {
%>
        <div class="error-container">
          <h2>Access Denied</h2>
          <p>You don't have permission to access adminDashboard.jsp. <a href="loginHashing.jsp">Go back</a></p>
        </div>
<%
                    auth.close();
                }
            } else {
                boolean userAllowed = auth.canUserAccessPage(userId, userHome);
                if (userAllowed) {
                    auth.setLastPage(userId, userHome);
                    auth.close();
                    response.sendRedirect(userHome);
                } else {
%>
        <div class="error-container">
          <h2>Access Denied</h2>
          <p>You don't have permission to access <%= userHome %>. <a href="loginHashing.jsp">Go back</a></p>
        </div>
<%
                    auth.close();
                }
            }
        } else {
%>
        <div class="error-container">
          <h2>Login Failed</h2>
          <p>Invalid credentials. <a href="loginHashing.jsp">Try again</a></p>
        </div>
<%
            auth.close();
        }
    } catch (Exception ex) {
%>
        <div class="error-container">
          <h2>Error</h2>
          <p>Unexpected error during authentication. <a href="loginHashing.jsp">Try again</a></p>
        </div>
<%
        try { auth.close(); } catch (Exception ignore) {}
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
    }
  }
%>
      </div>
    </div>

    <!-- right aside (col-3 desktop; full width on mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Login Tips</h2>
        <p>Use your email or username with the correct password.</p>
        <h3>Forgot Password?</h3>
        <p>Contact support or your administrator.</p>
        <h3>New Here?</h3>
        <p>Create your account from the Register link.</p>
      </div>
    </div>

  </div>

  <!-- footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
