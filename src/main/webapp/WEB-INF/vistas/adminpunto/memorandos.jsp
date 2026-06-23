<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Memorandos"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">⚠️ Empleados con Memorandos</h1>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Empleado</th><th>Tipo</th><th>Descripción</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> memorandos = (List<Map<String,Object>>) request.getAttribute("memorandos");
                if (memorandos != null && !memorandos.isEmpty()) {
                    for (Map<String,Object> m : memorandos) { %>
                <tr>
                    <td><strong><%= m.get("nombre") %></strong></td>
                    <td><span class="badge badge-inactivo"><%= m.get("tipo") %></span></td>
                    <td><%= m.get("descripcion") %></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="3"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">Sin memorandos activos.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
