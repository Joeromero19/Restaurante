package com.restaurante.controlador;

import com.restaurante.modelo.dao.UsuarioDAO;
import com.restaurante.util.ConexionDB;
import com.restaurante.util.SesionUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/clientes")
public class ClienteServlet extends HttpServlet {

    // ── Carga la lista de sedes activas ──────────────────────────────────────
    private List<Map<String, Object>> cargarSedes(Connection conn) {
        List<Map<String, Object>> sedes = new ArrayList<>();
        String sql = "SELECT r.id_restaurante, r.nombre, r.capacidad, c.nombre AS ciudad " +
                     "FROM RESTAURANTE r JOIN CIUDAD c ON r.id_ciudad = c.id_ciudad " +
                     "WHERE r.activo = TRUE ORDER BY r.nombre";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id_restaurante", rs.getInt("id_restaurante"));
                row.put("nombre",         rs.getString("nombre"));
                row.put("capacidad",      rs.getInt("capacidad"));
                row.put("ciudad",         rs.getString("ciudad"));
                sedes.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[ClienteServlet] Error cargando sedes: " + e.getMessage());
        }
        return sedes;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String accion = req.getParameter("accion");

        if ("registro".equals(accion)) {
            // Cargar sedes para mostrar en el formulario
            Connection conn = ConexionDB.getInstancia().getConexion();
            req.setAttribute("sedes", cargarSedes(conn));
            req.getRequestDispatcher("/WEB-INF/vistas/shared/registroCliente.jsp").forward(req, resp);
            return;
        }

        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_PUNTO,
                SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;

        List<Map<String, Object>> clientes = new ArrayList<>();
        String sql = "SELECT c.id_cliente, p.nombre, p.apellido, p.correo, p.telefono, " +
                     "p.fecha_nacimiento, c.activo, r.nombre AS restaurante " +
                     "FROM CLIENTE c JOIN PERSONA p ON c.id_persona = p.id_persona " +
                     "LEFT JOIN RESTAURANTE r ON c.id_restaurante = r.id_restaurante " +
                     "ORDER BY p.apellido, p.nombre";
        Connection conn = ConexionDB.getInstancia().getConexion();
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idCliente",    rs.getInt("id_cliente"));
                row.put("nombre",       rs.getString("nombre") + " " + rs.getString("apellido"));
                row.put("correo",       rs.getString("correo"));
                row.put("telefono",     rs.getString("telefono"));
                row.put("nacimiento",   rs.getDate("fecha_nacimiento"));
                row.put("activo",       rs.getBoolean("activo"));
                row.put("restaurante",  rs.getString("restaurante"));
                clientes.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[ClienteServlet] Error listando: " + e.getMessage());
        }

        req.setAttribute("clientes", clientes);
        req.setAttribute("pageTitle", "Clientes");
        req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/clientes.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");
        String base   = req.getContextPath() + "/clientes?accion=registro";

        if ("registrar".equals(accion)) {

            // ── 1. Parsear y validar campos ──────────────────────────────────
            String idPersonaStr      = req.getParameter("idPersona");
            String nombre            = req.getParameter("nombre");
            String apellido          = req.getParameter("apellido");
            String correo            = req.getParameter("correo");
            String telefono          = req.getParameter("telefono");
            String fechaNacimientoStr = req.getParameter("fechaNacimiento");
            String idRestauranteStr  = req.getParameter("idRestaurante");

            if (idPersonaStr == null || idPersonaStr.trim().isEmpty() ||
                nombre == null || nombre.trim().isEmpty() ||
                apellido == null || apellido.trim().isEmpty() ||
                correo == null || correo.trim().isEmpty() ||
                fechaNacimientoStr == null || fechaNacimientoStr.trim().isEmpty()) {
                resp.sendRedirect(base + "&msg=campos_vacios");
                return;
            }

            // Validar sede seleccionada
            int idRestaurante;
            try {
                idRestaurante = Integer.parseInt(idRestauranteStr.trim());
                if (idRestaurante <= 0) throw new NumberFormatException();
            } catch (Exception e) {
                resp.sendRedirect(base + "&msg=sede_invalida");
                return;
            }

            // Validar formato nombre/apellido (solo letras)
            if (!nombre.trim().matches("[\\p{L}\\s'.\\-]{2,80}")) {
                resp.sendRedirect(base + "&msg=nombre_invalido");
                return;
            }
            if (!apellido.trim().matches("[\\p{L}\\s'.\\-]{2,80}")) {
                resp.sendRedirect(base + "&msg=nombre_invalido");
                return;
            }

            // Validar formato email
            if (!correo.trim().matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]{2,}$")) {
                resp.sendRedirect(base + "&msg=correo_invalido");
                return;
            }

            // Validar teléfono (opcional)
            if (telefono != null && !telefono.trim().isEmpty() &&
                !telefono.trim().matches("\\d{7,15}")) {
                resp.sendRedirect(base + "&msg=telefono_invalido");
                return;
            }

            // Validar documento: solo números, 6-12 dígitos
            long idPersona;
            try {
                idPersona = Long.parseLong(idPersonaStr.trim());
                if (idPersonaStr.trim().length() < 6 || idPersonaStr.trim().length() > 12) {
                    resp.sendRedirect(base + "&msg=documento_invalido");
                    return;
                }
            } catch (NumberFormatException e) {
                resp.sendRedirect(base + "&msg=documento_invalido");
                return;
            }

            // Validar fecha de nacimiento y edad mínima (13 años)
            java.sql.Date nacimiento;
            try {
                nacimiento = java.sql.Date.valueOf(fechaNacimientoStr.trim());
                java.util.Calendar cal = java.util.Calendar.getInstance();
                java.util.Calendar nac = java.util.Calendar.getInstance();
                nac.setTime(nacimiento);
                if (nac.after(cal)) {
                    resp.sendRedirect(base + "&msg=fecha_invalida");
                    return;
                }
                int edad = cal.get(java.util.Calendar.YEAR) - nac.get(java.util.Calendar.YEAR);
                if (cal.get(java.util.Calendar.DAY_OF_YEAR) < nac.get(java.util.Calendar.DAY_OF_YEAR)) edad--;
                if (edad < 13) {
                    resp.sendRedirect(base + "&msg=edad_invalida");
                    return;
                }
            } catch (IllegalArgumentException e) {
                resp.sendRedirect(base + "&msg=fecha_invalida");
                return;
            }

            // ── 2. Verificar correo duplicado ────────────────────────────────
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            if (usuarioDAO.correoExiste(correo.trim())) {
                resp.sendRedirect(base + "&msg=correo_existe");
                return;
            }

            // ── 3. Insertar PERSONA + CLIENTE en transacción ─────────────────
            Connection conn = ConexionDB.getInstancia().getConexion();
            try {
                conn.setAutoCommit(false);

                // Insertar PERSONA
                String sqlP =
                    "INSERT INTO PERSONA (id_persona, nombre, apellido, correo, telefono, " +
                    "fecha_nacimiento, tipo_persona) VALUES (?,?,?,?,?,?,'cliente') " +
                    "ON DUPLICATE KEY UPDATE nombre=VALUES(nombre), apellido=VALUES(apellido), " +
                    "correo=VALUES(correo), telefono=VALUES(telefono), " +
                    "fecha_nacimiento=VALUES(fecha_nacimiento)";
                try (PreparedStatement ps = conn.prepareStatement(sqlP)) {
                    ps.setLong(1, idPersona);
                    ps.setString(2, nombre.trim());
                    ps.setString(3, apellido.trim());
                    ps.setString(4, correo.trim());
                    ps.setString(5, telefono != null ? telefono.trim() : null);
                    ps.setDate(6, nacimiento);
                    ps.executeUpdate();
                }

                // Insertar CLIENTE con sede seleccionada
                String sqlC =
                    "INSERT INTO CLIENTE (id_persona, id_restaurante, activo) VALUES (?, ?, TRUE) " +
                    "ON DUPLICATE KEY UPDATE activo = TRUE, id_restaurante = VALUES(id_restaurante)";
                try (PreparedStatement ps = conn.prepareStatement(sqlC)) {
                    ps.setLong(1, idPersona);
                    ps.setInt(2, idRestaurante);
                    ps.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(req.getContextPath() + "/login?msg=registrado");

            } catch (SQLException e) {
                try { conn.rollback(); } catch (SQLException ex) {}
                System.err.println("[ClienteServlet] Error registrando: " + e.getMessage());
                resp.sendRedirect(base + "&msg=error");
            } finally {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
            }
        }
    }
}
