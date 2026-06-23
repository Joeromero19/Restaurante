package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

/**
 * UsuarioDAO.java
 * DAO para autenticación de usuarios (login) y validación de rol.
 * Consulta tanto empleados como clientes según el correo ingresado.
 *
 * Patrón: DAO (Data Access Object) + JDBC
 */
public class UsuarioDAO {

    private Connection conn;

    public UsuarioDAO() {
        this.conn = ConexionDB.getInstancia().getConexion();
    }

    /**
     * Autentica un usuario por correo y contraseña.
     * La contraseña se compara directamente (en producción usar bcrypt).
     *
     * Retorna un Map con:
     *   - "idUsuario"      → int (id_empleado o id_cliente)
     *   - "idPersona"      → long
     *   - "nombre"         → String
     *   - "apellido"       → String
     *   - "rol"            → int (id_tipo_usuario)
     *   - "idRestaurante"  → int (-1 si es cliente sin sede asignada)
     *   - "tipoSesion"     → "empleado" | "cliente"
     *
     * Retorna null si no se encontró el usuario o la contraseña no coincide.
     */
    public Map<String, Object> autenticar(String correo, String password) {
        // Primero buscar como EMPLEADO
        String sqlEmpleado =
            "SELECT e.id_empleado, e.id_restaurante, e.id_tipo_usuario, " +
            "       p.id_persona, p.nombre, p.apellido, p.correo " +
            "FROM   EMPLEADO e " +
            "JOIN   PERSONA  p ON e.id_persona = p.id_persona " +
            "WHERE  p.correo = ? " +
            "AND    e.estado = 'ACTIVO'";

        try (PreparedStatement ps = conn.prepareStatement(sqlEmpleado)) {
            ps.setString(1, correo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long idPersona = rs.getLong("id_persona");
                if (String.valueOf(idPersona).equals(password)) {
                    Map<String, Object> resultado = new HashMap<>();
                    resultado.put("idUsuario",     rs.getInt("id_empleado"));
                    resultado.put("idPersona",     idPersona);
                    resultado.put("nombre",        rs.getString("nombre"));
                    resultado.put("apellido",      rs.getString("apellido"));
                    resultado.put("rol",           rs.getInt("id_tipo_usuario"));
                    resultado.put("idRestaurante", rs.getInt("id_restaurante"));
                    resultado.put("tipoSesion",    "empleado");
                    return resultado;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error autenticando empleado: " + e.getMessage());
        }

        // Luego buscar como CLIENTE (incluye id_restaurante de su sede)
        String sqlCliente =
            "SELECT c.id_cliente, c.id_restaurante, p.id_persona, p.nombre, p.apellido, p.correo " +
            "FROM   CLIENTE c " +
            "JOIN   PERSONA  p ON c.id_persona = p.id_persona " +
            "WHERE  p.correo = ? " +
            "AND    c.activo = TRUE";

        try (PreparedStatement ps = conn.prepareStatement(sqlCliente)) {
            ps.setString(1, correo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long idPersona = rs.getLong("id_persona");
                if (String.valueOf(idPersona).equals(password)) {
                    Map<String, Object> resultado = new HashMap<>();
                    resultado.put("idUsuario",     rs.getInt("id_cliente"));
                    resultado.put("idPersona",     idPersona);
                    resultado.put("nombre",        rs.getString("nombre"));
                    resultado.put("apellido",      rs.getString("apellido"));
                    resultado.put("rol",           8);   // ROL_CLIENTE
                    // Usar la sede del cliente (puede ser null → -1)
                    int idRestaurante = rs.getInt("id_restaurante");
                    resultado.put("idRestaurante", rs.wasNull() ? -1 : idRestaurante);
                    resultado.put("tipoSesion",    "cliente");
                    return resultado;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error autenticando cliente: " + e.getMessage());
        }

        return null; // Autenticación fallida
    }

    /**
     * Verifica si un correo ya existe en la tabla PERSONA.
     * Útil para el registro de nuevos clientes.
     */
    public boolean correoExiste(String correo) {
        String sql = "SELECT COUNT(*) FROM PERSONA WHERE correo = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, correo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error verificando correo: " + e.getMessage());
        }
        return false;
    }
}
