<%-- adminpunto/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO)) return;
    request.setAttribute("pageTitle", "Panel Administrador de Punto");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Panel del Administrador de Punto</h1>
    <p class="page-subtitle">Gestión operativa diaria de la sede</p>
</div>

<div class="stats-grid">
    <div class="stat-card dorado"><span class="stat-icon">🧾</span><div class="stat-label">Ventas hoy</div><div class="stat-value currency">—</div></div>
    <div class="stat-card verde"><span class="stat-icon">📝</span><div class="stat-label">Pedidos activos</div><div class="stat-value">—</div></div>
    <div class="stat-card naranja" style="--naranja:#e67e22;"><span class="stat-icon">⏰</span><div class="stat-label">Prod. por vencer</div><div class="stat-value" id="kpiVencer">—</div></div>
    <div class="stat-card azul"><span class="stat-icon">📅</span><div class="stat-label">Reservas hoy</div><div class="stat-value">—</div></div>
</div>

<!-- Acciones rápidas -->
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:1rem;margin-bottom:2rem;">
    <a href="${pageContext.request.contextPath}/facturas?accion=nueva" class="btn btn-primary" style="justify-content:center;padding:1rem;font-size:0.9rem;">🧾 Generar Factura</a>
    <a href="${pageContext.request.contextPath}/inventario?accion=registrar" class="btn btn-secondary" style="justify-content:center;padding:1rem;font-size:0.9rem;">📦 Registrar Producto</a>
    <a href="${pageContext.request.contextPath}/clientes?accion=registrar" class="btn btn-secondary" style="justify-content:center;padding:1rem;font-size:0.9rem;">👤 Nuevo Cliente</a>
    <a href="${pageContext.request.contextPath}/productos?accion=menu" class="btn btn-secondary" style="justify-content:center;padding:1rem;font-size:0.9rem;">🍽️ Crear Menú</a>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;">
    <!-- Productos por vencer -->
    <div class="table-card">
        <div class="table-card-header">
            <span class="table-card-title">⏰ Próximos a Vencer (5 días)</span>
            <a href="${pageContext.request.contextPath}/inventario?accion=vencer" class="btn btn-secondary btn-sm">Ver todos</a>
        </div>
        <div class="table-wrapper">
            <table>
                <thead><tr><th>Producto</th><th>Cantidad</th><th>Días restantes</th></tr></thead>
                <tbody>
                    <tr><td colspan="3"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">Sin vencimientos próximos</div></div></td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pedidos en curso -->
    <div class="table-card">
        <div class="table-card-header">
            <span class="table-card-title">📝 Pedidos en Curso</span>
            <a href="${pageContext.request.contextPath}/pedidos?accion=listar" class="btn btn-secondary btn-sm">Ver todos</a>
        </div>
        <div class="table-wrapper">
            <table>
                <thead><tr><th>Mesa</th><th>Estado</th><th>Alergias</th><th>Hora</th></tr></thead>
                <tbody>
                    <tr><td colspan="4"><div class="empty-state"><div class="empty-state-icon">📋</div><div class="empty-state-desc">Sin pedidos activos</div></div></td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
