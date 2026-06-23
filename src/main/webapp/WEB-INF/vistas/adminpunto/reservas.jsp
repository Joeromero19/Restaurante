<%-- adminpunto/reservas.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL)) return;
    request.setAttribute("pageTitle", "Reservas");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Gestión de Reservas</h1>
    <p class="page-subtitle">Reservas activas y próximas de la sede</p>
</div>
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Reservas del restaurante</span>
        <input type="text" placeholder="Buscar..." class="form-control" style="width:200px;" oninput="filtrarTabla(this.id,'tablaRes')" id="buscarRes">
    </div>
    <div class="table-wrapper">
        <table id="tablaRes">
            <thead><tr><th>#</th><th>Cliente</th><th>Fecha</th><th>Hora</th><th>Personas</th><th>Mesa</th><th>Estado</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> reservas = (List<Map<String,Object>>) request.getAttribute("reservas");
                if (reservas != null && !reservas.isEmpty()) {
                    for (Map<String,Object> r : reservas) {
                        String est = (String) r.get("estado");
            %>
                <tr>
                    <td><%= r.get("idReserva") %></td>
                    <td><strong><%= r.get("cliente") %></strong></td>
                    <td><%= r.get("fechaReserva") %></td>
                    <td><%= r.get("horaReserva") %></td>
                    <td><%= r.get("cantidadPersonas") %> pers.</td>
                    <td>Mesa <%= r.get("idMesa") %></td>
                    <td><span class="badge badge-<%= est %>"><%= est %></span></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">📅</div><div class="empty-state-desc">Sin reservas registradas.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
