<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%@ page import="ut.JAR.CPEN410.applicationDBAuthenticationGoodComplete" %>
<%@ page import="java.util.*, java.io.*, java.nio.file.*" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.apache.commons.fileupload2.jakarta.servlet5.JakartaServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload2.core.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload2.core.FileItem" %>
<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();
    if (ctx == null) ctx = "";

    String redirect = null;

    // --- Session guard ---
    Long adminId = (Long) session.getAttribute("userId");
    if (adminId == null) {
        redirect = "loginHashing.jsp";
    }

    // --- Role guard ---
    if (redirect == null) {
        String role = (String) session.getAttribute("role");
        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            redirect = "welcomeMenu.jsp?err=1";
        }
    }

    // --- ACL (usa editUser.jsp para no chocar con permisos) ---
    applicationDBAuthenticationGoodComplete auth = null;
    if (redirect == null) {
        auth = new applicationDBAuthenticationGoodComplete();
        String thisPage = "editUser.jsp"; // <--- importante
        if (!auth.canUserAccessPage(adminId, thisPage)) {
            redirect = "welcomeMenu.jsp?err=1";
        } else {
            auth.setLastPage(adminId, thisPage);
        }
    }

    // Variables comunes
    String action = null;
    long userId = -1L;

    // BASIC
    String name = null, email = null, birth = null, gender = null, password = null;

    // ADDRESS
    String street = null, town = null, state = null, country = null;

    // Education / Photos
    String eduIdStr = null;
    String degree = null, school = null;
    String photoIdStr = null;

    // Password independiente (form "change_password")
    String newPassword = null;

    // Foto de perfil (ruta relativa si sube archivo)
    String newProfileRelPath = null;

    boolean isMultipart = false;
    String ctype = request.getContentType();
    if (ctype != null && ctype.toLowerCase().contains("multipart/form-data")) {
        isMultipart = true;
    }

    try {
        if (redirect == null) {
            if (isMultipart) {
                // --- MULTIPART (Commons FileUpload v2) ---
                String baseProfileDir = application.getRealPath("/") + "cpen410/imagesjson/profile/";
                File profDir = new File(baseProfileDir);
                if (!profDir.exists()) profDir.mkdirs();

                DiskFileItemFactory factory = DiskFileItemFactory.builder()
                    .setPath(profDir.getAbsolutePath())
                    .get();

                JakartaServletFileUpload upload = new JakartaServletFileUpload(factory);
                upload.setSizeMax(10L * 1024L * 1024L); // 10MB

                List<FileItem> items = upload.parseRequest(request);
                if (items != null) {
                    for (FileItem it : items) {
                        if (it.isFormField()) {
                            String fn = it.getFieldName();
                            String val = it.getString(StandardCharsets.UTF_8);

                            if ("action".equals(fn))           action = val;
                            else if ("id".equals(fn))          { try { userId = Long.parseLong(val); } catch(Exception ig){} }
                            else if ("name".equals(fn))         name = val;
                            else if ("email".equals(fn))        email = val;
                            else if ("birth".equals(fn) || "birthDate".equals(fn)) birth = val;
                            else if ("gender".equals(fn))       gender = val;
                            else if ("password".equals(fn))     password = val;
                            else if ("newPassword".equals(fn))  newPassword = val; // para change_password

                            else if ("street".equals(fn))       street = val;
                            else if ("town".equals(fn))         town = val;
                            else if ("state".equals(fn))        state = val;
                            else if ("country".equals(fn))      country = val;

                            else if ("eduId".equals(fn))        eduIdStr = val;
                            else if ("degree".equals(fn))       degree = val;
                            else if ("school".equals(fn))       school = val;

                            else if ("photoId".equals(fn))      photoIdStr = val;
                        } else {
                            // Archivo: profilePicture
                            if ("profilePicture".equals(it.getFieldName())) {
                                String fileName = new File(it.getName()).getName();
                                if (fileName != null && !fileName.trim().isEmpty() && userId > 0) {
                                    String newName = userId + "_" + System.currentTimeMillis() + "_" + fileName;
                                    File target = new File(profDir, newName);
                                    it.write(target.toPath());
                                    newProfileRelPath = "cpen410/imagesjson/profile/" + newName;
                                }
                            }
                        }
                    }
                }
            } else {
                // --- FORM NORMAL ---
                action  = request.getParameter("action");
                try { userId = Long.parseLong(request.getParameter("id")); } catch(Exception ig) {}

                name    = request.getParameter("name");
                email   = request.getParameter("email");
                birth   = request.getParameter("birth");
                if (birth == null || birth.isEmpty()) birth = request.getParameter("birthDate");
                gender  = request.getParameter("gender");
                password= request.getParameter("password");
                newPassword = request.getParameter("newPassword"); // para change_password

                street  = request.getParameter("street");
                town    = request.getParameter("town");
                state   = request.getParameter("state");
                country = request.getParameter("country");

                eduIdStr= request.getParameter("eduId");
                degree  = request.getParameter("degree");
                school  = request.getParameter("school");

                photoIdStr = request.getParameter("photoId");
            }

            // --- Normalización de acciones (acepta las tuyas) ---
            if (action != null) {
                String a = action.trim().toLowerCase(Locale.ROOT);
                if ("update_basic".equals(a))        action = "basic";
                else if ("upsert_address".equals(a)) action = "addr";
                else if ("add_education".equals(a))  action = "addEdu";
                else if ("update_education".equals(a)) action = "updEdu";
                else if ("delete_education".equals(a)) action = "delEdu";
                else if ("delete_photo".equals(a))   action = "delPhoto";
                else if ("clear_pp".equals(a))       action = "clrPic";
                // "change_password" se deja tal cual y se maneja abajo
            }

            if (action == null || userId <= 0) {
                redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&err=1";
            } else {
                AdminConn dao = new AdminConn();
                boolean ok = false;

                try {
                    switch (action) {
                        case "basic": {
                            ok = dao.updateUserBasic(userId, name, email, birth, gender);
                            if (!ok) { redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&err=1"; break; }
                            if (password != null && password.trim().length() > 0) {
                                dao.changePassword(userId, password);
                            }
                            if (newProfileRelPath != null && newProfileRelPath.trim().length() > 0) {
                                dao.updateProfilePicture(userId, newProfileRelPath);
                            }
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&ok=1";
                            break;
                        }
                        case "addr": {
                            ok = dao.upsertAddress(userId, street, town, state, country);
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "addEdu": {
                            ok = dao.addEducation(userId, degree, school);
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "updEdu": {
                            long eduId = -1;
                            try { eduId = Long.parseLong(eduIdStr); } catch(Exception ig){}
                            if (eduId <= 0) { redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&err=1"; break; }
                            ok = dao.updateEducation(eduId, degree, school);
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "delEdu": {
                            long eduId = -1;
                            try { eduId = Long.parseLong(eduIdStr); } catch(Exception ig){}
                            if (eduId <= 0) { redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&err=1"; break; }
                            ok = dao.deleteEducation(eduId);
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "delPhoto": {
                            long photoId = -1;
                            try { photoId = Long.parseLong(photoIdStr); } catch(Exception ig){}
                            if (photoId <= 0) { redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&err=1"; break; }
                            ok = dao.deletePhoto(photoId);
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "clrPic": {
                            ok = dao.clearProfilePicture(userId);
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "setDefaultPic": {
                            ok = dao.updateProfilePicture(userId, "cpen410/imagesjson/default-profile.png");
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        case "change_password": { // ← tu formulario separado
                            if (newPassword != null && newPassword.trim().length() > 0) {
                                ok = dao.changePassword(userId, newPassword);
                            }
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + (ok ? "&ok=1" : "&err=1");
                            break;
                        }
                        default: {
                            redirect = ctx + "/cpen410/editUser.jsp?id=" + userId + "&err=1";
                            break;
                        }
                    }
                } catch (Exception daoEx) {
                    daoEx.printStackTrace();
                    redirect = (ctx == null ? "" : ctx) + "/cpen410/editUser.jsp?id=" + userId + "&err=1";
                } finally {
                    try { dao.close(); } catch(Exception ignore){}
                }
            }
        }
    } catch (Exception ex) {
        ex.printStackTrace();
        if (redirect == null) {
            redirect = (ctx == null ? "" : ctx) + "/cpen410/editUser.jsp?id=" + (userId>0?userId:0) + "&err=1";
        }
    } finally {
        try { if (auth != null) auth.close(); } catch (Exception ignore) {}
    }

    if (redirect == null) {
        redirect = (ctx == null ? "" : ctx) + "/cpen410/adminDashboard.jsp";
    }

    response.sendRedirect(redirect);
%>
