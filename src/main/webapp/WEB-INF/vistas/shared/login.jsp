<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sabor Distrital — Iniciar Sesión</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>

<div class="login-container">
    <!-- Panel izquierdo: branding -->
    <div class="login-brand">
        <div class="brand-content">
            <div class="logo-mark">SD</div>
            <h1 class="brand-name">Sabor<br>Distrital</h1>
            <p class="brand-tagline">Sistema de Gestión Integral<br>Cadena Internacional de Restaurantes</p>
            <div class="brand-deco">
                <span></span><span></span><span></span>
            </div>
        </div>
        <div class="brand-bg-pattern"></div>
    </div>

    <!-- Panel derecho: formulario -->
    <div class="login-form-panel">
        <div class="form-wrapper">
            <h2 class="form-title">Bienvenido</h2>
            <p class="form-subtitle">Ingrese sus credenciales para continuar</p>

            <%-- Mensajes de error / info --%>
            <% String error = (String) request.getAttribute("error"); %>
            <% String msg   = request.getParameter("msg"); %>

            <% if (error != null) { %>
            <div class="alert alert-error">
                <span class="alert-icon">⚠</span>
                <%= error %>
            </div>
            <% } %>

            <% if ("sesion_cerrada".equals(msg)) { %>
            <div class="alert alert-info">
                <span class="alert-icon">✓</span>
                Sesión cerrada correctamente.
            </div>
            <% } %>

            <% if ("rol_invalido".equals(msg)) { %>
            <div class="alert alert-error">
                <span class="alert-icon">⚠</span>
                Su cuenta no tiene un rol válido asignado. Contacte al administrador.
            </div>
            <% } %>

            <% if ("registrado".equals(msg)) { %>
            <div class="alert alert-info">
                <span class="alert-icon">✓</span>
                Cuenta creada exitosamente. Ya puede iniciar sesión.
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm" novalidate>

                <div class="form-group">
                    <label for="correo" class="form-label">Correo electrónico</label>
                    <div class="input-wrapper">
                        <input type="email" id="correo" name="correo"
                               class="form-input"
                               placeholder="usuario@email.com"
                               required autocomplete="email"
                               value="${not empty param.correo ? param.correo : ''}">
                        <span class="input-icon">✉</span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">Contraseña</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password"
                               class="form-input"
                               placeholder="••••••••"
                               required autocomplete="current-password">
                        <span class="input-icon toggle-pwd" id="togglePwd" title="Mostrar/ocultar">👁</span>
                    </div>
                    <small class="form-hint">Use su número de documento como contraseña (sistema académico)</small>
                </div>

                <button type="submit" class="btn-login" id="btnLogin">
                    <span class="btn-text">Ingresar al sistema</span>
                    <span class="btn-arrow">→</span>
                </button>

            </form>

            <div class="login-footer">
                <p>¿Nuevo cliente? <a href="${pageContext.request.contextPath}/clientes?accion=registro">Regístrese aquí</a></p>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/login.js"></script>
</body>
</html>
