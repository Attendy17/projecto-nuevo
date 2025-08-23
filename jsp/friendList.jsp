<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.Friendship" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.sql.ResultSet" %>

<%-- Friend list page with grid layout, taskbar hover, and responsive columns --%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Friend List - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <meta http-equiv="Expires" content="0"/>

  <style>
    /* grid system (mobile-first) */
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

    /* mobile: columns take full width */
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

    .sub {
      font-size: 12px;
      color: #e8e8ff;
      margin-top: 4px;
    }

    /* top taskbar with hover */
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

    /* content card and table */
    .content h2 {
      margin: 0 0 10px 0;
      font-size: 20px;
      color: #222222;
    }

    .box {
      background-color: #f7f7fb;
      padding: 20px;
      border-radius: 8px;
      border: 1px solid #e2e2e2;
      box-shadow: 0 2px 10px rgba(0,0,0,.08);
    }

    .table-wrap {
      overflow-x: auto;
      margin-top: 10px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      background: #ffffff;
    }

    th, td {
      border: 1px solid #dddddd;
      text-align: left;
      padding: 8px;
      line-height: 1.6;
      vertical-align: middle;
    }

    th {
      background: #e9ecef;
      color: #000000;
    }

    .thumb {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border-radius: 50%;
      display: block;
      margin: 4px 0;
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
  // authentication and authorization
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) {
      response.sendRedirect("loginHashing.jsp");
      return;
  }

  String userName = (String) session.getAttribute("userName");

  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String pageName = "friendList.jsp";
  boolean allowed = auth.canUserAccessPage(userId, pageName);
  if (allowed) {
      auth.setLastPage(userId, pageName);
  }
%>

  <!-- header -->
  <div class="header">
    <h1>MiniFacebook</h1>
    <div class="sub"><%= (allowed ? "Logged in as: " + (userName==null?"User":userName) : "Access denied") %></div>
  </div>

  <!-- taskbar -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="searchFriends.jsp">Search Friends</a></li>
      <li><a href="profile.jsp">Profile</a></li>
      <li><a href="signout.jsp">Sign Out</a></li>
    </ul>
  </nav>

  <!-- three-column layout -->
  <div class="row">

    <!-- left menu (col-3 desktop, full on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="friendList.jsp">Friend List</a></li>
        <li><a href="searchFriends.jsp">Find Friends</a></li>
        <li><a href="addFriend.jsp">Add Friend</a></li>
        <li><a href="welcomeMenu.jsp">Home</a></li>
      </ul>
    </div>

    <!-- main content (col-6 desktop, full on mobile) -->
    <div class="col-6 content">
      <div class="box">
        <h2>Friend List</h2>

<%
  if (!allowed) {
      try { auth.close(); } catch (Exception ignore) {}
%>
        <p class="muted">Your role is not authorized for this page.</p>
<%
  } else {
      Friendship fdao = new Friendship();
      ResultSet rs = null;
      boolean any = false;
      try {
          rs = fdao.listFriends(userId);
%>
        <div class="table-wrap">
          <table>
            <tr>
              <th>Photo</th>
              <th>Name</th>
              <th>Gender</th>
              <th>Age</th>
              <th>Email</th>
            </tr>
<%
            while (rs != null && rs.next()) {
                any = true;
                String img = rs.getString("profile_picture");
                if (img == null || img.trim().isEmpty()) {
                    img = "cpen410/imagesjson/default-profile.png";
                }
%>
            <tr>
              <td><img class="thumb" src="<%= request.getContextPath() %>/<%= img %>" alt="photo"/></td>
              <td><%= rs.getString("name") %></td>
              <td><%= rs.getString("gender") %></td>
              <td><%= rs.getInt("age") %></td>
              <td><%= rs.getString("email") %></td>
            </tr>
<%
            }
%>
<%
            if (!any) {
%>
            <tr>
              <td colspan="5" class="muted">You do not have friends yet.</td>
            </tr>
<%
            }
%>
          </table>
        </div>
<%
      } catch (Exception e) {
%>
        <p class="muted">There was an error loading your friend list.</p>
<%
      } finally {
          try { if (rs != null) rs.close(); } catch (Exception ignore) {}
          try { fdao.close(); } catch (Exception ignore) {}
          try { auth.close(); } catch (Exception ignore) {}
      }
  }
%>
      </div>
    </div>

    <!-- right aside (col-3 desktop, full on mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Tips</h2>
        <p>Keep your profile updated so friends can find you easily.</p>
        <h3>Need more friends?</h3>
        <p>Use the search page to discover and add new connections.</p>
      </div>
    </div>

  </div>

  <!-- footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
