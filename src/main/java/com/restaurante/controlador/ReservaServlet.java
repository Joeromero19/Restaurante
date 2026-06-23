package com.restaurante.controlador;

import com.restaurante.util.ConexionDB;
import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/reservas")
public class ReservaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarSesion(req, resp)) return;

        String accion = req.getParameter("accion");
        int rol = SesionUtil.getRol(req);
        com.restaurante.modelo.dao.ReservaDAO dao = new com.restaurante.modelo.dao.ReservaDAO();

        if ("misReservas".equals(accion) && rol == SesionUtil.ROL_CLIENTE) {
            int idCliente = ((Number) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID)).intValue();
            req.setAttribute("reservas", dao.listarPorCliente(idCliente));
            req.setAttribute("pageTitle", "Mis Reservas");
            req.getRequestDispatcher("/WEB-INF/vistas/cliente/misReservas.jsp").forward(req, resp);

        } else if ("nueva".equals(accion) && rol == SesionUtil.ROL_CLIENTE) {
            // Cargar restaurantes activos
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
                System.err.println("[ReservaServlet] Error cargando restaurantes: " + e.getMessage());
            }
            req.setAttribute("restaurantes", restaurantes);
            req.setAttribute("pageTitle", "Nueva Reserva");
            req.getRequestDispatcher("/WEB-INF/vistas/cliente/nuevaReserva.jsp").forward(req, resp);

        } else {
            if (!SesionUtil.verificarRol(req, resp,
                    SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;
            int idRest = SesionUtil.getRestauranteId(req);
            req.setAttribute("reservas", dao.listar(idRest));
            req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/reservas.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarSesion(req, resp)) return;

        String accion = req.getParameter("accion");
        com.restaurante.modelo.dao.ReservaDAO dao = new com.restaurante.modelo.dao.ReservaDAO();
        int idCliente = ((Number) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID)).intValue();

        if ("crear".equals(accion)) {
            java.sql.Date fecha = java.sql.Date.valueOf(req.getParameter("fecha"));
            String hora         = req.getParameter("hora");
            int    personas     = Integer.parseInt(req.getParameter("personas"));
            int    idMesa       = Integer.parseInt(req.getParameter("idMesa"));
            int    idRest       = Integer.parseInt(req.getParameter("idRestaurante"));
            boolean ok = dao.crear(fecha, hora, personas, idCliente, idMesa, idRest);
            resp.sendRedirect(req.getContextPath() + "/reservas?accion=misReservas&msg=" + (ok ? "creada" : "error"));

        } else if ("cancelar".equals(accion)) {
            int idReserva = Integer.parseInt(req.getParameter("idReserva"));
            boolean ok    = dao.cancelar(idReserva);
            resp.sendRedirect(req.getContextPath() + "/reservas?accion=misReservas&msg=" + (ok ? "cancelada" : "no_cancelable"));

        } else if ("modificar".equals(accion)) {
            int           idReserva = Integer.parseInt(req.getParameter("idReserva"));
            java.sql.Date fecha     = java.sql.Date.valueOf(req.getParameter("fecha"));
            String        hora      = req.getParameter("hora");
            int           personas  = Integer.parseInt(req.getParameter("personas"));
            boolean ok = dao.modificar(idReserva, fecha, hora, personas);
            resp.sendRedirect(req.getContextPath() + "/reservas?accion=misReservas&msg=" + (ok ? "modificada" : "error"));
        }
    }
}
