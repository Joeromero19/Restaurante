<%-- cliente/misPedidos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Mis Pedidos");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">📦 Mis Pedidos</h1>
    <p class="page-subtitle">Historial de pedidos realizados</p>
</div>

<% String msg = request.getParameter("msg"); %>
<% if ("creado".equals(msg)) { %>
<div class="msg-success">✓ Pedido registrado exitosamente. En breve lo prepararemos.</div>
<% } %>

<div style="display:flex;justify-content:flex-end;margin-bottom:1rem;">
    <a href="${pageContext.request.contextPath}/pedidos?accion=nuevo" class="btn btn-primary">
        🛒 Nuevo Pedido
    </a>
</div>

<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Fecha</th>
                    <th>Mesa</th>
                    <th>Estado</th>
                    <th>Alergias</th>
                    <th>Total</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> pedidos =
                    (List<Map<String,Object>>) request.getAttribute("pedidos");
                if (pedidos != null && !pedidos.isEmpty()) {
                    for (Map<String,Object> p : pedidos) {
                        String est = (String) p.get("estado");
            %>
                <tr>
                    <td><%= p.get("idPedido") %></td>
                    <td><%= p.get("fechaPedido") %></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td><span class="badge badge-<%= est %>"><%= est %></span></td>
                    <td><%= Boolean.TRUE.equals(p.get("tieneAlergias")) ? "⚠ Sí" : "No" %></td>
                    <td class="currency">
                        <%= p.get("total") != null ? "$ " + p.get("total") : "—" %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/pedidos?accion=detalle&id=<%= p.get("idPedido") %>"
                           class="btn btn-secondary btn-sm">🔍 Ver detalle</a>
                    </td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="7">
                    <div class="empty-state">
                        <div class="empty-state-icon">📦</div>
                        <div class="empty-state-title">Sin pedidos aún</div>
                        <div class="empty-state-desc">
                            <a href="${pageContext.request.contextPath}/pedidos?accion=nuevo">
                                Haga su primer pedido
                            </a>
                        </div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
