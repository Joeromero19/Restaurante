<%-- superadmin/sedes.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_SUPERADMIN)) return;
    request.setAttribute("pageTitle", "Todas las Sedes");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Gestión de Sedes</h1>
    <p class="page-subtitle">Visión global de todos los restaurantes de la cadena</p>
</div>
<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Sedes registradas</span>
        <input type="text" placeholder="Buscar sede..." class="form-control" style="width:200px;" oninput="filtrarTabla(this.id,'tablaSedes')" id="buscarSedes">
    </div>
    <div class="table-wrapper">
        <table id="tablaSedes">
            <thead><tr><th>#</th><th>Nombre</th><th>Ciudad</th><th>País</th><th>Capacidad</th><th>Estado</th><th>Acciones</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> sedes = (List<Map<String,Object>>) request.getAttribute("sedes");
                if (sedes != null && !sedes.isEmpty()) {
                    for (Map<String,Object> s : sedes) { %>
                <tr>
                    <td><%= s.get("idRestaurante") %></td>
                    <td><strong><%= s.get("nombre") %></strong></td>
                    <td><%= s.get("ciudad") %></td>
                    <td><%= s.get("pais") %></td>
                    <td><%= s.get("capacidad") %> mesas</td>
                    <td><span class="badge badge-<%= Boolean.TRUE.equals(s.get("activo")) ? "activo" : "inactivo" %>"><%= Boolean.TRUE.equals(s.get("activo")) ? "Activa" : "Inactiva" %></span></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/finanzas?accion=resumen&sede=<%= s.get("idRestaurante") %>" class="btn btn-secondary btn-sm">💰 Finanzas</a>
                        <a href="${pageContext.request.contextPath}/empleados?accion=todos&sede=<%= s.get("idRestaurante") %>" class="btn btn-secondary btn-sm">👥 Empleados</a>
                    </td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">🏢</div><div class="empty-state-desc">Sin sedes registradas.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
