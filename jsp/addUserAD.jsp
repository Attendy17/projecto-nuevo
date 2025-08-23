<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%-- addUserAD.jsp · Admin-only user creation using DAO methods (no SQL in JSP) --%>

<%
  // Session/role guard (ADMIN only)
  Object u = session.getAttribute("user");
  String r = (String) session.getAttribute("role");
  if (u == null || r == null || !"ADMIN".equalsIgnoreCase(r)) {
      response.sendRedirect("loginHashing.jsp");
      return;
  }

  // Feedback messages
  String err = null;
  String ok  = null;

  // Handle POST
  boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
  if (isPost) {
      String name     = request.getParameter("name");
      String email    = request.getParameter("email");
      String pass     = request.getParameter("password");
      String confirm  = request.getParameter("confirm");
      String birth    = request.getParameter("birth");
      String gender   = request.getParameter("gender");
      String street   = request.getParameter("street");
      String town     = request.getParameter("town");
      String state    = request.getParameter("state");
      String country  = request.getParameter("country");
      String degree   = request.getParameter("degree");
      String school   = request.getParameter("school");
      String roleCode = request.getParameter("roleCode"); // ADMIN or USER

      if (name==null||email==null||pass==null||confirm==null||birth==null||gender==null||
          street==null||town==null||state==null||country==null||degree==null||school==null||
          roleCode==null) {
          err = "Missing fields.";
      } else if (!pass.equals(confirm)) {
          err = "Passwords do not match.";
      } else if (pass.length() < 6) {
          err = "Password must be at least 6 characters.";
      } else if (!( "ADMIN".equalsIgnoreCase(roleCode) || "USER".equalsIgnoreCase(roleCode) )) {
          err = "Invalid role.";
      } else {
          AdminConn dao = null;
          try {
              dao = new AdminConn();
              long newId = dao.createUserBasic(name, email, pass, birth, gender);
              if (newId <= 0) {
                  err = "Email already exists or could not create user.";
              } else {
                  boolean roleOK = dao.assignRoleToUser(newId, roleCode.toUpperCase());
                  boolean addrOK = dao.upsertAddress(newId, street, town, state, country);
                  boolean eduOK  = dao.addEducation(newId, degree, school);
                  if (roleOK) {
                      ok = "User created successfully (ID " + newId + ").";
                  } else {
                      err = "User created, but role assignment failed.";
                  }
              }
          } catch (Exception ex) {
              ex.printStackTrace();
              err = "Error creating user.";
          } finally {
              try { if (dao != null) dao.close(); } catch(Exception ignore){}
          }
      }
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Add User (Admin) - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    /* Grid (sample-based): mobile first */
    * {
      box-sizing: border-box;
    }
    html {
      font-family: "Lucida Sans", sans-serif;
    }
    .row::after {
      content: "";
      clear: both;
      display: table;
    }
    [class*="col-"] {
      width: 100%;
      float: left;
      padding: 15px;
    }
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

    /* Top taskbar (with hover) */
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

    /* Right aside */
    .aside {
      background-color: #33b5e5;
      padding: 15px;
      color: #ffffff;
      text-align: center;
      font-size: 14px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
    }

    /* Content + form styling */
    .content h1 {
      margin: 0 0 10px 0;
      font-size: 22px;
    }
    .card {
      background-color: #f7f9fb;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 16px;
      box-shadow: 0 1px 2px rgba(0,0,0,0.06), 0 1px 1px rgba(0,0,0,0.04);
    }
    .title {
      text-align: center;
      margin-bottom: 8px;
      font-size: 20px;
      font-weight: 700;
    }
    .msg {
      text-align: center;
      margin: 10px 0 2px 0;
      font-weight: 700;
      font-size: 13px;
    }
    .msg.ok {
      color: #2D6A2D;
    }
    .msg.error {
      color: #AA3333;
    }

    /* Sections inside the form */
    .section {
      border-top: 1px dashed #e2e2e2;
      padding: 10px 0 18px 0;
      margin-top: 12px;
    }
    .section:first-of-type {
      border-top: none;
      margin-top: 4px;
      padding-top: 6px;
    }
    .subtitle {
      color: #333333;
      font-size: 16px;
      margin: 6px 0 10px 0;
      font-weight: 700;
    }

    /* Two-column layout for inputs on desktop */
    .grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 12px 16px;
    }
    @media only screen and (min-width: 768px) {
      .grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    /* Inputs */
    .form-group {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .form-group label {
      font-weight: 700;
      color: #555555;
      font-size: 13px;
    }
    .form-group input,
    .form-group select {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #cccccc;
      border-radius: 8px;
      font-size: 14px;
      background: #ffffff;
      transition: border-color .15s, box-shadow .15s;
    }
    .form-group input:focus,
    .form-group select:focus {
      outline: none;
      border-color: #33b5e5;
      box-shadow: 0 0 0 3px rgba(51, 181, 229, .20);
    }

    /* Buttons */
    .form-buttons {
      display: flex;
      gap: 12px;
      flex-wrap: wrap;
      justify-content: space-between;
      margin-top: 10px;
      padding-top: 12px;
      border-top: 1px dashed #e2e2e2;
    }
    .btn {
      border: none;
      border-radius: 10px;
      padding: 10px 18px;
      cursor: pointer;
      font-size: 14px;
      font-weight: 700;
      box-shadow: 0 2px 10px rgba(0,0,0,.08);
      flex: 1 1 160px;
    }
    .btn-primary {
      background: #33b5e5;
      color: #ffffff;
    }
    .btn-primary:hover {
      background: #0099cc;
    }
    .btn-secondary {
      background: #e9ecef;
    }
    .btn-secondary:hover {
      background: #dfe3e7;
    }

    /* Footer */
    .footer {
      background-color: #0099cc;
      color: #ffffff;
      text-align: center;
      font-size: 12px;
      padding: 15px;
      margin-top: 10px;
    }

    /* Simple top link set above the card */
    .top-links {
      text-align: center;
      margin: 4px 0 10px 0;
    }
    .top-links a {
      color: #33b5e5;
      text-decoration: none;
      font-weight: 700;
      margin: 0 6px;
    }
    .top-links a:hover {
      color: #0099cc;
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

  <!-- Main layout -->
  <div class="row">

    <!-- Left menu (col-3 desktop) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="adminDashboard.jsp">Admin Dashboard</a></li>
        <li><a href="userList.jsp">Manage Users</a></li>
        <li><a href="addUserAD.jsp">Create New User</a></li>
        <li><a href="roles.jsp">Roles & Permissions</a></li>
      </ul>
    </div>

    <!-- Content (col-6 desktop) -->
    <div class="col-6 content">
      <h1>Add User (Admin)</h1>
      <div class="card">

        <div class="top-links">
          <a href="adminDashboard.jsp">← Back to Dashboard</a>
        </div>

        <h2 class="title">New Account</h2>

        <% if (err != null) { %>
          <div class="msg error"><%= err %></div>
        <% } %>
        <% if (ok  != null) { %>
          <div class="msg ok"><%= ok  %></div>
        <% } %>

        <form action="addUserAD.jsp" method="post" autocomplete="off">
          <!-- Role -->
          <div class="section">
            <div class="subtitle">Role</div>
            <div class="grid">
              <div class="form-group">
                <label for="roleCode">Assign role</label>
                <select id="roleCode" name="roleCode" required>
                  <option value="USER">USER</option>
                  <option value="ADMIN">ADMIN</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Basic Info -->
          <div class="section">
            <div class="subtitle">Basic Info</div>
            <div class="grid">
              <div class="form-group">
                <label for="name">Full name</label>
                <input type="text" id="name" name="name" maxlength="100" required />
              </div>
              <div class="form-group">
                <label for="email">Email (unique)</label>
                <input type="email" id="email" name="email" maxlength="100" required />
              </div>
              <div class="form-group">
                <label for="password">Password (min 6 chars)</label>
                <input type="password" id="password" name="password" required />
              </div>
              <div class="form-group">
                <label for="confirm">Confirm Password</label>
                <input type="password" id="confirm" name="confirm" required />
              </div>
              <div class="form-group">
                <label for="birth">Birth date</label>
                <input type="date" id="birth" name="birth" required />
              </div>
              <div class="form-group">
                <label for="gender">Gender</label>
                <select id="gender" name="gender" required>
                  <option value="">Select gender</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Address -->
          <div class="section">
            <div class="subtitle">Address</div>
            <div class="grid">
              <div class="form-group">
                <label for="street">Street</label>
                <input type="text" id="street" name="street" required />
              </div>
              <div class="form-group">
                <label for="town">Town</label>
                <input type="text" id="town" name="town" required />
              </div>
              <div class="form-group">
                <label for="state">State</label>
                <input type="text" id="state" name="state" required />
              </div>
              <div class="form-group">
                <label for="country">Country</label>
                <input type="text" id="country" name="country" required />
              </div>
            </div>
          </div>

          <!-- Education -->
          <div class="section">
            <div class="subtitle">Education</div>
            <div class="grid">
              <div class="form-group">
                <label for="degree">Degree</label>
                <select id="degree" name="degree" required>
                  <option value="">(none)</option>
                  <option value="High School Degree">High School Degree</option>
                  <option value="Bachelor's Degree">Bachelor's Degree</option>
                  <option value="Master's Degree">Master's Degree</option>
                  <option value="Doctorate Degree">Doctorate Degree</option>
                  <option value="Other">Other</option>
                </select>
              </div>
              <div class="form-group">
                <label for="school">School</label>
                <input type="text" id="school" name="school" required />
              </div>
            </div>
          </div>

          <!-- Buttons -->
          <div class="form-buttons">
            <input class="btn btn-primary" type="submit" value="Create User" />
            <input class="btn btn-secondary" type="reset" value="Reset" />
          </div>
        </form>
      </div>
    </div>

    <!-- Right aside (col-3 desktop) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Quick Tips</h2>
        <p>Passwords should be strong and at least 6 characters.</p>
        <h3>Roles</h3>
        <p>Assign <b>ADMIN</b> only to trusted accounts.</p>
        <h3>After Creation</h3>
        <p>Review the new user in the Users list.</p>
      </div>
    </div>

  </div>

  <!-- Footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
