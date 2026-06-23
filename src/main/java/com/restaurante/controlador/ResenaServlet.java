package com.restaurante.controlador;

import com.restaurante.util.ConexionDB;
import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/resenas")
public class ResenaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarSesion(req, resp)) return;
        String accion = req.getParameter("accion");
        int rol = SesionUtil.getRol(req);

        if ("encuesta".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CLIENTE)) return;
            req.setAttribute("pageTitle", "Encuesta de Satisfacción");
            req.getRequestDispatcher("/WEB-INF/vistas/cliente/encuesta.jsp").forward(req, resp);

        } else if ("nueva".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CLIENTE)) return;
            // Cargar restaurantes para el formulario
            List<Map<String, Object>> restaurantes = new ArrayList<>();
            String sql = "SELECT id_restaurante, nombre FROM RESTAURANTE WHERE activo = TRUE ORDER BY nombre";
            try (PreparedStatement ps = ConexionDB.getInstancia().getConexion().prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> r = new HashMap<>();
                    r.put("idRestaurante", rs.getInt("id_restaurante"));
                    r.put("nombre", rs.getString("nombre"));
                    restaurantes.add(r);
                }
            } catch (SQLException e) {
                System.err.println("[ResenaServlet] Error cargando restaurantes: " + e.getMessage());
            }
            req.setAttribute("restaurantes", restaurantes);
            req.setAttribute("pageTitle", "Nueva Reseña");
            req.getRequestDispatcher("/WEB-INF/vistas/cliente/nuevaResena.jsp").forward(req, resp);

        } else if ("mis".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CLIENTE)) return;
            int idCliente = ((Number) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID)).intValue();
            List<Map<String, Object>> misResenas = new ArrayList<>();
            String sql = "SELECT r.id_resena, r.calificacion, r.comentario, r.fecha, res.nombre AS restaurante " +
                         "FROM RESENA r JOIN RESTAURANTE res ON r.id_restaurante = res.id_restaurante " +
                         "WHERE r.id_cliente = ? ORDER BY r.fecha DESC";
            try (PreparedStatement ps = ConexionDB.getInstancia().getConexion().prepareStatement(sql)) {
                ps.setInt(1, idCliente);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("idResena",     rs.getInt("id_resena"));
                    row.put("calificacion", rs.getInt("calificacion"));
                    row.put("comentario",   rs.getString("comentario"));
                    row.put("fecha",        rs.getDate("fecha"));
                    row.put("restaurante",  rs.getString("restaurante"));
                    misResenas.add(row);
                }
            } catch (SQLException e) {
                System.err.println("[ResenaServlet] Error cargando reseñas: " + e.getMessage());
            }
            req.setAttribute("misResenas", misResenas);
            req.setAttribute("pageTitle", "Mis Reseñas");
            req.getRequestDispatcher("/WEB-INF/vistas/cliente/misResenas.jsp").forward(req, resp);

        } else {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
            req.setAttribute("pageTitle", "Reseñas y Encuestas");
            req.getRequestDispatcher("/WEB-INF/vistas/admingen/resenas.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarSesion(req, resp)) return;

        String accion = req.getParameter("accion");
        int idCliente = ((Number) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID)).intValue();

        if ("encuesta".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CLIENTE)) return;

            String satisfecho  = req.getParameter("satisfecho");
            String comida      = req.getParameter("comida");
            String espera      = req.getParameter("espera");
            String observacion = req.getParameter("observacion");

            // Convertir respuestas a calificación 1-5
            int puntos = puntaje(satisfecho) + puntaje(comida) + puntaje(espera); // 3-9
            int calificacion = Math.round((puntos - 3) * 4.0f / 6.0f) + 1;       // escala a 1-5

            // Buscar restaurante del cliente (última reserva, o el primero disponible)
            int idRestaurante = 1;
            String sqlRest = "SELECT id_restaurante FROM RESERVA WHERE id_cliente = ? ORDER BY fecha_reserva DESC LIMIT 1";
            try (PreparedStatement ps = ConexionDB.getInstancia().getConexion().prepareStatement(sqlRest)) {
                ps.setInt(1, idCliente);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) idRestaurante = rs.getInt("id_restaurante");
            } catch (SQLException e) {
                System.err.println("[ResenaServlet] Error buscando restaurante: " + e.getMessage());
            }

            String sqlIns = "INSERT INTO RESENA (id_cliente, id_restaurante, calificacion, comentario, fecha) VALUES (?,?,?,?,CURDATE())";
            try (PreparedStatement ps = ConexionDB.getInstancia().getConexion().prepareStatement(sqlIns)) {
                ps.setInt(1, idCliente);
                ps.setInt(2, idRestaurante);
                ps.setInt(3, calificacion);
                ps.setString(4, observacion != null ? observacion.trim() : "");
                ps.executeUpdate();
                resp.sendRedirect(req.getContextPath() + "/dashboard?msg=encuesta_enviada");
            } catch (SQLException e) {
                System.err.println("[ResenaServlet] Error guardando encuesta: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/resenas?accion=encuesta&msg=error");
            }

        } else if ("nueva".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CLIENTE)) return;
            int idRestaurante = Integer.parseInt(req.getParameter("idRestaurante"));
            int calificacion  = Integer.parseInt(req.getParameter("calificacion"));
            String comentario = req.getParameter("comentario");

            String sqlIns = "INSERT INTO RESENA (id_cliente, id_restaurante, calificacion, comentario, fecha) VALUES (?,?,?,?,CURDATE())";
            try (PreparedStatement ps = ConexionDB.getInstancia().getConexion().prepareStatement(sqlIns)) {
                ps.setInt(1, idCliente);
                ps.setInt(2, idRestaurante);
                ps.setInt(3, calificacion);
                ps.setString(4, comentario != null ? comentario.trim() : "");
                ps.executeUpdate();
                resp.sendRedirect(req.getContextPath() + "/resenas?accion=mis&msg=creada");
            } catch (SQLException e) {
                System.err.println("[ResenaServlet] Error guardando reseña: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/resenas?accion=nueva&msg=error");
            }
        }
    }

    private int puntaje(String val) {
        if ("si".equals(val))      return 3;
        if ("regular".equals(val)) return 2;
        return 1;
    }
}
