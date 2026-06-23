<%-- cliente/nuevaReserva.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.restaurante.util.SesionUtil,java.util.*" %>
<%
    if (!SesionUtil.verificarRol(request, response, SesionUtil.ROL_CLIENTE)) return;
    request.setAttribute("pageTitle", "Nueva Reserva");
%>
<%@ include file="/WEB-INF/vistas/shared/header.jsp" %>

<div class="page-header">
    <h1 class="page-title">Nueva Reserva</h1>
    <p class="page-subtitle">Complete los datos para reservar su mesa. Cancelaciones hasta 2 horas antes.</p>
</div>

<div style="max-width:560px;">
    <div class="form-card">
        <form action="${pageContext.request.contextPath}/reservas" method="post">
            <input type="hidden" name="accion" value="crear">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Fecha de reserva</label>
                    <input type="date" name="fecha" class="form-control" required
                           min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                </div>
                <div class="form-group">
                    <label class="form-label">Hora</label>
                    <input type="time" name="hora" class="form-control" required min="10:00" max="22:00">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Número de personas</label>
                    <input type="number" name="personas" class="form-control" min="1" max="20" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Restaurante</label>
                    <select name="idRestaurante" class="form-control" required onchange="cargarMesas(this.value)">
                        <option value="">— Seleccione sede —</option>
                        <%
                            List<Map<String,Object>> restaurantes = (List<Map<String,Object>>) request.getAttribute("restaurantes");
                            if (restaurantes != null) {
                                for (Map<String,Object> r : restaurantes) { %>
                        <option value="<%= r.get("idRestaurante") %>"><%= r.get("nombre") %></option>
                        <%  }
                            }
                        %>
                    </select>
                </div>
            </div>
            <div class="form-group" style="margin-bottom:1.5rem;">
                <label class="form-label">Mesa preferida</label>
                <select name="idMesa" id="selectMesa" class="form-control" required>
                    <option value="">— Primero seleccione restaurante —</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary btn-lg">📅 Confirmar Reserva</button>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary btn-lg" style="margin-left:0.8rem;">Cancelar</a>
        </form>
    </div>
    <p style="margin-top:1rem;font-size:0.82rem;color:#888;">
        ℹ Las reservas pueden modificarse o cancelarse hasta <strong>2 horas antes</strong> del horario reservado.
    </p>
</div>

<script>
function cargarMesas(idRestaurante) {
    var sel = document.getElementById('selectMesa');
    sel.innerHTML = '<option value="">Cargando...</option>';
    // En producción: fetch al servidor para mesas disponibles del restaurante
    // Simplificado: mesas de ejemplo
    sel.innerHTML = '<option value="">— Seleccione mesa —</option>';
}
</script>

<%@ include file="/WEB-INF/vistas/shared/footer.jsp" %>
