<%-- admingen/contratos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Contratos"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">📄 Contratos del Empleado</h1>
    <p class="page-subtitle">Historial de contratos — puede finalizar contratos vigentes</p>
</div>
<% String msg = request.getParameter("msg");
   if ("terminado".equals(msg)) { %><div class="msg-success">✓ Contrato finalizado correctamente.</div><% } %>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Tipo</th><th>Fecha Inicio</th><th>Fecha Fin</th><th>Salario</th><th>Estado</th><th>Acción</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> contratos = (List<Map<String,Object>>) request.getAttribute("contratos");
                String idEmp = request.getParameter("id");
                if (contratos != null && !contratos.isEmpty()) {
                    for (Map<String,Object> c : contratos) {
                        boolean vigente = c.get("fechaFin") == null;
            %>
                <tr>
                    <td><%= c.get("tipo") %></td>
                    <td><%= c.get("fechaInicio") %></td>
                    <td><%= vigente ? "—" : c.get("fechaFin") %></td>
                    <td class="currency">$ <%= c.get("salario") %></td>
                    <td><span class="badge badge-<%= vigente ? "activo" : "inactivo" %>"><%= vigente ? "Vigente" : "Finalizado" %></span></td>
                    <td>
                        <% if (vigente) { %>
                        <form method="post" action="${pageContext.request.contextPath}/admingen" style="display:inline;">
                            <input type="hidden" name="accion" value="terminarContrato">
                            <input type="hidden" name="idContrato" value="<%= c.get("idContrato") %>">
                            <input type="hidden" name="idEmpleado" value="<%= idEmp %>">
                            <button type="submit" class="btn btn-danger btn-sm"
                                    onclick="return confirm('¿Finalizar este contrato hoy?')">🔚 Terminar</button>
                        </form>
                        <% } else { %>
                        <span style="color:#999;font-size:0.8rem;">—</span>
                        <% } %>
                    </td>
                </tr>
            <% } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">📄</div><div class="empty-state-desc">Sin contratos.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<a href="javascript:history.back()" class="btn btn-secondary" style="margin-top:1rem;">← Volver</a>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
