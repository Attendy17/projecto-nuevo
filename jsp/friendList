<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.Friendship" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.sql.ResultSet" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Friend List - MiniFacebook</title>
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <meta http-equiv="Expires" content="0"/>
  <style>
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

    .sub {
      font-size: 12px;
      color: #eef;
      margin-top: 4px;
    }

    .box {
      background-color: #f1f1f1;
      padding: 20px;
      border-radius: 5px;
      box-shadow: 0 0 10px #ccc;
    }

    .content {
      overflow-x: auto;
      margin-top: 10px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th, td {
      border: 1px solid #ddd;
      text-align: left;
      padding: 8px;
      line-height: 1.6;
    }

    th {
      background: #ddd;
      color: #000;
    }

    .thumb {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border-radius: 50%;
      display: block;
      margin: 4px 0;
    }

    .links {
      text-align: center;
      margin-top: 12px;
    }

    .links a {
      color: #33b5e5;
      text-decoration: none;
      font-weight: bold;
      margin: 0 6px;
    }

    .links a:hover {
      color: #0099cc;
      text-decoration: underline;
    }

    .muted {
      color: #666;
      text-align: center;
    }
  </style>
</head>
<body>
<%
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) { response.sendRedirect("loginHashing.jsp"); return; }

  String userName = (String) session.getAttribute("userName");

  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String thisPage = "friendList.jsp";
  if (!auth.canUserAccessPage(userId, thisPage)) {
      auth.close();
%>
  <div class="header">
    <h1>MiniFacebook</h1>
    <div class="sub">Access denied</div>
  </div>
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="box">
        <h2>Friend List</h2>
        <p class="muted">Your role is not authorized for this page.</p>
        <div class="links">
          <a href="welcomeMenu.jsp">Home</a> |
          <a href="searchFriends.jsp">Search Friends</a> |
          <a href="profile.jsp">Profile</a> |
          <a href="signout.jsp">Sign Out</a>
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>
</body>
</html>
<%  return; }

  auth.setLastPage(userId, thisPage);

  Friendship fdao = new Friendship();
  ResultSet rs = fdao.listFriends(userId);
%>

  <!-- Taskbar at the top, above the friend list -->
  <div class="row">
    <div class="col-12">
      <div class="header">
        <h1>MiniFacebook</h1>
        <div class="sub">Logged in as: <%= userName %></div>
      </div>
    </div>
  </div>

  <!-- Friend list content -->
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="box">
        <h2>Friend List</h2>
        <div class="content">
          <table>
            <tr>
              <th>Photo</th>
              <th>Name</th>
              <th>Gender</th>
              <th>Age</th>
              <th>Email</th>
            </tr>
<%
          boolean any = false;
          while (rs != null && rs.next()) {
              any = true;
              String img = rs.getString("profile_picture");
              if (img == null || img.trim().isEmpty()) img = "cpen410/imagesjson/default-profile.png";
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
          if (!any) {
%>
            <tr><td colspan="5" class="muted">You do not have friends yet.</td></tr>
<%
          }
          if (rs != null) try { rs.close(); } catch (Exception ignore) {}
          fdao.close();
          auth.close();
%>
          </table>
        </div>
        <div class="links">
          <a href="welcomeMenu.jsp">Home</a>
          <a href="searchFriends.jsp">Search Friends</a>
          <a href="profile.jsp">Profile</a>
          <a href="signout.jsp">Sign Out</a>
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>
</body>
</html>
