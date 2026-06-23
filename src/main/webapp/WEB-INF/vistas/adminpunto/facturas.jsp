<%-- adminpunto/facturas.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_CAJERO)) return;
    request.setAttribute("pageTitle", "Facturas");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Registro de Facturas</h1>
    <p class="page-subtitle">Historial completo de facturación</p>
</div>

<% String msg = request.getParameter("msg"); if ("generada".equals(msg)) { %><div class="msg-success">✓ Factura generada correctamente.</div><% } %>

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;flex-wrap:wrap;gap:0.8rem;">
    <input type="text" placeholder="Buscar factura..." class="form-control" style="max-width:260px;" oninput="filtrarTabla(this.id,'tablaFact')" id="buscarFact">
    <a href="${pageContext.request.contextPath}/facturas?accion=nueva" class="btn btn-primary">🧾 Generar Factura</a>
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Facturas del restaurante</span>
    </div>
    <div class="table-wrapper">
        <table id="tablaFact">
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Hora</th><th>Cliente</th><th>Subtotal</th><th>IVA</th><th>Total</th><th>Propina</th><th>Método</th></tr>
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
            <%  }
                } else { %>
                <tr><td colspan="9"><div class="empty-state"><div class="empty-state-icon">🧾</div><div class="empty-state-desc">Sin facturas registradas.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
