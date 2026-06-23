<%-- cajero/pedidosListos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CAJERO)) return;
   request.setAttribute("pageTitle", "Pedidos para Cobrar"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">📋 Pedidos para Cobrar</h1>
    <p class="page-subtitle">Pedidos entregados que aún no tienen factura</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#</th><th>Mesa</th><th>Fecha</th><th>Total Pedido</th><th>Observaciones</th><th>Acción</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> pedidos = (List<Map<String,Object>>) request.getAttribute("pedidos");
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String,Object> p : pedidos) {
            %>
                <tr>
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td style="font-size:0.82rem;"><%= p.get("fechaPedido") %></td>
                    <td class="currency"><%= p.get("total") != null ? p.get("total") : "—" %></td>
                    <td><%= p.get("observaciones") != null ? p.get("observaciones") : "—" %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/cajero?accion=generarFactura&idPedido=<%= p.get("idPedido") %>" class="btn btn-primary btn-sm">🧾 Facturar</a>
                    </td>
                </tr>
            <% } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">No hay pedidos pendientes de cobro.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<div style="margin-top:1rem;">
    <a href="${pageContext.request.contextPath}/cajero" class="btn btn-secondary">← Volver al panel</a>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
