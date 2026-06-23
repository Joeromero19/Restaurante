package com.restaurante.controlador;

import com.restaurante.util.SesionUtil;
import com.restaurante.modelo.dao.FacturaDAO;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;

/**
 * FacturaServlet.java
 * CORRECCIONES:
 *   - Mesero ve solo sus propias facturas (listarPorMesero).
 *   - Cajero (rol 6) tiene acceso a listado y generación de facturas.
 */
@WebServlet("/facturas")
public class FacturaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!SesionUtil.verificarRol(req, resp,
                SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL,
                SesionUtil.ROL_SUPERADMIN, SesionUtil.ROL_MESERO,
                SesionUtil.ROL_CAJERO)) return;

        String accion  = req.getParameter("accion");
        FacturaDAO dao = new FacturaDAO();
        int rol        = SesionUtil.getRol(req);
        int idRest     = SesionUtil.getRestauranteId(req);

        if ("nueva".equals(accion)) {
            // Solo el cajero puede generar facturas directamente
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CAJERO)) return;
            req.setAttribute("pageTitle", "Generar Factura");
            req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/nuevaFactura.jsp").forward(req, resp);

        } else if ("misFact".equals(accion) || rol == SesionUtil.ROL_MESERO) {
            // CORRECCIÓN: mesero ve solo sus facturas
            int idEmpleado = (int) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID);
            req.setAttribute("facturas", dao.listarPorMesero(idEmpleado));
            req.setAttribute("pageTitle", "Mis Facturas");
            req.getRequestDispatcher("/WEB-INF/vistas/mesero/misFacturas.jsp").forward(req, resp);

        } else {
            req.setAttribute("facturas", dao.listarPorRestaurante(idRest));
            req.setAttribute("pageTitle", "Facturas");
            req.getRequestDispatcher("/WEB-INF/vistas/adminpunto/facturas.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        // Solo el cajero puede generar facturas
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CAJERO)) return;

        FacturaDAO dao      = new FacturaDAO();
        int idPedido        = Integer.parseInt(req.getParameter("idPedido"));
        int idCliente       = Integer.parseInt(req.getParameter("idCliente"));
        BigDecimal subtotal = new BigDecimal(req.getParameter("subtotal"));
        BigDecimal iva      = new BigDecimal(req.getParameter("iva"));
        BigDecimal propina  = new BigDecimal(req.getParameter("propina"));
        int idTipoPago      = Integer.parseInt(req.getParameter("idTipoPago"));

        int id = dao.generarFactura(idPedido, idCliente, subtotal, iva, idTipoPago, propina);
        resp.sendRedirect(req.getContextPath() + "/facturas?msg=" + (id > 0 ? "generada" : "error"));
    }
}
