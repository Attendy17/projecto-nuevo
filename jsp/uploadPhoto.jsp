<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="ut.JAR.CPEN410.AdminConn" %>
<%@ page import="java.util.*, java.io.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>

<%
  request.setCharacterEncoding("UTF-8");

  // ---- Auth ----
  Object user = session.getAttribute("user");
  if (user == null) {
    session.setAttribute("flash_err", "Please log in.");
    response.sendRedirect("loginHashing.html");
    return;
  }
  String role = (String) session.getAttribute("role");
  if (role == null || !role.equalsIgnoreCase("admin")) {
    session.setAttribute("flash_err", "Access denied");
    response.sendRedirect("adminDashboard.jsp");
    return;
  }

  // ---- Leer params (multipart con Commons FileUpload clásico o normal) ----
  boolean isMultipart = ServletFileUpload.isMultipartContent(request);
  Map<String,String> fields = new HashMap<String,String>();
  FileItem profileFileItem = null;

  if (isMultipart) {
    // Configuración de subida (misma idea que en tus páginas)
    int maxFileSize = 5 * 1024 * 1024; // 5MB
    String uploadPath = application.getRealPath("/") + "uploads/profile_pictures/";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setSizeThreshold(2 * 1024 * 1024); // 2MB memoria
    ServletFileUpload upload = new ServletFileUpload(factory);
    upload.setHeaderEncoding("UTF-8");
    // upload.setSizeMax(maxFileSize); // opcional

    try {
      List<FileItem> items = upload.parseRequest(request);
      if (items != null) {
        for (FileItem it : items) {
          if (it.isFormField()) {
            fields.put(it.getFieldName(), it.getString("UTF-8").trim());
          } else {
            if ("profilePicture".equals(it.getFieldName()) && it.getSize() > 0) {
              profileFileItem = it;
            }
          }
        }
      }
      // guardamos la ruta base absoluta para usarla al escribir el archivo
      fields.put("_uploadPathAbs", uploadPath);
    } catch (Exception ex) {
      session.setAttribute("flash_err", "Upload/parse error");
      response.sendRedirect("adminDashboard.jsp");
      return;
    }
  } else {
    // No multipart (password, address, education, delete photo, etc.)
    Enumeration<String> p = request.getParameterNames();
    while (p.hasMoreElements()) {
      String k = p.nextElement();
      fields.put(k, request.getParameter(k));
    }
  }

  String action = fields.get("action"); // puede ser null → default update_basic si vino multipart del form principal
  String idStr  = fields.get("id");
  long userId = -1L;
  try { if (idStr!=null && idStr.trim().length()>0) userId = Long.parseLong(idStr.trim()); } catch(Exception ign){}

  if (userId < 0) {
    String userIdAlt = fields.get("userId");
    try { if (userIdAlt!=null && userIdAlt.trim().length()>0) userId = Long.parseLong(userIdAlt.trim()); } catch(Exception ign){}
  }

  AdminConn admin = new AdminConn();
  boolean ok = false;
  String nextMsg = null;
  String nextErr = null;

  try {
    if (action == null || "update_basic".equalsIgnoreCase(action)) {
      // ---- Actualizar básicos ----
      String name      = fields.get("name");
      String email     = fields.get("email");
      String birthDate = fields.get("birthDate");
      String gender    = fields.get("gender");

      boolean basic = admin.updateUserBasic(userId, name, email, birthDate, gender);
      if (!basic) {
        nextErr = "Email duplicado o error al actualizar.";
      } else {
        ok = true;
        nextMsg = "User updated.";
      }

      // ---- Subir foto si vino archivo (Commons FileUpload clásico) ----
      if (profileFileItem != null && profileFileItem.getSize() > 0) {
        try {
          String uploadPathAbs = fields.get("_uploadPathAbs");
          if (uploadPathAbs == null) {
            uploadPathAbs = application.getRealPath("/") + "uploads/profile_pictures/";
            File fallback = new File(uploadPathAbs);
            if (!fallback.exists()) fallback.mkdirs();
          }

          String original = new File(profileFileItem.getName()).getName();
          String ext = "";
          int dot = original.lastIndexOf('.');
          if (dot >= 0) ext = original.substring(dot);
          String newFileName = userId + "_" + System.currentTimeMillis() + ext;

          File dest = new File(uploadPathAbs, newFileName);
          profileFileItem.write(dest); // FileUpload 1.x: write(File)

          // ruta relativa que usas en IMG src="/<relative>"
          String relative = "uploads/profile_pictures/" + newFileName;
          boolean ppOk = admin.updateProfilePicture(userId, relative);
          if (ppOk) {
            ok = true;
            nextMsg = (nextMsg==null? "Profile photo updated." : nextMsg + " Profile photo updated.");
          } else {
            nextErr = (nextErr==null? "Error al guardar ruta de foto." : nextErr + " Error al guardar ruta de foto.");
          }
        } catch(Exception upEx) {
          nextErr = (nextErr==null? "Error subiendo la foto." : nextErr + " Error subiendo la foto.");
        }
      }

    } else if ("clear_pp".equalsIgnoreCase(action)) {
      ok = admin.clearProfilePicture(userId);
      nextMsg = ok ? "Profile photo cleared." : null;
      if (!ok) nextErr = "No se pudo limpiar la foto de perfil.";

    } else if ("change_password".equalsIgnoreCase(action)) {
      String newPw = fields.get("newPassword");
      ok = admin.changePassword(userId, newPw);
      nextMsg = ok ? "Password updated." : null;
      if (!ok) nextErr = "No se pudo actualizar el password.";

    } else if ("upsert_address".equalsIgnoreCase(action)) {
      String street  = fields.get("street");
      String town    = fields.get("town");
      String state   = fields.get("state");
      String country = fields.get("country");
      ok = admin.upsertAddress(userId, street, town, state, country);
      nextMsg = ok ? "Address saved." : null;
      if (!ok) nextErr = "No se pudo guardar la dirección.";

    } else if ("add_education".equalsIgnoreCase(action)) {
      String degree = fields.get("degree");
      String school = fields.get("school");
      ok = admin.addEducation(userId, degree, school);
      nextMsg = ok ? "Education added." : null;
      if (!ok) nextErr = "No se pudo agregar education.";

    } else if ("update_education".equalsIgnoreCase(action)) {
      String eduIdStr = fields.get("eduId");
      long eduId = Long.parseLong(eduIdStr);
      String degree = fields.get("degree");
      String school = fields.get("school");
      ok = admin.updateEducation(eduId, degree, school);
      nextMsg = ok ? "Education updated." : null;
      if (!ok) nextErr = "No se pudo actualizar education.";

    } else if ("delete_education".equalsIgnoreCase(action)) {
      String eduIdStr = fields.get("eduId");
      long eduId = Long.parseLong(eduIdStr);
      ok = admin.deleteEducation(eduId);
      nextMsg = ok ? "Education deleted." : null;
      if (!ok) nextErr = "No se pudo borrar education.";

    } else if ("delete_photo".equalsIgnoreCase(action)) {
      String photoIdStr = fields.get("photoId");
      long photoId = Long.parseLong(photoIdStr);
      ok = admin.deletePhoto(photoId);
      nextMsg = ok ? "Photo deleted." : null;
      if (!ok) nextErr = "No se pudo borrar la foto.";

    } else if ("delete_user".equalsIgnoreCase(action)) {
      ok = admin.deleteUser(userId);
      if (ok) {
        try { admin.close(); } catch(Exception ignore){}
        session.setAttribute("flash_msg", "User deleted");
        response.sendRedirect("adminDashboard.jsp");
        return;
      } else {
        nextErr = "No se pudo borrar el usuario.";
      }

    } else {
      nextErr = "Acción no reconocida.";
    }

  } catch (Exception e) {
    e.printStackTrace();
    nextErr = "Error procesando la solicitud.";
  } finally {
    try { admin.close(); } catch(Exception ignore){}
  }

  // ---- Redirección con mensajes flash (sin URLEncoder) ----
  if (nextMsg != null) session.setAttribute("flash_msg", nextMsg);
  if (nextErr != null) session.setAttribute("flash_err", nextErr);

  if (userId > 0) {
    response.sendRedirect("editUser.jsp?id=" + userId);
  } else {
    response.sendRedirect("adminDashboard.jsp");
  }
%>
