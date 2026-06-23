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

@WebServlet("/productos")
public class ProductoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarSesion(req, resp)) return;
        String accion = req.getParameter("accion");
        com.restaurante.modelo.dao.ProductoDAO dao = new com.restaurante.modelo.dao.ProductoDAO();

        if ("menu".equals(accion)) {
            // Vista de menú para clientes (solo lectura)
            req.setAttribute("productos", dao.listarActivos());
            req.setAttribute("pageTitle", "Nuestro Menú");
            req.getRequestDispatcher("/WEB-INF/vistas/cliente/menu.jsp").forward(req, resp);

        } else if ("recetas".equals(accion)) {
            // Para cocinero: listar todos los productos con sus recetas
            List<Map<String,Object>> recetas = new ArrayList<>();
            String sql = "SELECT pr.id_producto, pr.nombre AS plato, pr.precio, tp.nombre AS tipo, " +
                         "i.nombre AS ingrediente, r.cantidad, r.unidad " +
                         "FROM PRODUCTO pr " +
                         "JOIN TIPO_PRODUCTO tp ON pr.id_tipo_producto=tp.id_tipo_producto " +
                         "JOIN RECETA r ON pr.id_producto=r.id_producto " +
                         "JOIN INGREDIENTE i ON r.id_ingrediente=i.id_ingrediente " +
                         "WHERE pr.activo=TRUE ORDER BY pr.nombre, i.nombre";
            Connection conn = ConexionDB.getInstancia().getConexion();
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("idProducto",  rs.getInt("id_producto"));
                    row.put("plato",       rs.getString("plato"));
                    row.put("precio",      rs.getBigDecimal("precio"));
                    row.put("tipo",        rs.getString("tipo"));
                    row.put("ingrediente", rs.getString("ingrediente"));
                    row.put("cantidad",    rs.getBigDecimal("cantidad"));
                    row.put("unidad",      rs.getString("unidad"));
                    recetas.add(row);
                }
            } catch (SQLException e) { System.err.println(e.getMessage()); }
            req.setAttribute("recetas", recetas);
            req.getRequestDispatcher("/WEB-INF/vistas/cocinero/recetas.jsp").forward(req, resp);

        } else {
            // Lista general de productos
            req.setAttribute("productos", dao.listarActivos());
            req.setAttribute("pageTitle", "Productos");
            req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/productos.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_PUNTO)) return;
        com.restaurante.modelo.dao.ProductoDAO dao = new com.restaurante.modelo.dao.ProductoDAO();
        String nombre  = req.getParameter("nombre");
        java.math.BigDecimal precio = new java.math.BigDecimal(req.getParameter("precio"));
        int idTipo = Integer.parseInt(req.getParameter("idTipo"));
        String idProvStr = req.getParameter("idProveedor");
        Integer idProv = (idProvStr != null && !idProvStr.isEmpty()) ? Integer.parseInt(idProvStr) : null;
        boolean ok = dao.registrar(nombre, precio, idTipo, idProv);
        resp.sendRedirect(req.getContextPath() + "/productos?msg=" + (ok ? "registrado" : "error"));
    }
}
