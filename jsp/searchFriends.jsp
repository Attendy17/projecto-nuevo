<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="ut.JAR.CPEN410.SearchFriend" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.sql.ResultSet" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Search Friends - MiniFacebook</title>
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <meta http-equiv="Expires" content="0"/>

  <style>
    /* Base del login (sin padding) */
    * { box-sizing: border-box; margin: 0; }
    html { font-family: "Lucida Sans", sans-serif; }
    body { background-color: #ffffff; margin: 0; }

    .row::after { content: ""; display: table; clear: both; }
    [class*="col-"] { float: left; width: 100%; margin: 0; }
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
      background-color: #999fff; color: #fff; text-align: center; overflow: auto; border: 0;
    }
    .header h1 { margin: 14px 0 2px 0; font-weight: 600; }
    .header .sub { font-size: 12px; color: #eef; margin: 4px 0 10px 0; }

    .login-box {
      background-color: #f1f1f1; border-radius: 5px; box-shadow: 0 0 10px #ccc;
      margin: 18px 0; overflow: auto;
    }
    .login-box h2 { text-align: center; margin: 18px 0 12px 0; font-weight: 600; }

    /* Centrado del formulario SIN padding */
    .center { text-align: center; }
    .input-row {
      display: flex; justify-content: center; align-items: center; gap: 10px;
      margin: 10px 16px 0 16px;
    }
    .input-row input[type="text"] {
      width: 70%; height: 34px; border: 1px solid #ccc; border-radius: 3px; outline: none; margin: 0;
    }
    .btn-submit {
      background-color: #33b5e5; color: #fff; border: 0; border-radius: 3px;
      height: 36px; line-height: 36px; min-width: 120px; cursor: pointer; margin: 0;
    }
    .btn-submit:hover { background-color: #0099cc; }

    .links { text-align: center; margin: 8px 0 12px 0; }
    .links a { color: #33b5e5; text-decoration: none; font-weight: bold; margin: 0 6px; }
    .links a:hover { color: #0099cc; }

    /* Resultados SIN padding */
    .results-wrap { margin: 12px 16px 16px 16px; overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; text-align: left; line-height: 1.8; margin: 0; }
    th { background: #ddd; color: #000; }
    img.thumb { width: 60px; height: 60px; object-fit: cover; border-radius: 50%; display: block; margin: 4px 0; }
    .muted { color: #666; text-align: center; }

    /* Botón Add Friend SIN padding (altura/line-height) */
    .btn {
      display: inline-block; background-color: #33b5e5; color: #fff; text-decoration: none; font-weight: bold;
      height: 30px; line-height: 30px; min-width: 110px; text-align: center; border-radius: 3px; border: 0; margin: 0;
    }
    .btn:hover { background-color: #0099cc; }
  </style>
</head>
<body>
<%
  // --- Session guard ---
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) { response.sendRedirect("loginHashing.jsp"); return; }
  String userName = (String) session.getAttribute("userName");

  // --- Page permission (Rule C.b) + last_page ---
  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String thisPage = "searchFriends.jsp";
  boolean allowed = auth.canUserAccessPage(userId, thisPage);
  if (allowed) { auth.setLastPage(userId, thisPage); }

  // --- Read query keyword (keep it across add friend) ---
  String q = request.getParameter("q");
  String qEnc = "";
  try { qEnc = (q == null) ? "" : java.net.URLEncoder.encode(q, "UTF-8"); } catch (Exception ignore) {}

  // --- Inline Add Friend (GET action): /searchFriends.jsp?add=1&friendId=XX&q=... ---
  String add = request.getParameter("add");
  String friendIdParam = request.getParameter("friendId");
  Integer addedFlag = null; // null=not attempted, 1=success, 0=failure

  if (allowed && "1".equals(add) && friendIdParam != null && friendIdParam.matches("\\d+")) {
      long friendId = 0L;
      try { friendId = Long.parseLong(friendIdParam); } catch (Exception ignore) {}
      if (friendId > 0 && friendId != userId.longValue()) {
          ut.JAR.CPEN410.Friendship fdao = new ut.JAR.CPEN410.Friendship();
          boolean ok = false;
          try {
              ok = fdao.addFriend(userId, friendId);  // idempotent in DAO
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

  // --- Run search if there's a keyword ---
  java.sql.ResultSet rs = null;
  ut.JAR.CPEN410.SearchFriend sf = null;
  boolean runSearch = (q != null && q.trim().length() > 0 && allowed);
  if (runSearch) {
      sf = new ut.JAR.CPEN410.SearchFriend();
      rs = sf.searchFriend(q);
  }
%>

  <div class="taskbar">
    <h1>minifacebook</h1>
    <p style="color:#ddd; font-size:12px;">Logged in as: <%= userName %></p>
  </div>

  <div class="nav-bar">
    <div style="color:#fff; font-weight:bold;">Search Friends</div>
    <div class="nav-links">
      <a href="welcomeMenu.jsp">Home</a>
      <a href="friendList.jsp">Friend List</a>
      <a href="profile.jsp">Profile</a>
      <a href="signout.jsp">Sign Out</a>
    </div>
  </div>

  <div class="container">
<% if (!allowed) { %>
      <h2 style="text-align:center; margin: 10px 0;">Access Denied</h2>
      <p style="text-align:center; margin: 6px 0;">Your role is not authorized for this page.</p>
<% } else { %>
      <!-- Search bar (GET) -->
      <form class="searchbar" method="get" action="searchFriends.jsp" style="display:flex; justify-content:center; gap:6px; margin:10px 0;">
        <input type="text" name="q" placeholder="Search by name, email, town, state, country, gender or age..." value="<%= (q==null? "" : q) %>"/>
        <input type="submit" value="Search"/>
      </form>

      <!-- Inline add-friend feedback -->
<%    if (addedFlag != null) { %>
        <% if (addedFlag == 1) { %>
          <div style="text-align:center; color:#2d6a2d; margin:8px 0;">Friend added successfully.</div>
        <% } else { %>
          <div style="text-align:center; color:#a33; margin:8px 0;">Could not add friend (already friends or invalid request).</div>
        <% } %>
<%    } %>

<%    if (runSearch) { %>
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
          <td><img class="thumb" src="<%= request.getContextPath() %>/<%= img %>" alt="photo"/></td>
          <td><%= nm %></td>
          <td><%= gd %></td>
          <td><%= age %></td>
          <td><%= addr.isEmpty() ? "-" : addr %></td>
          <td>
            <% if (uid != userId) { %>
              <a href="searchFriends.jsp?q=<%= qEnc %>&add=1&friendId=<%= uid %>">Add Friend</a>
            <% } else { %> — <% } %>
          </td>
        </tr>
<%
        }
        if (!any) {
%>
        <tr><td colspan="6" style="text-align:center; color:#666;">No results found.</td></tr>
<%
        }
%>
      </table>
<%    } %>
<% } %>
  </div>

<%
  // --- Cleanup ---
  if (rs != null) try { rs.close(); } catch (Exception ignore) {}
  if (sf != null) try { sf.close(); } catch (Exception ignore) {}
  try { auth.close(); } catch (Exception ignore) {}
%>
</body>
