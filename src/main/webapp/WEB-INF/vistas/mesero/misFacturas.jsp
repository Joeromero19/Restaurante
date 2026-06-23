<%-- mesero/misFacturas.jsp — Facturas de los pedidos del mesero --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_MESERO)) return;
    request.setAttribute("pageTitle", "Mis Facturas");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Mis Facturas</h1>
    <p class="page-subtitle">Facturas generadas a partir de sus pedidos</p>
</div>

<% String msg = request.getParameter("msg"); if ("generada".equals(msg)) { %>
<div class="msg-success">✓ Factura generada correctamente.</div>
<% } %>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Historial de facturas</span>
        <input type="text" placeholder="Buscar..." class="form-control" style="width:200px;"
               oninput="filtrarTabla(this.id,'tablaFact')" id="buscarFact">
    </div>
    <div class="table-wrapper">
        <table id="tablaFact">
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Hora</th><th>Cliente</th><th>Subtotal</th><th>IVA</th><th>Total</th><th>Propina</th><th>Método Pago</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> facturas = (List<Map<String,Object>>) request.getAttribute("facturas");
                if (facturas != null && !facturas.isEmpty()) {
                    for (Map<String,Object> f : facturas) { %>
                <tr>
                    <td><strong>#<%= f.get("idFactura") %></strong></td>
                    <td><%= f.get("fecha") %></td>
                    <td><%= f.get("hora") %></td>
                    <td><%= f.get("cliente") %></td>
                    <td class="currency"><%= f.get("subtotal") %></td>
                    <td class="currency"><%= f.get("iva") %></td>
                    <td class="currency" style="font-weight:700;"><%= f.get("total") %></td>
                    <td class="currency"><%= f.get("propina") != null ? f.get("propina") : "—" %></td>
                    <td><span class="badge badge-activo"><%= f.get("metodoPago") %></span></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="9">
                    <div class="empty-state">
                        <div class="empty-state-icon">🧾</div>
                        <div class="empty-state-title">Sin facturas aún</div>
                        <div class="empty-state-desc">Las facturas aparecerán aquí cuando se generen a partir de sus pedidos.</div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
