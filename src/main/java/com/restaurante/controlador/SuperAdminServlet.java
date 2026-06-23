package com.restaurante.controlador;

import com.restaurante.util.ConexionDB;
import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet("/superadmin")
public class SuperAdminServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_SUPERADMIN)) return;
        String accion = req.getParameter("accion");

        Connection conn = ConexionDB.getInstancia().getConexion();

        if ("sedes".equals(accion)) {
            // Listar todos los restaurantes con resumen
            List<Map<String,Object>> sedes = new ArrayList<>();
            String sql = "SELECT r.id_restaurante, r.nombre, r.capacidad, r.activo, c.nombre AS ciudad, p.nombre AS pais " +
                         "FROM RESTAURANTE r JOIN CIUDAD c ON r.id_ciudad=c.id_ciudad JOIN PAIS p ON c.id_pais=p.id_pais ORDER BY p.nombre, c.nombre";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("idRestaurante", rs.getInt("id_restaurante"));
                    row.put("nombre",        rs.getString("nombre"));
                    row.put("capacidad",     rs.getInt("capacidad"));
                    row.put("activo",        rs.getBoolean("activo"));
                    row.put("ciudad",        rs.getString("ciudad"));
                    row.put("pais",          rs.getString("pais"));
                    sedes.add(row);
                }
            } catch (SQLException e) { System.err.println(e.getMessage()); }
            req.setAttribute("sedes", sedes);
            req.setAttribute("pageTitle", "Todas las Sedes");
            req.getRequestDispatcher("/WEB-INF/vistas/superadmin/sedes.jsp").forward(req, resp);

        } else if ("admins".equals(accion)) {
            // Listar administradores
            List<Map<String,Object>> admins = new ArrayList<>();
            String sql = "SELECT e.id_empleado, p.nombre, p.apellido, p.correo, r.nombre AS restaurante, tu.nombre AS rol " +
                         "FROM EMPLEADO e JOIN PERSONA p ON e.id_persona=p.id_persona " +
                         "JOIN RESTAURANTE r ON e.id_restaurante=r.id_restaurante " +
                         "JOIN TIPO_USUARIO tu ON e.id_tipo_usuario=tu.id_tipo_usuario " +
                         "WHERE e.id_tipo_usuario IN (2,3) ORDER BY tu.nombre";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("idEmpleado",  rs.getInt("id_empleado"));
                    row.put("nombre",      rs.getString("nombre") + " " + rs.getString("apellido"));
                    row.put("correo",      rs.getString("correo"));
                    row.put("restaurante", rs.getString("restaurante"));
                    row.put("rol",         rs.getString("rol"));
                    admins.add(row);
                }
            } catch (SQLException e) { System.err.println(e.getMessage()); }
            req.setAttribute("admins", admins);
            req.setAttribute("pageTitle", "Administradores");
            req.getRequestDispatcher("/WEB-INF/vistas/superadmin/admins.jsp").forward(req, resp);

        } else {
            // Dashboard
            req.getRequestDispatcher("/WEB-INF/vistas/superadmin/dashboard.jsp").forward(req, resp);
        }
    }
}
