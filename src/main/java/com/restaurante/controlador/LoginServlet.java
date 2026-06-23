package com.restaurante.controlador;

import com.restaurante.modelo.dao.UsuarioDAO;
import com.restaurante.util.SesionUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Map;

/**
 * LoginServlet.java
 * Controlador para autenticación de usuarios.
 * GET  → muestra el formulario de login
 * POST → procesa credenciales y redirige según el rol
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Si ya tiene sesión activa, redirigir al dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(SesionUtil.ATTR_USUARIO_ID) != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        // Mostrar página de login
        request.getRequestDispatcher("/WEB-INF/vistas/shared/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String correo   = request.getParameter("correo");
        String password = request.getParameter("password");

        // Validación de campos
        if (correo == null || correo.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Por favor ingrese correo y contraseña.");
            request.getRequestDispatcher("/WEB-INF/vistas/shared/login.jsp").forward(request, response);
            return;
        }
        if (!correo.trim().matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]{2,}$")) {
            request.setAttribute("error", "El correo ingresado no tiene un formato válido.");
            request.getRequestDispatcher("/WEB-INF/vistas/shared/login.jsp").forward(request, response);
            return;
        }
        if (password.trim().length() < 6) {
            request.setAttribute("error", "La contraseña debe tener al menos 6 caracteres.");
            request.getRequestDispatcher("/WEB-INF/vistas/shared/login.jsp").forward(request, response);
            return;
        }

        // Autenticar contra la base de datos
        UsuarioDAO dao = new UsuarioDAO();
        Map<String, Object> usuario = dao.autenticar(correo.trim(), password.trim());

        if (usuario == null) {
            // Credenciales inválidas
            request.setAttribute("error", "Correo o contraseña incorrectos. Verifique sus datos.");
            request.getRequestDispatcher("/WEB-INF/vistas/shared/login.jsp").forward(request, response);
            return;
        }

        // Crear sesión y guardar datos del usuario
        HttpSession session = request.getSession(true);
        session.setAttribute(SesionUtil.ATTR_USUARIO_ID,      usuario.get("idUsuario"));
        session.setAttribute(SesionUtil.ATTR_USUARIO_ROL,     usuario.get("rol"));
        session.setAttribute(SesionUtil.ATTR_RESTAURANTE_ID,  usuario.get("idRestaurante"));
        session.setAttribute(SesionUtil.ATTR_USUARIO_NOMBRE,
            usuario.get("nombre") + " " + usuario.get("apellido"));

        // Si es cliente, asignar la siguiente mesa libre del restaurante
        if ((int) usuario.get("rol") == SesionUtil.ROL_CLIENTE) {
            int idRestaurante = (int) usuario.get("idRestaurante");
            com.restaurante.modelo.dao.PedidoDAO pedidoDAO = new com.restaurante.modelo.dao.PedidoDAO();
            int mesaAsignada = pedidoDAO.asignarMesaCliente(idRestaurante);
            session.setAttribute("mesaAsignada", mesaAsignada);
        }

        // Redirigir al dashboard central (que enrutará por rol)
        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}
