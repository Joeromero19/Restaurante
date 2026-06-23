<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  header.jsp — Fragmento de cabecera reutilizable.
  Incluye sidebar + topbar según el rol del usuario.

  Uso:  <%@ include file="/WEB-INF/vistas/shared/header.jsp" %>
  Param: pageTitle (String) — título de la página actual
--%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Sabor Distrital" %> — Sabor Distrital</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<%
    // Obtener datos de sesión para el header
    String nombreUsuario = (String) session.getAttribute("usuarioNombre");
    Integer rolUsuario   = (Integer) session.getAttribute("usuarioRol");
    if (nombreUsuario == null) nombreUsuario = "Usuario";
    if (rolUsuario    == null) rolUsuario    = -1;

    String rolTexto;
    switch (rolUsuario) {
        case 1:  rolTexto = "Superadministrador";    break;
        case 2:  rolTexto = "Administrador General"; break;
        case 3:  rolTexto = "Admin. de Punto";       break;
        case 4:  rolTexto = "Mesero";                break;
        case 5:  rolTexto = "Cocinero";              break;
        case 6:  rolTexto = "Cajero";                break;
        case 7:  rolTexto = "Inversionista";         break;
        case 8:  rolTexto = "Cliente";               break;
        default: rolTexto = "Sin rol";
    }

    // Iniciales del usuario para el avatar
    String[] partes    = nombreUsuario.split(" ");
    String iniciales   = partes.length >= 2
        ? String.valueOf(partes[0].charAt(0)) + String.valueOf(partes[1].charAt(0))
        : String.valueOf(partes[0].charAt(0));
    iniciales = iniciales.toUpperCase();
%>

<!-- Overlay para mobile -->
<div id="sidebarOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:99;"></div>

<div class="app-layout">

<!-- ================================================================
     SIDEBAR
================================================================ -->
<aside class="sidebar">

    <!-- Logo -->
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-logo">
            <div class="sidebar-logo-mark">SD</div>
            <div>
                <div class="sidebar-logo-text">Sabor Distrital</div>
                <div class="sidebar-logo-sub">Sistema de Gestión</div>
            </div>
        </a>
    </div>

    <!-- Info usuario -->
    <div class="sidebar-user">
        <div class="sidebar-user-avatar"><%= iniciales %></div>
        <div class="sidebar-user-info">
            <div class="sidebar-user-name"><%= nombreUsuario %></div>
            <div class="sidebar-user-role"><%= rolTexto %></div>
        </div>
    </div>

    <!-- Navegación según rol -->
    <nav class="sidebar-nav">

        <% if (rolUsuario == 1) { // SUPERADMIN %>
        <div class="sidebar-section-title">GLOBAL</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/superadmin?accion=sedes"><span class="nav-icon">🏢</span> Todas las Sedes</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=global"><span class="nav-icon">💰</span> Finanzas Globales</a>
        <a href="${pageContext.request.contextPath}/empleados?accion=todos"><span class="nav-icon">👥</span> Todos los Empleados</a>
        <a href="${pageContext.request.contextPath}/inventario"><span class="nav-icon">📦</span> Inventarios</a>
        <a href="${pageContext.request.contextPath}/superadmin?accion=admins"><span class="nav-icon">🔑</span> Administradores</a>

        <% } else if (rolUsuario == 2) { // ADMIN GENERAL %>
        <div class="sidebar-section-title">GESTIÓN</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=resumen"><span class="nav-icon">💰</span> Finanzas</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=gastos"><span class="nav-icon">📋</span> Gastos</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=propinas"><span class="nav-icon">💳</span> Propinas</a>
        <a href="${pageContext.request.contextPath}/empleados"><span class="nav-icon">👥</span> Empleados y Contratos</a>
        <a href="${pageContext.request.contextPath}/admingen?accion=clientes"><span class="nav-icon">🚫</span> Clientes / Banear</a>
        <a href="${pageContext.request.contextPath}/resenas"><span class="nav-icon">⭐</span> Reseñas</a>

        <% } else if (rolUsuario == 3) { // ADMIN PUNTO %>
        <div class="sidebar-section-title">PUNTO</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/inventario"><span class="nav-icon">📦</span> Inventario</a>
        <a href="${pageContext.request.contextPath}/inventario?accion=vencer"><span class="nav-icon">⏰</span> Por Vencer</a>
        <a href="${pageContext.request.contextPath}/inventario?accion=stockBajo"><span class="nav-icon">⚡</span> Stock Bajo</a>
        <a href="${pageContext.request.contextPath}/inventario?accion=disponibilidad"><span class="nav-icon">🍽️</span> Disp. Platos</a>
        <a href="${pageContext.request.contextPath}/productos"><span class="nav-icon">🥘</span> Productos / Menú</a>
        <a href="${pageContext.request.contextPath}/clientes"><span class="nav-icon">👤</span> Clientes</a>
        <a href="${pageContext.request.contextPath}/facturas"><span class="nav-icon">🧾</span> Facturas</a>
        <a href="${pageContext.request.contextPath}/pedidos?accion=listar"><span class="nav-icon">📝</span> Pedidos</a>
        <a href="${pageContext.request.contextPath}/reservas"><span class="nav-icon">📅</span> Reservas</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=metodoPago"><span class="nav-icon">💳</span> Métodos de Pago</a>
        <a href="${pageContext.request.contextPath}/empleados?accion=memorandos"><span class="nav-icon">⚠️</span> Memorandos</a>

        <% } else if (rolUsuario == 4) { // MESERO %>
        <div class="sidebar-section-title">MESERO</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/pedidos?accion=listar"><span class="nav-icon">📝</span> Mis Pedidos</a>
        <a href="${pageContext.request.contextPath}/pedidos?accion=nuevo"><span class="nav-icon">➕</span> Nuevo Pedido</a>
        <a href="${pageContext.request.contextPath}/facturas?accion=misFact"><span class="nav-icon">🧾</span> Mis Facturas</a>

        <% } else if (rolUsuario == 5) { // COCINERO — SIN stock bajo %>
        <div class="sidebar-section-title">COCINA</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/pedidos?accion=listar"><span class="nav-icon">📋</span> Cola de Pedidos</a>
        <a href="${pageContext.request.contextPath}/pedidos?accion=alergias"><span class="nav-icon">⚠️</span> Alergias</a>
        <a href="${pageContext.request.contextPath}/productos?accion=recetas"><span class="nav-icon">📖</span> Recetas</a>

        <% } else if (rolUsuario == 6) { // CAJERO %>
        <div class="sidebar-section-title">CAJERO</div>
        <a href="${pageContext.request.contextPath}/cajero"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/cajero?accion=pedidosListos"><span class="nav-icon">📋</span> Cobrar Pedidos</a>
        <a href="${pageContext.request.contextPath}/cajero?accion=historial"><span class="nav-icon">🧾</span> Historial Facturas</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=metodoPago"><span class="nav-icon">💳</span> Métodos de Pago</a>

        <% } else if (rolUsuario == 7) { // INVERSIONISTA — con propinas %>
        <div class="sidebar-section-title">INVERSIÓN</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=resumen"><span class="nav-icon">💰</span> Resumen Financiero</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=gastos"><span class="nav-icon">📋</span> Gastos Detallados</a>
        <a href="${pageContext.request.contextPath}/finanzas?accion=propinas"><span class="nav-icon">🎉</span> Propinas por Mes</a>

        <% } else if (rolUsuario == 8) { // CLIENTE %>
        <div class="sidebar-section-title">MI CUENTA</div>
        <a href="${pageContext.request.contextPath}/dashboard"><span class="nav-icon">🏠</span> Inicio</a>
        <a href="${pageContext.request.contextPath}/reservas?accion=misReservas"><span class="nav-icon">📅</span> Mis Reservas</a>
        <a href="${pageContext.request.contextPath}/reservas?accion=nueva"><span class="nav-icon">➕</span> Nueva Reserva</a>
        <a href="${pageContext.request.contextPath}/resenas?accion=mis"><span class="nav-icon">⭐</span> Mis Reseñas</a>
        <a href="${pageContext.request.contextPath}/resenas?accion=encuesta"><span class="nav-icon">📊</span> Encuesta</a>
        <% } %>

    </nav>

    <!-- Cerrar sesión -->
    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout"
           onclick="return confirm('¿Desea cerrar sesión?')">
            <span>🚪</span> Cerrar Sesión
        </a>
    </div>

</aside>

<!-- ================================================================
     CONTENIDO PRINCIPAL
================================================================ -->
<div class="main-content">

    <!-- Topbar -->
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:1rem;">
            <!-- Botón hamburguesa (mobile) -->
            <button id="sidebarToggle"
                    style="background:none;border:none;font-size:1.3rem;cursor:pointer;display:none;"
                    aria-label="Menú">☰</button>
            <span class="topbar-title"><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Panel" %></span>
        </div>
        <div class="topbar-actions">
            <% Integer ridAttr = (Integer) session.getAttribute("restauranteId");
               if (ridAttr != null && ridAttr > 0) { %>
            <span class="topbar-restaurante">🏢 Sede #<%= ridAttr %></span>
            <% } %>
            <span style="font-size:0.82rem;color:#888;"><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %></span>
        </div>
    </header>

    <!-- Área de página -->
    <main class="page-content">
