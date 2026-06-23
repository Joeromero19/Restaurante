<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Por Vencer");
   boolean esAdminPunto = SesionUtil.getRol(request) == SesionUtil.ROL_ADMIN_PUNTO; %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">⏰ Inventario Próximo a Vencer</h1>
    <p class="page-subtitle">Productos que vencen en los próximos 5 días</p>
</div>
<% String msg = request.getParameter("msg");
   if ("eliminado".equals(msg)) { %><div class="msg-success">✓ Ítem retirado del inventario.</div><% }
   if ("errorElim".equals(msg)) { %><div class="msg-error">✗ Error al retirar el ítem.</div><% } %>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Producto</th><th>Cantidad</th><th>Vence</th><th>Días restantes</th><% if (esAdminPunto) { %><th>Acción</th><% } %></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> inv = (List<Map<String,Object>>) request.getAttribute("inventario");
                if (inv != null && !inv.isEmpty()) {
                    for (Map<String,Object> i : inv) {
                        int dias = (int) i.get("diasRestantes"); %>
                <tr>
                    <td><strong><%= i.get("producto") %></strong></td>
                    <td><%= i.get("cantidad") %></td>
                    <td><%= i.get("fechaVencimiento") %></td>
                    <td><span class="badge badge-<%= dias <= 2 ? "inactivo" : "activo" %>"><%= dias %> días</span></td>
                    <% if (esAdminPunto) { %>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/inventario" style="display:inline;">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="idInventario" value="<%= i.get("idInventario") %>">
                            <button type="submit" class="btn btn-danger btn-sm"
                                    onclick="return confirm('¿Retirar este ítem del inventario?')">🗑️ Retirar</button>
                        </form>
                    </td>
                    <% } %>
                </tr>
            <% } } else { %>
                <tr><td colspan="<%= esAdminPunto ? 5 : 4 %>"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">Ningún producto próximo a vencer.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
