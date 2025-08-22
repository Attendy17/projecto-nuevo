<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ut.JAR.CPEN410.UserNew" %>
<%
    request.setCharacterEncoding("UTF-8");

    // === Lee parámetros exactamente como los envía el usuario (solo trim) ===
    String name    = request.getParameter("name");     name    = (name==null?null:name.trim());
    String email   = request.getParameter("email");    email   = (email==null?null:email.trim());
    String pass    = request.getParameter("password"); pass    = (pass==null?null:pass.trim());
    String confirm = request.getParameter("confirm");  confirm = (confirm==null?null:confirm.trim());
    String birth   = request.getParameter("birth");    birth   = (birth==null?null:birth.trim());   // YYYY-MM-DD
    String gender  = request.getParameter("gender");   gender  = (gender==null?null:gender.trim());

    String street  = request.getParameter("street");   street  = (street==null?null:street.trim());
    String town    = request.getParameter("town");     town    = (town==null?null:town.trim());
    String state   = request.getParameter("state");    state   = (state==null?null:state.trim());
    String country = request.getParameter("country");  country = (country==null?null:country.trim());

    String degree  = request.getParameter("degree");   degree  = (degree==null?null:degree.trim());
    String school  = request.getParameter("school");   school  = (school==null?null:school.trim());

    // === ÚNICA validación: presencia de campos requeridos ===
    if (name==null || name.isEmpty() ||
        email==null || email.isEmpty() ||
        pass==null || pass.isEmpty() ||
        confirm==null || confirm.isEmpty() ||
        birth==null || birth.isEmpty() ||
        gender==null || gender.isEmpty()) {

        response.sendRedirect("singup.jsp?err=Missing+required+fields");
        return;
    }

    // *** SIN restricciones adicionales ***
    // - NO comparamos password vs confirm
    // - NO imponemos longitud mínima
    // - NO validamos formato de fecha o email
    // Lo demás lo maneja el DAO (e.g. email duplicado)

    ut.JAR.CPEN410.UserNew dao = new ut.JAR.CPEN410.UserNew();
    long newUserId = -1L;
    boolean okAll  = false;

    try {
        // Crea usuario (DAO hace SHA2 en DB y valida unicidad email)
        newUserId = dao.createUser(name, email, pass, birth, gender);
        if (newUserId <= 0) {
            response.sendRedirect("singup.jsp?err=Email+already+used+or+invalid+data");
            return;
        }

        // Rol por defecto
        dao.ensureUserRole(newUserId);

        // Address/education: solo si el usuario escribió algo (cotejar que estén llenos)
        boolean hasAddress = (street!=null && !street.isEmpty()) ||
                             (town!=null   && !town.isEmpty())   ||
                             (state!=null  && !state.isEmpty())  ||
                             (country!=null&& !country.isEmpty());
        if (hasAddress) {
            dao.upsertAddress(newUserId, street, town, state, country);
        }

        boolean hasEdu = (degree!=null && !degree.isEmpty()) ||
                         (school!=null && !school.isEmpty());
        if (hasEdu) {
            dao.addEducation(newUserId, degree==null?"":degree, school==null?"":school);
        }

        okAll = true;
    } catch (Exception e) {
        okAll = false;
        e.printStackTrace();
    } finally {
        dao.close();
    }

    if (okAll) {
        response.sendRedirect("loginHashing.jsp?registered=1");
    } else {
        response.sendRedirect("singup.jsp?err=Could+not+create+account");
    }
%>
