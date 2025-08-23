<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Date" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Edit User - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    /* grid system (mobile-first, columns for responsiveness) */
    * {
      box-sizing: border-box;
    }

    html {
      font-family: "Lucida Sans", sans-serif;
    }

    body {
      margin: 0;
      background-color: #f8f9fa;
      color: #333333;
    }

    .row::after {
      content: "";
      clear: both;
      display: table;
    }

    /* columns default to full width on mobile */
    [class*="col-"] {
      width: 100%;
      float: left;
      padding: 15px;
    }

    /* desktop column widths */
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
    }

    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
      text-align: center;
    }

    /* top taskbar with hover on links */
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

    /* left navigation menu */
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

    /* right aside tips */
    .aside {
      background-color: #33b5e5;
      padding: 15px;
      color: #ffffff;
      text-align: center;
      font-size: 14px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
    }

    /* main content area */
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

    .pill {
      display: inline-block;
      padding: 6px 10px;
      border-radius: 999px;
      background: #eeeeee;
      margin-left: 8px;
      font-size: 12px;
      color: #333333;
    }

    .muted {
      color: #666666;
      font-size: 13px;
    }

    .msg {
      margin: 10px 0;
      padding: 10px;
      background: #f0fff0;
      border: 1px solid #b3e6b3;
      border-radius: 6px;
      color: #225522;
      font-weight: 700;
      text-align: center;
    }

    .err {
      margin: 10px 0;
      padding: 10px;
      background: #fff0f0;
      border: 1px solid #e6b3b3;
      border-radius: 6px;
      color: #772222;
      font-weight: 700;
      text-align: center;
    }

    /* form grids and groups */
    .section {
      margin-top: 25px;
    }

    .section h2 {
      margin: 0 0 15px 0;
      color: #333333;
    }

    .form-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 12px;
    }

    @media only screen and (min-width: 768px) {
      .form-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    .form-group {
      display: flex;
      flex-direction: column;
    }

    .form-group label {
      font-weight: bold;
      color: #555555;
      margin-bottom: 5px;
    }

    input[type="text"],
    input[type="email"],
    input[type="date"],
    input[type="password"],
    select {
      width: 100%;
      padding: 10px;
      font-size: 14px;
      border: 1px solid #cccccc;
      border-radius: 4px;
      background: #ffffff;
    }

    input[type="file"] {
      font-size: 14px;
    }

    .actions {
      display: flex;
      gap: 10px;
      margin-top: 10px;
      flex-wrap: wrap;
    }

    .btn {
      background: #33b5e5;
      color: #ffffff;
      padding: 10px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
    }

    .btn.secondary {
      background: #888888;
    }

    /* simple row/col helpers inside cards (independent of main grid) */
    .inline-row {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
    }

    .inline-col {
      flex: 1 1 280px;
    }

    /* user photo gallery */
    .photo-gallery {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
    }

    .photo-post {
      width: 180px;
      text-align: center;
    }

    .photo-post img {
      width: 100%;
      max-width: 180px;
      border-radius: 4px;
      display: block;
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
      <li><a href="adminDashboard.jsp">Dashboard</a></li>
      <li><a href="userList.jsp">Users</a></li>
      <li><a href="addUserAD.jsp">Add User</a></li>
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="signout.jsp">Sign Out</a></li>
    </ul>
  </nav>

  <!-- three-column layout (menu · content · aside) -->
  <div class="row">

    <!-- left menu (col-3 on desktop; full width on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="adminDashboard.jsp">Admin Panel</a></li>
        <li><a href="userList.jsp">Manage Users</a></li>
        <li><a href="roles.jsp">Roles &amp; Permissions</a></li>
        <li><a href="auditLogs.jsp">Audit Logs</a></li>
      </ul>
    </div>

    <!-- main content (col-6 on desktop; full width on mobile) -->
    <div class="col-6 content">
      <h1>Edit User</h1>
      <div class="card">
        <div class="title">
          Admin Editing
          <span class="pill" id="user-id-pill"><!-- user id will be placed via JSP below --></span>
        </div>

<%
  // signin/role checks and data retrieval happen here so the layout still renders
  Object sessionUser = session.getAttribute("user");
  String sessionRole = (String) session.getAttribute("role");

  // values to control rendering below
  boolean ready = false;
  String statusError = null;

  // user being edited
  long userIdToEdit = -1L;
  String idParam = request.getParameter("id");

  // fields for the forms
  String name = null;
  String email = null;
  Date birthDate = null;
  String gender = null;
  String profilePicture = null;

  // address fields (may be empty)
  String street = "";
  String town = "";
  String state = "";
  String country = "";

  // flash messages
  String flashMsg = (String) session.getAttribute("flash_msg");
  String flashErr = (String) session.getAttribute("flash_err");
  if (flashMsg != null) session.removeAttribute("flash_msg");
  if (flashErr != null) session.removeAttribute("flash_err");

  if (sessionUser == null) {
      statusError = "You must be signed in.";
  } else if (sessionRole == null || !sessionRole.equalsIgnoreCase("admin")) {
      statusError = "Access denied: You do not have permission to edit users.";
  } else if (idParam == null || idParam.trim().isEmpty()) {
      statusError = "No user ID provided.";
  } else {
      try {
          userIdToEdit = Long.parseLong(idParam.trim());
      } catch (Exception ex) {
          statusError = "Invalid user ID.";
      }
      if (statusError == null) {
          AdminConn admin = new AdminConn();
          try {
              ResultSet rs = admin.getUserById(userIdToEdit);
              if (rs == null || !rs.next()) {
                  statusError = "User not found.";
                  if (rs != null) rs.close();
              } else {
                  name = rs.getString("name");
                  email = rs.getString("email");
                  birthDate = rs.getDate("birth_date");
                  gender = rs.getString("gender");
                  profilePicture = rs.getString("profile_picture");
                  rs.close();

                  // address (if present)
                  ResultSet ra = admin.getAddress(userIdToEdit);
                  if (ra != null && ra.next()) {
                      street  = (ra.getString("street")  == null) ? "" : ra.getString("street");
                      town    = (ra.getString("town")    == null) ? "" : ra.getString("town");
                      state   = (ra.getString("state")   == null) ? "" : ra.getString("state");
                      country = (ra.getString("country") == null) ? "" : ra.getString("country");
                  }
                  if (ra != null) ra.close();

                  ready = true;
              }
          } catch (Exception e) {
              statusError = "Error retrieving user.";
          } finally {
              try { admin.close(); } catch (Exception ignore) {}
          }
      }
  }
%>

        <%-- flash messages --%>
        <% if (flashMsg != null) { %><div class="msg"><%= flashMsg %></div><% } %>
        <% if (flashErr != null) { %><div class="err"><%= flashErr %></div><% } %>

        <%-- status or forms --%>
        <% if (!ready) { %>
          <div class="err"><%= statusError %></div>
          <div class="actions" style="justify-content:center;">
            <a class="btn" href="adminDashboard.jsp">Back to Dashboard</a>
          </div>
        <% } else { %>
          <script>
            // set the ID pill content once the server-side id is known
            document.addEventListener('DOMContentLoaded', function () {
              var pill = document.getElementById('user-id-pill');
              if (pill) pill.textContent = "ID <%= userIdToEdit %>";
            });
          </script>

          <!-- basic info + profile picture -->
          <div class="section">
            <h2>Basic Info</h2>
            <form action="updateUser.jsp" method="post" enctype="multipart/form-data">
              <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
              <input type="hidden" name="action" value="update_basic"/>
              <div class="form-grid">
                <div class="form-group">
                  <label for="name">Name</label>
                  <input id="name" name="name" type="text" value="<%= (name==null?"":name) %>" />
                </div>
                <div class="form-group">
                  <label for="email">Email</label>
                  <input id="email" name="email" type="email" value="<%= (email==null?"":email) %>" />
                </div>
                <div class="form-group">
                  <label for="birthDate">Birth Date</label>
                  <input id="birthDate" name="birthDate" type="date" value="<%= (birthDate!=null? birthDate.toString() : "") %>" required/>
                </div>
                <div class="form-group">
                  <label for="gender">Gender</label>
                  <select id="gender" name="gender">
                    <option value="Male"   <%= ("Male".equalsIgnoreCase(gender) ? "selected" : "") %>  >Male</option>
                    <option value="Female" <%= ("Female".equalsIgnoreCase(gender) ? "selected" : "") %>>Female</option>
                    <option value="Other"  <%= ("Other".equalsIgnoreCase(gender) ? "selected" : "") %> >Other</option>
                  </select>
                </div>
                <div class="form-group">
                  <label for="profilePicture">Profile Picture (Upload)</label>
                  <input id="profilePicture" name="profilePicture" type="file" accept="image/*"/>
                  <div class="muted">Current: <%= (profilePicture!=null && !profilePicture.trim().isEmpty() ? "/"+profilePicture : "(none)") %></div>
                  <% if (profilePicture != null && profilePicture.trim().length() > 0) { %>
                    <div style="margin-top:8px;">
                      <img src="/<%= profilePicture %>" alt="profile" style="max-width:140px;border-radius:4px;"/>
                    </div>
                  <% } %>
                </div>
              </div>
              <div class="actions">
                <button type="submit" class="btn">Update User</button>
              </div>
            </form>

            <% if (profilePicture != null && profilePicture.trim().length() > 0) { %>
              <form action="updateUser.jsp" method="post" style="margin-top:10px;">
                <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
                <input type="hidden" name="action" value="clear_pp"/>
                <button type="submit" class="btn secondary" onclick="return confirm('Clear profile picture?');">Clear Photo</button>
              </form>
            <% } %>
          </div>

          <!-- change password -->
          <div class="section">
            <h2>Change Password</h2>
            <form action="updateUser.jsp" method="post">
              <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
              <input type="hidden" name="action" value="change_password"/>
              <div class="inline-row">
                <div class="inline-col form-group">
                  <label for="newPassword">New Password</label>
                  <input id="newPassword" name="newPassword" type="password" />
                </div>
              </div>
              <div class="actions">
                <button type="submit" class="btn">Update Password</button>
              </div>
            </form>
          </div>

          <!-- address upsert -->
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

          <!-- education list + update forms -->
          <div class="section">
            <h2>Education</h2>
            <div class="inline-row">
              <div class="inline-col">
                <h3 class="muted" style="margin:0 0 10px 0;">Existing</h3>
                <div>
<%
  // list existing education entries for this user
  AdminConn adminForEdu = new AdminConn();
  ResultSet re = null;
  try {
      re = adminForEdu.listEducation(userIdToEdit);
      while (re != null && re.next()) {
        long eduId = re.getLong("id");
        String degreeVal = re.getString("degree");
        String schoolVal = re.getString("school");
%>
                  <div style="border:1px solid #eeeeee; padding:10px; border-radius:6px; margin-bottom:10px;">
                    <form action="updateUser.jsp" method="post" class="inline-row" style="gap:10px;">
                      <input type="hidden" name="action" value="update_education"/>
                      <input type="hidden" name="id" value="<%= userIdToEdit %>"/>
                      <input type="hidden" name="eduId" value="<%= eduId %>"/>
                      <div class="inline-col form-group">
                        <label>Degree</label>
                        <input name="degree" type="text" value="<%= (degreeVal==null?"":degreeVal) %>" />
                      </div>
                      <div class="inline-col form-group">
                        <label>School</label>
                        <input name="school" type="text" value="<%= (schoolVal==null?"":schoolVal) %>" />
                      </div>
                      <div class="actions">
                        <button type="submit" class="btn">Update</button>
                      </div>
                    </form>
                  </div>
<%
      }
  } catch (Exception e) {
%>
                  <div class="err">Error loading education.</div>
<%
  } finally {
      try { if (re != null) re.close(); } catch (Exception ignore) {}
      try { adminForEdu.close(); } catch (Exception ignore) {}
  }
%>
                </div>
              </div>
            </div>
          </div>

          <!-- user photo posts -->
          <div class="section">
            <h2>User Photo Posts</h2>
            <div class="photo-gallery">
<%
  AdminConn adminForPhotos = new AdminConn();
  ResultSet rp = null;
  try {
      rp = adminForPhotos.getUserPhotos(userIdToEdit);
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
  } catch (Exception e) {
%>
              <div class="err">Error loading photos.</div>
<%
  } finally {
      try { if (rp != null) rp.close(); } catch (Exception ignore) {}
      try { adminForPhotos.close(); } catch (Exception ignore) {}
  }
%>
            </div>
          </div>

        <% } %>
      </div>
    </div>

    <!-- right aside (col-3 on desktop; full width on mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Quick Tips</h2>
        <p>Keep user emails unique to avoid conflicts.</p>
        <h3>Images</h3>
        <p>Prefer square images for consistent thumbnails.</p>
        <h3>Security</h3>
        <p>Update passwords with strong combinations.</p>
      </div>
    </div>

  </div>

  <!-- footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
