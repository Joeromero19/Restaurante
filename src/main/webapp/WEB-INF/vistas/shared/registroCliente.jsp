<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sabor Distrital — Registro de Cliente</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    <style>
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0 1.2rem; }
        .form-grid .form-group.full { grid-column: 1 / -1; }
        .form-hint-block {
            background: #fef9f0;
            border: 1px solid #e8d5b0;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            margin-bottom: 1.2rem;
            font-size: 0.82rem;
            color: #7a5c2e;
            line-height: 1.5;
        }
        .sede-options {
            display: grid;
            grid-template-columns: 1fr;
            gap: 0.6rem;
            margin-top: 0.4rem;
        }
        .sede-card {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            border: 2px solid #e8d5b0;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
            background: #fff;
        }
        .sede-card:has(input:checked) {
            border-color: #b8860b;
            background: #fef9f0;
        }
        .sede-card input[type="radio"] {
            accent-color: #b8860b;
            width: 18px;
            height: 18px;
            flex-shrink: 0;
        }
        .sede-card-info { display: flex; flex-direction: column; }
        .sede-card-nombre { font-weight: 600; font-size: 0.92rem; color: #2c1a0e; }
        .sede-card-ciudad { font-size: 0.8rem; color: #7a5c2e; margin-top: 1px; }
        @media (max-width: 480px) { .form-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-brand">
        <div class="brand-content">
            <div class="logo-mark">SD</div>
            <h1 class="brand-name">Sabor<br>Distrital</h1>
            <p class="brand-tagline">Sistema de Gestión Integral<br>Cadena Internacional de Restaurantes</p>
            <div class="brand-deco"><span></span><span></span><span></span></div>
        </div>
        <div class="brand-bg-pattern"></div>
    </div>

    <div class="login-form-panel">
        <div class="form-wrapper">
            <h2 class="form-title">Crear cuenta</h2>
            <p class="form-subtitle">Regístrese para hacer reservas y más</p>

            <%
                String msg = request.getParameter("msg");
                String alertMsg = null;
                if ("correo_existe".equals(msg))        alertMsg = "Ese correo ya está registrado. Intente iniciar sesión.";
                else if ("correo_invalido".equals(msg))    alertMsg = "El correo ingresado no tiene un formato válido.";
                else if ("documento_invalido".equals(msg)) alertMsg = "El número de documento debe contener entre 6 y 12 dígitos numéricos.";
                else if ("nombre_invalido".equals(msg))    alertMsg = "Nombre y apellido solo pueden contener letras.";
                else if ("telefono_invalido".equals(msg))  alertMsg = "El teléfono solo debe contener números (7 a 15 dígitos).";
                else if ("fecha_invalida".equals(msg))     alertMsg = "La fecha de nacimiento no puede ser hoy ni en el futuro.";
                else if ("edad_invalida".equals(msg))      alertMsg = "Debe tener al menos 13 años para registrarse.";
                else if ("campos_vacios".equals(msg))      alertMsg = "Por favor complete todos los campos obligatorios.";
                else if ("sede_invalida".equals(msg))      alertMsg = "Por favor seleccione una sede.";
                else if ("error".equals(msg))              alertMsg = "Ocurrió un error al registrar. Intente de nuevo.";
            %>
            <% if (alertMsg != null) { %>
            <div class="alert alert-error">
                <span class="alert-icon">⚠</span>
                <%= alertMsg %>
            </div>
            <% } %>

            <div class="form-hint-block">
                💡 Su <strong>número de documento</strong> será su contraseña para ingresar al sistema.
            </div>

            <form action="${pageContext.request.contextPath}/clientes" method="post" id="registroForm" novalidate>
                <input type="hidden" name="accion" value="registrar">

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Nombre *</label>
                        <div class="input-wrapper">
                            <input type="text" name="nombre" class="form-input"
                                   placeholder="Ej: Juan" required maxlength="80"
                                   value="${param.nombre}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Apellido *</label>
                        <div class="input-wrapper">
                            <input type="text" name="apellido" class="form-input"
                                   placeholder="Ej: Pérez" required maxlength="80"
                                   value="${param.apellido}">
                        </div>
                    </div>
                    <div class="form-group full">
                        <label class="form-label">Número de documento (CC / CE) *</label>
                        <div class="input-wrapper">
                            <input type="text" name="idPersona" class="form-input"
                                   placeholder="Ej: 1012345678" required
                                   pattern="[0-9]+" title="Solo números"
                                   value="${param.idPersona}">
                            <span class="input-icon">🪪</span>
                        </div>
                    </div>
                    <div class="form-group full">
                        <label class="form-label">Correo electrónico *</label>
                        <div class="input-wrapper">
                            <input type="email" name="correo" class="form-input"
                                   placeholder="usuario@email.com" required maxlength="120"
                                   value="${param.correo}">
                            <span class="input-icon">✉</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Teléfono</label>
                        <div class="input-wrapper">
                            <input type="tel" name="telefono" class="form-input"
                                   placeholder="Ej: 3001234567" maxlength="20"
                                   value="${param.telefono}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Fecha de nacimiento *</label>
                        <div class="input-wrapper">
                            <input type="date" name="fechaNacimiento" class="form-input"
                                   required value="${param.fechaNacimiento}">
                        </div>
                    </div>

                    <%-- ── Selector de sede ── --%>
                    <div class="form-group full">
                        <label class="form-label">Sede de preferencia *</label>
                        <%
                            @SuppressWarnings("unchecked")
                            java.util.List<java.util.Map<String,Object>> sedes =
                                (java.util.List<java.util.Map<String,Object>>) request.getAttribute("sedes");
                            String sedeSeleccionada = request.getParameter("idRestaurante");
                        %>
                        <% if (sedes != null && !sedes.isEmpty()) { %>
                        <div class="sede-options">
                            <% for (java.util.Map<String,Object> sede : sedes) {
                                String sid = String.valueOf(sede.get("id_restaurante"));
                                boolean checked = sid.equals(sedeSeleccionada);
                            %>
                            <label class="sede-card">
                                <input type="radio" name="idRestaurante" value="<%= sid %>"
                                       <%= checked ? "checked" : "" %> required>
                                <span class="sede-icon">🏠</span>
                                <div class="sede-card-info">
                                    <span class="sede-card-nombre"><%= sede.get("nombre") %></span>
                                    <span class="sede-card-ciudad">📍 <%= sede.get("ciudad") %> &nbsp;·&nbsp; Capacidad: <%= sede.get("capacidad") %> personas</span>
                                </div>
                            </label>
                            <% } %>
                        </div>
                        <% } else { %>
                        <p style="color:#c0392b;font-size:0.88rem;">No hay sedes disponibles en este momento.</p>
                        <% } %>
                    </div>
                </div>

                <button type="submit" class="btn-login">
                    <span class="btn-text">Crear cuenta</span>
                    <span class="btn-arrow">→</span>
                </button>
            </form>

            <div class="login-footer">
                <p>¿Ya tiene cuenta? <a href="${pageContext.request.contextPath}/login">Inicie sesión aquí</a></p>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/login.js"></script>
</body>
</html>
