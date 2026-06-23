<%-- inversionista/dashboard.jsp --%>
<%-- CORRECCIÓN: añadido acceso a Propinas por Mes --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_INVERSIONISTA)) return;
    request.setAttribute("pageTitle", "Panel Inversionista");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Panel del Inversionista</h1>
    <p class="page-subtitle">Flujo de dinero, ingresos, egresos y ganancias</p>
</div>

<%
    Map<String,Object> res = (Map<String,Object>) request.getAttribute("resumen");
%>

<div class="stats-grid">
    <div class="stat-card dorado">
        <span class="stat-icon">💵</span>
        <div class="stat-label">Total Ingresos</div>
        <div class="stat-value currency"><%= res != null ? res.get("totalIngresos") : "—" %></div>
    </div>
    <div class="stat-card rojo">
        <span class="stat-icon">📤</span>
        <div class="stat-label">Total Egresos</div>
        <div class="stat-value currency"><%= res != null ? res.get("totalGastos") : "—" %></div>
    </div>
    <div class="stat-card verde">
        <span class="stat-icon">📈</span>
        <div class="stat-label">Ganancia Neta</div>
        <div class="stat-value currency"><%= res != null ? res.get("ganancia") : "—" %></div>
    </div>
    <div class="stat-card azul">
        <span class="stat-icon">🏦</span>
        <div class="stat-label">IVA Recolectado</div>
        <div class="stat-value currency"><%= res != null ? res.get("totalIva") : "—" %></div>
    </div>
</div>

<div style="display:flex;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/finanzas?accion=resumen"  class="btn btn-primary">💰 Resumen Financiero</a>
    <a href="${pageContext.request.contextPath}/finanzas?accion=gastos"   class="btn btn-secondary">📋 Gastos Detallados</a>
    <a href="${pageContext.request.contextPath}/finanzas?accion=propinas" class="btn btn-secondary">🎉 Propinas por Mes</a>
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Gastos Detallados</span>
    </div>
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Fecha</th><th>Descripción</th><th>Valor</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> gastos = (List<Map<String,Object>>) request.getAttribute("gastos");
                if (gastos != null && !gastos.isEmpty()) {
                    for (Map<String,Object> g : gastos) { %>
                <tr>
                    <td><%= g.get("fecha") %></td>
                    <td><%= g.get("descripcion") %></td>
                    <td class="currency"><%= g.get("valor") %></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="3">
                    <div class="empty-state">
                        <div class="empty-state-icon">📋</div>
                        <div class="empty-state-desc">Sin gastos registrados.</div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
