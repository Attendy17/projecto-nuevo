<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Delete User - MiniFacebook</title>
  <style>
    *{box-sizing:border-box;margin:0;padding:0;}
    body{font-family:Arial, sans-serif;background:#f8f9fa;color:#333;}
    .taskbar{background:#999fff;color:#fff;text-align:center;padding:12px 16px;}
    .wrap{max-width:720px;margin:28px auto;background:#fff;border:1px solid #e2e2e2;
          border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,.08);padding:24px;}
    h1{font-size:20px;text-align:center;margin-bottom:8px;color:#222;}
    .msg{margin:14px 0;text-align:center;font-weight:700;}
    .ok{color:#2d6a2d;}
    .err{color:#a33;}
    .actions{display:flex;gap:10px;justify-content:center;margin-top:16px;flex-wrap:wrap;}
    .btn{display:inline-block;padding:10px 16px;border-radius:8px;border:1px solid #e2e2e2;
         background:#e9ecef;color:#333;text-decoration:none;font-weight:700;min-width:160px;text-align:center;}
    .btn:hover{background:#dfe3e7;}
  </style>
</head>
<body>

<div class="taskbar"><h1>MiniFacebook</h1></div>
<div class="wrap">
  <h1>Delete User</h1>

  <div class="msg">
<%
    // 1) Session guard
    Long adminId = (Long) session.getAttribute("userId");
    if (adminId == null) {
%>
      <div class="err">You must be signed in.</div>
      <div class="actions">
        <a class="btn" href="loginHashing.jsp">Go to Login</a>
      </div>
<%
    } else {
        // 2) ACL + last_page
        applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
        String pageName = "deleteUser.jsp";
        boolean allowed = auth.canUserAccessPage(adminId, pageName);
        if (allowed) auth.setLastPage(adminId, pageName);

        if (!allowed) {
            auth.close();
%>
      <div class="err">Access denied.</div>
      <div class="actions">
        <a class="btn" href="welcomeMenu.jsp">Go to Home</a>
      </div>
<%
        } else {
            // 3) Procesar parámetro id
            String idParam = request.getParameter("id");
            boolean ok = false;
            String message = "";

            if (idParam != null && idParam.matches("\\d+")) {
                long targetId = Long.parseLong(idParam);

                if (targetId == adminId.longValue()) {
                    ok = false;
                    message = "You cannot delete your own account.";
                } else {
                    AdminConn dao = new AdminConn();
                    try {
                        ok = dao.deleteUser(targetId);
                        message = ok ? "User deleted successfully." : "User not found or not deleted.";
                    } catch (Exception e) {
                        ok = false;
                        message = "Error deleting user.";
                    } finally {
                        try { dao.close(); } catch (Exception ignore) {}
                    }
                }
            } else {
                ok = false;
                message = "Invalid or missing user id.";
            }

            auth.close();
%>
      <div class="<%= (ok ? "ok" : "err") %>"><%= message %></div>
      <div class="actions">
        <a class="btn" href="adminDashboard.jsp">Back to Admin Dashboard</a>
      </div>
<%
        }
    }
%>
  </div>
</div>
</body>
</html>
