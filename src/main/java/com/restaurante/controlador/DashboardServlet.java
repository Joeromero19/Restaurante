package com.restaurante.controlador;

import com.restaurante.util.SesionUtil;
import com.restaurante.modelo.dao.FacturaDAO;
import com.restaurante.modelo.dao.FinanzasDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * DashboardServlet.java
 * Enrutador central. Redirige al dashboard según el rol.
 * CORRECCIÓN: añadido ROL_CAJERO (6). Carga las últimas facturas para el cajero.
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SesionUtil.verificarSesion(request, response)) return;

        int rol = SesionUtil.getRol(request);
        String vista;

        switch (rol) {
            case SesionUtil.ROL_SUPERADMIN:
                vista = "/WEB-INF/vistas/superadmin/dashboard.jsp";
                break;
            case SesionUtil.ROL_ADMIN_GENERAL: {
                int idRestAG = SesionUtil.getRestauranteId(request);
                FinanzasDAO finanzasAG = new FinanzasDAO();
                FacturaDAO facturaAG   = new FacturaDAO();
                request.setAttribute("resumen",   finanzasAG.resumenRestaurante(idRestAG));
                request.setAttribute("facturas",  facturaAG.listarPorRestaurante(idRestAG));
                vista = "/WEB-INF/vistas/admingen/dashboard.jsp";
                break;
            }
            case SesionUtil.ROL_ADMIN_PUNTO:
                vista = "/WEB-INF/vistas/adminpunto/dashboard.jsp";
                break;
            case SesionUtil.ROL_MESERO: {
                int idRest = SesionUtil.getRestauranteId(request);
                com.restaurante.modelo.dao.PedidoDAO daoPedM = new com.restaurante.modelo.dao.PedidoDAO();
                request.setAttribute("pedidos", daoPedM.listarListosPorRestaurante(idRest));
                vista = "/WEB-INF/vistas/mesero/dashboard.jsp";
                break;
            }
            case SesionUtil.ROL_COCINERO:
                vista = "/WEB-INF/vistas/cocinero/dashboard.jsp";
                break;
            case SesionUtil.ROL_CAJERO: {
                // Redirigir al servlet del cajero que carga todos los datos necesarios
                response.sendRedirect(request.getContextPath() + "/cajero");
                return;
            }
            case SesionUtil.ROL_INVERSIONISTA:
                int idRestInv = SesionUtil.getRestauranteId(request);
                FinanzasDAO finanzasDAO = new FinanzasDAO();
                request.setAttribute("resumen", finanzasDAO.resumenRestaurante(idRestInv));
                request.setAttribute("gastos",  finanzasDAO.gastosDetallados(idRestInv));
                vista = "/WEB-INF/vistas/inversionista/dashboard.jsp";
                break;
            case SesionUtil.ROL_CLIENTE:
                vista = "/WEB-INF/vistas/cliente/dashboard.jsp";
                break;
            default:
                SesionUtil.cerrarSesion(request);
                response.sendRedirect(request.getContextPath() + "/login?msg=rol_invalido");
                return;
        }

        request.getRequestDispatcher(vista).forward(request, response);
    }
}
