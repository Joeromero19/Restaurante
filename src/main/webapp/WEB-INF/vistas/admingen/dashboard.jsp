<%-- admingen/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL)) return;
    request.setAttribute("pageTitle", "Panel General");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Panel del Administrador General</h1>
    <p class="page-subtitle">Resumen financiero y operativo de la sede</p>
</div>

<% String msg = request.getParameter("msg"); if ("ok".equals(msg)) { %>
<div class="msg-success">✓ Operación realizada correctamente.</div>
<% } %>

<!-- KPI Cards -->
<div class="stats-grid">
    <div class="stat-card dorado">
        <span class="stat-icon">💰</span>
        <div class="stat-label">Ingresos del mes</div>
        <%
            Map<String,Object> resumen = (Map<String,Object>) request.getAttribute("resumen");
            Object ingresos = resumen != null ? resumen.get("ingresos") : null;
        %>
        <div class="stat-value currency"><%= ingresos != null ? "$ " + ingresos : "—" %></div>
        <div class="stat-sub">Facturación total</div>
    </div>
    <div class="stat-card rojo">
        <span class="stat-icon">📋</span>
        <div class="stat-label">Gastos del mes</div>
        <% Object gastos = resumen != null ? resumen.get("gastos") : null; %>
        <div class="stat-value currency"><%= gastos != null ? "$ " + gastos : "—" %></div>
        <div class="stat-sub">Servicios, arriendo, nómina</div>
    </div>
    <div class="stat-card verde">
        <span class="stat-icon">📈</span>
        <div class="stat-label">Ganancia neta</div>
        <% Object ganancia = resumen != null ? resumen.get("ganancia") : null; %>
        <div class="stat-value currency"><%= ganancia != null ? "$ " + ganancia : "—" %></div>
        <div class="stat-sub">Ingresos − Gastos</div>
    </div>
    <div class="stat-card azul">
        <span class="stat-icon">💳</span>
        <div class="stat-label">IVA recolectado</div>
        <% Object iva = resumen != null ? resumen.get("iva") : null; %>
        <div class="stat-value currency"><%= iva != null ? "$ " + iva : "—" %></div>
        <div class="stat-sub">Pendiente de pago al gobierno</div>
    </div>
</div>

<!-- Segunda fila de cards -->
<div class="stats-grid" style="margin-top:0;">
    <div class="stat-card">
        <span class="stat-icon">🎉</span>
        <div class="stat-label">Propinas del mes</div>
        <% Object propinas = resumen != null ? resumen.get("propinas") : null; %>
        <div class="stat-value currency"><%= propinas != null ? "$ " + propinas : "—" %></div>
        <div class="stat-sub">Para distribución entre empleados</div>
    </div>
    <div class="stat-card">
        <span class="stat-icon">👥</span>
        <div class="stat-label">Empleados activos</div>
        <% Object nEmpleados = resumen != null ? resumen.get("empleadosActivos") : null; %>
        <div class="stat-value"><%= nEmpleados != null ? nEmpleados : "—" %></div>
    </div>
</div>

<!-- Accesos rápidos -->
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:1.2rem;margin-bottom:2rem;">
    <a href="${pageContext.request.contextPath}/finanzas?accion=gastos" class="btn btn-secondary" style="justify-content:center;padding:1rem;">
        📋 Registrar Gasto
    </a>
    <a href="${pageContext.request.contextPath}/finanzas?accion=propinas" class="btn btn-secondary" style="justify-content:center;padding:1rem;">
        💳 Ver Propinas por Mes
    </a>
    <a href="${pageContext.request.contextPath}/empleados" class="btn btn-secondary" style="justify-content:center;padding:1rem;">
        👥 Gestionar Empleados
    </a>
    <a href="${pageContext.request.contextPath}/admingen?accion=clientes" class="btn btn-secondary" style="justify-content:center;padding:1rem;">
        🚫 Clientes / Banear
    </a>
    <a href="${pageContext.request.contextPath}/resenas" class="btn btn-secondary" style="justify-content:center;padding:1rem;">
        ⭐ Reseñas y Encuestas
    </a>
</div>

<!-- Últimas facturas -->
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Últimas Facturas</span>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Subtotal</th><th>IVA</th><th>Total</th><th>Método Pago</th></tr>
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
                    <td><%= f.get("fecha") %></td>
                    <td class="currency"><%= f.get("subtotal") %></td>
                    <td class="currency"><%= f.get("iva") %></td>
                    <td class="currency" style="font-weight:700;"><%= f.get("total") %></td>
                    <td><span class="badge badge-activo"><%= f.get("metodoPago") %></span></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="6">
                    <div class="empty-state">
                        <div class="empty-state-icon">🧾</div>
                        <div class="empty-state-desc">Sin facturas registradas.</div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
