<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Welcome Menu - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    /* basic reset */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html {
      font-family: "Lucida Sans", sans-serif;
    }

    body {
      background-color: #f8f9fa;
      color: #333333;
      margin: 0;
    }

    /* clearfix helper */
    .row::after {
      content: "";
      display: table;
      clear: both;
    }

    /* columns default to full width on mobile */
    [class*="col-"] {
      float: left;
      width: 100%;
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

    /* top header */
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

    /* taskbar with hoverable links */
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

    /* content card */
    .box {
      background-color: #ffffff;
      border: 1px solid #e2e2e2;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.10);
      padding: 16px;
    }

    .title {
      text-align: center;
      margin-bottom: 8px;
      color: #222222;
      font-size: 20px;
      font-weight: 700;
    }

    /* friend photo gallery */
    .gallery {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      justify-content: center;
    }

    .photo-card {
      width: 220px;
      background: #ffffff;
      border: 1px solid #e2e2e2;
      border-radius: 6px;
      box-shadow: 0 1px 6px rgba(0,0,0,0.08);
      padding: 10px;
      text-align: center;
    }

    .photo-card img {
      width: 100%;
      height: auto;
      max-width: 200px;
      border-radius: 4px;
      display: block;
      margin: 0 auto;
    }

    .photo-card p {
      margin-top: 6px;
      color: #333333;
      font-weight: 700;
      font-size: 14px;
    }

    .muted {
      color: #666666;
      text-align: center;
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

<%
  // identity check
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) {
      response.sendRedirect("loginHashing.jsp");
      return;
  }
  String userName = (String) session.getAttribute("userName");

  // optional page permission and last page tracking
  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String thisPage = "welcomeMenu.jsp";
  boolean allowed = auth.canUserAccessPage(userId, thisPage);
  if (allowed) { auth.setLastPage(userId, thisPage); }
%>

  <!-- header -->
  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <!-- taskbar with hover -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="profile.jsp">Profile</a></li>
      <li><a href="searchFriends.jsp">Search Friends</a></li>
      <li><a href="friendList.jsp">Friend List</a></li>
      <li><a href="signout.jsp">Sign Out</a></li>
    </ul>
  </nav>

  <!-- three-column layout -->
  <div class="row">

    <!-- left navigation (col-3 desktop; full width on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="welcomeMenu.jsp">Home</a></li>
        <li><a href="profile.jsp">My Profile</a></li>
        <li><a href="searchFriends.jsp">Find Friends</a></li>
        <li><a href="friendList.jsp">Friend List</a></li>
      </ul>
    </div>

    <!-- main content (col-6 desktop; full width on mobile) -->
    <div class="col-6 content">
      <div class="box">
        <div class="title">Welcome, <%= (userName == null ? "User" : userName) %>!</div>

        <% if (!allowed) { %>
          <p class="muted">Access denied: your role is not authorized for this page.</p>
        <% } else { %>

          <h2 class="title" style="margin-top:10px;">Friend Photo Posts</h2>

          <div class="gallery">
          <%
            // load latest photos from friends (up to 30)
            ut.JAR.CPEN410.Friendship fr = new ut.JAR.CPEN410.Friendship();
            java.sql.ResultSet feed = null;
            boolean any = false;
            try {
                feed = fr.getFriendsPhotos(userId, 30);
                while (feed != null && feed.next()) {
                    any = true;
                    String img    = feed.getString("image_url");
                    String poster = feed.getString("name");
                    if (img == null || img.trim().isEmpty()) {
                        img = "cpen410/imagesjson/default-profile.png";
                    }
          %>
            <div class="photo-card">
              <img src="<%= request.getContextPath() %>/<%= img %>" alt="Friend Photo">
              <p><%= poster %></p>
            </div>
          <%
                }
            } catch (Exception e) {
          %>
              <p class="muted" style="width:100%;">Error loading friend posts.</p>
          <%
            } finally {
                try { if (feed != null) feed.close(); } catch (Exception ignore) {}
                try { fr.close(); } catch (Exception ignore) {}
            }

            if (!any) {
          %>
              <p class="muted" style="width:100%;">No recent friend photos.</p>
          <%
            }
          %>
          </div>

        <% } %>
      </div>
    </div>

    <!-- right aside (col-3 desktop; full width on mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Tips</h2>
        <p>Browse your feed to see what your friends are sharing.</p>
        <h3>Navigation</h3>
        <p>Use the menu to visit your profile or find more friends.</p>
        <h3>Privacy</h3>
        <p>Adjust your settings to control who can see your posts.</p>
      </div>
    </div>

  </div>

  <!-- footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

<%
  try { auth.close(); } catch (Exception ignore) {}
%>
</body>
</html>
