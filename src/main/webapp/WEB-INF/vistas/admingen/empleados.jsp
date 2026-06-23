<%-- admingen/empleados.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
    request.setAttribute("pageTitle", "Empleados");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Gestión de Empleados</h1>
    <p class="page-subtitle">Salarios, contratos, roles y novedades</p>
</div>

<div style="display:flex;gap:1rem;flex-wrap:wrap;margin-bottom:1rem;">
    <input type="text" placeholder="Buscar empleado..." class="form-control" style="max-width:260px;" oninput="filtrarTabla(this.id,'tablaEmp')" id="buscarEmp">
    <a href="${pageContext.request.contextPath}/empleados?accion=registrar" class="btn btn-primary">➕ Nuevo Empleado</a>
</div>

<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaEmp">
            <thead>
                <tr><th>Nombre</th><th>Rol</th><th>Cargo</th><th>Salario</th><th>F. Ingreso</th><th>Estado</th><th>Acciones</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> empleados = (List<Map<String,Object>>) request.getAttribute("empleados");
                if (empleados != null && !empleados.isEmpty()) {
                    for (Map<String,Object> e : empleados) {
                        String est = (String) e.get("estado");
            %>
                <tr>
                    <td><strong><%= e.get("nombre") %></strong><br><span style="font-size:0.78rem;color:#888;"><%= e.get("correo") %></span></td>
                    <td><%= e.get("rol") %></td>
                    <td><%= e.get("cargo") %></td>
                    <td class="currency"><%= e.get("salario") %></td>
                    <td><%= e.get("fechaIngreso") %></td>
                    <td><span class="badge badge-<%= "ACTIVO".equals(est) ? "activo" : "inactivo" %>"><%= est %></span></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/empleados?accion=novedades&id=<%= e.get("idEmpleado") %>" class="btn btn-secondary btn-sm">📋 Novedades</a>
                        <a href="${pageContext.request.contextPath}/empleados?accion=contratos&id=<%= e.get("idEmpleado") %>" class="btn btn-secondary btn-sm">📄 Contrato</a>
                    </td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">👥</div><div class="empty-state-desc">Sin empleados registrados.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
