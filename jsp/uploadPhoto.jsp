<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.nio.file.*, java.nio.charset.StandardCharsets" %>
<%@ page import="jakarta.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload2.jakarta.servlet5.JakartaServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload2.core.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload2.core.FileItem" %>
<%@ page import="ut.JAR.CPEN410.ProfileDAO" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Upload Photo - minifacebook</title>
  <style>body{font-family:Arial,sans-serif;background:#f8f9fa;text-align:center;margin:0}</style>
</head>
<body>
<%
    // ---- Session guard ----
    Long userId = (Long) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("loginHashing.jsp");
        return;
    }

    // ---- Page permission (Rule C.b) ----
    applicationDBAuthenticationGoodComplete auth = new applicationDBAuthenticationGoodComplete();
    String thisPage = "uploadPhoto.jsp";
    if (!auth.canUserAccessPage(userId, thisPage)) {
        auth.close();
        response.sendRedirect("profile.jsp?upload=0"); // no autorizado
        return;
    }
    auth.setLastPage(userId, thisPage);
    auth.close();

    // ---- Ensure multipart/form-data ----
    HttpServletRequest req = (HttpServletRequest) request;
    String contentType = req.getContentType();
    if (contentType == null || !contentType.toLowerCase().contains("multipart/form-data")) {
        response.sendRedirect("profile.jsp?upload=0");
        return;
    }

    // ---- Config upload ----
    int maxFileSize = 5 * 1024 * 1024; // 5MB
    String basePath = application.getRealPath("/") + "cpen410/imagesjson/";

    // Read fields: type=profile|post, caption (optional)
    String opType = "post"; // default
    String caption = "";

    String dstRelative = "";  // relative path to store in DB
    String dstFolder = "";    // physical folder absolute
    String savedRelative = ""; // final saved relative path

    DiskFileItemFactory factory = DiskFileItemFactory.builder()
                                  .setPath(basePath) // temp path
                                  .get();
    JakartaServletFileUpload upload = new JakartaServletFileUpload(factory);
    upload.setSizeMax(maxFileSize);

    try {
        List<FileItem> items = upload.parseRequest(req);
        if (items != null && !items.isEmpty()) {
            for (FileItem item : items) {
                if (item.isFormField()) {
                    String fn = item.getFieldName();
                    if ("type".equals(fn)) {
                        opType = (item.getString("UTF-8") == null) ? "post" : item.getString("UTF-8").trim().toLowerCase();
                    } else if ("caption".equals(fn)) {
                        caption = item.getString("UTF-8");
                        if (caption == null) caption = "";
                        if (caption.length() > 255) caption = caption.substring(0,255);
                    }
                }
            }
            // Choose folder by operation type
            if ("profile".equals(opType)) {
                dstFolder = basePath + "profile/";
                dstRelative = "cpen410/imagesjson/profile/";
            } else {
                dstFolder = basePath + "userpost/";
                dstRelative = "cpen410/imagesjson/userpost/";
            }
            File dir = new File(dstFolder);
            if (!dir.exists()) dir.mkdirs();

            // Iterate again for the file content
            for (FileItem item : items) {
                if (!item.isFormField()) {
                    String fileName = new File(item.getName()).getName();
                    if (fileName != null && !fileName.isEmpty()) {
                        String newFileName = userId + "_" + System.currentTimeMillis() + "_" + fileName;
                        Path path = FileSystems.getDefault().getPath(dstFolder + newFileName);
                        item.write(path);
                        savedRelative = dstRelative + newFileName;
                        break; // single file expected
                    }
                }
            }
        }
    } catch (Exception ex) {
        ex.printStackTrace();
        response.sendRedirect("profile.jsp?upload=0");
        return;
    }

    // ---- Persist in DB via DAO ----
    if (savedRelative != null && !savedRelative.isEmpty()) {
        ProfileDAO dao = new ProfileDAO();
        boolean ok = false;
        try {
            if ("profile".equals(opType)) {
                ok = dao.updateProfilePicture(userId, savedRelative);
                response.sendRedirect("profile.jsp?pp=" + (ok ? "1" : "0")); // pp = profile picture result
            } else {
                ok = dao.addUserPost(userId, savedRelative, caption);
                response.sendRedirect("profile.jsp?post=" + (ok ? "1" : "0"));
            }
            return;
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?upload=0");
            return;
        } finally {
            dao.close();
        }
    }

    response.sendRedirect("profile.jsp?upload=0");
%>
</body>
</html>
