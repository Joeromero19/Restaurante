<%-- ============================================================
     superadmin/dashboard.jsp — Panel SuperAdministrador
============================================================ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_SUPERADMIN)) return;
    request.setAttribute("pageTitle", "Panel Global");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Visión Global — Todas las Sedes</h1>
    <p class="page-subtitle">Control total de la cadena internacional de restaurantes</p>
</div>

<div class="stats-grid">
    <div class="stat-card dorado"><span class="stat-icon">🏢</span><div class="stat-label">Sedes activas</div><div class="stat-value">—</div></div>
    <div class="stat-card verde"><span class="stat-icon">💰</span><div class="stat-label">Ingresos globales</div><div class="stat-value currency">—</div></div>
    <div class="stat-card rojo"><span class="stat-icon">📋</span><div class="stat-label">Gastos globales</div><div class="stat-value currency">—</div></div>
    <div class="stat-card azul"><span class="stat-icon">👥</span><div class="stat-label">Total empleados</div><div class="stat-value">—</div></div>
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Resumen Financiero por Sede</span>
        <a href="${pageContext.request.contextPath}/finanzas?accion=global" class="btn btn-primary btn-sm">Detalle completo</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Sede</th><th>Ciudad</th><th>Ingresos</th><th>Gastos</th><th>Balance</th><th>Acciones</th></tr></thead>
            <tbody>
                <%
                    List<Map<String, Object>> resumen = (List<Map<String, Object>>) request.getAttribute("resumenGlobal");
                    if (resumen != null && !resumen.isEmpty()) {
                        for (Map<String, Object> fila : resumen) { %>
                <tr>
                    <td><strong><%= fila.get("restaurante") %></strong></td>
                    <td>—</td>
                    <td class="currency"><%= fila.get("totalIngresos") %></td>
                    <td class="currency"><%= fila.get("totalGastos") %></td>
                    <td class="currency"><%= fila.get("balance") %></td>
                    <td><a href="${pageContext.request.contextPath}/superadmin?accion=sede&id=<%= fila.get("idRestaurante") %>" class="btn btn-secondary btn-sm">Ver</a></td>
                </tr>
                <%      }
                    } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">📊</div><div class="empty-state-desc">Sin datos disponibles</div></div></td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
