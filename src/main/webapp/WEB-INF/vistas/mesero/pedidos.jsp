<%-- mesero/pedidos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_MESERO)) return;
    request.setAttribute("pageTitle", "Pedidos Listos");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">🚀 Pedidos Listos para Entregar</h1>
    <p class="page-subtitle">Solo aparecen pedidos que el cocinero ya marcó como <strong>listos</strong></p>
</div>
<% String msg = request.getParameter("msg");
   if ("actualizado".equals(msg)) { %><div class="msg-success">✓ Pedido marcado como entregado.</div><% }
   if ("cancelado".equals(msg))  { %><div class="msg-success">✓ Pedido cancelado correctamente.</div><% }
   if ("error".equals(msg))      { %><div class="msg-error">✗ No se pudo procesar. El pedido ya no está en estado listo.</div><% } %>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#</th><th>Mesa</th><th>Hora</th><th>Alergias</th><th>Observaciones</th><th>Acciones</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> pedidos = (List<Map<String,Object>>) request.getAttribute("pedidos");
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String,Object> p : pedidos) {
                        boolean alergia = Boolean.TRUE.equals(p.get("tieneAlergias"));
            %>
                <tr>
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td style="font-size:0.82rem;"><%= p.get("fechaPedido") %></td>
                    <td><%= alergia ? "<span class='badge badge-alerta'>⚠ Sí</span>" : "No" %></td>
                    <td><%= p.get("observaciones") != null ? p.get("observaciones") : "—" %></td>
                    <td style="display:flex;gap:0.4rem;flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/pedidos?accion=detalle&id=<%= p.get("idPedido") %>"
                           class="btn btn-secondary btn-sm">📋 Detalle</a>
                        <form method="post" action="${pageContext.request.contextPath}/pedidos" style="display:inline;">
                            <input type="hidden" name="accion" value="entregar">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <button type="submit" class="btn btn-primary btn-sm"
                                    onclick="return confirm('¿Marcar como entregado?')">✅ Entregar</button>
                        </form>
                        <form method="post" action="${pageContext.request.contextPath}/pedidos" style="display:inline;">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <button type="submit" class="btn btn-danger btn-sm"
                                    onclick="return confirm('¿Cancelar este pedido?')">✖ Cancelar</button>
                        </form>
                    </td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">⏳</div><div class="empty-state-desc">No hay pedidos listos aún. En espera del cocinero.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
