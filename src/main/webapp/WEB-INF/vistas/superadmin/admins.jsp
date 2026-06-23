<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Administradores"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Administradores</h1>
    <p class="page-subtitle">Gestión de administradores por sede</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaAdmins">
            <thead><tr><th>Nombre</th><th>Correo</th><th>Rol</th><th>Restaurante</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> admins = (List<Map<String,Object>>) request.getAttribute("admins");
                if (admins != null && !admins.isEmpty()) {
                    for (Map<String,Object> a : admins) { %>
                <tr>
                    <td><strong><%= a.get("nombre") %></strong></td>
                    <td><%= a.get("correo") %></td>
                    <td><%= a.get("rol") %></td>
                    <td><%= a.get("restaurante") %></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="4"><div class="empty-state"><div class="empty-state-icon">🔑</div><div class="empty-state-desc">Sin administradores registrados.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
