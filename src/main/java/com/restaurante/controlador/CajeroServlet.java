package com.restaurante.controlador;

import com.restaurante.modelo.dao.FacturaDAO;
import com.restaurante.modelo.dao.PedidoDAO;
import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/**
 * CajeroServlet.java
 * Maneja las vistas y acciones del cajero:
 *   GET  ?accion=pedidosListos   → muestra pedidos en estado "entregado" sin factura
 *   GET  ?accion=generarFactura  → formulario para facturar un pedido específico
 *   GET  ?accion=historial       → historial de facturas generadas por este cajero
 *   POST ?accion=generar         → procesa y genera la factura
 */
@WebServlet("/cajero")
public class CajeroServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CAJERO)) return;

        String accion = req.getParameter("accion");
        int idRest    = SesionUtil.getRestauranteId(req);
        int idCajero  = (int) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID);
        FacturaDAO facturaDAO = new FacturaDAO();
        PedidoDAO  pedidoDAO  = new PedidoDAO();

        if ("pedidosListos".equals(accion)) {
            // Pedidos entregados sin factura aún
            req.setAttribute("pedidos", pedidoDAO.listarEntregadosSinFactura(idRest));
            req.setAttribute("pageTitle", "Pedidos para Cobrar");
            req.getRequestDispatcher("/WEB-INF/vistas/cajero/pedidosListos.jsp").forward(req, resp);

        } else if ("generarFactura".equals(accion)) {
            // Formulario de factura para un pedido específico
            String idPedidoStr = req.getParameter("idPedido");
            if (idPedidoStr == null) {
                resp.sendRedirect(req.getContextPath() + "/cajero?accion=pedidosListos");
                return;
            }
            int idPedido = Integer.parseInt(idPedidoStr);
            req.setAttribute("idPedido", idPedido);
            req.setAttribute("detalles", pedidoDAO.obtenerDetalle(idPedido));
            req.setAttribute("pageTitle", "Generar Factura");
            req.getRequestDispatcher("/WEB-INF/vistas/cajero/generarFactura.jsp").forward(req, resp);

        } else if ("historial".equals(accion)) {
            req.setAttribute("facturas", facturaDAO.listarPorCajero(idCajero, idRest));
            req.setAttribute("pageTitle", "Historial de Facturas");
            req.getRequestDispatcher("/WEB-INF/vistas/cajero/historialFacturas.jsp").forward(req, resp);

        } else {
            // Dashboard: pedidos listos + últimas facturas del cajero
            req.setAttribute("pedidosListos", pedidoDAO.listarEntregadosSinFactura(idRest));
            req.setAttribute("facturas", facturaDAO.listarPorCajero(idCajero, idRest));
            req.getRequestDispatcher("/WEB-INF/vistas/cajero/dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CAJERO)) return;

        String accion = req.getParameter("accion");
        if ("generar".equals(accion)) {
            FacturaDAO dao  = new FacturaDAO();
            int idPedido    = Integer.parseInt(req.getParameter("idPedido"));
            int idCliente   = Integer.parseInt(req.getParameter("idCliente"));
            BigDecimal subtotal = new BigDecimal(req.getParameter("subtotal"));
            BigDecimal iva      = new BigDecimal(req.getParameter("iva"));
            BigDecimal propina  = new BigDecimal(req.getParameter("propina").isEmpty() ? "0" : req.getParameter("propina"));
            int idTipoPago  = Integer.parseInt(req.getParameter("idTipoPago"));

            int id = dao.generarFactura(idPedido, idCliente, subtotal, iva, idTipoPago, propina);
            resp.sendRedirect(req.getContextPath() + "/cajero?msg=" + (id > 0 ? "generada" : "error"));
        }
    }
}
