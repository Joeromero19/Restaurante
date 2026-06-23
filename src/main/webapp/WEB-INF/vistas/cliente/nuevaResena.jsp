<%-- cliente/nuevaResena.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Nueva Reseña");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Nueva Reseña</h1>
    <p class="page-subtitle">Cuéntenos su experiencia</p>
</div>
<div style="max-width:560px;">
    <div class="form-card">
        <form action="${pageContext.request.contextPath}/resenas" method="post">
            <input type="hidden" name="accion" value="nueva">
            <div class="form-group">
                <label class="form-label">Restaurante</label>
                <select name="idRestaurante" class="form-control" required>
                    <option value="">— Seleccione sede —</option>
                    <%
                        List<Map<String,Object>> restaurantes = (List<Map<String,Object>>) request.getAttribute("restaurantes");
                        if (restaurantes != null) for (Map<String,Object> r : restaurantes) { %>
                    <option value="<%= r.get("idRestaurante") %>"><%= r.get("nombre") %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Calificación</label>
                <select name="calificacion" class="form-control" required>
                    <option value="5">⭐⭐⭐⭐⭐ Excelente</option>
                    <option value="4">⭐⭐⭐⭐ Muy bueno</option>
                    <option value="3">⭐⭐⭐ Bueno</option>
                    <option value="2">⭐⭐ Regular</option>
                    <option value="1">⭐ Malo</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Comentario</label>
                <textarea name="comentario" class="form-control" rows="4" placeholder="Cuéntenos su experiencia..."></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-lg">⭐ Enviar Reseña</button>
            <a href="${pageContext.request.contextPath}/resenas?accion=mis" class="btn btn-secondary btn-lg" style="margin-left:0.8rem;">Cancelar</a>
        </form>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
