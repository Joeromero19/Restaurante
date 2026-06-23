package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EmpleadoDAO {
    private final Connection conn;
    public EmpleadoDAO() { this.conn = ConexionDB.getInstancia().getConexion(); }

    /** Listar empleados de un restaurante con datos completos */
    public List<Map<String, Object>> listarPorRestaurante(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT e.id_empleado, e.cargo, e.salario, e.fecha_ingreso, e.estado, " +
            "       p.nombre, p.apellido, p.correo, p.telefono, " +
            "       tu.nombre AS rol " +
            "FROM   EMPLEADO     e " +
            "JOIN   PERSONA      p  ON e.id_persona      = p.id_persona " +
            "JOIN   TIPO_USUARIO tu ON e.id_tipo_usuario = tu.id_tipo_usuario " +
            "WHERE  e.id_restaurante = ? " +
            "ORDER  BY tu.nombre, p.apellido";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idEmpleado",   rs.getInt("id_empleado"));
                row.put("nombre",       rs.getString("nombre") + " " + rs.getString("apellido"));
                row.put("correo",       rs.getString("correo"));
                row.put("telefono",     rs.getString("telefono"));
                row.put("cargo",        rs.getString("cargo"));
                row.put("salario",      rs.getBigDecimal("salario"));
                row.put("fechaIngreso", rs.getDate("fecha_ingreso"));
                row.put("estado",       rs.getString("estado"));
                row.put("rol",          rs.getString("rol"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[EmpleadoDAO] Error listando: " + e.getMessage());
        }
        return lista;
    }

    /** Listar empleados de TODOS los restaurantes (superadmin) */
    public List<Map<String, Object>> listarTodos() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT e.id_empleado, e.cargo, e.salario, e.estado, " +
            "       p.nombre, p.apellido, tu.nombre AS rol, r.nombre AS restaurante " +
            "FROM   EMPLEADO     e " +
            "JOIN   PERSONA      p  ON e.id_persona      = p.id_persona " +
            "JOIN   TIPO_USUARIO tu ON e.id_tipo_usuario = tu.id_tipo_usuario " +
            "JOIN   RESTAURANTE  r  ON e.id_restaurante  = r.id_restaurante " +
            "ORDER  BY r.nombre, tu.nombre";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idEmpleado",  rs.getInt("id_empleado"));
                row.put("nombre",      rs.getString("nombre") + " " + rs.getString("apellido"));
                row.put("cargo",       rs.getString("cargo"));
                row.put("salario",     rs.getBigDecimal("salario"));
                row.put("estado",      rs.getString("estado"));
                row.put("rol",         rs.getString("rol"));
                row.put("restaurante", rs.getString("restaurante"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[EmpleadoDAO] Error listando todos: " + e.getMessage());
        }
        return lista;
    }

    /** Novedades (memorandos / reconocimientos) de un empleado */
    public List<Map<String, Object>> novedades(int idEmpleado) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT id_novedad, descripcion, fecha, tipo " +
            "FROM   NOVEDAD_EMPLEADO WHERE id_empleado = ? ORDER BY fecha DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idEmpleado);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idNovedad",   rs.getInt("id_novedad"));
                row.put("descripcion", rs.getString("descripcion"));
                row.put("fecha",       rs.getDate("fecha"));
                row.put("tipo",        rs.getString("tipo"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[EmpleadoDAO] Error novedades: " + e.getMessage());
        }
        return lista;
    }

    /** Empleados con memorandos (admin de punto solo ve si tiene o no) */
    public List<Map<String, Object>> conMemorandos(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT DISTINCT e.id_empleado, p.nombre, p.apellido, n.tipo, n.descripcion " +
            "FROM   EMPLEADO        e " +
            "JOIN   PERSONA         p  ON e.id_persona  = p.id_persona " +
            "JOIN   NOVEDAD_EMPLEADO n  ON e.id_empleado = n.id_empleado " +
            "WHERE  n.tipo = 'Memorando' AND e.id_restaurante = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idEmpleado",  rs.getInt("id_empleado"));
                row.put("nombre",      rs.getString("nombre") + " " + rs.getString("apellido"));
                row.put("tipo",        rs.getString("tipo"));
                row.put("descripcion", rs.getString("descripcion"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[EmpleadoDAO] Error memorandos: " + e.getMessage());
        }
        return lista;
    }

    /** Contratos de un empleado */
    public List<Map<String, Object>> contratos(int idEmpleado) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT id_contrato, fecha_inicio, fecha_fin, tipo, salario " +
            "FROM CONTRATO WHERE id_empleado = ? ORDER BY fecha_inicio DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idEmpleado);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idContrato",  rs.getInt("id_contrato"));
                row.put("fechaInicio", rs.getDate("fecha_inicio"));
                row.put("fechaFin",    rs.getDate("fecha_fin"));
                row.put("tipo",        rs.getString("tipo"));
                row.put("salario",     rs.getBigDecimal("salario"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[EmpleadoDAO] Error contratos: " + e.getMessage());
        }
        return lista;
    }

    /** Registrar nuevo empleado (inserta en PERSONA y luego en EMPLEADO) */
    public boolean registrar(long idPersona, String nombre, String apellido,
                              String telefono, String correo, java.util.Date fechaNac, String direccion,
                              int idTipoUsuario, int idRestaurante, BigDecimal salario,
                              String cargo, java.util.Date fechaIngreso) {
        try {
            conn.setAutoCommit(false);

            // 1. Insertar PERSONA
            String sqlP = "INSERT IGNORE INTO PERSONA (id_persona, nombre, apellido, telefono, correo, fecha_nacimiento, direccion, tipo_persona) VALUES (?,?,?,?,?,?,?,'empleado')";
            try (PreparedStatement ps = conn.prepareStatement(sqlP)) {
                ps.setLong(1, idPersona);
                ps.setString(2, nombre);
                ps.setString(3, apellido);
                ps.setString(4, telefono);
                ps.setString(5, correo);
                ps.setDate(6, new java.sql.Date(fechaNac.getTime()));
                ps.setString(7, direccion);
                ps.executeUpdate();
            }

            // 2. Insertar EMPLEADO
            String sqlE = "INSERT INTO EMPLEADO (id_persona, id_tipo_usuario, id_restaurante, salario, cargo, fecha_ingreso) VALUES (?,?,?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlE)) {
                ps.setLong(1, idPersona);
                ps.setInt(2, idTipoUsuario);
                ps.setInt(3, idRestaurante);
                ps.setBigDecimal(4, salario);
                ps.setString(5, cargo);
                ps.setDate(6, new java.sql.Date(fechaIngreso.getTime()));
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            System.err.println("[EmpleadoDAO] Error registrando empleado: " + e.getMessage());
            return false;
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException e) {}
        }
    }
}
