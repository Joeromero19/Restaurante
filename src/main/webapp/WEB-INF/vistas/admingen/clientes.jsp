<%-- admingen/clientes.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL)) return;
   request.setAttribute("pageTitle", "Clientes"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">👤 Gestión de Clientes</h1>
    <p class="page-subtitle">Active o desactive (banee) el acceso de un cliente a la plataforma</p>
</div>
<% String msg = request.getParameter("msg");
   if ("baneado".equals(msg)) { %><div class="msg-success">✓ Cliente desactivado correctamente.</div><% }
   if ("activado".equals(msg)) { %><div class="msg-success">✓ Cliente reactivado correctamente.</div><% } %>
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Clientes de la Sede</span>
        <input type="text" placeholder="Buscar..." class="form-control" style="width:200px;"
               oninput="filtrarTabla(this.id,'tablaClientes')" id="buscarClientes">
    </div>
    <div class="table-wrapper">
        <table id="tablaClientes">
            <thead><tr><th>#</th><th>Nombre</th><th>Correo</th><th>Teléfono</th><th>Estado</th><th>Acción</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> clientes = (List<Map<String,Object>>) request.getAttribute("clientes");
                if (clientes != null && !clientes.isEmpty()) {
                    for (Map<String,Object> c : clientes) {
                        boolean activo = Boolean.TRUE.equals(c.get("activo"));
            %>
                <tr>
                    <td><%= c.get("idCliente") %></td>
                    <td><strong><%= c.get("nombre") %></strong></td>
                    <td><%= c.get("correo") %></td>
                    <td><%= c.get("telefono") != null ? c.get("telefono") : "—" %></td>
                    <td><span class="badge badge-<%= activo ? "activo" : "inactivo" %>"><%= activo ? "Activo" : "Baneado" %></span></td>
                    <td>
                        <% if (activo) { %>
                        <form method="post" action="${pageContext.request.contextPath}/admingen" style="display:inline;">
                            <input type="hidden" name="accion" value="banearCliente">
                            <input type="hidden" name="idCliente" value="<%= c.get("idCliente") %>">
                            <button type="submit" class="btn btn-danger btn-sm"
                                    onclick="return confirm('¿Desactivar acceso de <%= c.get("nombre") %>?')">🚫 Banear</button>
                        </form>
                        <% } else { %>
                        <form method="post" action="${pageContext.request.contextPath}/admingen" style="display:inline;">
                            <input type="hidden" name="accion" value="activarCliente">
                            <input type="hidden" name="idCliente" value="<%= c.get("idCliente") %>">
                            <button type="submit" class="btn btn-primary btn-sm"
                                    onclick="return confirm('¿Reactivar a <%= c.get("nombre") %>?')">✅ Activar</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
            <% } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">👤</div><div class="empty-state-desc">Sin clientes registrados.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
