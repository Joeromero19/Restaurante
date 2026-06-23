<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Disponibilidad Platos"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">🍽️ Disponibilidad de Platos</h1>
    <p class="page-subtitle">Platos posibles según stock actual</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Plato</th><th>Platos Posibles</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> platos = (List<Map<String,Object>>) request.getAttribute("platos");
                if (platos != null && !platos.isEmpty()) {
                    for (Map<String,Object> p : platos) {
                        int posibles = (int) p.get("platosPosibles"); %>
                <tr>
                    <td><strong><%= p.get("plato") %></strong></td>
                    <td><span class="badge badge-<%= posibles > 5 ? "activo" : "inactivo" %>"><%= posibles %> platos</span></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="2"><div class="empty-state"><div class="empty-state-icon">🍽️</div><div class="empty-state-desc">Sin datos de disponibilidad.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
