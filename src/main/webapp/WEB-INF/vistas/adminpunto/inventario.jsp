<%-- adminpunto/inventario.jsp — Vista completa de inventario --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
    request.setAttribute("pageTitle", "Inventario");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Gestión de Inventario</h1>
    <p class="page-subtitle">Control de productos, vencimientos y stock</p>
</div>

<% String msg = request.getParameter("msg"); %>
<% if ("registrado".equals(msg)) { %><div class="msg-success">✓ Producto registrado al inventario.</div><% } %>

<!-- Alertas rápidas -->
<div style="display:flex;gap:1rem;flex-wrap:wrap;margin-bottom:1.5rem;">
    <a href="${pageContext.request.contextPath}/inventario?accion=vencer" class="btn btn-danger">⏰ Por vencer (5 días)</a>
    <a href="${pageContext.request.contextPath}/inventario?accion=stockBajo" class="btn btn-secondary">⚡ Stock bajo</a>
    <a href="${pageContext.request.contextPath}/inventario?accion=disponibilidad" class="btn btn-secondary">🍽️ Disponibilidad platos</a>
    <button onclick="abrirModal('modalAgregar')" class="btn btn-primary">➕ Registrar producto</button>
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Inventario General</span>
        <input type="text" placeholder="Buscar..." class="form-control" style="width:200px;"
               oninput="filtrarTabla(this.id,'tablaInv')" id="buscarInv">
    </div>
    <div class="table-wrapper">
        <table id="tablaInv">
            <thead>
                <tr><th>#</th><th>Producto</th><th>Proveedor</th><th>Cantidad</th><th>Vencimiento</th><th>Días rest.</th><th>Estado</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> inv = (List<Map<String,Object>>) request.getAttribute("inventario");
                if (inv != null && !inv.isEmpty()) {
                    for (Map<String,Object> item : inv) {
                        int dias = item.get("diasParaVencer") != null ? ((Number) item.get("diasParaVencer")).intValue() : 999;
                        String badge = dias <= 5 ? "badge-alerta" : dias <= 15 ? "badge-pendiente" : "badge-activo";
                        String estadoTexto = dias <= 5 ? "⚠ Urgente" : dias <= 15 ? "Próximo" : "OK";
            %>
                <tr>
                    <td><%= item.get("idInventario") %></td>
                    <td><strong><%= item.get("producto") %></strong></td>
                    <td><%= item.get("proveedor") != null ? item.get("proveedor") : "—" %></td>
                    <td><%= item.get("cantidadDisponible") %></td>
                    <td><%= item.get("fechaVencimiento") != null ? item.get("fechaVencimiento") : "—" %></td>
                    <td><%= dias < 999 ? dias + " días" : "—" %></td>
                    <td><span class="badge <%= badge %>"><%= estadoTexto %></span></td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon">📦</div><div class="empty-state-desc">Sin productos en inventario.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal agregar producto al inventario -->
<div class="modal-overlay" id="modalAgregar">
    <div class="modal-box">
        <button class="modal-close" onclick="cerrarModal('modalAgregar')">✖</button>
        <div class="modal-title">Registrar Producto al Inventario</div>
        <form action="${pageContext.request.contextPath}/inventario" method="post">
            <input type="hidden" name="accion" value="registrar">
            <div class="form-group" style="margin-bottom:1rem;">
                <label class="form-label">Producto</label>
                <select name="idProducto" class="form-control" required>
                    <option value="">— Seleccione —</option>
                    <%
                        List<Map<String,Object>> prods = (List<Map<String,Object>>) request.getAttribute("productos");
                        if (prods != null) {
                            for (Map<String,Object> p : prods) { %>
                    <option value="<%= p.get("idProducto") %>"><%= p.get("nombre") %></option>
                    <%  }
                        }
                    %>
                </select>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Proveedor</label>
                    <select name="idProveedor" class="form-control" required>
                        <option value="">— Seleccione —</option>
                        <%
                            List<Map<String,Object>> provs = (List<Map<String,Object>>) request.getAttribute("proveedores");
                            if (provs != null) {
                                for (Map<String,Object> pv : provs) { %>
                        <option value="<%= pv.get("idProveedor") %>"><%= pv.get("nombre") %></option>
                        <%  }
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Cantidad</label>
                    <input type="number" name="cantidad" class="form-control" min="0.01" step="0.01" required>
                </div>
            </div>
            <div class="form-group" style="margin-bottom:1.2rem;">
                <label class="form-label">Fecha de Vencimiento</label>
                <input type="date" name="fechaVencimiento" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-primary">✅ Registrar</button>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
