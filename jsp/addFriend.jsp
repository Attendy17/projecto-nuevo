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
  <meta charset="UTF-8"/>
  <title>Add Friend - MiniFacebook</title>
  <style>
    /* Same look as login, without padding anywhere */
    * { box-sizing: border-box; margin: 0; }
    html { font-family: "Lucida Sans", sans-serif; }
    body { background-color: #ffffff; margin: 0; }
    .row::after { content: ""; display: table; clear: both; }
    [class*="col-"] { float: left; width: 100%; margin: 0; }
    @media only screen and (min-width: 768px) { .col-3 { width:25%; } .col-6 { width:50%; } }
    .header { background:#999fff; color:#fff; text-align:center; border:0; }
    .header h1 { margin:14px 0 2px 0; font-weight:600; }
    .login-box { background:#f1f1f1; border-radius:5px; box-shadow:0 0 10px #ccc; margin:18px 0; }
    .login-box h2 { text-align:center; margin:18px 0 12px 0; font-weight:600; }
    .msg { text-align:center; color:#a33; margin:14px 0 18px 0; }
    .links { text-align:center; margin:8px 0 14px 0; }
    .links a { color:#33b5e5; text-decoration:none; font-weight:bold; margin:0 6px; }
    .links a:hover { color:#0099cc; }
  </style>
</head>
<body>
  <div class="header"><h1>MiniFacebook</h1></div>
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="login-box">
        <h2>Add Friend</h2>
        <div class="msg">Access Denied: your role is not authorized for this page.</div>
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
