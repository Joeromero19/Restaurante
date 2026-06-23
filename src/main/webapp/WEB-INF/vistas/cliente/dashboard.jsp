<%-- cliente/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Mi Portal");
    String nombre = SesionUtil.getNombreUsuario(request);
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">¡Bienvenido, <%= nombre.split(" ")[0] %>!</h1>
    <p class="page-subtitle">Gestione sus pedidos, reservas, reseñas y más desde aquí.</p>
</div>

<% String msg = request.getParameter("msg"); %>
<% if ("creada".equals(msg)) { %><div class="msg-success">✓ Reserva creada exitosamente.</div><% } %>
<% if ("cancelada".equals(msg)) { %><div class="msg-success">✓ Reserva cancelada.</div><% } %>
<% if ("no_cancelable".equals(msg)) { %><div class="msg-error">⚠ No puede cancelar una reserva con menos de 2 horas de anticipación.</div><% } %>

<!-- Acciones rápidas -->
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1.2rem;margin-bottom:2rem;">
    <a href="${pageContext.request.contextPath}/productos?accion=menu" class="btn btn-primary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        🍽️ Ver Menú
    </a>
    <a href="${pageContext.request.contextPath}/pedidos?accion=nuevo" class="btn btn-primary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        🛒 Hacer Pedido
    </a>
    <a href="${pageContext.request.contextPath}/pedidos?accion=misPedidos" class="btn btn-secondary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        📦 Mis Pedidos
    </a>
    <a href="${pageContext.request.contextPath}/reservas?accion=nueva" class="btn btn-secondary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        📅 Nueva Reserva
    </a>
    <a href="${pageContext.request.contextPath}/reservas?accion=misReservas" class="btn btn-secondary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        📋 Mis Reservas
    </a>
    <a href="${pageContext.request.contextPath}/resenas?accion=nueva" class="btn btn-secondary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        ⭐ Dejar Reseña
    </a>
    <a href="${pageContext.request.contextPath}/resenas?accion=encuesta" class="btn btn-secondary" style="justify-content:center;padding:1.2rem;font-size:1rem;border-radius:10px;">
        📊 Encuesta de Satisfacción
    </a>
</div>

<!-- Reservas recientes -->
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Mis Reservas Recientes</span>
        <a href="${pageContext.request.contextPath}/reservas?accion=misReservas" class="btn btn-secondary btn-sm">Ver todas →</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#</th><th>Fecha</th><th>Hora</th><th>Personas</th><th>Restaurante</th><th>Estado</th><th>Acciones</th></tr></thead>
            <tbody>
            <%
                List<Map<String, Object>> reservas = (List<Map<String, Object>>) request.getAttribute("reservas");
                if (reservas != null && !reservas.isEmpty()) {
                    int mostrar = Math.min(5, reservas.size());
                    for (int i = 0; i < mostrar; i++) {
                        Map<String, Object> r = reservas.get(i);
                        String est = (String) r.get("estado");
            %>
                <tr>
                    <td><%= r.get("idReserva") %></td>
                    <td><%= r.get("fechaReserva") %></td>
                    <td><%= r.get("horaReserva") %></td>
                    <td><%= r.get("cantidadPersonas") %> pers.</td>
                    <td><%= r.get("restaurante") %></td>
                    <td><span class="badge badge-<%= est %>"><%= est %></span></td>
                    <td>
                        <% if ("pendiente".equals(est) || "confirmada".equals(est)) { %>
                        <a href="${pageContext.request.contextPath}/reservas?accion=modificar&id=<%= r.get("idReserva") %>" class="btn btn-secondary btn-sm">✏️ Editar</a>
                        <form action="${pageContext.request.contextPath}/reservas" method="post" style="display:inline;" onsubmit="return confirm('¿Cancelar esta reserva?')">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="idReserva" value="<%= r.get("idReserva") %>">
                            <button class="btn btn-danger btn-sm">✖ Cancelar</button>
                        </form>
                        <% } else { %> — <% } %>
                    </td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">📅</div><div class="empty-state-title">Sin reservas aún</div><div class="empty-state-desc">Cree su primera reserva.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
