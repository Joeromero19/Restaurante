<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Pedidos"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">📝 Pedidos Activos</h1>
    <p class="page-subtitle">Pedidos en curso del restaurante</p>
</div>
<% String msg = request.getParameter("msg"); if ("actualizado".equals(msg)) { %><div class="msg-success">✓ Estado actualizado.</div><% } %>
<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaPedidos">
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Mesa</th><th>Empleado</th><th>Estado</th><th>Alergias</th><th>Acciones</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> pedidos = (List<Map<String,Object>>) request.getAttribute("pedidos");
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String,Object> p : pedidos) {
                        String estado = (String) p.get("estado");
                        boolean alergia = Boolean.TRUE.equals(p.get("tieneAlergias")); %>
                <tr>
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td><%= p.get("fechaPedido") %></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td><%= p.get("empleado") %></td>
                    <td><span class="badge badge-<%= "entregado".equals(estado) ? "activo" : "inactivo" %>"><%= estado %></span></td>
                    <td><%= alergia ? "<span class='badge badge-inactivo'>⚠️ Sí</span>" : "No" %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/pedidos?accion=detalle&id=<%= p.get("idPedido") %>" class="btn btn-secondary" style="padding:0.3rem 0.7rem;font-size:0.8rem;">Ver</a>
                        <form method="post" action="${pageContext.request.contextPath}/pedidos" style="display:inline;">
                            <input type="hidden" name="accion" value="cambiarEstado">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <select name="nuevoEstado" onchange="this.form.submit()" style="font-size:0.8rem;padding:0.2rem;">
                                <option value="">Cambiar...</option>
                                <option value="pendiente">Pendiente</option>
                                <option value="en_preparacion">En preparación</option>
                                <option value="entregado">Entregado</option>
                                <option value="cancelado">Cancelado</option>
                            </select>
                        </form>
                    </td>
                </tr>
            <% } } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">📝</div><div class="empty-state-desc">No hay pedidos activos.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
