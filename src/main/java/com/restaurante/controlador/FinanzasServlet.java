package com.restaurante.controlador;

import com.restaurante.util.SesionUtil;
import com.restaurante.modelo.dao.FinanzasDAO;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;

/**
 * FinanzasServlet.java
 * CORRECCIÓN: inversionista ahora puede ver propinas por mes.
 * La accion "propinas" acepta ROL_ADMIN_GENERAL y ROL_INVERSIONISTA.
 */
@WebServlet("/finanzas")
public class FinanzasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!SesionUtil.verificarRol(req, resp,
                SesionUtil.ROL_ADMIN_GENERAL, SesionUtil.ROL_INVERSIONISTA,
                SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_ADMIN_PUNTO,
                SesionUtil.ROL_CAJERO)) return;

        String accion = req.getParameter("accion");
        int idRest    = SesionUtil.getRestauranteId(req);
        int rol       = SesionUtil.getRol(req);
        FinanzasDAO dao = new FinanzasDAO();

        boolean esAdminPunto     = (rol == SesionUtil.ROL_ADMIN_PUNTO);
        boolean esInversionista  = (rol == SesionUtil.ROL_INVERSIONISTA);
        boolean esCajero         = (rol == SesionUtil.ROL_CAJERO);

        switch (accion == null ? "resumen" : accion) {

            case "gastos":
                // AdminPunto y cajero no pueden ver gastos; inversionista sí
                if (esAdminPunto || esCajero) { resp.sendError(403); return; }
                req.setAttribute("gastos", dao.gastosDetallados(idRest));
                req.setAttribute("pageTitle", "Gastos");
                req.getRequestDispatcher("/WEB-INF/vistas/admingen/gastos.jsp").forward(req, resp);
                break;

            case "propinas":
                // Permitido a admin general, inversionista y superadmin
                if (esAdminPunto || esCajero) { resp.sendError(403); return; }
                req.setAttribute("propinas", dao.propinasPorMes(idRest));
                req.setAttribute("pageTitle", "Propinas por Mes");
                req.getRequestDispatcher("/WEB-INF/vistas/admingen/propinas.jsp").forward(req, resp);
                break;

            case "metodoPago":
                java.sql.Date hoy = new java.sql.Date(System.currentTimeMillis());
                req.setAttribute("metodoPago", dao.ingresosPorMetodoPago(idRest, hoy));
                req.setAttribute("pageTitle", "Ingresos por Método de Pago");
                req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/metodoPago.jsp").forward(req, resp);
                break;

            case "global":
                if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_SUPERADMIN)) return;
                req.setAttribute("resumenGlobal", dao.resumenGlobal());
                req.setAttribute("pageTitle", "Finanzas Globales");
                req.getRequestDispatcher("/WEB-INF/vistas/superadmin/finanzasGlobal.jsp").forward(req, resp);
                break;

            default:
                if (esAdminPunto || esCajero) { resp.sendError(403); return; }
                req.setAttribute("resumen", dao.resumenRestaurante(idRest));
                req.setAttribute("pageTitle", "Resumen Financiero");
                String vistaResumen = esInversionista
                    ? "/WEB-INF/vistas/inversionista/dashboard.jsp"
                    : "/WEB-INF/vistas/admingen/finanzas.jsp";
                req.getRequestDispatcher(vistaResumen).forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_ADMIN_GENERAL)) return;

        String descripcion  = req.getParameter("descripcion");
        BigDecimal valor    = new BigDecimal(req.getParameter("valor"));
        java.sql.Date fecha = java.sql.Date.valueOf(req.getParameter("fecha"));
        int idRest          = SesionUtil.getRestauranteId(req);

        FinanzasDAO dao = new FinanzasDAO();
        boolean ok = dao.registrarGasto(descripcion, valor, fecha, idRest);
        resp.sendRedirect(req.getContextPath() + "/finanzas?accion=gastos&msg=" + (ok ? "registrado" : "error"));
    }
}
