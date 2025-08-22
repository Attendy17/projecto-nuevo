<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Date" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Edit User - minifacebook</title>
    <style>
      body { font-family: Arial, sans-serif; background-color: #f8f9fa; margin:0; padding:20px; }
      .taskbar { background-color:#999fff; color:#fff; padding:10px 20px; text-align:center; margin-bottom:20px; }
      .nav-bar { display:flex; flex-direction:column; background-color:#f1f1f1; border-bottom:1px solid #e2e2e2; padding:10px 20px; margin-bottom:20px; }
      .nav-left { color:#333; font-size:18px; font-weight:bold; margin-bottom:10px; }
      .nav-right { display:flex; flex-wrap:wrap; gap:10px; }
      .nav-right a { color:#33b5e5; text-decoration:none; font-weight:bold; }
      .nav-right a:hover { color:#0099cc; text-decoration:underline; }

      .container { background:#fff; padding:20px; border-radius:8px; box-shadow:0 2px 10px rgba(0,0,0,.1); margin:0 auto; width:100%; max-width:1000px; }
      .section { margin-top:25px; }
      h2 { margin:0 0 15px 0; color:#333; }
      .form-grid { display:grid; grid-template-columns:1fr; gap:12px; }
      .form-group { display:flex; flex-direction:column; }
      label { font-weight:bold; color:#555; margin-bottom:5px; }
      input[type="text"], input[type="email"], input[type="date"], input[type="password"], select {
        width:100%; padding:10px; font-size:14px; border:1px solid #ccc; border-radius:4px;
      }
      input[type="file"] { font-size:14px; }
      .actions { display:flex; gap:10px; margin-top:10px; }
      .btn { background:#33b5e5; color:#fff; padding:10px 16px; border:none; border-radius:4px; cursor:pointer; font-weight:bold; }
      .btn.secondary { background:#888; }
      .row { display:flex; flex-wrap:wrap; gap:16px; }
      .col { flex:1 1 280px; }

      .photo-gallery { display:flex; flex-wrap:wrap; gap:16px; }
      .photo-post { width:180px; text-align:center; }
      .photo-post img { width:100%; max-width:180px; border-radius:4px; display:block; }

      .pill { display:inline-block; padding:6px 10px; border-radius:999px; background:#eee; margin-left:8px; font-size:12px; }
      .muted { color:#666; font-size:13px; }
      .msg { margin:10px 0; padding:10px; background:#f0fff0; border:1px solid #b3e6b3; border-radius:6px; color:#225522; }
      .err { margin:10px 0; padding:10px; background:#fff0f0; border:1px solid #e6b3b3; border-radius:6px; color:#772222; }

      @media (min-width: 700px){
        .form-grid { grid-template-columns: repeat(2, 1fr); }
      }
    </style>
  </head>
  <body>
<%
  // --- Guard de sesión y rol ---
  Object user = session.getAttribute("user");
  if (user == null) { response.sendRedirect("loginHashing.html"); return; }
  String role = (String) session.getAttribute("role");
  if (role == null || !role.equalsIgnoreCase("admin")) {
    out.println("<h2>Access denied: You do not have permission to edit users.</h2>");
    return;
  }

  // --- ID del usuario a editar ---
  String idParam = request.getParameter("id");
  if (idParam == null || idParam.trim().isEmpty()) {
    out.println("<h2>Error: No user ID provided.</h2>");
    return;
  }
  long userIdToEdit = Long.parseLong(idParam.trim());

  // --- DAO ---
  AdminConn admin = new AdminConn();

  // --- Datos básicos ---
  ResultSet rs = admin.getUserById(userIdToEdit);
  if (rs == null || !rs.next()) {
    out.println("<h2>Error: User not found.</h2>");
    if (rs != null) rs.close();
    admin.close();
    return;
  }
  String name = rs.getString("name");
  String email = rs.getString("email");
  Date birthDate = rs.getDate("birth_date");
  String gender = rs.getString("gender");
  String profilePicture = rs.getString("profile_picture");
  rs.close();

  // --- Address (puede no existir) ---
  String street = "", town = "", state = "", country = "";
  ResultSet ra = admin.getAddress(userIdToEdit);
  if (ra != null && ra.next()) {
    street  = (ra.getString("street")  == null) ? "" : ra.getString("street");
    town    = (ra.getString("town")    == null) ? "" : ra.getString("town");
    state   = (ra.getString("state")   == null) ? "" : ra.getString("state");
    country = (ra.getString("country") == null) ? "" : ra.getString("country");
  }
  if (ra != null) ra.close();

  // --- Mensajes flash en sesión ---
  String msg = (String) session.getAttribute("flash_msg");
  String err = (String) session.getAttribute("flash_err");
  if (msg != null) session.removeAttribute("flash_msg");
  if (err != null) session.removeAttribute("flash_err");
%>

    <div class="taskbar"><h1>minifacebook</h1></div>

    <div class="nav-bar">
      <div class="nav-left">Edit User - Admin Panel <span class="pill">ID <%= userIdToEdit %></span></div>
      <div class="nav-right">
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="signout.jsp">Sign Out</a>
      </div>
    </div>

    <div class="container">
      <% if (msg != null) { %><div class="msg"><%= msg %></div><% } %>
      <% if (err != null) { %><div class="err"><%= err %></div><% } %>

      <!-- ========== Basic Info + Profile Picture (multipart, fileupload2) ========== -->
      <div class="section">
        <h2>Basic Info</h2>
        <form action="updateUser.jsp" method="post" enctype="multipart/form-data">
          <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
          <input type="hidden" name="action" value="update_basic"/>
          <div class="form-grid">
            <div class="form-group">
              <label for="name">Name</label>
              <input id="name" name="name" type="text" value="<%= name %>" />
            </div>
            <div class="form-group">
              <label for="email">Email</label>
              <input id="email" name="email" type="email" value="<%= email %>" />
            </div>
            <div class="form-group">
              <label for="birthDate">Birth Date</label>
              <input id="birthDate" name="birthDate" type="date" value="<%= (birthDate!=null)? birthDate.toString() : "" %>" required/>
            </div>
            <div class="form-group">
              <label for="gender">Gender</label>
              <select id="gender" name="gender" >
                <option value="Male"   %>>Male</option>
                <option value="Female" %>>Female</option>
                <option value="Other"  %>>Other</option>
              </select>
            </div>
            <div class="form-group">
              <label for="profilePicture">Profile Picture (Upload)</label>
              <input id="profilePicture" name="profilePicture" type="file" accept="image/*"/>
              <div class="muted">Actual: <%= (profilePicture!=null ? "/"+profilePicture : "(none)") %></div>
              <% if (profilePicture != null && profilePicture.trim().length() > 0) { %>
                <div style="margin-top:8px;"><img src="/<%= profilePicture %>" alt="profile" style="max-width:140px;border-radius:4px;"/></div>
              <% } %>
            </div>
          </div>
          <div class="actions">
            <button type="submit" class="btn">Update User</button>
          </div>
        </form>

        <% if (profilePicture != null && profilePicture.trim().length() > 0) { %>
          <!-- Botón separado para limpiar foto -->
          <form action="updateUser.jsp" method="post" style="margin-top:10px;">
            <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
            <input type="hidden" name="action" value="clear_pp"/>
            <button type="submit" class="btn secondary" onclick="return confirm('Clear profile picture?');">Clear Photo</button>
          </form>
        <% } %>
      </div>

      <!-- ========== Change Password ========== -->
      <div class="section">
        <h2>Change Password</h2>
        <form action="updateUser.jsp" method="post">
          <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
          <input type="hidden" name="action" value="change_password"/>
          <div class="row">
            <div class="col form-group">
              <label for="newPassword">New Password</label>
              <input id="newPassword" name="newPassword" type="password" />
            </div>
          </div>
          <div class="actions">
            <button type="submit" class="btn">Update Password</button>
          </div>
        </form>
      </div>

      <!-- ========== Address (upsert) ========== -->
      <div class="section">
        <h2>Address</h2>
        <form action="updateUser.jsp" method="post">
          <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
          <input type="hidden" name="action" value="upsert_address"/>
          <div class="form-grid">
            <div class="form-group">
              <label for="street">Street</label>
              <input id="street" name="street" type="text" value="<%= street %>"/>
            </div>
            <div class="form-group">
              <label for="town">Town</label>
              <input id="town" name="town" type="text" value="<%= town %>"/>
            </div>
            <div class="form-group">
              <label for="state">State</label>
              <input id="state" name="state" type="text" value="<%= state %>"/>
            </div>
            <div class="form-group">
              <label for="country">Country</label>
              <input id="country" name="country" type="text" value="<%= country %>"/>
            </div>
          </div>
          <div class="actions">
            <button type="submit" class="btn">Save Address</button>
          </div>
        </form>
      </div>

      <!-- ========== Education (1:N) ========== -->
      <div class="section">
        <h2>Education</h2>
        <div class="row">
          <div class="col">
            <h3 class="muted" style="margin:0 0 10px 0;">Existing</h3>
            <div>
<%
  ResultSet re = admin.listEducation(userIdToEdit);
  while (re != null && re.next()) {
    long eduId = re.getLong("id");
    String degree = re.getString("degree");
    String school = re.getString("school");
%>
              <div style="border:1px solid #eee; padding:10px; border-radius:6px; margin-bottom:10px;">
                <form action="updateUser.jsp" method="post" class="row" style="gap:10px;">
                  <input type="hidden" name="action" value="update_education"/>
                  <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
                  <input type="hidden" name="eduId" value="<%= eduId %>"/>
                  <div class="col form-group">
                    <label>Degree</label>
                    <input name="degree" type="text" value="<%= (degree==null?"":degree) %>" />
                  </div>
                  <div class="col form-group">
                    <label>School</label>
                    <input name="school" type="text" value="<%= (school==null?"":school) %>" />
                  </div>
                  <div class="actions">
                    <button type="submit" class="btn">Update</button>
                  </div>
                </form>
              </div>
<%
  }
  if (re != null) re.close();
%>
            </div>
          </div>

         
        </div>
      </div>

      <!-- ========== Fotos publicadas ========== -->
      <div class="section">
        <h2>User Photo Posts</h2>
        <div class="photo-gallery">
<%
  ResultSet rp = admin.getUserPhotos(userIdToEdit);
  while (rp != null && rp.next()) {
    String imageURL = rp.getString("image_url");
    long photoId = rp.getLong("id");
%>
          <div class="photo-post">
            <img src="/<%= imageURL %>" alt="Photo Post"/>
            <form action="updateUser.jsp" method="post" onsubmit="return confirm('Are you sure you want to delete this photo?');" style="margin-top:8px;">
              <input type="hidden" name="action" value="delete_photo"/>
              <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
              <input type="hidden" name="photoId" value="<%= photoId %>"/>
              <button type="submit" class="btn secondary">Delete</button>
            </form>
          </div>
<%
  }
  if (rp != null) rp.close();
  admin.close();
%>
        </div>
      </div>

    </div>
  </body>
</html>
