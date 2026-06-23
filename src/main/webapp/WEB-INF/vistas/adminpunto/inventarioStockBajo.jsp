<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Stock Bajo"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">📉 Productos con Stock Bajo</h1>
    <p class="page-subtitle">Productos por debajo del umbral mínimo</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>Producto</th><th>Cantidad Disponible</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> inv = (List<Map<String,Object>>) request.getAttribute("inventario");
                if (inv != null && !inv.isEmpty()) {
                    for (Map<String,Object> i : inv) { %>
                <tr>
                    <td><strong><%= i.get("producto") %></strong></td>
                    <td><span class="badge badge-inactivo"><%= i.get("cantidad") %></span></td>
                </tr>
            <% } } else { %>
                <tr><td colspan="2"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-desc">Stock suficiente en todos los productos.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
