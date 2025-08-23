<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="ut.JAR.CPEN410.SearchFriend" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.sql.ResultSet" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Search Friends - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <meta http-equiv="Expires" content="0"/>

  <style>
    /* Global and grid (mobile-first) */
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
      color: #333333;
    }

    .row::after {
      content: "";
      display: table;
      clear: both;
    }

    /* Columns: full width on mobile */
    [class*="col-"] {
      float: left;
      width: 100%;
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
      text-align: center;
    }

    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
    }

    .sub {
      font-size: 12px;
      color: #efeaff;
      margin-top: 4px;
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

    /* Content card */
    .box {
      background-color: #f7f7fb;
      padding: 20px;
      border-radius: 8px;
      border: 1px solid #e2e2e2;
      box-shadow: 0 2px 10px rgba(0,0,0,.08);
    }

    .content h2 {
      margin: 0 0 10px 0;
      font-size: 20px;
      color: #222222;
      text-align: left;
    }

    /* Search form */
    .searchbar {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 8px;
      margin: 10px 0 6px 0;
    }

    .searchbar input[type="text"] {
      flex: 1 1 320px;
      min-width: 240px;
      height: 36px;
      padding: 0 10px;
      border: 1px solid #cccccc;
      border-radius: 4px;
      outline: none;
      background: #ffffff;
      font-size: 14px;
    }

    .searchbar input[type="submit"] {
      background-color: #33b5e5;
      color: #ffffff;
      border: 0;
      border-radius: 4px;
      height: 36px;
      line-height: 36px;
      min-width: 120px;
      padding: 0 16px;
      cursor: pointer;
      font-weight: 700;
    }

    .searchbar input[type="submit"]:hover {
      background-color: #0099cc;
    }

    /* Feedback messages */
    .feedback {
      text-align: center;
      margin: 8px 0;
      font-weight: 700;
    }

    .feedback.ok {
      color: #2d6a2d;
    }

    .feedback.err {
      color: #aa3333;
    }

    /* Results table */
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

    tr:hover {
      background: #f7fbff;
    }

    .thumb {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border-radius: 50%;
      display: block;
      margin: 4px 0;
    }

    td a {
      color: #33b5e5;
      font-weight: bold;
      text-decoration: none;
    }

    td a:hover {
      color: #0099cc;
      text-decoration: underline;
    }

    .muted {
      color: #666666;
      text-align: center;
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
  </style>
</head>
<body>
<%
  // Identity from session
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) { response.sendRedirect("loginHashing.jsp"); return; }
  String userName = (String) session.getAttribute("userName");

  // Page permission and last page
  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String thisPage = "searchFriends.jsp";
  boolean allowed = auth.canUserAccessPage(userId, thisPage);
  if (allowed) { auth.setLastPage(userId, thisPage); }

  // Search keyword and encoded variant
  String q = request.getParameter("q");
  String qEnc = "";
  try { qEnc = (q == null) ? "" : java.net.URLEncoder.encode(q, "UTF-8"); } catch (Exception ignore) {}

  // Inline add-friend action
  String add = request.getParameter("add");
  String friendIdParam = request.getParameter("friendId");
  Integer addedFlag = null; // null = not attempted, 1 = ok, 0 = fail

  if (allowed && "1".equals(add) && friendIdParam != null && friendIdParam.matches("\\d+")) {
      long friendId = 0L;
      try { friendId = Long.parseLong(friendIdParam); } catch (Exception ignore) {}
      if (friendId > 0 && friendId != userId.longValue()) {
          ut.JAR.CPEN410.Friendship fdao = new ut.JAR.CPEN410.Friendship();
          boolean ok = false;
          try {
              ok = fdao.addFriend(userId, friendId); // DAO should be idempotent
          } catch (Exception ex) {
              ok = false;
              ex.printStackTrace();
          } finally {
              try { fdao.close(); } catch (Exception ignore) {}
          }
          addedFlag = ok ? 1 : 0;
      } else {
          addedFlag = 0;
      }
  }

  // Run search only if allowed and keyword present
  ResultSet rs = null;
  ut.JAR.CPEN410.SearchFriend sf = null;
  boolean runSearch = (allowed && q != null && q.trim().length() > 0);
  if (runSearch) {
      sf = new ut.JAR.CPEN410.SearchFriend();
      rs = sf.searchFriend(q);
  }
%>

  <!-- Header -->
  <div class="header">
    <h1>MiniFacebook</h1>
    <div class="sub"><%= allowed ? ("Logged in as: " + (userName == null ? "User" : userName)) : "Access denied" %></div>
  </div>

  <!-- Taskbar with hover -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="friendList.jsp">Friend List</a></li>
      <li><a href="profile.jsp">Profile</a></li>
      <li><a href="signout.jsp">Sign Out</a></li>
    </ul>
  </nav>

  <!-- Three-column layout -->
  <div class="row">

    <!-- Left menu (col-3 desktop; full width mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="searchFriends.jsp">Search Friends</a></li>
        <li><a href="friendList.jsp">Friend List</a></li>
        <li><a href="addFriend.jsp">Add Friend</a></li>
        <li><a href="welcomeMenu.jsp">Home</a></li>
      </ul>
    </div>

    <!-- Main content (col-6 desktop; full width mobile) -->
    <div class="col-6 content">
      <div class="box">
        <h2>Search Friends</h2>

        <% if (!allowed) { %>
          <p class="muted">Your role is not authorized for this page.</p>
        <% } else { %>

          <!-- Search form -->
          <form class="searchbar" method="get" action="searchFriends.jsp">
            <input
              type="text"
              name="q"
              placeholder="Search by name, email, town, state, country, gender or age..."
              value="<%= (q == null ? "" : q) %>" />
            <input type="submit" value="Search" />
          </form>

          <!-- Add-friend feedback -->
          <% if (addedFlag != null) { %>
            <% if (addedFlag == 1) { %>
              <div class="feedback ok">Friend added successfully.</div>
            <% } else { %>
              <div class="feedback err">Could not add friend (already friends or invalid request).</div>
            <% } %>
          <% } %>

          <!-- Results -->
          <div class="table-wrap">
          <% if (runSearch) { %>
            <table>
              <tr>
                <th>Photo</th>
                <th>Name</th>
                <th>Gender</th>
                <th>Age</th>
                <th>Address</th>
                <th>Action</th>
              </tr>
              <%
                boolean any = false;
                try {
                    while (rs != null && rs.next()) {
                        any = true;
                        long uid = rs.getLong("id");
                        String nm = rs.getString("name");
                        String gd = rs.getString("gender");
                        int age   = rs.getInt("age");
                        String tw = rs.getString("town");
                        String st = rs.getString("state");
                        String co = rs.getString("country");
                        String img = rs.getString("profile_picture");
                        if (img == null || img.trim().isEmpty()) img = "cpen410/imagesjson/default-profile.png";

                        String addr = "";
                        if (tw != null && !tw.isEmpty()) addr += tw;
                        if (st != null && !st.isEmpty()) addr += (addr.isEmpty() ? "" : ", ") + st;
                        if (co != null && !co.isEmpty()) addr += (addr.isEmpty() ? "" : ", ") + co;
              %>
              <tr>
                <td><img class="thumb" src="<%= request.getContextPath() %>/<%= img %>" alt="photo" /></td>
                <td><%= nm %></td>
                <td><%= gd %></td>
                <td><%= age %></td>
                <td><%= addr.isEmpty() ? "-" : addr %></td>
                <td>
                  <% if (uid != userId) { %>
                    <a href="searchFriends.jsp?q=<%= qEnc %>&add=1&friendId=<%= uid %>">Add Friend</a>
                  <% } else { %>
                    —
                  <% } %>
                </td>
              </tr>
              <%
                    }
                } catch (Exception e) {
              %>
                <tr><td colspan="6" class="muted">There was an error loading results.</td></tr>
              <%
                }

                if (!any && runSearch) {
              %>
                <tr><td colspan="6" class="muted">No results found.</td></tr>
              <%
                }
              %>
            </table>
          <% } %>
          </div>

        <% } %>
      </div>
    </div>

    <!-- Right aside (col-3 desktop; full width mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Tips</h2>
        <p>Try searching by full name or email for better accuracy.</p>
        <h3>Shortcut</h3>
        <p>Use the address fields (town/state/country) to refine results.</p>
        <h3>Next Steps</h3>
        <p>Open a profile to learn more before adding as a friend.</p>
      </div>
    </div>

  </div>

  <!-- Footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

<%
  // Cleanup
  try { if (rs != null) rs.close(); } catch (Exception ignore) {}
  try { if (sf != null) sf.close(); } catch (Exception ignore) {}
  try { auth.close(); } catch (Exception ignore) {}
%>
</body>
</html>
