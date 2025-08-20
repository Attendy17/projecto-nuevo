<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Add New User - Admin Panel</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      body {
        font-family: Arial, sans-serif;
        background-color: #f8f9fa;
        font-size: 14px;
        padding: 20px;
      }
      .taskbar {
        background-color: #6F4E37;
        color: #fff;
        padding: 10px 20px;
        text-align: center;
        margin-bottom: 20px;
      }
      .nav-bar {
        display: flex;
        flex-direction: column;
        gap: 10px;
        background-color: #6F4E37;
        padding: 10px 20px;
        margin-bottom: 20px;
      }
      .nav-left {
        font-size: 18px;
        font-weight: bold;
        color: #fff;
      }
      .nav-right {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
      .nav-right a {
        color: #fff;
        text-decoration: none;
        font-weight: bold;
        padding: 6px 10px;
        border-radius: 4px;
        transition: background-color 0.3s ease;
      }
      .nav-right a:hover {
        background-color: #8c6d54;
      }

      .container {
        background-color: #fff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        max-width: 800px;
        margin: 0 auto;
      }
      .container h2 {
        text-align: center;
        margin-bottom: 20px;
        color: #333;
      }
      .section {
        margin-bottom: 20px;
      }
      .section h2 {
        font-size: 16px;
        color: #333;
        margin-bottom: 10px;
      }
      .form-group {
        margin-bottom: 15px;
      }
      .form-group label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
        color: #555;
      }
      .form-group input,
      .form-group select {
        width: 100%;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 4px;
      }
      .form-group input[type="checkbox"] {
        width: auto;
        margin-left: 5px;
      }
      .form-buttons {
        text-align: center;
        margin-top: 20px;
      }
      .form-buttons input[type="submit"] {
        background-color: #4e310c;
        color: #fff;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
      }

      /* Tablet layout - 600px columns */
      @media only screen and (min-width: 600px) {
        .nav-bar {
          flex-direction: row;
          justify-content: space-between;
          align-items: center;
        }
        .nav-right {
          flex-direction: row;
          flex-wrap: wrap;
        }
        .col-1 { width: 8.33%; }
        .col-2 { width: 16.66%; }
        .col-3 { width: 25%; }
        .col-4 { width: 33.33%; }
        .col-5 { width: 41.66%; }
        .col-6 { width: 50%; }
        .col-7 { width: 58.33%; }
        .col-8 { width: 66.66%; }
        .col-9 { width: 75%; }
        .col-10 { width: 83.33%; }
        .col-11 { width: 91.66%; }
        .col-12 { width: 100%; }
      }

      /* Desktop layout - 768px columns */
      @media only screen and (min-width: 768px) {
        .col-1 { width: 8.33%; }
        .col-2 { width: 16.66%; }
        .col-3 { width: 25%; }
        .col-4 { width: 33.33%; }
        .col-5 { width: 41.66%; }
        .col-6 { width: 50%; }
        .col-7 { width: 58.33%; }
        .col-8 { width: 66.66%; }
        .col-9 { width: 75%; }
        .col-10 { width: 83.33%; }
        .col-11 { width: 91.66%; }
        .col-12 { width: 100%; }
      }
    </style>
  </head>
  <body>
<%
 
  Object user = session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("loginHashing.html");
    return;
  }

  String role = (String) session.getAttribute("role");
  if (role == null || !role.equalsIgnoreCase("admin")) {
    out.println("<h2>Access denied: You do not have permission to access this page.</h2>");
    return;
  }
%>

    <div class="taskbar">
      <h1>minifacebook</h1>
    </div>
    <div class="nav-bar">
      <div class="nav-left">Add New User - Admin Panel</div>
      <div class="nav-right">
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="signout.jsp">Sign Out</a>
      </div>
    </div>

    <div class="container">
      <h2>Add New User</h2>
      <form action="addUserAdminResult.jsp" method="post">
        <div class="section">
          <h2>Basic Information</h2>
          <div class="form-group">
            <label for="name">Full Name:</label>
            <input type="text" id="name" name="name" required />
          </div>
          <div class="form-group">
            <label for="email">Email (Username):</label>
            <input type="email" id="email" name="email" required />
          </div>
          <div class="form-group">
            <label for="userPass">Password:</label>
            <input type="password" id="userPass" name="userPass" required />
          </div>
          <div class="form-group">
            <label for="birthDate">Birth Date:</label>
            <input type="date" id="birthDate" name="birthDate" required />
          </div>
          <div class="form-group">
            <label for="gender">Gender:</label>
            <select id="gender" name="gender" required>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
              <option value="Other">Other</option>
            </select>
          </div>
          <div class="form-group">
            <label for="isAdmin">Administrator?</label>
            <input type="checkbox" id="isAdmin" name="isAdmin" value="true" />
          </div>
        </div>

        <div class="section">
          <h2>Address</h2>
          <div class="form-group">
            <label for="street">Street:</label>
            <input type="text" id="street" name="street" required />
          </div>
          <div class="form-group">
            <label for="town">Town:</label>
            <input type="text" id="town" name="town" required />
          </div>
          <div class="form-group">
            <label for="state">State:</label>
            <input type="text" id="state" name="state" required />
          </div>
          <div class="form-group">
            <label for="country">Country:</label>
            <input type="text" id="country" name="country" required />
          </div>
        </div>

        <div class="section">
          <h2>Education</h2>
          <div class="form-group">
            <label for="degree">Degree:</label>
            <select id="degree" name="degree" required>
              <option value="">Select a degree</option>
              <option value="High School Degree">High School Degree</option>
              <option value="Bachelor's Degree">Bachelor's Degree</option>
              <option value="Master's Degree">Master's Degree</option>
              <option value="Doctorate Degree">Doctorate Degree</option>
              <option value="Other">Other</option>
            </select>
          </div>
          <div class="form-group">
            <label for="school">School:</label>
            <input type="text" id="school" name="school" required />
          </div>
        </div>

        <div class="form-buttons">
          <input type="submit" value="Add User" />
        </div>
      </form>
    </div>
  </body>
</html>
