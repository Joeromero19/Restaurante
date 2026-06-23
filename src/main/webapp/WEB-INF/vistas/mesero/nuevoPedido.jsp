<%-- mesero/nuevoPedido.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_MESERO)) return;
    request.setAttribute("pageTitle", "Nuevo Pedido");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Registrar Nuevo Pedido</h1>
    <p class="page-subtitle">Seleccione la mesa, productos y registre alergias si aplica</p>
</div>

<% String error = (String) request.getAttribute("error"); if (error != null) { %>
<div class="msg-error">⚠ <%= error %></div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 360px;gap:1.5rem;align-items:start;">

    <!-- Formulario del pedido -->
    <div class="form-card">
        <form action="${pageContext.request.contextPath}/pedidos" method="post" id="formPedido">
            <input type="hidden" name="accion" value="crear">

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Mesa</label>
                    <select name="idMesa" class="form-control" required>
                        <option value="">— Seleccione mesa —</option>
                        <%
                            List<Map<String,Object>> mesas = (List<Map<String,Object>>) request.getAttribute("mesas");
                            if (mesas != null) {
                                for (Map<String,Object> m : mesas) { %>
                        <option value="<%= m.get("idMesa") %>">Mesa <%= m.get("idMesa") %> (cap. <%= m.get("capacidad") %>)</option>
                        <%      }
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">¿Tiene alergias?</label>
                    <select name="tieneAlergias" class="form-control" id="selectAlergias">
                        <option value="false">No</option>
                        <option value="true">Sí</option>
                    </select>
                </div>
            </div>

            <div class="form-group" style="margin-bottom:1.2rem;">
                <label class="form-label">Observaciones generales</label>
                <textarea name="observaciones" class="form-control" placeholder="Ej: sin cilantro, término del lomito…"></textarea>
            </div>

            <!-- Tabla de productos del pedido -->
            <div style="margin-bottom:1rem;">
                <label class="form-label">Productos del pedido</label>
                <div class="table-wrapper" style="border:1.5px solid #e0ddd8;border-radius:8px;overflow:hidden;">
                    <table>
                        <thead>
                            <tr><th>Producto</th><th>Precio</th><th>Cantidad</th><th>Alergia ítem</th><th></th></tr>
                        </thead>
                        <tbody id="tablaItems">
                            <!-- Filas añadidas dinámicamente por JS -->
                        </tbody>
                    </table>
                </div>
                <button type="button" onclick="agregarFila()" class="btn btn-secondary" style="margin-top:0.7rem;">
                    ➕ Agregar producto
                </button>
            </div>

            <!-- Total calculado -->
            <div style="display:flex;justify-content:flex-end;align-items:center;gap:1rem;padding:1rem 0;border-top:1px solid #e0ddd8;">
                <span style="font-weight:500;color:#5a5a5a;">Total estimado:</span>
                <span style="font-family:'Playfair Display',serif;font-size:1.4rem;font-weight:700;color:#3b1f0a;" id="totalEstimado">$ 0</span>
            </div>

            <button type="submit" class="btn btn-primary btn-lg" onclick="return validarFormulario()">
                ✅ Registrar Pedido
            </button>
        </form>
    </div>

    <!-- Catálogo de productos -->
    <div class="table-card">
        <div class="table-card-header">
            <span class="table-card-title">🍽️ Menú disponible</span>
        </div>
        <div style="padding:0.8rem;">
            <input type="text" placeholder="Buscar producto..." class="form-control"
                   oninput="filtrarTabla('buscaMenu', 'tablaMenu')" id="buscaMenu">
        </div>
        <div class="table-wrapper" style="max-height:420px;overflow-y:auto;">
            <table id="tablaMenu">
                <thead><tr><th>Producto</th><th>Tipo</th><th>Precio</th><th></th></tr></thead>
                <tbody>
                <%
                    List<Map<String,Object>> productos = (List<Map<String,Object>>) request.getAttribute("productos");
                    if (productos != null) {
                        for (Map<String,Object> prod : productos) { %>
                <tr>
                    <td><%= prod.get("nombre") %></td>
                    <td style="font-size:0.78rem;"><%= prod.get("tipo") %></td>
                    <td class="currency"><%= prod.get("precio") %></td>
                    <td>
                        <button type="button"
                                onclick="agregarProducto(<%= prod.get("idProducto") %>, '<%= prod.get("nombre") %>', <%= prod.get("precio") %>)"
                                class="btn btn-primary btn-sm">+</button>
                    </td>
                </tr>
                <%  }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script>
var itemCount = 0;

function agregarProducto(id, nombre, precio) {
    agregarFila(id, nombre, precio);
}

function agregarFila(id, nombre, precio) {
    id     = id     || '';
    nombre = nombre || '';
    precio = precio || '';
    itemCount++;
    var fila = '<tr id="fila_' + itemCount + '">' +
        '<td>' +
        '  <input type="hidden" name="idProducto" value="' + id + '">' +
        '  <input type="hidden" name="precioUnitario" value="' + precio + '">' +
        '  <input type="text" class="form-control" value="' + nombre + '" readonly style="width:140px;">' +
        '</td>' +
        '<td class="currency">' + (precio ? '$ ' + parseFloat(precio).toLocaleString('es-CO') : '—') + '</td>' +
        '<td><input type="number" name="cantidad" min="1" value="1" class="form-control qty-input" style="width:70px;" onchange="calcularTotal()"></td>' +
        '<td><input type="text" name="descripcionItem" placeholder="alergia específica..." class="form-control" style="width:140px;"></td>' +
        '<td><button type="button" onclick="quitarFila(' + itemCount + ')" class="btn btn-danger btn-sm">✖</button></td>' +
        '</tr>';
    document.getElementById('tablaItems').insertAdjacentHTML('beforeend', fila);
    calcularTotal();
}

function quitarFila(n) {
    var el = document.getElementById('fila_' + n);
    if (el) el.remove();
    calcularTotal();
}

function calcularTotal() {
    var filas = document.querySelectorAll('#tablaItems tr');
    var total = 0;
    filas.forEach(function(fila) {
        var precioInput = fila.querySelector('input[name="precioUnitario"]');
        var cantInput   = fila.querySelector('input[name="cantidad"]');
        if (precioInput && cantInput) {
            total += parseFloat(precioInput.value || 0) * parseInt(cantInput.value || 1);
        }
    });
    document.getElementById('totalEstimado').textContent = '$ ' + total.toLocaleString('es-CO');
}

function validarFormulario() {
    var filas = document.querySelectorAll('#tablaItems tr');
    if (filas.length === 0) {
        alert('Debe agregar al menos un producto al pedido.');
        return false;
    }
    var idsMesa = document.querySelector('[name="idMesa"]').value;
    if (!idsMesa) {
        alert('Seleccione una mesa.');
        return false;
    }
    return true;
}
</script>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
