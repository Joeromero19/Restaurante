<%-- cliente/misResenas.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Mis Reseñas");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Mis Reseñas</h1>
    <p class="page-subtitle">Historial de sus opiniones y encuestas</p>
</div>
<% String msg = request.getParameter("msg");
   if ("creada".equals(msg)) { %>
<div class="msg-success">✓ Reseña enviada correctamente.</div>
<% } %>
<div style="margin-bottom:1rem;">
    <a href="${pageContext.request.contextPath}/resenas?accion=nueva" class="btn btn-primary">⭐ Nueva Reseña</a>
    <a href="${pageContext.request.contextPath}/resenas?accion=encuesta" class="btn btn-secondary" style="margin-left:0.5rem;">📊 Encuesta</a>
</div>
<div class="table-card">
    <div class="table-wrapper">
        <table>
            <thead><tr><th>#</th><th>Restaurante</th><th>Calificación</th><th>Comentario</th><th>Fecha</th></tr></thead>
            <tbody>
            <%
                List<Map<String,Object>> misResenas = (List<Map<String,Object>>) request.getAttribute("misResenas");
                if (misResenas != null && !misResenas.isEmpty()) {
                    for (Map<String,Object> r : misResenas) {
                        int cal = ((Number) r.get("calificacion")).intValue();
                        StringBuilder estrellas = new StringBuilder();
                        for (int i = 1; i <= 5; i++) estrellas.append(i <= cal ? "★" : "☆");
            %>
                <tr>
                    <td><%= r.get("idResena") %></td>
                    <td><%= r.get("restaurante") %></td>
                    <td style="color:#e0a800;font-size:1.1rem;"><%= estrellas %></td>
                    <td><%= r.get("comentario") != null ? r.get("comentario") : "—" %></td>
                    <td><%= r.get("fecha") %></td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="5">
                    <div class="empty-state">
                        <div class="empty-state-icon">⭐</div>
                        <div class="empty-state-desc">Aún no ha enviado reseñas.</div>
                    </div>
                </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
