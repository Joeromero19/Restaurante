<%-- cajero/historialFacturas.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CAJERO)) return;
   request.setAttribute("pageTitle", "Historial de Facturas"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">🧾 Historial de Facturas</h1>
    <p class="page-subtitle">Todas las facturas generadas en la sede</p>
</div>
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Facturas</span>
        <input type="text" placeholder="Buscar..." class="form-control" style="width:200px;"
               oninput="filtrarTabla(this.id,'tablaFact')" id="buscarFact">
    </div>
    <div class="table-wrapper">
        <table id="tablaFact">
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Hora</th><th>Subtotal</th><th>IVA</th><th>Total</th><th>Método de Pago</th><th>Propina</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> facturas = (List<Map<String,Object>>) request.getAttribute("facturas");
                if (facturas != null && !facturas.isEmpty()) {
                    for (Map<String,Object> f : facturas) {
            %>
                <tr>
                    <td><strong>#<%= f.get("idFactura") %></strong></td>
                    <td><%= f.get("fecha") %></td>
                    <td><%= f.get("hora") %></td>
                    <td class="currency"><%= f.get("subtotal") %></td>
                    <td class="currency"><%= f.get("iva") %></td>
                    <td class="currency" style="font-weight:700;"><%= f.get("total") %></td>
                    <td><span class="badge badge-activo"><%= f.get("metodoPago") %></span></td>
                    <td class="currency"><%= f.get("propina") != null ? f.get("propina") : "—" %></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="8"><div class="empty-state"><div class="empty-state-icon">🧾</div><div class="empty-state-desc">Sin facturas registradas.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<div style="margin-top:1rem;">
    <a href="${pageContext.request.contextPath}/cajero" class="btn btn-secondary">← Volver al panel</a>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
