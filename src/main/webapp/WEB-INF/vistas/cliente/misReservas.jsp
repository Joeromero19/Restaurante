<%-- cliente/misReservas.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Mis Reservas");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Mis Reservas</h1>
    <p class="page-subtitle">Puede modificar o cancelar hasta 2 horas antes</p>
</div>
<% String msg = request.getParameter("msg");
   if ("cancelada".equals(msg)) { %><div class="msg-success">✓ Reserva cancelada.</div><%
   } else if ("no_cancelable".equals(msg)) { %><div class="msg-error">⚠ No puede cancelar con menos de 2 horas de anticipación.</div><%
   } else if ("modificada".equals(msg)) { %><div class="msg-success">✓ Reserva modificada correctamente.</div><% } %>
<div style="margin-bottom:1rem;">
    <a href="${pageContext.request.contextPath}/reservas?accion=nueva" class="btn btn-primary">📅 Nueva Reserva</a>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#</th><th>Restaurante</th><th>Fecha</th><th>Hora</th><th>Personas</th><th>Estado</th><th>Acciones</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> reservas = (List<Map<String,Object>>) request.getAttribute("reservas");
                if (reservas != null && !reservas.isEmpty()) {
                    for (Map<String,Object> r : reservas) {
                        String est = (String) r.get("estado");
                        boolean cancelable = "pendiente".equals(est) || "confirmada".equals(est);
            %>
                <tr>
                    <td><%= r.get("idReserva") %></td>
                    <td><%= r.get("restaurante") %></td>
                    <td><%= r.get("fechaReserva") %></td>
                    <td><%= r.get("horaReserva") %></td>
                    <td><%= r.get("cantidadPersonas") %></td>
                    <td><span class="badge badge-<%= est %>"><%= est %></span></td>
                    <td>
                        <% if (cancelable) { %>
                        <form action="${pageContext.request.contextPath}/reservas" method="post" style="display:inline;" onsubmit="return confirm('¿Cancelar esta reserva?')">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="idReserva" value="<%= r.get("idReserva") %>">
                            <button class="btn btn-danger btn-sm">✖ Cancelar</button>
                        </form>
                        <% } else { %> — <% } %>
                    </td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">📅</div><div class="empty-state-desc">Sin reservas aún.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
