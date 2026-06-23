<%-- cliente/encuesta.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Encuesta de Satisfacción");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
<div class="page-header">
    <h1 class="page-title">Encuesta de Satisfacción</h1>
    <p class="page-subtitle">Su opinión nos ayuda a mejorar</p>
</div>
<div style="max-width:540px;">
<div class="form-card">
<form action="${pageContext.request.contextPath}/resenas" method="post">
    <input type="hidden" name="accion" value="encuesta">
    <div class="form-group" style="margin-bottom:1.2rem;">
        <label class="form-label">¿Quedó satisfecho con el servicio?</label>
        <div style="display:flex;gap:1rem;margin-top:0.4rem;">
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="satisfecho" value="si" required> Sí</label>
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="satisfecho" value="no"> No</label>
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="satisfecho" value="regular"> Regular</label>
        </div>
    </div>
    <div class="form-group" style="margin-bottom:1.2rem;">
        <label class="form-label">¿Le gustó la comida?</label>
        <div style="display:flex;gap:1rem;margin-top:0.4rem;">
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="comida" value="si" required> Sí</label>
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="comida" value="no"> No</label>
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="comida" value="regular"> Regular</label>
        </div>
    </div>
    <div class="form-group" style="margin-bottom:1.2rem;">
        <label class="form-label">¿El tiempo de espera fue adecuado?</label>
        <div style="display:flex;gap:1rem;margin-top:0.4rem;">
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="espera" value="si" required> Sí</label>
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="espera" value="no"> No</label>
            <label style="display:flex;align-items:center;gap:0.4rem;cursor:pointer;"><input type="radio" name="espera" value="regular"> Regular</label>
        </div>
    </div>
    <div class="form-group" style="margin-bottom:1.5rem;">
        <label class="form-label">Observación general</label>
        <textarea name="observacion" class="form-control" rows="4" placeholder="Cuéntenos su experiencia..."></textarea>
    </div>
    <button type="submit" class="btn btn-primary btn-lg">📊 Enviar Encuesta</button>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary btn-lg" style="margin-left:0.8rem;">Cancelar</a>
</form>
</div>
</div>
<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
