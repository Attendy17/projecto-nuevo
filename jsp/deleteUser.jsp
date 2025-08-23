<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%-- deleteUser.jsp · Admin deletes a user ID via DAO; simple messages rendered below --%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Delete User - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
   
    * {
      box-sizing: border-box;
    }

    html {
      font-family: "Lucida Sans", sans-serif;
    }

    body {
      margin: 0;
      background: #f8f9fa;
      color: #333333;
    }

    .row::after {
      content: "";
      clear: both;
      display: table;
    }

    /* Mobile default: columns are full width */
    [class*="col-"] {
      width: 100%;
      float: left;
      padding: 15px;
    }

    /* Desktop widths */
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

    /* Header */
    .header {
      background-color: #9933cc;
      color: #ffffff;
      padding: 15px;
    }

    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
      text-align: center;
    }

    /* Top taskbar with hover */
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
      background-color: #0099cc; /* requested hover */
      transform: translateY(-1px);
    }

    /* Left menu */
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
      box-shadow:
        0 1px 3px rgba(0,0,0,0.12),
        0 1px 2px rgba(0,0,0,0.24);
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

    /* Right aside */
    .aside {
      background-color: #33b5e5;
      padding: 15px;
      color: #ffffff;
      text-align: center;
      font-size: 14px;
      box-shadow:
        0 1px 3px rgba(0,0,0,0.12),
        0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
    }

    /* Main content and status card */
    .content h1 {
      margin: 0 0 10px 0;
      font-size: 22px;
    }

    .card {
      background-color: #ffffff;
      border: 1px solid #e2e2e2;
      border-radius: 10px;
      padding: 16px;
      box-shadow: 0 2px 10px rgba(0,0,0,.08);
    }

    .title {
      text-align: center;
      margin-bottom: 8px;
      font-size: 20px;
      font-weight: 700;
      color: #222222;
    }

    .msg {
      margin: 14px 0;
      text-align: center;
      font-weight: 700;
    }

    .ok {
      color: #2d6a2d;
    }

    .err {
      color: #aa3333;
    }

    .actions {
      display: flex;
      gap: 10px;
      justify-content: center;
      margin-top: 16px;
      flex-wrap: wrap;
    }

    .btn {
      display: inline-block;
      padding: 10px 16px;
      border-radius: 8px;
      border: 1px solid #e2e2e2;
      background: #e9ecef;
      color: #333333;
      text-decoration: none;
      font-weight: 700;
      min-width: 160px;
      text-align: center;
      transition: background-color 0.2s ease;
    }

    .btn:hover {
      background: #dfe3e7;
    }

    /* Footer (same style family as sample) */
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

  <!-- Header -->
  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <!-- Taskbar with hover -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="adminDashboard.jsp">Dashboard</a></li>
      <li><a href="userList.jsp">Users</a></li>
      <li><a href="addUserAD.jsp">Add User</a></li>
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="logout.jsp">Logout</a></li>
    </ul>
  </nav>

  <!-- Main three-column layout (menu · content · aside) -->
  <div class="row">

    <!-- Left menu (col-3 desktop; full width on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="adminDashboard.jsp">Admin Dashboard</a></li>
        <li><a href="userList.jsp">Manage Users</a></li>
        <li><a href="roles.jsp">Roles &amp; Permissions</a></li>
        <li><a href="auditLogs.jsp">Audit Logs</a></li>
      </ul>
    </div>

    <!-- Content (col-6 desktop; full width on mobile) -->
    <div class="col-6 content">
      <h1>Delete User</h1>
      <div class="card">
        <div class="title">Execute Deletion</div>

        <div class="msg">
<%
    // Sign-in check
    Long adminId = (Long) session.getAttribute("userId");
    if (adminId == null) {
%>
          <div class="err">You must be signed in.</div>
          <div class="actions">
            <a class="btn" href="loginHashing.jsp">Go to Login</a>
          </div>
<%
    } else {
        // Page-level ACL and last page tracking
        applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
        String pageName = "deleteUser.jsp";
        boolean allowed = auth.canUserAccessPage(adminId, pageName);
        if (allowed) {
            auth.setLastPage(adminId, pageName);
        }

        if (!allowed) {
            try { auth.close(); } catch (Exception ignore) {}
%>
          <div class="err">Access denied.</div>
          <div class="actions">
            <a class="btn" href="welcomeMenu.jsp">Go to Home</a>
          </div>
<%
        } else {
            // Parse and validate ?id; prevent self-deletion; call DAO
            String idParam = request.getParameter("id");
            boolean ok = false;
            String message = "";

            if (idParam != null && idParam.matches("\\d+")) {
                long targetId = Long.parseLong(idParam);

                if (targetId == adminId.longValue()) {
                    ok = false;
                    message = "You cannot delete your own account.";
                } else {
                    AdminConn dao = new AdminConn();
                    try {
                        ok = dao.deleteUser(targetId);
                        message = ok ? "User deleted successfully." : "User not found or not deleted.";
                    } catch (Exception e) {
                        ok = false;
                        message = "Error deleting user.";
                    } finally {
                        try { dao.close(); } catch (Exception ignore) {}
                    }
                }
            } else {
                ok = false;
                message = "Invalid or missing user id.";
            }

            try { auth.close(); } catch (Exception ignore) {}
%>
          <div class="<%= (ok ? "ok" : "err") %>"><%= message %></div>
          <div class="actions">
            <a class="btn" href="adminDashboard.jsp">Back to Admin Dashboard</a>
          </div>
<%
        }
    }
%>
        </div>
      </div>
    </div>

    <!-- Right aside (col-3 desktop; full width on mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Quick Notes</h2>
        <p>Deleting a user is irreversible. Ensure the ID is correct before proceeding.</p>
        <h3>Tip</h3>
        <p>Consider disabling an account instead of deleting if you need an audit trail.</p>
      </div>
    </div>

  </div>

  <!-- Footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
