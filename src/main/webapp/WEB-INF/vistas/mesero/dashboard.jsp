<%-- mesero/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_MESERO)) return;
    request.setAttribute("pageTitle", "Panel Mesero");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Panel del Mesero</h1>
    <p class="page-subtitle">Gestione sus pedidos y mesas asignadas</p>
</div>

<% String msgM = request.getParameter("msg"); if ("creado".equals(msgM)) { %>
<div class="msg-success">✓ Pedido registrado correctamente.</div><% } %>
<% if ("actualizado".equals(msgM)) { %>
<div class="msg-success">✓ Pedido marcado como entregado.</div><% } %>

<div style="display:flex;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/pedidos?accion=nuevo" class="btn btn-primary btn-lg">➕ Nuevo Pedido</a>
    <a href="${pageContext.request.contextPath}/pedidos?accion=listar" class="btn btn-secondary btn-lg">📋 Mis Pedidos</a>
    <a href="${pageContext.request.contextPath}/facturas?accion=misFact" class="btn btn-secondary btn-lg">🧾 Mis Facturas</a>
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Mis Pedidos Activos</span>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>#</th><th>Mesa</th><th>Fecha / Hora</th><th>Estado</th><th>Alergias</th><th>Acciones</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String, Object>> pedidos = (List<Map<String, Object>>) request.getAttribute("pedidos");
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String, Object> p : pedidos) {
                        String estado = (String) p.get("estado");
                        String badgeClass = "pendiente".equals(estado) ? "badge-pendiente"
                            : "en_preparacion".equals(estado) ? "badge-preparacion"
                            : "listo".equals(estado) ? "badge-activo" : "badge-entregado";
            %>
                <tr>
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td><%= p.get("fechaPedido") %></td>
                    <td><span class="badge <%= badgeClass %>"><%= estado %></span></td>
                    <td><%= Boolean.TRUE.equals(p.get("tieneAlergias")) ? "<span class='badge badge-alerta'>⚠ Sí</span>" : "No" %></td>
                    <td style="display:flex;gap:0.4rem;flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/pedidos?accion=detalle&id=<%= p.get("idPedido") %>" class="btn btn-secondary btn-sm">Ver</a>
                        <% if ("listo".equals(estado)) { %>
                        <form method="post" action="${pageContext.request.contextPath}/pedidos" style="display:inline;">
                            <input type="hidden" name="accion" value="entregar">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <button type="submit" class="btn btn-primary btn-sm" onclick="return confirm('¿Entregar pedido #<%= p.get("idPedido") %>?')">🚀 Entregar</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">📋</div><div class="empty-state-title">Sin pedidos activos</div><div class="empty-state-desc">Cree un nuevo pedido para comenzar.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
