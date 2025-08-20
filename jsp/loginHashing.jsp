<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login - MiniFacebook</title>
  <style>
    /* (Style kept exactly as provided) */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html {
      font-family: "Lucida Sans", sans-serif;
    }

    body {
      background-color: #ffffff;
      margin: 0;
      padding: 0;
    }

    .row::after {
      content: "";
      clear: both;
      display: table;
    }

    [class*="col-"] {
      float: left;
      width: 100%;
      padding: 15px;
    }

    @media only screen and (min-width: 768px) {
      .col-1 {width: 8.33%;}
      .col-2 {width: 16.66%;}
      .col-3 {width: 25%;}
      .col-4 {width: 33.33%;}
      .col-5 {width: 41.66%;}
      .col-6 {width: 50%;}
      .col-7 {width: 58.33%;}
      .col-8 {width: 66.66%;}
      .col-9 {width: 75%;}
      .col-10 {width: 83.33%;}
      .col-11 {width: 91.66%;}
      .col-12 {width: 100%;}
    }

    .header {
      background-color: #999fff;
      color: white;
      padding: 15px;
      text-align: center;
    }

    .login-box {
      background-color: #f1f1f1;
      padding: 20px;
      border-radius: 5px;
      box-shadow: 0 0 10px #ccc;
    }

    .login-box h2 {
      text-align: center;
      margin-bottom: 20px;
    }

    .form-group {
      margin-bottom: 15px;
    }

    .form-group label {
      display: block;
      margin-bottom: 5px;
    }

    .form-group input {
      width: 100%;
      padding: 8px;
      border: 1px solid #ccc;
      border-radius: 3px;
    }

    .form-buttons {
      text-align: center;
    }

    .form-buttons input[type="submit"] {
      background-color: #33b5e5;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 3px;
      cursor: pointer;
    }

    .form-buttons input[type="submit"]:hover {
      background-color: #0099cc;
    }

    .signup-link {
      text-align: center;
      margin-top: 15px;
    }

    .signup-link a {
      color: #33b5e5;
      text-decoration: none;
    }

    .signup-link a:hover {
      color: #0099cc;
    }

    .error-container {
      background-color: #fff;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      padding: 40px;
      text-align: center;
    }

    .error-container h2 {
      color: #333;
      margin-bottom: 20px;
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
  </style>
</head>
<body>
  <!-- Page header (kept as-is) -->
  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="login-box">
        <h2>Login</h2>
<%
  //________________________________________________________________
  // Read submitted credentials (if any). If null, show the login form.
  // The form posts back to this same JSP (loginHashing.jsp).
  //
  String userName = request.getParameter("userName");
  String userPass = request.getParameter("userPass");

  if (userName == null || userPass == null) {
%>
        <!-- Render login form when there are no submitted credentials yet -->
        <form action="loginHashing.jsp" method="post">
          <div class="form-group">
            <label for="userName">Email / Username:</label>
            <input type="text" id="userName" name="userName" required />
          </div>
          <div class="form-group">
            <label for="userPass">Password:</label>
            <input type="password" id="userPass" name="userPass" required />
          </div>
          <div class="form-buttons">
            <input type="submit" value="Login">
          </div>
        </form>
        <div class="signup-link">
          <p>Don't have an account? <a href="newUser.html">Register here</a></p>
        </div>
<%
  } else {
    // _____________________________________________________________
    // Credentials were submitted. We now authenticate against the DB,
    // obtain the user's role CODE (ADMIN/USER), validate page access,
    // and update last_page_id if allowed.
    // DB access is encapsulated in the Java class (per course rules).
    // 
    applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
    ResultSet rs = auth.authenticate(userName, userPass);  // uses SHA2 hashing in SQL

    if (rs != null && rs.next()) {
      // Pull minimal user profile
      long userId = rs.getLong("id");
      String name = rs.getString("name");
      // Close the statement behind this ResultSet to avoid leaks
      

      // Save identity in the session for subsequent pages
      session.setAttribute("user", userName);
      session.setAttribute("userId", userId);
      session.setAttribute("userName", userName);
      session.setAttribute("name", name);

      // IMPORTANT: get role CODE ('ADMIN' or 'USER'), not display name
      String role = auth.getUserRoleCode(userId);
      session.setAttribute("role", role);

      // Target pages (must exist in webPageGood.pageURL exactly as written)
      String userHome  = "welcomeMenu.jsp";
      String adminHome = "adminDashboard.jsp";

      if ("ADMIN".equalsIgnoreCase(role)) {
        // Validate ADMIN's access to admin dashboard via rolewebpagegood
        boolean adminAllowed = auth.canUserAccessPage(userId, adminHome);
        if (adminAllowed) {
          // Track last visited page
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
        // Validate USER's access to the user home page
        boolean userAllowed = auth.canUserAccessPage(userId, userHome);
        if (userAllowed) {
          // Track last visited page
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
      // Authentication failed (no match for email+hashed password)
%>
        <div class="error-container">
          <h2>Login Failed</h2>
          <p>Invalid credentials. <a href="loginHashing.jsp">Try again</a></p>
        </div>
<%
      auth.close();
    }
  }
%>
      </div>
    </div>
    <div class="col-3"></div>
  </div>
</body>
</html>
