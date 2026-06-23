<%-- shared/detallePedido.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarSesion(request, response)) return;
    request.setAttribute("pageTitle", "Detalle del Pedido");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Detalle del Pedido #<%= request.getAttribute("idPedido") %></h1>
    <p class="page-subtitle">Productos, cantidades y observaciones de alergias</p>
</div>

<a href="javascript:history.back()" class="btn btn-secondary" style="margin-bottom:1.5rem;">← Volver</a>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Productos del Pedido</span>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>#</th><th>Producto</th><th>Cantidad</th><th>Precio unitario</th><th>Subtotal</th><th>Obs. Alergia</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> detalles = (List<Map<String,Object>>) request.getAttribute("detalles");
                java.math.BigDecimal subtotal = java.math.BigDecimal.ZERO;
                if (detalles != null && !detalles.isEmpty()) {
                    for (Map<String,Object> d : detalles) {
                        java.math.BigDecimal sub = (java.math.BigDecimal) d.get("subtotalLinea");
                        if (sub != null) subtotal = subtotal.add(sub);
            %>
                <tr>
                    <td><%= d.get("idDetalle") %></td>
                    <td><strong><%= d.get("producto") %></strong></td>
                    <td><%= d.get("cantidad") %></td>
                    <td class="currency"><%= d.get("precioUnitario") %></td>
                    <td class="currency"><strong><%= d.get("subtotalLinea") %></strong></td>
                    <td><%= d.get("alergiaItem") != null ? "<span class='badge badge-alerta'>⚠ " + d.get("alergiaItem") + "</span>" : "—" %></td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">📝</div><div class="empty-state-desc">Sin productos.</div></div></td></tr>
            <% } %>
            </tbody>
            <tfoot>
                <tr style="background:#faf7f2;">
                    <td colspan="4" style="text-align:right;font-weight:700;padding:0.8rem 1rem;">SUBTOTAL:</td>
                    <td class="currency" style="font-weight:700;padding:0.8rem 1rem;"><%= subtotal %></td>
                    <td></td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
