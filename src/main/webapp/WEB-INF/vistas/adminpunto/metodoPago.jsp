<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_CAJERO)) return;
   request.setAttribute("pageTitle", "Ingresos por Método de Pago"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">💳 Ingresos por Método de Pago</h1>
    <p class="page-subtitle">Resumen del día actual</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Método de Pago</th><th>Total Recaudado</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> metodos = (List<Map<String,Object>>) request.getAttribute("metodoPago");
                if (metodos != null && !metodos.isEmpty()) {
                    for (Map<String,Object> m : metodos) { %>
                <tr><td><%= m.get("metodo") %></td><td class="currency">$ <%= m.get("total") %></td></tr>
            <% } } else { %>
                <tr><td colspan="2"><div class="empty-state"><div class="empty-state-icon">💳</div><div class="empty-state-desc">Sin pagos registrados hoy.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
