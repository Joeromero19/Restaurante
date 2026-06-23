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

@WebServlet("/empleados")
public class EmpleadoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_SUPERADMIN)) return;

        String accion = req.getParameter("accion");
        com.restaurante.modelo.dao.EmpleadoDAO dao = new com.restaurante.modelo.dao.EmpleadoDAO();
        int idRest = SesionUtil.getRestauranteId(req);

        if ("todos".equals(accion)) {
            req.setAttribute("empleados", dao.listarTodos());
            req.setAttribute("pageTitle", "Todos los Empleados");
            req.getRequestDispatcher("/WEB-INF/vistas/superadmin/empleados.jsp").forward(req, resp);
        } else if ("novedades".equals(accion)) {
            int idEmp = Integer.parseInt(req.getParameter("id"));
            req.setAttribute("novedades", dao.novedades(idEmp));
            req.setAttribute("pageTitle", "Novedades");
            req.getRequestDispatcher("/WEB-INF/vistas/admingen/novedades.jsp").forward(req, resp);
        } else if ("contratos".equals(accion)) {
            int idEmp = Integer.parseInt(req.getParameter("id"));
            req.setAttribute("contratos", dao.contratos(idEmp));
            req.setAttribute("pageTitle", "Contratos");
            req.getRequestDispatcher("/WEB-INF/vistas/admingen/contratos.jsp").forward(req, resp);
        } else if ("memorandos".equals(accion)) {
            req.setAttribute("memorandos", dao.conMemorandos(idRest));
            req.setAttribute("pageTitle", "Empleados con Memorandos");
            req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/memorandos.jsp").forward(req, resp);
        } else {
            req.setAttribute("empleados", dao.listarPorRestaurante(idRest));
            req.setAttribute("pageTitle", "Empleados");
            req.getRequestDispatcher("/WEB-INF/vistas/admingen/empleados.jsp").forward(req, resp);
        }
    }
}
