<%-- admingen/gastos.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_INVERSIONISTA)) return;
    request.setAttribute("pageTitle", "Gastos");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Registro de Gastos</h1>
    <p class="page-subtitle">Servicios, arriendo, nómina, imprevistos y más</p>
</div>

<% String msg = request.getParameter("msg"); if ("registrado".equals(msg)) { %><div class="msg-success">✓ Gasto registrado correctamente.</div><% } %>

<%-- Solo admin general puede registrar --%>
<% if (SesionUtil.getRol(request) == SesionUtil.ROL_ADMIN_GENERAL) { %>
<div class="form-card" style="margin-bottom:2rem;">
    <h3 style="font-family:'Playfair Display',serif;margin-bottom:1.2rem;font-size:1.1rem;">Registrar nuevo gasto</h3>
    <form action="${pageContext.request.contextPath}/finanzas" method="post">
        <input type="hidden" name="accion" value="registrarGasto">
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Descripción</label>
                <input type="text" name="descripcion" class="form-control" required placeholder="Ej: Pago arriendo mayo...">
            </div>
            <div class="form-group">
                <label class="form-label">Valor ($)</label>
                <input type="number" name="valor" class="form-control" min="0" step="0.01" required>
            </div>
            <div class="form-group">
                <label class="form-label">Fecha</label>
                <input type="date" name="fecha" class="form-control" required value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            </div>
        </div>
        <button type="submit" class="btn btn-primary">💾 Registrar Gasto</button>
    </form>
</div>
<% } %>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">Historial de Gastos</span>
        <input type="text" placeholder="Buscar..." class="form-control" style="width:200px;"
               oninput="filtrarTabla(this.id,'tablaGastos')" id="buscarGastos">
    </div>
    <div class="table-wrapper">
        <table id="tablaGastos">
            <thead><tr><th>Fecha</th><th>Descripción</th><th>Valor</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> gastos = (List<Map<String,Object>>) request.getAttribute("gastos");
                java.math.BigDecimal totalGastos = java.math.BigDecimal.ZERO;
                if (gastos != null && !gastos.isEmpty()) {
                    for (Map<String,Object> g : gastos) {
                        java.math.BigDecimal val = (java.math.BigDecimal) g.get("valor");
                        if (val != null) totalGastos = totalGastos.add(val);
            %>
                <tr>
                    <td><%= g.get("fecha") %></td>
                    <td><%= g.get("descripcion") %></td>
                    <td class="currency" style="font-weight:600;"><%= g.get("valor") %></td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="3"><div class="empty-state"><div class="empty-state-icon">📋</div><div class="empty-state-desc">Sin gastos registrados.</div></div></td></tr>
            <% } %>
            </tbody>
            <tfoot>
                <tr style="background:#faf7f2;">
                    <td colspan="2" style="font-weight:700;text-align:right;padding:0.8rem 1rem;">TOTAL:</td>
                    <td class="currency" style="font-weight:700;font-size:1.05rem;padding:0.8rem 1rem;"><%= totalGastos %></td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
