package com.restaurante.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * SesionUtil.java
 * Utilidades para manejo de sesiones y validación de roles.
 * Centraliza la lógica de seguridad de acceso.
 *
 * Roles del sistema:
 *   1 → Superadministrador
 *   2 → Administrador General
 *   3 → Administrador de Punto
 *   4 → Mesero
 *   5 → Cocinero
 *   6 → Cajero
 *   7 → Inversionista
 *   8 → Cliente
 */
public class SesionUtil {

    // Constantes de rol (coinciden con TIPO_USUARIO en la BD)
    public static final int ROL_SUPERADMIN      = 1;
    public static final int ROL_ADMIN_GENERAL   = 2;
    public static final int ROL_ADMIN_PUNTO     = 3;
    public static final int ROL_MESERO          = 4;
    public static final int ROL_COCINERO        = 5;
    public static final int ROL_CAJERO          = 6;
    public static final int ROL_INVERSIONISTA   = 7;
    public static final int ROL_CLIENTE         = 8;

    // Atributos de sesión
    public static final String ATTR_USUARIO_ID   = "usuarioId";
    public static final String ATTR_USUARIO_ROL  = "usuarioRol";
    public static final String ATTR_USUARIO_NOMBRE = "usuarioNombre";
    public static final String ATTR_RESTAURANTE_ID = "restauranteId";

    /**
     * Verifica si el usuario tiene una sesión activa.
     * Si no la tiene, redirige al login.
     * @return true si la sesión es válida, false si fue redirigido.
     */
    public static boolean verificarSesion(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_USUARIO_ID) == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    /**
     * Verifica que el usuario tenga uno de los roles permitidos.
     * Si no tiene permiso, redirige a acceso-denegado.
     * @param rolesPermitidos ids de roles que pueden acceder.
     * @return true si tiene acceso, false si fue redirigido.
     */
    public static boolean verificarRol(HttpServletRequest request, HttpServletResponse response,
                                       int... rolesPermitidos) throws IOException {
        // Primero verificar que haya sesión activa
        if (!verificarSesion(request, response)) return false;

        HttpSession session = request.getSession(false);
        Object rolObj = session.getAttribute(ATTR_USUARIO_ROL);
        if (rolObj == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        int rolUsuario = ((Number) rolObj).intValue();

        for (int rol : rolesPermitidos) {
            if (rolUsuario == rol) return true;
        }

        // Sin acceso → 403
        response.sendRedirect(request.getContextPath() + "/WEB-INF/vistas/shared/acceso-denegado.jsp");
        return false;
    }

    /**
     * Obtiene el rol del usuario actualmente en sesión.
     */
    public static int getRol(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return -1;
        Object rol = session.getAttribute(ATTR_USUARIO_ROL);
        return rol != null ? ((Number) rol).intValue() : -1;
    }

    /**
     * Obtiene el id del restaurante asociado al usuario en sesión.
     * El superadmin puede ver todos los restaurantes (retorna -1).
     */
    public static int getRestauranteId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return -1;
        Object rid = session.getAttribute(ATTR_RESTAURANTE_ID);
        return rid != null ? ((Number) rid).intValue() : -1;
    }

    /**
     * Obtiene el nombre completo del usuario en sesión.
     */
    public static String getNombreUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return "";
        Object nombre = session.getAttribute(ATTR_USUARIO_NOMBRE);
        return nombre != null ? (String) nombre : "";
    }

    /**
     * Cierra la sesión del usuario.
     */
    public static void cerrarSesion(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
}
