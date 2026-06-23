<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Todos los Empleados"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Todos los Empleados</h1>
    <p class="page-subtitle">Vista global de empleados en todas las sedes</p>
</div>
<div style="margin-bottom:1rem;">
    <input type="text" placeholder="Buscar empleado..." class="form-control" style="max-width:260px;" oninput="filtrarTabla(this.id,'tablaEmpG')" id="buscarEmpG">
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaEmpG">
            <thead><tr><th>Nombre</th><th>Rol</th><th>Cargo</th><th>Salario</th><th>Estado</th><th>Restaurante</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> empleados = (List<Map<String,Object>>) request.getAttribute("empleados");
                if (empleados != null && !empleados.isEmpty()) {
                    for (Map<String,Object> e : empleados) {
                        String est = (String) e.get("estado"); %>
                <tr>
                    <td><strong><%= e.get("nombre") %></strong></td>
                    <td><%= e.get("rol") %></td>
                    <td><%= e.get("cargo") %></td>
                    <td class="currency"><%= e.get("salario") %></td>
                    <td><span class="badge badge-<%= "ACTIVO".equals(est) ? "activo" : "inactivo" %>"><%= est %></span></td>
                    <td><%= e.get("restaurante") %></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">👥</div><div class="empty-state-desc">Sin empleados registrados.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
