<%-- index.jsp — Redirige automáticamente al login o dashboard --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Si hay sesión activa, ir al dashboard; si no, al login
    javax.servlet.http.HttpSession sess = request.getSession(false);
    if (sess != null && sess.getAttribute("usuarioId") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>
