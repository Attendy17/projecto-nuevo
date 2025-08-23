<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.Friendship" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%--
  addFriend.jsp
  Creates a friendship between session user and ?friendId using DAO classes.
  Redirects to friendList.jsp (?added=1 on success, ?added=0 otherwise).
  Notes: no SQL in JSP, statement-based DAOs, per-page permission check.
--%>
<%
  // Basic flow control
  Long userId = (Long) session.getAttribute("userId");
  boolean sessionOk = (userId != null);
  boolean allowed = false;
  String redirectUrl = null;

  applicationDBAuthenticationGoodComplete auth = null;

  if (!sessionOk) {
      redirectUrl = "loginHashing.jsp"; // not logged in
  } else {
      auth = new applicationDBAuthenticationGoodComplete();
      allowed = auth.canUserAccessPage(userId, "addFriend.jsp"); // page-level ACL

      if (allowed) {
          auth.setLastPage(userId, "addFriend.jsp");

          String fidParam = request.getParameter("friendId");
          boolean okParam = (fidParam != null && fidParam.matches("\\d+"));

          if (!okParam) {
              redirectUrl = "friendList.jsp?added=0";
          } else {
              long friendId = 0L;
              try { friendId = Long.parseLong(fidParam); } catch (Exception ignore) {}

              // guard: positive and not self
              if (friendId <= 0 || friendId == userId.longValue()) {
                  redirectUrl = "friendList.jsp?added=0";
              } else {
                  boolean ok = false;
                  Friendship f = new Friendship();
                  try {
                      ok = f.addFriend(userId, friendId);
                  } catch (Exception ex) {
                      ok = false; ex.printStackTrace();
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
    // single exit point
    response.sendRedirect(redirectUrl);
  %>
<% } else { %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Add Friend - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    /* grid: mobile-first, sample-based */
    * { box-sizing: border-box; }
    html { font-family: "Lucida Sans", sans-serif; }
    .row::after { content: ""; clear: both; display: table; }

    /* columns default to full width on mobile */
    [class*="col-"] { width: 100%; float: left; padding: 15px; }

    /* desktop widths */
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
    .header { background-color: #9933cc; color: #ffffff; padding: 15px; }
    .header h1 { margin: 0; font-size: 24px; font-weight: 700; text-align: center; }

    /* top taskbar with hover */
    .taskbar { background-color: #33b5e5; padding: 10px 15px; }
    .taskbar-nav { display: flex; flex-wrap: wrap; gap: 8px; list-style: none; margin: 0; padding: 0; }
    .taskbar-nav li { display: inline-block; }
    .taskbar-nav a {
      display: inline-block;
      text-decoration: none;
      color: #ffffff;
      padding: 8px 12px;
      border-radius: 4px;
      transition: background-color 0.2s ease, transform 0.1s ease;
    }
    .taskbar-nav a:hover { background-color: #0099cc; transform: translateY(-1px); }

    /* left menu */
    .menu ul { list-style-type: none; margin: 0; padding: 0; }
    .menu li {
      padding: 8px;
      margin-bottom: 7px;
      background-color: #33b5e5;
      color: #ffffff;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
      transition: background-color 0.2s ease;
    }
    .menu li:hover { background-color: #0099cc; }
    .menu li a { color: #ffffff; text-decoration: none; display: block; }

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

    /* main card */
    .content h1 { margin: 0 0 10px 0; font-size: 22px; }
    .card {
      background-color: #f7f9fb;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 16px;
      box-shadow: 0 1px 2px rgba(0,0,0,0.06), 0 1px 1px rgba(0,0,0,0.04);
    }
    .status { margin: 10px 0 0 0; color: #a33; font-weight: 600; text-align: center; }
    .links-center { margin-top: 12px; text-align: center; }
    .links-center a { color: #33b5e5; text-decoration: none; font-weight: 700; margin: 0 6px; }
    .links-center a:hover { color: #0099cc; }

    /* footer */
    .footer { background-color: #0099cc; color: #ffffff; text-align: center; font-size: 12px; padding: 15px; margin-top: 10px; }
  </style>
</head>
<body>

  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="friendList.jsp">Friends</a></li>
      <li><a href="searchFriends.jsp">Search</a></li>
      <li><a href="profile.jsp">Profile</a></li>
      <li><a href="logout.jsp">Logout</a></li>
    </ul>
  </nav>

  <div class="row">
    <div class="col-3 menu">
      <ul>
        <li><a href="friendList.jsp">Friends list</a></li>
        <li><a href="addFriend.jsp">Add friend</a></li>
        <li><a href="searchFriends.jsp">Find friends</a></li>
        <li><a href="welcomeMenu.jsp">Home</a></li>
      </ul>
    </div>

    <div class="col-6 content">
      <h1>Add Friend</h1>
      <div class="card">
        <p>You do not have permission to access this page or the action is not valid right now.</p>
        <p class="status">Access denied.</p>
        <div class="links-center">
          <a href="welcomeMenu.jsp">Go to Home</a> |
          <a href="friendList.jsp">View Friends</a> |
          <a href="searchFriends.jsp">Search Friends</a>
        </div>
      </div>
    </div>

    <div class="col-3 right">
      <div class="aside">
        <h2>Quick Help</h2>
        <p>To add a friend you need proper permissions and a valid <em>friendId</em>.</p>
        <h3>Where?</h3>
        <p>Use the search page or a users list.</p>
        <h3>How?</h3>
        <p>Select the user and confirm the request.</p>
      </div>
    </div>
  </div>

  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
<% } %>
