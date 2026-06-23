package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReservaDAO {
    private final Connection conn;
    public ReservaDAO() { this.conn = ConexionDB.getInstancia().getConexion(); }

    /** Listar todas las reservas de un restaurante */
    public List<Map<String, Object>> listar(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT rv.id_reserva, rv.fecha_reserva, rv.hora_reserva, " +
            "       rv.cantidad_personas, rv.estado, m.id_mesa, " +
            "       p.nombre AS cliente_nombre, p.apellido AS cliente_apellido " +
            "FROM   RESERVA  rv " +
            "JOIN   CLIENTE  c  ON rv.id_cliente = c.id_cliente " +
            "JOIN   PERSONA  p  ON c.id_persona  = p.id_persona " +
            "JOIN   MESA     m  ON rv.id_mesa    = m.id_mesa " +
            "WHERE  rv.id_restaurante = ? " +
            "ORDER  BY rv.fecha_reserva DESC, rv.hora_reserva DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idReserva",        rs.getInt("id_reserva"));
                row.put("fechaReserva",     rs.getDate("fecha_reserva"));
                row.put("horaReserva",      rs.getString("hora_reserva"));
                row.put("cantidadPersonas", rs.getInt("cantidad_personas"));
                row.put("estado",           rs.getString("estado"));
                row.put("idMesa",           rs.getInt("id_mesa"));
                row.put("cliente",          rs.getString("cliente_nombre") + " " + rs.getString("cliente_apellido"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[ReservaDAO] Error listando: " + e.getMessage());
        }
        return lista;
    }

    /** Crear nueva reserva */
    public boolean crear(java.sql.Date fecha, String hora, int personas,
                         int idCliente, int idMesa, int idRestaurante) {
        String sql =
            "INSERT INTO RESERVA (fecha_reserva, hora_reserva, cantidad_personas, estado, id_cliente, id_mesa, id_restaurante) " +
            "VALUES (?, ?, ?, 'pendiente', ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fecha);
            ps.setString(2, hora);
            ps.setInt(3, personas);
            ps.setInt(4, idCliente);
            ps.setInt(5, idMesa);
            ps.setInt(6, idRestaurante);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservaDAO] Error creando: " + e.getMessage());
            return false;
        }
    }

    /** Cancelar reserva — solo si faltan más de 2 horas */
    public boolean cancelar(int idReserva) {
        // Verificar tiempo restante
        String sqlCheck =
            "SELECT TIMESTAMPDIFF(MINUTE, NOW(), TIMESTAMP(fecha_reserva, hora_reserva)) AS minutos_restantes " +
            "FROM RESERVA WHERE id_reserva = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
            ps.setInt(1, idReserva);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int minutosRestantes = rs.getInt("minutos_restantes");
                if (minutosRestantes < 120) {
                    System.out.println("[ReservaDAO] Cancelación rechazada: menos de 2 horas para la reserva.");
                    return false;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReservaDAO] Error verificando tiempo: " + e.getMessage());
            return false;
        }

        String sql = "UPDATE RESERVA SET estado = 'cancelada' WHERE id_reserva = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idReserva);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservaDAO] Error cancelando: " + e.getMessage());
            return false;
        }
    }

    /** Modificar reserva */
    public boolean modificar(int idReserva, java.sql.Date fecha, String hora, int personas) {
        // Mismo check de 2 horas antes de modificar
        String sqlCheck =
            "SELECT TIMESTAMPDIFF(MINUTE, NOW(), TIMESTAMP(fecha_reserva, hora_reserva)) AS minutos_restantes " +
            "FROM RESERVA WHERE id_reserva = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
            ps.setInt(1, idReserva);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getInt("minutos_restantes") < 120) return false;
        } catch (SQLException e) { return false; }

        String sql = "UPDATE RESERVA SET fecha_reserva=?, hora_reserva=?, cantidad_personas=? WHERE id_reserva=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fecha);
            ps.setString(2, hora);
            ps.setInt(3, personas);
            ps.setInt(4, idReserva);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservaDAO] Error modificando: " + e.getMessage());
            return false;
        }
    }

    /** Reservas de un cliente específico */
    public List<Map<String, Object>> listarPorCliente(int idCliente) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT rv.id_reserva, rv.fecha_reserva, rv.hora_reserva, " +
            "       rv.cantidad_personas, rv.estado, r.nombre AS restaurante " +
            "FROM   RESERVA     rv " +
            "JOIN   RESTAURANTE r  ON rv.id_restaurante = r.id_restaurante " +
            "WHERE  rv.id_cliente = ? " +
            "ORDER  BY rv.fecha_reserva DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idReserva",        rs.getInt("id_reserva"));
                row.put("fechaReserva",     rs.getDate("fecha_reserva"));
                row.put("horaReserva",      rs.getString("hora_reserva"));
                row.put("cantidadPersonas", rs.getInt("cantidad_personas"));
                row.put("estado",           rs.getString("estado"));
                row.put("restaurante",      rs.getString("restaurante"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[ReservaDAO] Error listando por cliente: " + e.getMessage());
        }
        return lista;
    }
}
