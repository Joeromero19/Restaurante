<%-- cajero/generarFactura.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*,java.math.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CAJERO)) return;
   request.setAttribute("pageTitle", "Generar Factura"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">🧾 Generar Factura</h1>
    <p class="page-subtitle">Pedido #<%= request.getAttribute("idPedido") %> — complete los datos para facturar</p>
</div>
<%
    List<Map<String,Object>> detalles = (List<Map<String,Object>>) request.getAttribute("detalles");
    BigDecimal subtotal = BigDecimal.ZERO;
    if (detalles != null) {
        for (Map<String,Object> d : detalles) {
            Object precioObj = d.get("precioUnitario");
            Object cantObj = d.get("cantidad");
            if (precioObj != null && cantObj != null) {
                BigDecimal precio = new BigDecimal(precioObj.toString());
                int cant = Integer.parseInt(cantObj.toString());
                subtotal = subtotal.add(precio.multiply(new BigDecimal(cant)));
            }
        }
    }
    BigDecimal iva = subtotal.multiply(new BigDecimal("0.19")).setScale(2, BigDecimal.ROUND_HALF_UP);
%>

<!-- Detalle del pedido -->
<div class="table-card" style="margin-bottom:1.5rem;">
    <div class="table-card-header"><span class="table-card-title">Detalle del Pedido</span></div>
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Producto</th><th>Cantidad</th><th>Precio Unit.</th><th>Subtotal</th></tr></thead>
            <tbody>
            <%
                if (detalles != null) {
                    for (Map<String,Object> d : detalles) {
                        BigDecimal precio = d.get("precioUnitario") != null ? new BigDecimal(d.get("precioUnitario").toString()) : BigDecimal.ZERO;
                        int cant = d.get("cantidad") != null ? Integer.parseInt(d.get("cantidad").toString()) : 0;
            %>
                <tr>
                    <td><%= d.get("nombreProducto") != null ? d.get("nombreProducto") : d.get("producto") %></td>
                    <td><%= cant %></td>
                    <td class="currency"><%= precio %></td>
                    <td class="currency"><strong><%= precio.multiply(new BigDecimal(cant)) %></strong></td>
                </tr>
            <% } } %>
            <tr style="background:#f8f9fa;">
                <td colspan="3" style="text-align:right;font-weight:600;">Subtotal:</td>
                <td class="currency"><strong><%= subtotal %></strong></td>
            </tr>
            <tr style="background:#f8f9fa;">
                <td colspan="3" style="text-align:right;font-weight:600;">IVA (19%):</td>
                <td class="currency"><strong><%= iva %></strong></td>
            </tr>
            <tr style="background:#f0f8ff;">
                <td colspan="3" style="text-align:right;font-weight:700;font-size:1.1rem;">TOTAL:</td>
                <td class="currency" style="font-weight:700;font-size:1.1rem;"><strong><%= subtotal.add(iva) %></strong></td>
            </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Formulario de facturación -->
<div class="form-card" style="max-width:520px;">
    <form method="post" action="${pageContext.request.contextPath}/cajero">
        <input type="hidden" name="accion" value="generar">
        <input type="hidden" name="idPedido" value="<%= request.getAttribute("idPedido") %>">
        <input type="hidden" name="subtotal" value="<%= subtotal %>">
        <input type="hidden" name="iva" value="<%= iva %>">

        <div class="form-group">
            <label class="form-label">ID Cliente</label>
            <input type="number" name="idCliente" class="form-control" required placeholder="Ej: 1" min="1">
        </div>
        <div class="form-group">
            <label class="form-label">Propina ($) <span style="color:#888;font-size:0.85rem;">(opcional)</span></label>
            <input type="number" step="100" name="propina" class="form-control" value="0" min="0">
        </div>
        <div class="form-group">
            <label class="form-label">Método de Pago</label>
            <select name="idTipoPago" class="form-control" required>
                <option value="1">💵 Efectivo</option>
                <option value="2">💳 Tarjeta débito</option>
                <option value="3">💳 Tarjeta crédito</option>
                <option value="4">📱 App móvil</option>
            </select>
        </div>
        <div style="display:flex;gap:1rem;margin-top:1.5rem;">
            <button type="submit" class="btn btn-primary">✅ Generar Factura</button>
            <a href="${pageContext.request.contextPath}/cajero?accion=pedidosListos" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
