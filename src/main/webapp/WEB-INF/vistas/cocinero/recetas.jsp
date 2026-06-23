<%-- cocinero/recetas.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_COCINERO, SesionUtil.ROL_ADMIN_PUNTO)) return;
    request.setAttribute("pageTitle", "Recetas");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Libro de Recetas</h1>
    <p class="page-subtitle">Ingredientes, cantidades y modo de preparación</p>
</div>

<div style="margin-bottom:1rem;">
    <input type="text" placeholder="Buscar plato..." class="form-control" style="max-width:300px;"
           oninput="filtrarTabla(this.id,'tablaRecetas')" id="buscarRecetas">
</div>

<div class="table-card">
    <div class="table-card-header">
        <span class="table-card-title">📖 Recetas del Menú</span>
    </div>
    <div class="table-wrapper">
        <table id="tablaRecetas">
            <thead>
                <tr><th>Plato</th><th>Tipo</th><th>Ingrediente</th><th>Cantidad</th><th>Unidad</th><th>Precio</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> recetas = (List<Map<String,Object>>) request.getAttribute("recetas");
                if (recetas != null && !recetas.isEmpty()) {
                    String platoActual = "";
                    for (Map<String,Object> r : recetas) {
                        String plato = (String) r.get("plato");
                        boolean nuevaSeccion = !plato.equals(platoActual);
                        if (nuevaSeccion) platoActual = plato;
            %>
                <tr style="<%= nuevaSeccion ? "background:#faf7f2;" : "" %>">
                    <td><%= nuevaSeccion ? "<strong>" + plato + "</strong>" : "" %></td>
                    <td style="font-size:0.78rem;"><%= nuevaSeccion ? r.get("tipo") : "" %></td>
                    <td><%= r.get("ingrediente") %></td>
                    <td><%= r.get("cantidad") %></td>
                    <td><%= r.get("unidad") %></td>
                    <td class="currency"><%= nuevaSeccion ? r.get("precio") : "" %></td>
                </tr>
            <%  }
                } else { %>
                <tr><td colspan="6"><div class="empty-state"><div class="empty-state-icon">📖</div><div class="empty-state-desc">Sin recetas registradas.</div></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
