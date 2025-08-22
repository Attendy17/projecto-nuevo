<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Add User (Admin) - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <style>
    :root{
      --brand:#999fff; --text:#333; --muted:#555; --border:#E2E2E2; --input:#ccc; --focus:#33B5E5;
      --bg:#f8f9fa; --ok:#2D6A2D; --error:#AA3333; --shadow:0 2px 10px rgba(0,0,0,.08);
      --shadow-lg:0 6px 24px rgba(0,0,0,.10); --radius:12px; --maxw:720px;
    }
    * { box-sizing:border-box; margin:0; padding:0; }
    body { font-family: Arial, sans-serif; background:var(--bg); color:var(--text); }
    .taskbar { position:sticky; top:0; z-index:10; background:var(--brand); color:#fff; }
    .bar-inner{ max-width:var(--maxw); margin:0 auto; padding:12px 16px; text-align:center; }
    .shell{ max-width:var(--maxw); margin:0 auto; padding:16px; }
    .container{ background:#fff; border-radius:var(--radius); border:1px solid var(--border);
      box-shadow:var(--shadow); padding:20px; }
    .title{ text-align:center; margin-bottom:8px; font-size:22px; }
    .section{ display:grid; grid-template-columns:1fr; gap:12px 16px; padding:10px 0 18px 0;
      border-top:1px dashed var(--border); margin-top:12px; }
    .section:first-of-type{ border-top:none; margin-top:4px; padding-top:6px; }
    @media (min-width:768px){ .section{ grid-template-columns:repeat(2, minmax(0,1fr)); } }
    .subtitle{ grid-column:1/-1; color:#333; font-size:16px; margin:6px 0 4px 0; }
    .form-group{ display:flex; flex-direction:column; gap:6px; }
    .form-group label{ font-weight:700; color:var(--muted); font-size:13px; }
    .form-group input, .form-group select{ width:100%; padding:10px 12px; border:1px solid var(--input);
      border-radius:8px; font-size:14px; background:#fff; transition:border-color .15s, box-shadow .15s; }
    .form-group input:focus, .form-group select:focus{
      outline:none; border-color:var(--focus); box-shadow:0 0 0 3px rgba(51,181,229,.20);
    }
    .form-buttons{ display:flex; gap:12px; flex-wrap:wrap; justify-content:space-between; margin-top:10px; padding-top:6px; border-top:1px dashed var(--border); }
    .btn{ border:none; border-radius:10px; padding:10px 18px; cursor:pointer; font-size:14px; font-weight:700; box-shadow:var(--shadow); flex:1 1 160px; }
    .btn-primary{ background:var(--focus); color:#fff; } .btn-primary:hover{ background:#0099CC; }
    .btn-secondary{ background:#e9ecef; } .btn-secondary:hover{ background:#dfe3e7; }
    .msg{ text-align:center; margin:10px 0 2px 0; font-weight:700; font-size:13px; }
    .msg.ok{ color:var(--ok); } .msg.error{ color:var(--error); }
    .nav { margin:8px 0 14px 0; text-align:center; }
    .nav a{ color:#33B5E5; text-decoration:none; font-weight:700; }
    .nav a:hover{ color:#0099CC; }
  </style>
</head>
<body>
  <header class="taskbar"><div class="bar-inner"><h1>MiniFacebook</h1></div></header>
  <main class="shell">
<%
  // --- Guard de sesión/rol: solo ADMIN
  Object u = session.getAttribute("user");
  String r = (String) session.getAttribute("role");
  if (u == null || r == null || !"ADMIN".equalsIgnoreCase(r)) {
      response.sendRedirect("loginHashing.jsp");
      return;
  }

  // Mensajes
  String err = null;
  String ok  = null;

  // ¿Procesamos POST?
  boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
  if (isPost) {
      String name     = request.getParameter("name");
      String email    = request.getParameter("email");
      String pass     = request.getParameter("password");
      String confirm  = request.getParameter("confirm");
      String birth    = request.getParameter("birth");
      String gender   = request.getParameter("gender");
      String street   = request.getParameter("street");
      String town     = request.getParameter("town");
      String state    = request.getParameter("state");
      String country  = request.getParameter("country");
      String degree   = request.getParameter("degree");
      String school   = request.getParameter("school");
      String roleCode = request.getParameter("roleCode"); // "ADMIN" o "USER"

      if (name==null||email==null||pass==null||confirm==null||birth==null||gender==null||
          street==null||town==null||state==null||country==null||degree==null||school==null||
          roleCode==null) {
          err = "Missing fields.";
      } else if (!pass.equals(confirm)) {
          err = "Passwords do not match.";
      } else if (pass.length() < 6) {
          err = "Password must be at least 6 characters.";
      } else if (!( "ADMIN".equalsIgnoreCase(roleCode) || "USER".equalsIgnoreCase(roleCode) )) {
          err = "Invalid role.";
      } else {
          AdminConn dao = new AdminConn();
          try {
              long newId = dao.createUserBasic(name, email, pass, birth, gender);
              if (newId <= 0) {
                  err = "Email already exists or could not create user.";
              } else {
                  boolean roleOK = dao.assignRoleToUser(newId, roleCode.toUpperCase());
                  boolean addrOK = dao.upsertAddress(newId, street, town, state, country);
                  boolean eduOK  = dao.addEducation(newId, degree, school);
                  if (roleOK) {
                      ok = "User created successfully (ID " + newId + ").";
                  } else {
                      err = "User created, but role assignment failed.";
                  }
              }
          } catch (Exception ex) {
              ex.printStackTrace();
              err = "Error creating user.";
          } finally {
              try { dao.close(); } catch(Exception ignore){}
          }
      }
  }
%>
    <div class="container">
      <div class="nav">
        <a href="adminDashboard.jsp">← Back to Dashboard</a>
      </div>
      <h2 class="title">Add New User (Admin)</h2>

      <% if (err != null) { %><div class="msg error"><%= err %></div><% } %>
      <% if (ok  != null) { %><div class="msg ok"><%= ok  %></div><% } %>

      <form action="addUserAD.jsp" method="post" autocomplete="off">
        <!-- Role -->
        <div class="section">
          <h3 class="subtitle">Role</h3>
          <div class="form-group">
            <label for="roleCode">Assign role</label>
            <select id="roleCode" name="roleCode" required>
              <option value="USER">USER</option>
              <option value="ADMIN">ADMIN</option>
            </select>
          </div>
        </div>

        <!-- Basic Info -->
        <div class="section">
          <h3 class="subtitle">Basic Info</h3>
          <div class="form-group">
            <label for="name">Full name</label>
            <input type="text" id="name" name="name" maxlength="100" required />
          </div>
          <div class="form-group">
            <label for="email">Email (must be unique)</label>
            <input type="email" id="email" name="email" maxlength="100" required />
          </div>
          <div class="form-group">
            <label for="password">Password (min 6 chars)</label>
            <input type="password" id="password" name="password" required />
          </div>
          <div class="form-group">
            <label for="confirm">Confirm Password</label>
            <input type="password" id="confirm" name="confirm" required />
          </div>
          <div class="form-group">
            <label for="birth">Birth date (YYYY-MM-DD)</label>
            <input type="date" id="birth" name="birth" required />
          </div>
          <div class="form-group">
            <label for="gender">Gender</label>
            <select id="gender" name="gender" required>
              <option value="">Select gender</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>

        <!-- Address -->
        <div class="section">
          <h3 class="subtitle">Address</h3>
          <div class="form-group">
            <label for="street">Street</label>
            <input type="text" id="street" name="street" required />
          </div>
          <div class="form-group">
            <label for="town">Town</label>
            <input type="text" id="town" name="town" required />
          </div>
          <div class="form-group">
            <label for="state">State</label>
            <input type="text" id="state" name="state" required />
          </div>
          <div class="form-group">
            <label for="country">Country</label>
            <input type="text" id="country" name="country" required />
          </div>
        </div>

        <!-- Education -->
        <div class="section">
          <h3 class="subtitle">Education</h3>
          <div class="form-group">
            <label for="degree">Degree</label>
            <select id="degree" name="degree" required>
              <option value="">(none)</option>
              <option value="High School Degree">High School Degree</option>
              <option value="Bachelor's Degree">Bachelor's Degree</option>
              <option value="Master's Degree">Master's Degree</option>
              <option value="Doctorate Degree">Doctorate Degree</option>
              <option value="Other">Other</option>
            </select>
          </div>
          <div class="form-group">
            <label for="school">School</label>
            <input type="text" id="school" name="school" required />
          </div>
        </div>

        <!-- Buttons -->
        <div class="form-buttons">
          <input class="btn btn-primary" type="submit" value="Create User" />
          <input class="btn btn-secondary" type="reset" value="Reset" />
        </div>
      </form>
    </div>
  </main>
</body>
</html>
