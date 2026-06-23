<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_CAJERO)) return;
   request.setAttribute("pageTitle", "Generar Factura"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">🧾 Generar Factura</h1>
    <p class="page-subtitle">Crea una factura a partir de un pedido entregado</p>
</div>
<div class="form-card" style="max-width:520px;">
    <form method="post" action="${pageContext.request.contextPath}/facturas">
        <div class="form-group">
            <label class="form-label">ID Pedido</label>
            <input type="number" name="idPedido" class="form-control" required placeholder="Ej: 1">
        </div>
        <div class="form-group">
            <label class="form-label">ID Cliente</label>
            <input type="number" name="idCliente" class="form-control" required placeholder="Ej: 1">
        </div>
        <div class="form-group">
            <label class="form-label">Subtotal ($)</label>
            <input type="number" step="0.01" name="subtotal" class="form-control" required placeholder="Ej: 59000">
        </div>
        <div class="form-group">
            <label class="form-label">IVA ($)</label>
            <input type="number" step="0.01" name="iva" class="form-control" required placeholder="Ej: 11210">
        </div>
        <div class="form-group">
            <label class="form-label">Propina ($)</label>
            <input type="number" step="0.01" name="propina" class="form-control" value="0">
        </div>
        <div class="form-group">
            <label class="form-label">Método de Pago</label>
            <select name="idTipoPago" class="form-control">
                <option value="1">Efectivo</option>
                <option value="2">Tarjeta débito</option>
                <option value="3">Tarjeta crédito</option>
                <option value="4">App móvil</option>
            </select>
        </div>
        <div style="display:flex;gap:1rem;margin-top:1.5rem;">
            <button type="submit" class="btn btn-primary">✅ Generar Factura</button>
            <a href="${pageContext.request.contextPath}/facturas" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
