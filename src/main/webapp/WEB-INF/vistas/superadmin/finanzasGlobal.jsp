<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Finanzas Globales"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">💰 Finanzas Globales</h1>
    <p class="page-subtitle">Resumen financiero de todas las sedes</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaFinG">
            <thead><tr><th>Restaurante</th><th>Total Ingresos</th><th>Total Gastos</th><th>Balance</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> resumen = (List<Map<String,Object>>) request.getAttribute("resumenGlobal");
                if (resumen != null && !resumen.isEmpty()) {
                    for (Map<String,Object> r : resumen) {
                        java.math.BigDecimal bal = (java.math.BigDecimal) r.get("balance");
                        boolean positivo = bal != null && bal.compareTo(java.math.BigDecimal.ZERO) >= 0; %>
                <tr>
                    <td><strong><%= r.get("restaurante") %></strong></td>
                    <td class="currency">$ <%= r.get("totalIngresos") %></td>
                    <td class="currency">$ <%= r.get("totalGastos") %></td>
                    <td class="currency" style="color:<%= positivo ? "#2e7d32" : "#c62828" %>"><strong>$ <%= bal %></strong></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="4"><div class="empty-state"><div class="empty-state-icon">💰</div><div class="empty-state-desc">Sin datos financieros.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
