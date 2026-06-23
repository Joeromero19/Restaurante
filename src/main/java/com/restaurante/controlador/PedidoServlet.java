package com.restaurante.controlador;

import com.restaurante.modelo.dao.PedidoDAO;
import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

/**
 * PedidoServlet.java
 * Maneja pedidos:
 *  GET  ?accion=listar        → lista pedidos (mesero: los suyos; cocinero/admin: todos activos)
 *  GET  ?accion=detalle&id=   → detalle de un pedido
 *  GET  ?accion=alergias      → pedidos con alergias (cocinero)
 *  GET  ?accion=nuevo         → formulario nuevo pedido (mesero/cliente)
 *  GET  ?accion=misPedidos    → historial de pedidos del cliente
 *  POST ?accion=crear         → crear nuevo pedido (mesero o cliente)
 *  POST ?accion=cambiarEstado → cambiar a "en_preparacion" o "listo" (cocinero / admin)
 *  POST ?accion=entregar      → marcar como "entregado" (mesero, solo si está "listo")
 */
@WebServlet("/pedidos")
public class PedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SesionUtil.verificarRol(req, resp,
                SesionUtil.ROL_CLIENTE,
                SesionUtil.ROL_MESERO, SesionUtil.ROL_COCINERO,
                SesionUtil.ROL_ADMIN_PUNTO, SesionUtil.ROL_ADMIN_GENERAL,
                SesionUtil.ROL_SUPERADMIN)) return;

        String accion = req.getParameter("accion");
        PedidoDAO dao = new PedidoDAO();
        int rol       = SesionUtil.getRol(req);
        int idUsuario = (int) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID);

        // ── Flujo exclusivo del CLIENTE ──────────────────────────────────
        if (rol == SesionUtil.ROL_CLIENTE) {
            if ("nuevo".equals(accion)) {
                req.setAttribute("productos",
                        new com.restaurante.modelo.dao.ProductoDAO().listarActivos());
                req.setAttribute("pageTitle", "Hacer Pedido");
                req.getRequestDispatcher("/WEB-INF/vistas/cliente/nuevoPedido.jsp").forward(req, resp);
            } else if ("misPedidos".equals(accion)) {
                req.setAttribute("pedidos", dao.listarPorCliente(idUsuario));
                req.setAttribute("pageTitle", "Mis Pedidos");
                req.getRequestDispatcher("/WEB-INF/vistas/cliente/misPedidos.jsp").forward(req, resp);
            } else if ("detalle".equals(accion)) {
                int idPedido = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("detalles", dao.obtenerDetalle(idPedido));
                req.setAttribute("idPedido", idPedido);
                req.getRequestDispatcher("/WEB-INF/vistas/shared/detallePedido.jsp").forward(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/cliente");
            }
            return;
        }

        // ── Flujo para roles internos ────────────────────────────────────
        if ("detalle".equals(accion)) {
            int idPedido = Integer.parseInt(req.getParameter("id"));
            req.setAttribute("detalles", dao.obtenerDetalle(idPedido));
            req.setAttribute("idPedido", idPedido);
            req.getRequestDispatcher("/WEB-INF/vistas/shared/detallePedido.jsp").forward(req, resp);

        } else if ("alergias".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_COCINERO, SesionUtil.ROL_ADMIN_PUNTO)) return;
            req.setAttribute("pedidosAlergias", dao.listarConAlergias());
            req.getRequestDispatcher("/WEB-INF/vistas/cocinero/alergias.jsp").forward(req, resp);

        } else {
            List<Map<String, Object>> pedidos;
            if (rol == SesionUtil.ROL_MESERO) {
                int idRest = SesionUtil.getRestauranteId(req);
                // Si idRest es -1 (no asignado), usar listarPorMesero con el id del empleado
                if (idRest <= 0) {
                    pedidos = dao.listarPorMesero(idUsuario, 0); // fallback: todos los del mesero
                } else {
                    pedidos = dao.listarListosPorRestaurante(idRest);
                }
            } else {
                pedidos = dao.listarPedidosActivos();
            }
            req.setAttribute("pedidos", pedidos);
            String vista;
            if (rol == SesionUtil.ROL_COCINERO) {
                vista = "/WEB-INF/vistas/cocinero/pedidos.jsp";
            } else if (rol == SesionUtil.ROL_ADMIN_PUNTO || rol == SesionUtil.ROL_ADMIN_GENERAL || rol == SesionUtil.ROL_SUPERADMIN) {
                vista = "/WEB-INF/vistas/adminpunto/pedidos.jsp";
            } else {
                vista = "/WEB-INF/vistas/mesero/pedidos.jsp";
            }
            req.getRequestDispatcher(vista).forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        if (!SesionUtil.verificarRol(req, resp,
                SesionUtil.ROL_CLIENTE,
                SesionUtil.ROL_MESERO,
                SesionUtil.ROL_COCINERO, SesionUtil.ROL_ADMIN_PUNTO)) return;

        String accion = req.getParameter("accion");
        PedidoDAO dao = new PedidoDAO();
        int rol       = SesionUtil.getRol(req);
        int idUsuario = (int) req.getSession().getAttribute(SesionUtil.ATTR_USUARIO_ID);

        if ("crear".equals(accion)) {
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_CLIENTE, SesionUtil.ROL_MESERO)) return;

            int    idMesa    = Integer.parseInt(req.getParameter("idMesa"));
            String obs       = req.getParameter("observaciones");
            boolean alergias = "true".equals(req.getParameter("tieneAlergias"));

            String[] ids        = req.getParameterValues("idProducto");
            String[] cantidades = req.getParameterValues("cantidad");
            String[] precios    = req.getParameterValues("precioUnitario");
            String[] descs      = req.getParameterValues("descripcionItem");

            List<Map<String, Object>> productos = new ArrayList<>();
            if (ids != null) {
                for (int i = 0; i < ids.length; i++) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("idProducto",     Integer.parseInt(ids[i]));
                    p.put("cantidad",       Integer.parseInt(cantidades[i]));
                    p.put("precioUnitario", new BigDecimal(precios[i]));
                    p.put("descripcion",    descs != null ? descs[i] : null);
                    productos.add(p);
                }
            }

            Integer idEmpleado = (rol == SesionUtil.ROL_CLIENTE) ? null : idUsuario;

            int idPedido = dao.crearPedido(idEmpleado, idMesa, obs, alergias, productos);
            if (idPedido > 0) {
                if (rol == SesionUtil.ROL_CLIENTE) {
                    resp.sendRedirect(req.getContextPath() + "/pedidos?accion=misPedidos&msg=creado");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/pedidos?accion=listar&msg=creado");
                }
            } else {
                req.setAttribute("error", "No se pudo crear el pedido. Verifique el stock.");
                req.setAttribute("productos", new com.restaurante.modelo.dao.ProductoDAO().listarActivos());
                String vista = (rol == SesionUtil.ROL_CLIENTE)
                        ? "/WEB-INF/vistas/cliente/nuevoPedido.jsp"
                        : "/WEB-INF/vistas/mesero/nuevoPedido.jsp";
                req.getRequestDispatcher(vista).forward(req, resp);
            }

        } else if ("cambiarEstado".equals(accion)) {
            // Solo cocinero y admin pueden cambiar estado a en_preparacion / listo
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_COCINERO, SesionUtil.ROL_ADMIN_PUNTO)) return;

            int    idPedido = Integer.parseInt(req.getParameter("idPedido"));
            String estado   = req.getParameter("estado");

            // Solo permitir estados válidos para cocinero: en_preparacion, listo
            if (!"en_preparacion".equals(estado) && !"listo".equals(estado)) {
                resp.sendRedirect(req.getContextPath() + "/pedidos?accion=listar&msg=error");
                return;
            }
            boolean ok = dao.cambiarEstado(idPedido, estado);
            resp.sendRedirect(req.getContextPath() + "/pedidos?accion=listar&msg=" + (ok ? "actualizado" : "error"));

        } else if ("entregar".equals(accion)) {
            // Solo el mesero puede marcar como entregado, y solo si está en estado "listo"
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_MESERO)) return;

            int idPedido = Integer.parseInt(req.getParameter("idPedido"));
            boolean ok = dao.cambiarEstadoSiListo(idPedido, "entregado");
            resp.sendRedirect(req.getContextPath() + "/pedidos?accion=listar&msg=" + (ok ? "actualizado" : "error"));

        } else if ("cancelar".equals(accion)) {
            // Solo el mesero puede cancelar un pedido en estado "listo"
            if (!SesionUtil.verificarRol(req, resp, SesionUtil.ROL_MESERO)) return;

            int idPedido = Integer.parseInt(req.getParameter("idPedido"));
            boolean ok = dao.cancelarSiListo(idPedido);
            resp.sendRedirect(req.getContextPath() + "/pedidos?accion=listar&msg=" + (ok ? "cancelado" : "error"));
        }
    }
}
