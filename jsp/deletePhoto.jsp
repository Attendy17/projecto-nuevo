<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="ut.JAR.CPEN410.Profile" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Delete Photo</title></head><body>
<%
  Long userId = (Long) session.getAttribute("userId");
  if (userId == null) { response.sendRedirect("loginHashing.jsp"); return; }

  applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
  String thisPage = "deletePhoto.jsp";
  if (!auth.canUserAccessPage(userId, thisPage)) {
      auth.close();
      response.sendRedirect("profile.jsp"); 
      return;
  }
  auth.setLastPage(userId, thisPage);

  String idParam = request.getParameter("photoId");
  boolean ok = false;
  if (idParam != null && idParam.matches("\\d+")) {
      long pid = Long.parseLong(idParam);
      Profile p = new Profile();
      try { ok = p.deleteUserPost(userId, pid); } catch(Exception ex){} 
      finally { try { p.close(); } catch(Exception ig){} }
  }
  auth.close();
  response.sendRedirect("profile.jsp");
%>
</body></html>
