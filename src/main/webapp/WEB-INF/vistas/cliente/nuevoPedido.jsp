<%-- cliente/nuevoPedido.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Hacer Pedido");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">🛒 Hacer Pedido</h1>
    <p class="page-subtitle">Seleccione los productos que desea pedir</p>
</div>

<% String error = (String) request.getAttribute("error"); if (error != null) { %>
<div class="msg-error">⚠ <%= error %></div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 360px;gap:1.5rem;align-items:start;">

    <!-- Formulario del pedido -->
    <div class="form-card">
        <form action="${pageContext.request.contextPath}/pedidos" method="post" id="formPedido">
            <input type="hidden" name="accion" value="crear">
            <!-- Mesa asignada automáticamente al cliente en el login -->
            <input type="hidden" name="idMesa" value="${sessionScope.mesaAsignada != null ? sessionScope.mesaAsignada : 1}">
            <p style="font-size:0.85rem;color:#666;margin-bottom:1rem;">
                🪑 Mesa asignada: <strong>#${sessionScope.mesaAsignada != null ? sessionScope.mesaAsignada : 1}</strong>
            </p>

            <div class="form-group">
                <label class="form-label">¿Tiene alergias alimentarias?</label>
                <select name="tieneAlergias" class="form-control">
                    <option value="false">No</option>
                    <option value="true">Sí</option>
                </select>
            </div>

            <div class="form-group" style="margin-bottom:1.2rem;">
                <label class="form-label">Observaciones o indicaciones especiales</label>
                <textarea name="observaciones" class="form-control"
                          placeholder="Ej: sin cebolla, término del lomito…"></textarea>
            </div>

            <!-- Tabla de productos del pedido -->
            <div style="margin-bottom:1rem;">
                <label class="form-label">Productos seleccionados</label>
                <div class="table-wrapper" style="border:1.5px solid #e0ddd8;border-radius:8px;overflow:hidden;">
                    <table>
                        <thead>
                            <tr><th>Producto</th><th>Precio</th><th>Cantidad</th><th>Nota alergia</th><th></th></tr>
                        </thead>
                        <tbody id="tablaItems"></tbody>
                    </table>
                </div>
                <p id="msgVacio" style="color:#999;font-size:.9rem;margin-top:.5rem;">
                    👆 Agregue productos desde el menú de la derecha.
                </p>
            </div>

            <!-- Total -->
            <div style="display:flex;justify-content:flex-end;align-items:center;gap:1rem;
                        padding:1rem 0;border-top:1px solid #e0ddd8;">
                <span style="font-weight:500;color:#5a5a5a;">Total estimado:</span>
                <span style="font-family:'Playfair Display',serif;font-size:1.4rem;
                             font-weight:700;color:#3b1f0a;" id="totalEstimado">$ 0</span>
            </div>

            <button type="submit" class="btn btn-primary btn-lg"
                    onclick="return validarFormulario()">
                ✅ Confirmar Pedido
            </button>
        </form>
    </div>

    <!-- Catálogo de productos -->
    <div class="table-card">
        <div class="table-card-header">
            <span class="table-card-title">🍽️ Menú disponible</span>
        </div>
        <div style="padding:0.8rem;">
            <input type="text" placeholder="Buscar..." class="form-control"
                   oninput="filtrarTabla('buscaMenu','tablaMenu')" id="buscaMenu">
        </div>
        <div class="table-wrapper" style="max-height:420px;overflow-y:auto;">
            <table id="tablaMenu">
                <thead><tr><th>Producto</th><th>Tipo</th><th>Precio</th><th></th></tr></thead>
                <tbody>
                <%
                    List<Map<String,Object>> productos =
                        (List<Map<String,Object>>) request.getAttribute("productos");
                    if (productos != null) {
                        for (Map<String,Object> prod : productos) { %>
                <tr>
                    <td><%= prod.get("nombre") %></td>
                    <td style="font-size:.78rem;"><%= prod.get("tipo") %></td>
                    <td class="currency"><%= prod.get("precio") %></td>
                    <td>
                        <button type="button"
                                onclick="agregarProducto(<%= prod.get("idProducto") %>,'<%= prod.get("nombre") %>',<%= prod.get("precio") %>)"
                                class="btn btn-primary btn-sm">+</button>
                    </td>
                </tr>
                <%  } } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
var itemCount = 0;

function agregarProducto(id, nombre, precio) {
    document.getElementById('msgVacio').style.display = 'none';
    itemCount++;
    var fila = '<tr id="fila_' + itemCount + '">' +
        '<td>' +
        '  <input type="hidden" name="idProducto" value="' + id + '">' +
        '  <input type="hidden" name="precioUnitario" value="' + precio + '">' +
        '  <span style="font-size:.9rem;">' + nombre + '</span>' +
        '</td>' +
        '<td class="currency">$ ' + parseFloat(precio).toLocaleString("es-CO") + '</td>' +
        '<td><input type="number" name="cantidad" min="1" value="1"' +
        '     class="form-control qty-input" style="width:70px;" onchange="calcularTotal()"></td>' +
        '<td><input type="text" name="descripcionItem" placeholder="alergia específica..."' +
        '     class="form-control" style="width:130px;"></td>' +
        '<td><button type="button" onclick="quitarFila(' + itemCount + ')"' +
        '    class="btn btn-danger btn-sm">✖</button></td>' +
        '</tr>';
    document.getElementById('tablaItems').insertAdjacentHTML('beforeend', fila);
    calcularTotal();
}

function quitarFila(n) {
    var el = document.getElementById('fila_' + n);
    if (el) el.remove();
    calcularTotal();
    if (document.querySelectorAll('#tablaItems tr').length === 0) {
        document.getElementById('msgVacio').style.display = '';
    }
}

function calcularTotal() {
    var total = 0;
    document.querySelectorAll('#tablaItems tr').forEach(function(fila) {
        var p = fila.querySelector('input[name="precioUnitario"]');
        var c = fila.querySelector('input[name="cantidad"]');
        if (p && c) total += parseFloat(p.value || 0) * parseInt(c.value || 1);
    });
    document.getElementById('totalEstimado').textContent =
        '$ ' + total.toLocaleString('es-CO');
}

function validarFormulario() {
    if (document.querySelectorAll('#tablaItems tr').length === 0) {
        alert('Debe agregar al menos un producto al pedido.');
        return false;
    }
    return true;
}
</script>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
