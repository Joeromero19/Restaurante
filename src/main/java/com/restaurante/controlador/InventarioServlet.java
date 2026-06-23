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

@WebServlet("/inventario")
public class InventarioServlet extends HttpServlet {
    // GET  ?accion=listar|vencer|stockBajo|disponibilidad
    // POST ?accion=registrar

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarRol(req, resp,
                SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_SUPERADMIN)) return;

        String accion = req.getParameter("accion");
        com.restaurante.modelo.dao.InventarioDAO dao = new com.restaurante.modelo.dao.InventarioDAO();
        int idRest = SesionUtil.getRestauranteId(req);

        switch (accion == null ? "listar" : accion) {
            case "vencer":
                req.setAttribute("inventario", dao.proximosAVencer(5));
                req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/inventarioPorVencer.jsp").forward(req, resp);
                break;
            case "stockBajo":
                double umbral = 4.0;
                try { umbral = Double.parseDouble(req.getParameter("umbral")); } catch (Exception e) {}
                req.setAttribute("inventario", dao.stockBajo(umbral));
                req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/inventarioStockBajo.jsp").forward(req, resp);
                break;
            case "disponibilidad":
                req.setAttribute("platos", dao.disponibilidadPlatos());
                req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/disponibilidadPlatos.jsp").forward(req, resp);
                break;
            default:
                req.setAttribute("inventario", dao.listar(idRest));
                // Cargar productos y proveedores para el modal de "Registrar producto"
                req.setAttribute("productos", new com.restaurante.modelo.dao.ProductoDAO().listarActivos());
                req.setAttribute("proveedores", dao.listarProveedores());
                req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/inventario.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_PUNTO)) return;

        String accion = req.getParameter("accion");
        com.restaurante.modelo.dao.InventarioDAO dao = new com.restaurante.modelo.dao.InventarioDAO();

        if ("eliminar".equals(accion)) {
            int idInventario = Integer.parseInt(req.getParameter("idInventario"));
            boolean ok = dao.eliminarItem(idInventario);
            resp.sendRedirect(req.getContextPath() + "/inventario?accion=vencer&msg=" + (ok ? "eliminado" : "errorElim"));
        } else {
            int    idProducto    = Integer.parseInt(req.getParameter("idProducto"));
            int    idProveedor   = Integer.parseInt(req.getParameter("idProveedor"));
            double cantidad      = Double.parseDouble(req.getParameter("cantidad"));
            java.sql.Date fVenc  = java.sql.Date.valueOf(req.getParameter("fechaVencimiento"));
            boolean ok = dao.registrar(idProducto, idProveedor, cantidad, fVenc);
            resp.sendRedirect(req.getContextPath() + "/inventario?accion=listar&msg=" + (ok ? "registrado" : "error"));
        }
    }
}
