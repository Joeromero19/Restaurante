<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_INVERSIONISTA)) return;
   request.setAttribute("pageTitle", "Propinas por Mes"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">🤝 Propinas por Mes</h1>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Mes</th><th>Total Propinas</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> propinas = (List<Map<String,Object>>) request.getAttribute("propinas");
                if (propinas != null && !propinas.isEmpty()) {
                    for (Map<String,Object> p : propinas) { %>
                <tr><td><%= p.get("mes") %></td><td class="currency">$ <%= p.get("total") %></td></tr>
            <% } } else { %>
                <tr><td colspan="2"><div class="empty-state"><div class="empty-state-icon">🤝</div><div class="empty-state-desc">Sin propinas registradas.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
