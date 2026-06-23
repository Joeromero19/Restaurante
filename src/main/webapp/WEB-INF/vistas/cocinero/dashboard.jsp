<%-- cocinero/dashboard.jsp --%>
<%-- CORRECCIÓN: eliminado botón "Stock Bajo" del dashboard del cocinero --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_COCINERO)) return;
    request.setAttribute("pageTitle", "Panel de Cocina");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Panel de Cocina</h1>
    <p class="page-subtitle">Cola de pedidos en orden de llegada — prioridad FIFO</p>
</div>

<%-- Solo alergias y recetas, SIN stock bajo --%>
<div style="display:flex;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/pedidos?accion=alergias" class="btn btn-danger">⚠️ Ver Alergias</a>
    <a href="${pageContext.request.contextPath}/productos?accion=recetas" class="btn btn-secondary">📖 Ver Recetas</a>
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">🍳 Cola de Pedidos (orden de llegada)</span>
        <button onclick="location.reload()" class="btn btn-secondary btn-sm">🔄 Actualizar</button>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>Prioridad</th><th>#Pedido</th><th>Mesa</th><th>Hora ingreso</th><th>Estado</th><th>Alergias</th><th>Observaciones</th><th>Acción</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String, Object>> pedidos = (List<Map<String, Object>>) request.getAttribute("pedidos");
                int prioridad = 1;
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String, Object> p : pedidos) {
                        String estado = (String) p.get("estado");
                        boolean alergias = Boolean.TRUE.equals(p.get("tieneAlergias"));
            %>
                <tr style="<%= alergias ? "background:#fff8e1;" : "" %>">
                    <td><span style="font-weight:700;font-size:1.1rem;color:#c8973a;">#<%= prioridad++ %></span></td>
                    <td><strong><%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td style="font-size:0.82rem;"><%= p.get("fechaPedido") %></td>
                    <td>
                        <span class="badge <%= "pendiente".equals(estado) ? "badge-pendiente" : "badge-preparacion" %>">
                            <%= estado %>
                        </span>
                    </td>
                    <td><%= alergias ? "<span class='badge badge-alerta'>⚠ ALERGIAS</span>" : "—" %></td>
                    <td style="font-size:0.82rem;max-width:180px;"><%= p.get("observaciones") != null ? p.get("observaciones") : "—" %></td>
                    <td>
                        <form action="${pageContext.request.contextPath}/pedidos" method="post" style="display:inline;">
                            <input type="hidden" name="accion" value="cambiarEstado">
                            <input type="hidden" name="idPedido" value="<%= p.get("idPedido") %>">
                            <% if ("pendiente".equals(estado)) { %>
                            <input type="hidden" name="estado" value="en_preparacion">
                            <button type="submit" class="btn btn-primary btn-sm">🔥 Iniciar</button>
                            <% } else { %>
                            <input type="hidden" name="estado" value="entregado">
                            <button type="submit" class="btn btn-secondary btn-sm">✅ Listo</button>
                            <% } %>
                        </form>
                        <a href="${pageContext.request.contextPath}/pedidos?accion=detalle&id=<%= p.get("idPedido") %>" class="btn btn-secondary btn-sm">📋 Detalle</a>
                    </td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="8"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-title">Sin pedidos pendientes</div><div class="empty-state-desc">La cocina está al día.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<script>
setTimeout(function() { location.reload(); }, 30000);
var countdown = 30;
var timer = document.createElement('div');
timer.style = 'position:fixed;bottom:1rem;right:1rem;background:#3b1f0a;color:#faf7f2;padding:0.5rem 1rem;border-radius:20px;font-size:0.8rem;';
timer.id = 'refreshTimer';
document.body.appendChild(timer);
setInterval(function() {
    countdown--;
    document.getElementById('refreshTimer').textContent = '🔄 Actualiza en ' + countdown + 's';
    if (countdown <= 0) countdown = 30;
}, 1000);
</script>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
