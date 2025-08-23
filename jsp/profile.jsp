<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="ut.JAR.CPEN410.Profile" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.sql.ResultSet, java.sql.Date" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>My Profile - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <style>
    /* responsive grid (mobile-first columns) */
    * { box-sizing: border-box; }
    html { font-family: "Lucida Sans", sans-serif; }
    body { background-color: #ffffff; margin: 0; color:#333; }

    .row::after { content: ""; clear: both; display: table; }

    /* full-width on mobile */
    [class*="col-"] { float: left; width: 100%; padding: 15px; }

    /* desktop column widths */
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

    /* header */
    .header { background-color: #9933cc; color: #ffffff; text-align: center; padding: 15px; }
    .header h1 { margin: 0; font-size: 24px; font-weight: 700; }
    .sub { font-size: 12px; color: #efeaff; margin-top: 4px; }

    /* top taskbar with hover */
    .taskbar { background-color: #33b5e5; padding: 10px 15px; }
    .taskbar-nav {
      display: flex; flex-wrap: wrap; gap: 8px;
      list-style: none; margin: 0; padding: 0; justify-content: center;
    }
    .taskbar-nav li { display: inline-block; }
    .taskbar-nav a {
      display: inline-block; text-decoration: none; color: #ffffff;
      padding: 8px 12px; border-radius: 4px;
      transition: background-color 0.2s ease, transform 0.1s ease;
    }
    .taskbar-nav a:hover { background-color: #0099cc; transform: translateY(-1px); }

    /* left menu */
    .menu ul { list-style-type: none; margin: 0; padding: 0; }
    .menu li {
      padding: 8px; margin-bottom: 7px; background-color: #33b5e5; color: #ffffff;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px; transition: background-color 0.2s ease;
    }
    .menu li:hover { background-color: #0099cc; }
    .menu li a { color: #ffffff; text-decoration: none; display: block; }

    /* right aside */
    .aside {
      background-color: #33b5e5; padding: 15px; color: #ffffff; text-align: center; font-size: 14px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
    }

    /* reusable card */
    .box {
      background-color: #f1f1f1; border-radius: 5px; box-shadow: 0 0 10px #ccc; padding: 20px;
      border: 1px solid #e2e2e2;
    }

    .title { text-align: center; margin-bottom: 12px; }
    .center { text-align: center; }

    /* profile avatar */
    .avatar-wrap { text-align: center; margin: 10px 0 16px 0; }
    .avatar { width: 140px; height: 140px; border-radius: 50%; object-fit: cover; }

    /* key-value details */
    .kv { display: grid; grid-template-columns: 160px 1fr; gap: 8px 14px; }
    .kv .k { font-weight: bold; color: #333; }
    .kv .v { color: #222; }

    /* links row */
    .links { text-align: center; margin-top: 16px; }
    .links a { color: #33b5e5; text-decoration: none; font-weight: bold; margin: 0 8px; }
    .links a:hover { color: #0099cc; }

    /* file + button */
    .file { width: 100%; max-width: 320px; }
    .btn {
      background-color: #33b5e5; color:#fff; border:0; border-radius:3px;
      padding: 8px 14px; cursor:pointer; font-weight: 700;
    }
    .btn:hover { background-color:#0099cc; }

    /* gallery */
    .gallery { display:flex; flex-wrap:wrap; gap:12px; justify-content:center; }
    .photo-card { width: 220px; border:1px solid #ddd; border-radius:6px; background:#fff; padding:10px; text-align:center; }
    .thumb { width: 200px; height: auto; border-radius:4px; }
    .note { margin-top:6px; color:#666; font-size:12px; text-align:center; }

    /* footer */
    .footer { background-color: #0099cc; color: #ffffff; text-align: center; font-size: 12px; padding: 15px; margin-top: 10px; }
  </style>
</head>
<body>
<%
  // session guard
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) { response.sendRedirect("loginHashing.jsp"); return; }
  String userName = (String) session.getAttribute("userName");

  // page permission + last page tracking
  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String thisPage = "profile.jsp";
  boolean allowed = auth.canUserAccessPage(userId, thisPage);
  if (allowed) { auth.setLastPage(userId, thisPage); }
%>

  <!-- header -->
  <div class="header">
    <h1>MiniFacebook</h1>
    <div class="sub"><%= allowed ? ("Logged in as: " + (userName==null?"User":userName)) : "Access denied" %></div>
  </div>

  <!-- taskbar with hover -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="friendList.jsp">Friends</a></li>
      <li><a href="searchFriends.jsp">Search</a></li>
      <li><a href="profile.jsp">Profile</a></li>
      <li><a href="signout.jsp">Sign Out</a></li>
    </ul>
  </nav>

  <!-- three-column layout -->
  <div class="row">

    <!-- left menu (col-3 desktop; full width on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="profile.jsp">My Profile</a></li>
        <li><a href="friendList.jsp">Friend List</a></li>
        <li><a href="searchFriends.jsp">Find Friends</a></li>
        <li><a href="welcomeMenu.jsp">Home</a></li>
      </ul>
    </div>

    <!-- main content (col-6 desktop; full width on mobile) -->
    <div class="col-6 content">
<%
  if (!allowed) {
      try { auth.close(); } catch (Exception ignore) {}
%>
      <div class="box">
        <div class="title"><h2>My Profile</h2></div>
        <p class="center" style="c
