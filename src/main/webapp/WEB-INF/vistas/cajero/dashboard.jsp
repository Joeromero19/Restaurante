<%-- cajero/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CAJERO)) return;
    request.setAttribute("pageTitle", "Panel Cajero");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Panel del Cajero</h1>
    <p class="page-subtitle">Gestión de cobros, facturas y métodos de pago</p>
</div>

<% String msg = request.getParameter("msg"); if ("generada".equals(msg)) { %><div class="msg-success">✓ Factura generada correctamente.</div><% } %>
<% if ("error".equals(msg)) { %><div class="msg-error">✗ Error al generar la factura.</div><% } %>

<div class="stats-grid">
    <div class="stat-card dorado">
        <span class="stat-icon">🧾</span>
        <div class="stat-label">Facturas del día</div>
        <div class="stat-value" id="kpiFacturas">
            <% List<Map<String,Object>> factsHoy = (List<Map<String,Object>>) request.getAttribute("facturasHoy"); %>
            <%= factsHoy != null ? factsHoy.size() : 0 %>
        </div>
        <div class="stat-sub">Emitidas hoy</div>
    </div>
    <div class="stat-card verde">
        <span class="stat-icon">💵</span>
        <div class="stat-label">Pedidos listos</div>
        <div class="stat-value" id="kpiListos">
            <% List<Map<String,Object>> pedidosListos = (List<Map<String,Object>>) request.getAttribute("pedidosListos"); %>
            <%= pedidosListos != null ? pedidosListos.size() : 0 %>
        </div>
        <div class="stat-sub">Pendientes de cobro</div>
    </div>
</div>

<div style="display:flex;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/cajero?accion=pedidosListos" class="btn btn-primary btn-lg">📋 Pedidos para Cobrar</a>
    <a href="${pageContext.request.contextPath}/cajero?accion=historial" class="btn btn-secondary btn-lg">🧾 Historial de Facturas</a>
    <a href="${pageContext.request.contextPath}/finanzas?accion=metodoPago" class="btn btn-secondary btn-lg">💳 Métodos de Pago</a>
</div>

<!-- Pedidos listos para facturar -->
<div class="table-card" style="margin-bottom:1.5rem;">
    <div class="table-card-header">
        <span class="table-card-title">⚡ Pedidos Listos para Cobrar</span>
        <a href="${pageContext.request.contextPath}/cajero?accion=pedidosListos" class="btn btn-secondary btn-sm">Ver todos →</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>#</th><th>Mesa</th><th>Fecha</th><th>Observaciones</th><th>Acción</th></tr>
            </thead>
            <tbody>
            <%
                if (pedidosListos != null && !pedidosListos.isEmpty()) {
                    int mostrar = Math.min(5, pedidosListos.size());
                    for (int i = 0; i < mostrar; i++) {
                        Map<String,Object> p = pedidosListos.get(i);
            %>
                <tr>
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td style="font-size:0.82rem;"><%= p.get("fechaPedido") %></td>
                    <td><%= p.get("observaciones") != null ? p.get("observaciones") : "—" %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/cajero?accion=generarFactura&idPedido=<%= p.get("idPedido") %>" class="btn btn-primary btn-sm">🧾 Facturar</a>
                    </td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="5"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">No hay pedidos listos para cobrar.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Últimas facturas propias -->
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Mis Últimas Facturas</span>
        <a href="${pageContext.request.contextPath}/cajero?accion=historial" class="btn btn-secondary btn-sm">Ver todas →</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Total</th><th>Método de Pago</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> facturas = (List<Map<String,Object>>) request.getAttribute("facturas");
                if (facturas != null && !facturas.isEmpty()) {
                    int mostrar = Math.min(10, facturas.size());
                    for (int i = 0; i < mostrar; i++) {
                        Map<String,Object> f = facturas.get(i);
            %>
                <tr>
                    <td><strong>#<%= f.get("idFactura") %></strong></td>
                    <td><%= f.get("fecha") %> <%= f.get("hora") %></td>
                    <td class="currency" style="font-weight:700;"><%= f.get("total") %></td>
                    <td><span class="badge badge-activo"><%= f.get("metodoPago") %></span></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="4">
                    <div class="empty-state">
                        <div class="empty-state-icon">🧾</div>
                        <div class="empty-state-desc">Sin facturas registradas aún.</div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
