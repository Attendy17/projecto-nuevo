<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%
    // 1) Evitar cache para que el Back del navegador no muestre páginas privadas
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP/1.1
    response.setHeader("Pragma", "no-cache");                                    // HTTP/1.0
    response.setDateHeader("Expires", 0);                                         // Proxies

    // 2) Invalidar la sesión actual (si existe)
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    if (s != null) {
        s.removeAttribute("userId");
        s.removeAttribute("userName");
        s.removeAttribute("role");
        s.invalidate();
    }

    // 3) Redirigir al login
    String ctx = request.getContextPath(); // normalmente "" o "/ROOT"
    response.sendRedirect((ctx == null ? "" : ctx) + "/cpen410/loginHashing.jsp");
%>
