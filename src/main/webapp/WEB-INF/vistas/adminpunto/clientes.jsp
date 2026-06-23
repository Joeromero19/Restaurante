<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Clientes"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">👤 Clientes</h1>
    <p class="page-subtitle">Registro de clientes del restaurante</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Nombre</th><th>Correo</th><th>Teléfono</th><th>Estado</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> clientes = (List<Map<String,Object>>) request.getAttribute("clientes");
                if (clientes != null && !clientes.isEmpty()) {
                    for (Map<String,Object> c : clientes) { %>
                <tr>
                    <td><strong><%= c.get("nombre") %></strong></td>
                    <td><%= c.get("correo") %></td>
                    <td><%= c.get("telefono") %></td>
                    <td><span class="badge badge-<%= Boolean.TRUE.equals(c.get("activo")) ? "activo" : "inactivo" %>"><%= Boolean.TRUE.equals(c.get("activo")) ? "Activo" : "Inactivo" %></span></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="4"><div class="empty-state"><div class="empty-state-icon">👤</div><div class="empty-state-desc">Sin clientes registrados.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
