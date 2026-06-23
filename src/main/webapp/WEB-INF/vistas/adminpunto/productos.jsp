<%-- adminpunto/productos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
    request.setAttribute("pageTitle", "Productos / Menú");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Productos y Menú</h1>
    <p class="page-subtitle">Catálogo de productos y platos del restaurante</p>
</div>
<% String msg = request.getParameter("msg"); if ("registrado".equals(msg)) { %><div class="msg-success">✓ Producto registrado.</div><% } %>
<div style="display:flex;gap:1rem;flex-wrap:wrap;margin-bottom:1rem;">
    <input type="text" placeholder="Buscar producto..." class="form-control" style="max-width:260px;" oninput="filtrarTabla(this.id,'tablaProd')" id="buscarProd">
    <button onclick="abrirModal('modalProd')" class="btn btn-primary">➕ Nuevo Producto</button>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table id="tablaProd">
            <thead><tr><th>#</th><th>Nombre</th><th>Tipo</th><th>Precio</th><th>Proveedor</th><th>Acciones</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> productos = (List<Map<String,Object>>) request.getAttribute("productos");
                if (productos != null && !productos.isEmpty()) {
                    for (Map<String,Object> p : productos) { %>
                <tr>
                    <td><%= p.get("idProducto") %></td>
                    <td><strong><%= p.get("nombre") %></strong></td>
                    <td><span class="badge badge-activo"><%= p.get("tipo") %></span></td>
                    <td class="currency"><%= p.get("precio") %></td>
                    <td><%= p.get("proveedor") != null ? p.get("proveedor") : "—" %></td>
                    <td><a href="${pageContext.request.contextPath}/productos?accion=recetas&id=<%= p.get("idProducto") %>" class="btn btn-secondary btn-sm">📖 Receta</a></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">🍽️</div><div class="empty-state-desc">Sin productos registrados.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal nuevo producto -->
<div class="modal-overlay" id="modalProd">
    <div class="modal-box">
        <button class="modal-close" onclick="cerrarModal('modalProd')">✖</button>
        <div class="modal-title">Registrar Nuevo Producto</div>
        <form action="${pageContext.request.contextPath}/productos" method="post">
            <div class="form-group" style="margin-bottom:1rem;">
                <label class="form-label">Nombre del producto</label>
                <input type="text" name="nombre" class="form-control" required placeholder="Ej: Lomo al trapo">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Precio (COP)</label>
                    <input type="number" name="precio" class="form-control" min="0" step="0.01" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Tipo de producto</label>
                    <select name="idTipo" class="form-control" required>
                        <option value="">— Seleccione —</option>
                        <option value="1">Plato principal</option>
                        <option value="2">Entrada</option>
                        <option value="3">Bebida</option>
                        <option value="4">Postre</option>
                        <option value="5">Acompañamiento</option>
                    </select>
                </div>
            </div>
            <div class="form-group" style="margin-bottom:1.5rem;">
                <label class="form-label">Proveedor (opcional)</label>
                <input type="number" name="idProveedor" class="form-control" placeholder="ID del proveedor">
            </div>
            <button type="submit" class="btn btn-primary">✅ Registrar</button>
        </form>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
