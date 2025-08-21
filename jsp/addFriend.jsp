<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.Friendship" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%--
  ============================================================================
  File: addFriend.jsp
  Purpose:
    - Create a friendship between the logged-in user (session.userId)
      and the target user (?friendId) through ut.JAR.CPEN410.Friendship.
    - Redirect to friendList.jsp with ?added=1 on success, ?added=0 otherwise.

  Course constraints:
    - No connection strings nor SQL in JSP (Rule C.a): all DB access is in Java classes.
    - Statement-based only (NO PreparedStatement).
    - Every page must validate permissions (Rule C.b).
  ============================================================================
--%>
<%
  // ---------- Control flow (no stray 'return;' at the end) ----------
  Long userId = (Long) session.getAttribute("userId");
  boolean sessionOk = (userId != null);
  boolean allowed = false;
  String redirectUrl = null;

  applicationDBAuthenticationGoodComplete auth = null;

  if (!sessionOk) {
      // Not logged in -> go to login
      redirectUrl = "loginHashing.jsp";
  } else {
      auth = new applicationDBAuthenticationGoodComplete();

      // Page-level authorization (Rule C.b)
      allowed = auth.canUserAccessPage(userId, "addFriend.jsp");

      if (allowed) {
          // Track last visited page
          auth.setLastPage(userId, "addFriend.jsp");

          // Validate friendId parameter
          String fidParam = request.getParameter("friendId");
          boolean okParam = (fidParam != null && fidParam.matches("\\d+"));

          if (!okParam) {
              redirectUrl = "friendList.jsp?added=0";
          } else {
              long friendId = 0L;
              try { friendId = Long.parseLong(fidParam); } catch (Exception ignore) {}

              if (friendId <= 0 || friendId == userId.longValue()) {
                  redirectUrl = "friendList.jsp?added=0";
              } else {
                  // Create friendship (symmetric) via DAO
                  boolean ok = false;
                  Friendship f = new Friendship();
                  try {
                      ok = f.addFriend(userId, friendId);
                  } catch (Exception ex) {
                      ok = false;
                      ex.printStackTrace();
                  } finally {
                      try { f.close(); } catch (Exception ignore) {}
                  }

                  redirectUrl = ok ? "friendList.jsp?added=1" : "friendList.jsp?added=0";
              }
          }
      }

      try { auth.close(); } catch (Exception ignore) {}
  }
%>
<% if (redirectUrl != null) { %>
    <%
      // Single redirect point. No HTML after this branch.
      response.sendRedirect(redirectUrl);
    %>
<% } else { %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <!-- Responsive view as in the guide -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Add Friend - MiniFacebook</title>
  <style>
    /* Base styles (same look & feel, now with padding reset) */
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

    /* Row with clearfix (as in the guide) */
    .row::after {
      content: "";
      clear: both;
      display: table;
    }

    /* Mobile-first columns (as in the guide) */
    [class*="col-"] {
      float: left;
      width: 100%;
      padding: 15px;
    }

    /* Desktop grid system (as in the guide) */
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

    /* Header (same original palette) */
    .header {
      background-color: #999fff;
      color: #fff;
      text-align: center;
      padding: 15px;
      border: 0;
    }

    .header h1 {
      margin: 0;
      font-weight: 600;
    }

    /* Center box */
    .login-box {
      background-color: #f1f1f1;
      padding: 20px;
      border-radius: 5px;
      box-shadow: 0 0 10px #ccc;
      margin-top: 20px;
    }

    .login-box h2 {
      text-align: center;
      margin-bottom: 15px;
      font-weight: 600;
    }

    /* Error message */
    .msg {
      text-align: center;
      color: #a33;
      margin: 15px 0 20px 0;
    }

    /* Navigation links */
    .links {
      text-align: center;
      margin-top: 10px;
    }

    .links a {
      color: #33b5e5;
      text-decoration: none;
      font-weight: bold;
      margin: 0 6px;
    }

    .links a:hover {
      color: #0099cc;
    }
  </style>
</head>
<body>
  <!-- Main Header -->
  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="login-box">
        <h2>Add Friend</h2>
        <div class="msg">
          Access Denied: your role is not authorized for this page.
        </div>
        <div class="links">
          <a href="welcomeMenu.jsp">Home</a> |
          <a href="friendList.jsp">Friend List</a> |
          <a href="searchFriends.jsp">Search Friends</a>
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>
</body>
</html>
<% } %>

