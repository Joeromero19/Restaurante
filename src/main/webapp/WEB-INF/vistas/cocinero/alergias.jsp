<%-- cocinero/alergias.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_COCINERO, SesionUtil.ROL_ADMIN_PUNTO)) return;
    request.setAttribute("pageTitle", "Pedidos con Alergias");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">⚠️ Pedidos con Restricciones / Alergias</h1>
    <p class="page-subtitle">Preste especial atención a la preparación de estos platos</p>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#Pedido</th><th>Mesa</th><th>Hora</th><th>Producto</th><th>Alergia / Restricción</th><th>Obs. General</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> lista = (List<Map<String,Object>>) request.getAttribute("pedidosAlergias");
                if (lista != null && !lista.isEmpty()) {
                    for (Map<String,Object> p : lista) { %>
                <tr style="background:#fff8e1;">
                    <td><strong>#<%= p.get("idPedido") %></strong></td>
                    <td>Mesa <%= p.get("idMesa") %></td>
                    <td style="font-size:0.82rem;"><%= p.get("fechaPedido") %></td>
                    <td><%= p.get("producto") %></td>
                    <td><span class="badge badge-alerta">⚠ <%= p.get("alergiaItem") %></span></td>
                    <td style="font-size:0.82rem;"><%= p.get("observaciones") != null ? p.get("observaciones") : "—" %></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">✅</div><div class="empty-state-title">Sin alergias reportadas</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
