<%-- cliente/menu.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarSesion(request, response)) return;
    request.setAttribute("pageTitle", "Nuestro Menú");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">🍽️ Nuestro Menú</h1>
    <p class="page-subtitle">Explore nuestros platos y bebidas disponibles</p>
</div>

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;flex-wrap:wrap;gap:.8rem;">
    <input type="text" id="buscaMenu" placeholder="Buscar plato o bebida..."
           class="form-control" style="max-width:320px;"
           oninput="filtrarTabla('buscaMenu','tablaMenu')">
    <a href="${pageContext.request.contextPath}/pedidos?accion=nuevo"
       class="btn btn-primary">🛒 Hacer Pedido</a>
</div>

<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaMenu">
            <thead>
                <tr>
                    <th>Producto</th>
                    <th>Categoría</th>
                    <th>Precio</th>
                </tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> productos =
                    (List<Map<String,Object>>) request.getAttribute("productos");
                if (productos != null && !productos.isEmpty()) {
                    for (Map<String,Object> p : productos) {
            %>
                <tr>
                    <td><strong><%= p.get("nombre") %></strong></td>
                    <td><span class="badge badge-pendiente"><%= p.get("tipo") %></span></td>
                    <td class="currency">$ <%= p.get("precio") %></td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="3">
                    <div class="empty-state">
                        <div class="empty-state-icon">🍽️</div>
                        <div class="empty-state-title">Menú no disponible</div>
                        <div class="empty-state-desc">Por favor intente más tarde.</div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
