<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Welcome Menu - minifacebook</title>
    <style>
      /* Reset defaults */
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: Arial, sans-serif;
        font-size: 14px;
        background-color: #f8f9fa;
      }

      /* Top taskbar */
      .taskbar {
        background-color: #999fff; /* matches login header */
        color: #fff;
        padding: 10px 20px;
        text-align: center;
      }

      /* Navigation bar */
      .nav-bar {
        background-color: #999fff; /* same tone as header */
        padding: 10px 20px;
        display: flex;
        flex-direction: column;
        gap: 10px;
      }

      .nav-user {
        color: #fff;
        font-weight: bold;
      }

      .nav-links {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }

      .nav-links a {
        color: #fff;
        text-decoration: none;
        font-weight: bold;
        font-size: 14px;
        padding: 6px 10px;
        border-radius: 4px;
        transition: background-color 0.3s ease;
        background-color: #33b5e5; /* button color */
      }

      .nav-links a:hover {
        background-color: #0099cc; /* hover color */
      }

      /* Friend photos gallery */
      .friend-gallery {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        padding: 20px;
        gap: 20px;
      }

      .friend-photo {
        flex: 1 1 100%;
        max-width: 100%;
        text-align: center;
      }

      .friend-photo img {
        width: 100%;
        max-width: 200px;
        height: auto;
        border-radius: 4px;
      }

      .friend-photo p {
        margin-top: 5px;
        color: #333;
      }

      /* Responsive layout for tablets and above */
      @media screen and (min-width: 600px) {
        .col-1 { width: 8.33%; }
        .col-2 { width: 16.66%; }
        .col-3 { width: 25%; }
        .col-4 { width: 33.33%; }
        .col-5 { width: 41.66%; }
        .col-6 { width: 50%; }
        .col-7 { width: 58.33%; }
        .col-8 { width: 66.66%; }
        .col-9 { width: 75%; }
        .col-10 { width: 83.33%; }
        .col-11 { width: 91.66%; }
        .col-12 { width: 100%; }
      }

      @media screen and (min-width: 768px) {
        .nav-bar {
          flex-direction: row;
          justify-content: space-between;
          align-items: center;
        }

        .nav-links {
          flex-direction: row;
          flex-wrap: wrap;
        }

        .friend-photo {
          flex: 1 1 30%;
          max-width: 30%;
        }
      }
    </style>
  </head>
  <body>
<%
    Long userId = (Long) session.getAttribute("userId");

    if(userId == null) {
        response.sendRedirect("loginHashing.html");
        return;
    }

    String userName = (String) session.getAttribute("userName");
%>

    <div class="taskbar">
      <h1>MiniFacebook</h1>
    </div>

    <div class="nav-bar">
      <div class="nav-user">Welcome, <%= userName %>!</div>
      <div class="nav-links">
        <a href="profile.jsp">Profile</a>
        <a href="searchFriends.jsp">Search Friends</a>
        <a href="friendList.jsp">Friend List</a>
        <a href="signout.jsp">Sign Out</a>
      </div>
    </div>

    <div class="col-12" style="text-align:center; margin-top:20px;">
      <h2>Friend Photo Posts</h2>
    </div>

        <div class="friend-gallery">
<%
    // Cargar últimas fotos de amistades (máximo 30)
    ut.JAR.CPEN410.Friendship fr = new ut.JAR.CPEN410.Friendship();
    java.sql.ResultSet feed = null;
    try {
        feed = fr.getFriendsPhotos(userId, 30);

        boolean any = false;
        while (feed != null && feed.next()) {
            any = true;
            String img    = feed.getString("image_url"); // p.ej: cpen410/imagesjson/userpost/...
            String poster = feed.getString("name");      // nombre del amigo que publicó

            if (img == null || img.trim().isEmpty()) {
                img = "cpen410/imagesjson/default-profile.png";
            }
%>
      <div class="friend-photo">
        <img src="<%= request.getContextPath() %>/<%= img %>" alt="Friend Photo"/>
        <p><%= poster %></p>
      </div>
<%
        }

        if (!any) {
%>
      <p style="text-align:center; width:100%; color:#666;">No recent friend photos.</p>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
      <p style="text-align:center; width:100%; color:#a33;">Error loading friend posts.</p>
<%
    } finally {
        try { if (feed != null) feed.close(); } catch (Exception ignore) {}
        try { fr.close(); } catch (Exception ignore) {}
    }
%>
    </div>


  </body>
</html>
