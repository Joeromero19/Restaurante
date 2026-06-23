<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_ADMIN_PUNTO)) return;
   request.setAttribute("pageTitle", "Novedades"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">📋 Novedades del Empleado</h1>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Fecha</th><th>Tipo</th><th>Descripción</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> novedades = (List<Map<String,Object>>) request.getAttribute("novedades");
                if (novedades != null && !novedades.isEmpty()) {
                    for (Map<String,Object> n : novedades) { %>
                <tr>
                    <td><%= n.get("fecha") %></td>
                    <td><span class="badge badge-<%= "Memorando".equals(n.get("tipo")) ? "inactivo" : "activo" %>"><%= n.get("tipo") %></span></td>
                    <td><%= n.get("descripcion") %></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="3"><div class="empty-state"><div class="empty-state-icon">📋</div><div class="empty-state-desc">Sin novedades.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<a href="javascript:history.back()" class="btn btn-secondary" style="margin-top:1rem;">← Volver</a>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
