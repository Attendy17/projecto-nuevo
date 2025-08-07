<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="ut.JAR.CPEN410.FriendDAO" %>
<%@ page import="ut.JAR.CPEN410.MySQLCompleteConnector" %>
<%@ page import="java.sql.*" %>

<html>
<head>
  <meta charset="UTF-8">
  <title>Search Friends - minifacebook</title>
  
  <!-- Prevent browser from caching this page -->
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
  <meta http-equiv="Pragma" content="no-cache" />
  <meta http-equiv="Expires" content="0" />

  <style>
    /* Base reset */
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

    /* Header bar */
    .taskbar {
      background-color: #6F4E37;
      color: #fff;
      padding: 10px 20px;
      text-align: center;
    }

    /* Navigation bar */
    .nav-bar {
      background-color: #6F4E37;
      padding: 10px 20px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .nav-left {
      color: #fff;
      font-weight: bold;
    }

    .nav-right {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .nav-right a {
      color: #fff;
      text-decoration: none;
      font-weight: bold;
      padding: 6px 10px;
      border-radius: 4px;
      transition: background-color 0.3s ease;
    }

    .nav-right a:hover {
      background-color: #8c6d54;
    }

    /* Content container */
    .container {
      width: 90%;
      max-width: 1000px;
      margin: 20px auto;
      background-color: #fff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    h1 {
      color: #333;
      text-align: center;
      margin-bottom: 20px;
    }

    /* Search form styling */
    .search-form {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .search-form input, .search-form button {
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 4px;
      font-size: 14px;
    }

    .search-form button {
      background-color: #6F4E37;
      color: #fff;
      cursor: pointer;
    }

    /* Table styling for search results */
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }

    th, td {
      padding: 8px;
      border: 1px solid #ddd;
      text-align: left;
    }

    th {
      background-color: #6F4E37;
      color: #fff;
    }

    img {
      border-radius: 50%;
      object-fit: cover;
    }

    .action-link a {
      color: #6F4E37;
      text-decoration: none;
      font-weight: bold;
    }

    /* Mobile-first layout */
    [class*="col-"] {
      width: 100%;
    }

    /* Tablet view */
    @media only screen and (min-width: 600px) {
      .nav-bar {
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
      }

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

    /* Desktop view */
    @media only screen and (min-width: 768px) {
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
  </style>
</head>
<body>

<%
  // Retrieve the logged-in user's ID and username from the session
  Long userId = (Long) session.getAttribute("userId");
  String userName = (String) session.getAttribute("userName");

  // If the session does not have a valid user, redirect to login
  if (userId == null || userName == null) {
    response.sendRedirect("loginHashing.html");
    return;
  }
%>

<!-- Top header bar -->
<div class="taskbar col-12">
  <h1>minifacebook</h1>
</div>

<!-- Navigation menu -->
<div class="nav-bar col-12">
  <div class="nav-left col-6">Welcome, <%= userName %>!</div>
  <div class="nav-right col-6">
    <a href="welcomeMenu.jsp">Home</a>
    <a href="profile.jsp">Profile</a>
    <a href="friendList.jsp">Friend List</a>
    <a href="signout.jsp">Sign Out</a>
  </div>
</div>

<!-- Main content -->
<div class="container col-12">
  <h1>Search Friends</h1>
  
  <!-- Search form -->
  <form class="search-form col-12" action="searchFriends.jsp" method="get">
    <input type="text" id="searchQuery" name="searchQuery" placeholder="Search friends by name, location, etc." />
    <button type="submit">Search</button>
  </form>

<%
  // Get the search query parameter
  String searchQuery = request.getParameter("searchQuery");

  // If the user submitted a search term
  if (searchQuery != null && !searchQuery.trim().isEmpty()) {
    FriendDAO friendDAO = new FriendDAO();
    try {
      // Search friends based on the provided query
      ResultSet rs = friendDAO.searchFriends(searchQuery);
%>
  <!-- Results table -->
  <table class="col-12">
    <tr>
      <th>Name</th>
      <th>Age</th>
      <th>Address</th>
      <th>Profile Picture</th>
      <th>Action</th>
    </tr>
<%
      while(rs.next()) {
        String friendName = rs.getString("name");
        int age = rs.getInt("age");
        String friendTown = rs.getString("town");
        String friendState = rs.getString("state");
        String friendCountry = rs.getString("country");
        String profilePic = rs.getString("profile_picture");

        // Use default profile picture if none is provided
        if (profilePic == null || profilePic.trim().isEmpty()) {
          profilePic = "cpen410/imagesjson/default-profile.png";
        }

        // Build the address string
        String address = "";
        if (friendTown != null && !friendTown.trim().isEmpty()) {
          address += friendTown.trim();
        }
        if (friendState != null && !friendState.trim().isEmpty()) {
          address += (address.isEmpty() ? "" : ", ") + friendState.trim();
        }
        if (friendCountry != null && !friendCountry.trim().isEmpty()) {
          address += (address.isEmpty() ? "" : ", ") + friendCountry.trim();
        }
%>
    <tr>
      <td><%= friendName %></td>
      <td><%= age %></td>
      <td><%= address %></td>
      <td>
        <img src="<%= request.getContextPath() %>/<%= profilePic %>" alt="Profile Picture" width="50" height="50" />
      </td>
      <td class="action-link">
        <a href="addFriend.jsp?friendId=<%= rs.getLong("id") %>">Add Friend</a>
      </td>
    </tr>
<%
      }
      rs.close();
      friendDAO.close();
    } catch(Exception e) {
      out.println("Error searching for friends: " + e.getMessage());
      e.printStackTrace();
    }
  }
%>
  </table>
</div>

</body>
</html>
