<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*,java.math.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_INVERSIONISTA)) return;
   request.setAttribute("pageTitle", "Finanzas"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">💰 Finanzas del Restaurante</h1>
    <p class="page-subtitle">Ingresos, gastos y balance general</p>
</div>
<%
    Map<String,Object> res = (Map<String,Object>) request.getAttribute("resumen");
    if (res != null) {
        BigDecimal ingresos = (BigDecimal) res.get("totalIngresos");
        BigDecimal gastos   = (BigDecimal) res.get("totalGastos");
        BigDecimal ganancia = (BigDecimal) res.get("ganancia");
        BigDecimal propinas = (BigDecimal) res.get("totalPropinas");
%>
<div class="stats-grid">
    <div class="stat-card"><div class="stat-icon">📈</div><div class="stat-value">$ <%= ingresos %></div><div class="stat-label">Ingresos Totales</div></div>
    <div class="stat-card"><div class="stat-icon">📉</div><div class="stat-value">$ <%= gastos %></div><div class="stat-label">Gastos Totales</div></div>
    <div class="stat-card"><div class="stat-icon">💵</div><div class="stat-value" style="color:<%= ganancia != null && ganancia.compareTo(BigDecimal.ZERO)>=0?"#2e7d32":"#c62828" %>">$ <%= ganancia %></div><div class="stat-label">Ganancia Neta</div></div>
    <div class="stat-card"><div class="stat-icon">🤝</div><div class="stat-value">$ <%= propinas %></div><div class="stat-label">Propinas</div></div>
</div>
<div style="margin-top:1.5rem;display:flex;gap:1rem;flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/finanzas?accion=gastos" class="btn btn-secondary">📋 Ver Gastos</a>
    <a href="${pageContext.request.contextPath}/finanzas?accion=propinas" class="btn btn-secondary">🤝 Propinas por Mes</a>
</div>
<% } else { %>
    <div class="empty-state"><div class="empty-state-icon">💰</div><div class="empty-state-desc">Sin datos disponibles.</div></div>
<% } %>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
