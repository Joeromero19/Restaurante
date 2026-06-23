package com.restaurante.controlador;

import com.restaurante.modelo.dao.EmpleadoDAO;
import com.restaurante.util.ConexionDB;
import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * AdminGenServlet.java
 * Acciones del Administrador General:
 *   GET  ?accion=clientes          → lista de clientes con opción de banear
 *   POST ?accion=banearCliente      → desactiva un cliente
 *   POST ?accion=activarCliente     → reactiva un cliente
 *   POST ?accion=terminarContrato   → pone fecha_fin=TODAY en el contrato activo del empleado
 */
@WebServlet("/admingen")
public class AdminGenServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;

        String accion = req.getParameter("accion");
        int idRest    = SesionUtil.getRestauranteId(req);

        if ("clientes".equals(accion)) {
            // Lista de clientes de la sede con estado
            List<Map<String, Object>> clientes = listarClientes(idRest);
            req.setAttribute("clientes", clientes);
            req.setAttribute("pageTitle", "Clientes");
            req.getRequestDispatcher("/WEB-INF/vistas/admingen/clientes.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;

        String accion = req.getParameter("accion");
        Connection conn = ConexionDB.getInstancia().getConexion();

        if ("banearCliente".equals(accion)) {
            int idCliente = Integer.parseInt(req.getParameter("idCliente"));
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE CLIENTE SET activo = FALSE WHERE id_cliente = ?")) {
                ps.setInt(1, idCliente);
                ps.executeUpdate();
            } catch (SQLException e) {
                System.err.println("[AdminGenServlet] Error baneando: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admingen?accion=clientes&msg=baneado");

        } else if ("activarCliente".equals(accion)) {
            int idCliente = Integer.parseInt(req.getParameter("idCliente"));
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE CLIENTE SET activo = TRUE WHERE id_cliente = ?")) {
                ps.setInt(1, idCliente);
                ps.executeUpdate();
            } catch (SQLException e) {
                System.err.println("[AdminGenServlet] Error activando: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admingen?accion=clientes&msg=activado");

        } else if ("terminarContrato".equals(accion)) {
            int idContrato = Integer.parseInt(req.getParameter("idContrato"));
            int idEmpleado = Integer.parseInt(req.getParameter("idEmpleado"));
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE CONTRATO SET fecha_fin = CURDATE() WHERE id_contrato = ? AND fecha_fin IS NULL")) {
                ps.setInt(1, idContrato);
                ps.executeUpdate();
            } catch (SQLException e) {
                System.err.println("[AdminGenServlet] Error terminando contrato: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/empleados?accion=contratos&id=" + idEmpleado + "&msg=terminado");
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    private List<Map<String, Object>> listarClientes(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        // Si idRestaurante == -1 (superadmin), muestra todos los clientes
        String sql = idRestaurante == -1
            ? "SELECT c.id_cliente, p.nombre, p.apellido, p.correo, p.telefono, c.activo " +
              "FROM CLIENTE c JOIN PERSONA p ON c.id_persona = p.id_persona " +
              "ORDER BY p.apellido, p.nombre"
            : "SELECT c.id_cliente, p.nombre, p.apellido, p.correo, p.telefono, c.activo " +
              "FROM CLIENTE c JOIN PERSONA p ON c.id_persona = p.id_persona " +
              "WHERE c.id_restaurante = ? ORDER BY p.apellido, p.nombre";
        try (PreparedStatement ps = ConexionDB.getInstancia().getConexion().prepareStatement(sql)) {
            if (idRestaurante != -1) ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idCliente", rs.getInt("id_cliente"));
                row.put("nombre",    rs.getString("nombre") + " " + rs.getString("apellido"));
                row.put("correo",    rs.getString("correo"));
                row.put("telefono",  rs.getString("telefono"));
                row.put("activo",    rs.getBoolean("activo"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[AdminGenServlet] Error listando clientes: " + e.getMessage());
        }
        return lista;
    }
}
