<%-- cocinero/pedidos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_COCINERO, SesionUtil.ROL_ADMIN_PUNTO)) return;
   request.setAttribute("pageTitle", "Cola de Pedidos"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">👨‍🍳 Cola de Pedidos</h1>
    <p class="page-subtitle">Pedidos pendientes y en preparación — marcá como listo cuando esté preparado</p>
</div>
<% String msg = request.getParameter("msg"); if ("actualizado".equals(msg)) { %><div class="msg-success">✓ Estado actualizado correctamente.</div><% } %>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#</th><th>Mesa</th><th>Estado</th><th>Alergias</th><th>Observaciones</th><th>Acción</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> pedidos = (List<Map<String,Object>>) request.getAttribute("pedidos");
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String,Object> p : pedidos) {
                        String est = (String) p.get("estado");
                        boolean alergia = Boolean.TRUE.equals(p.get("tieneAlergias"));
                        String bc = "pendiente".equals(est) ? "badge-pendiente" : "en_preparacion".equals(est) ? "badge-preparacion" : "badge-activo";
            %>
                <tr>
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td><span class="badge <%= bc %>"><%= est %></span></td>
                    <td><%= alergia ? "<span class='badge badge-alerta'>⚠️ Sí</span>" : "No" %></td>
                    <td><%= p.get("observaciones") != null ? p.get("observaciones") : "—" %></td>
                    <td style="display:flex;gap:0.4rem;flex-wrap:wrap;">
                        <% if ("pendiente".equals(est)) { %>
                        <form method="post" action="${pageContext.request.contextPath}/pedidos" style="display:inline;">
                            <input type="hidden" name="accion" value="cambiarEstado">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <input type="hidden" name="estado" value="en_preparacion">
                            <button type="submit" class="btn btn-secondary btn-sm" style="padding:0.3rem 0.8rem;font-size:0.8rem;">🍳 Preparando</button>
                        </form>
                        <% } %>
                        <% if ("pendiente".equals(est) || "en_preparacion".equals(est)) { %>
                        <form method="post" action="${pageContext.request.contextPath}/pedidos" style="display:inline;">
                            <input type="hidden" name="accion" value="cambiarEstado">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <input type="hidden" name="estado" value="listo">
                            <button type="submit" class="btn btn-primary btn-sm" style="padding:0.3rem 0.8rem;font-size:0.8rem;">✅ Listo para entregar</button>
                        </form>
                        <% } %>
                        <% if ("listo".equals(est)) { %>
                        <span class="badge badge-activo">✓ Esperando mesero</span>
                        <% } %>
                    </td>
                </tr>
            <% } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">Sin pedidos pendientes.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
