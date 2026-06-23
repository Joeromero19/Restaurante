package com.restaurante.controlador;

import com.restaurante.util.SesionUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * LogoutServlet.java
 * Invalida la sesión actual y redirige al login.
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        SesionUtil.cerrarSesion(request);
        response.sendRedirect(request.getContextPath() + "/login?msg=sesion_cerrada");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
