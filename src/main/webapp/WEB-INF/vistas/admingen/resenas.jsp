<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<% if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
   request.setAttribute("pageTitle", "Reseñas"); %>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">⭐ Reseñas y Encuestas</h1>
    <p class="page-subtitle">Opiniones de los clientes</p>
</div>
<div class="empty-state" style="padding:3rem;">
    <div class="empty-state-icon">⭐</div>
    <div class="empty-state-desc">Módulo de reseñas en construcción.</div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
