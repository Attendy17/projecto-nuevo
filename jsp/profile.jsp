<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="ut.JAR.CPEN410.Profile" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.sql.ResultSet, java.sql.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>My Profile - MiniFacebook</title>
  <style>
    /* Same visual style as your login page */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html { font-family: "Lucida Sans", sans-serif; }
    body { background-color: #ffffff; margin: 0; }
    .row::after { content: ""; clear: both; display: table; }
    [class*="col-"] { float: left; width: 100%; padding: 15px; }

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

    .header { background-color: #999fff; color: white; text-align: center; padding: 15px; }
    .box { background-color: #f1f1f1; border-radius: 5px; box-shadow: 0 0 10px #ccc; padding: 20px; }

    .title { text-align: center; margin-bottom: 12px; }
    .avatar-wrap { text-align: center; margin: 10px 0 16px 0; }
    .avatar { width: 140px; height: 140px; border-radius: 50%; object-fit: cover; }

    .kv { display: grid; grid-template-columns: 160px 1fr; gap: 8px 14px; }
    .kv .k { font-weight: bold; color: #333; }
    .kv .v { color: #222; }

    .links { text-align: center; margin-top: 16px; }
    .links a { color: #33b5e5; text-decoration: none; font-weight: bold; margin: 0 8px; }
    .links a:hover { color: #0099cc; }
      .center { text-align: center; }
    .file { width: 100%; max-width: 320px; }
    .btn {
    background-color: #33b5e5; color:#fff; border:0; border-radius:3px;
    padding: 8px 14px; cursor:pointer;
  }
  .btn:hover { background-color:#0099cc; }

  .gallery { display:flex; flex-wrap:wrap; gap:12px; justify-content:center; }
  .photo-card { width: 220px; border:1px solid #ddd; border-radius:6px; background:#fff; padding:10px; text-align:center; }
  .thumb { width: 200px; height: auto; border-radius:4px; }
  .note { margin-top:6px; color:#666; font-size:12px; text-align:center; }

    
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
  String thisPage = "profile.jsp";
  if (!auth.canUserAccessPage(userId, thisPage)) {
      auth.close();
%>
  <div class="header"><h1>MiniFacebook</h1></div>
  <div class="row"><div class="col-3"></div>
    <div class="col-6"><div class="box">
      <div class="title"><h2>My Profile</h2></div>
      <p style="text-align:center; color:#a33;">Access Denied: your role is not authorized for this page.</p>
      <div class="links">
        <a href="welcomeMenu.jsp">Home</a> |
        <a href="searchFriends.jsp">Search Friends</a> |
        <a href="friendList.jsp">Friend List</a> |
        <a href="signout.jsp">Sign Out</a>
      </div>
    </div></div>
    <div class="col-3"></div>
  </div>
</body>
</html>
<%
      return;
  }
  auth.setLastPage(userId, thisPage);

  // --- DAO: profile + photos
  Profile p = new Profile();

  // Basic profile
  ResultSet rs = p.getOwnProfile(userId);
  String name = "-";
  String email = "-";
  String town = "-";
  String pic = "cpen410/imagesjson/default-profile.png";
  Date dob = null;

  if (rs != null && rs.next()) {
      String tmp;
      tmp = rs.getString("name"); if (tmp != null && tmp.trim().length() > 0) name = tmp;
      tmp = rs.getString("email"); if (tmp != null && tmp.trim().length() > 0) email = tmp;
      tmp = rs.getString("town"); if (tmp != null && tmp.trim().length() > 0) town = tmp;
      tmp = rs.getString("profile_picture");
      if (tmp != null && tmp.trim().length() > 0) pic = tmp;
      dob = rs.getDate("birth_date");
  }
  if (rs != null) try { rs.close(); } catch (Exception ignore) {}

  // Photo gallery (images)
  ResultSet rsPhotos = p.getUserPhotos(userId);

  // close auth (DAO p lo cerramos después de la galería)
  auth.close();
%>

  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <!-- BOX: Datos del perfil -->
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="box">
        <div class="title"><h2>My Profile</h2></div>

        <div class="avatar-wrap">
          <img class="avatar" src="<%= request.getContextPath() %>/<%= pic %>" alt="Profile Picture"/>
        </div>

        <div class="kv">
          <div class="k">Name</div>
          <div class="v"><%= name %></div>

          <div class="k">Email</div>
          <div class="v"><%= email %></div>

          <div class="k">Birthday</div>
          <div class="v"><%= (dob == null ? "-" : dob.toString()) %></div>

          <div class="k">Town</div>
          <div class="v"><%= town %></div>
        </div>

        <div class="links">
          <a href="welcomeMenu.jsp">Home</a>
          <a href="searchFriends.jsp">Search Friends</a>
          <a href="friendList.jsp">Friend List</a>
          <a href="signout.jsp">Sign Out</a>
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>

  <!-- BOX: Cambiar foto de perfil -->
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="box">
        <div class="title"><h2>Change Profile Picture</h2></div>
        <div class="center">
          <form action="uploadPhoto.jsp" method="post" enctype="multipart/form-data">
            <input type="hidden" name="target" value="profile"/>
            <input class="file" type="file" name="photoFile" accept="image/*" required />
            <div style="margin-top:10px;">
              <button class="btn" type="submit">Update Profile Picture</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>

  <!-- BOX: Publicar foto -->
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="box">
        <div class="title"><h2>Publish New Photo</h2></div>
        <div class="center">
          <form action="uploadPhoto.jsp" method="post" enctype="multipart/form-data">
            <input type="hidden" name="target" value="post"/>
            <input class="file" type="file" name="photoFile" accept="image/*" required />
            <div style="margin-top:10px;">
              <button class="btn" type="submit">Publish</button>
            </div>
          </form>   
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>

  <!-- BOX: Galería -->
  <div class="row">
    <div class="col-3"></div>
    <div class="col-6">
      <div class="box">
        <div class="title"><h2>My Photo Gallery</h2></div>

        <div class="gallery">
<%
          boolean any = false;
          while (rsPhotos != null && rsPhotos.next()) {
              any = true;
              long photoId = rsPhotos.getLong("id");
              String imageUrl = rsPhotos.getString("image_url");
%>
          <div class="photo-card">
            <img class="thumb" src="<%= request.getContextPath() %>/<%= imageUrl %>" alt="Photo"/>
            <form action="deletePhoto.jsp" method="post" onsubmit="return confirm('Delete this photo?');">
              <input type="hidden" name="photoId" value="<%= photoId %>"/>
              <div style="margin-top:6px;">
                <button class="btn" type="submit">Delete</button>
              </div>
            </form>
          </div>
<%
          }
          if (!any) {
%>
          <p class="center" style="width:100%;">No photos yet.</p>
<%
          }
          if (rsPhotos != null) try { rsPhotos.close(); } catch (Exception ignore) {}
          p.close();
%>
        </div>
      </div>
    </div>
    <div class="col-3"></div>
  </div>
</body>
</html>