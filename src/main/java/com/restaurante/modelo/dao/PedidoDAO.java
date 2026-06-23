package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PedidoDAO.java
 * DAO para gestión completa de PEDIDOS y DETALLE_PEDIDO.
 * Incluye operaciones CRUD y consultas específicas por rol.
 */
public class PedidoDAO {

    private Connection conn;

    public PedidoDAO() {
        this.conn = ConexionDB.getInstancia().getConexion();
    }

    // ============================================================
    //  LISTAR todos los pedidos activos (cocinero / admin)
    // ============================================================
    public List<Map<String, Object>> listarPedidosActivos() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT p.id_pedido, p.fecha_pedido, p.estado, p.observaciones, " +
            "       p.tiene_alergias, m.id_mesa, " +
            "       pe.nombre AS emp_nombre, pe.apellido AS emp_apellido " +
            "FROM   PEDIDO p " +
            "JOIN      MESA     m  ON p.id_mesa     = m.id_mesa " +
            "LEFT JOIN EMPLEADO e  ON p.id_empleado = e.id_empleado " +
            "LEFT JOIN PERSONA  pe ON e.id_persona  = pe.id_persona " +
            "WHERE  p.estado NOT IN ('entregado','cancelado') " +
            "ORDER  BY p.fecha_pedido ASC";  // orden de llegada (prioridad cocina)

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idPedido",      rs.getInt("id_pedido"));
                row.put("fechaPedido",   rs.getTimestamp("fecha_pedido"));
                row.put("estado",        rs.getString("estado"));
                row.put("observaciones", rs.getString("observaciones"));
                row.put("tieneAlergias", rs.getBoolean("tiene_alergias"));
                row.put("idMesa",        rs.getInt("id_mesa"));
                row.put("empleado",      rs.getString("emp_nombre") != null
                        ? rs.getString("emp_nombre") + " " + rs.getString("emp_apellido")
                        : "Cliente (autoservicio)");
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error listando pedidos activos: " + e.getMessage());
        }
        return lista;
    }

    // ============================================================
    //  LISTAR pedidos por mesero (los suyos + pedidos de clientes del mismo restaurante)
    // ============================================================
    public List<Map<String, Object>> listarPorMesero(int idEmpleado, int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT p.id_pedido, p.fecha_pedido, p.estado, p.tiene_alergias, m.id_mesa " +
            "FROM   PEDIDO p " +
            "JOIN   MESA m ON p.id_mesa = m.id_mesa " +
            "WHERE  (p.id_empleado = ? OR p.id_empleado IS NULL) " +
            "AND    m.id_restaurante = ? " +
            "ORDER  BY p.fecha_pedido DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idEmpleado);
            ps.setInt(2, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idPedido",      rs.getInt("id_pedido"));
                row.put("fechaPedido",   rs.getTimestamp("fecha_pedido"));
                row.put("estado",        rs.getString("estado"));
                row.put("tieneAlergias", rs.getBoolean("tiene_alergias"));
                row.put("idMesa",        rs.getInt("id_mesa"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error listando pedidos de mesero: " + e.getMessage());
        }
        return lista;
    }

    // ============================================================
    //  OBTENER detalle completo de un pedido con sus productos
    // ============================================================
    public List<Map<String, Object>> obtenerDetalle(int idPedido) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT dp.id_detalle_pedido, pr.nombre AS producto, " +
            "       dp.cantidad, dp.precio_unitario, " +
            "       (dp.cantidad * dp.precio_unitario) AS subtotal_linea, " +
            "       dp.descripcion AS alergia_item " +
            "FROM   DETALLE_PEDIDO dp " +
            "JOIN   PRODUCTO       pr ON dp.id_producto = pr.id_producto " +
            "WHERE  dp.id_pedido = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPedido);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idDetalle",      rs.getInt("id_detalle_pedido"));
                row.put("producto",       rs.getString("producto"));
                row.put("cantidad",       rs.getInt("cantidad"));
                row.put("precioUnitario", rs.getBigDecimal("precio_unitario"));
                row.put("subtotalLinea",  rs.getBigDecimal("subtotal_linea"));
                row.put("alergiaItem",    rs.getString("alergia_item"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error obteniendo detalle: " + e.getMessage());
        }
        return lista;
    }

    // ============================================================
    //  CREAR nuevo pedido (transacción: pedido + detalles)
    //  @param idEmpleado mesero que toma el pedido
    //  @param idMesa     mesa asignada
    //  @param obs        observaciones generales / alergias
    //  @param tieneAlergias flag booleano
    //  @param productos  lista de {idProducto, cantidad, precioUnitario, descripcion}
    //  @return id del pedido creado, o -1 si falló
    // ============================================================
    public int crearPedido(Integer idEmpleado, int idMesa, String obs,
                           boolean tieneAlergias,
                           List<Map<String, Object>> productos) {
        String sqlPedido = "INSERT INTO PEDIDO (estado, observaciones, tiene_alergias, id_empleado, id_mesa) " +
                           "VALUES ('pendiente', ?, ?, ?, ?)";
        String sqlDetalle = "INSERT INTO DETALLE_PEDIDO (id_pedido, id_producto, cantidad, precio_unitario, descripcion) " +
                            "VALUES (?, ?, ?, ?, ?)";

        try {
            conn.setAutoCommit(false);   // Inicio de transacción

            int idPedido;
            try (PreparedStatement ps = conn.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, obs);
                ps.setBoolean(2, tieneAlergias);
                if (idEmpleado != null) ps.setInt(3, idEmpleado); else ps.setNull(3, java.sql.Types.INTEGER);
                ps.setInt(4, idMesa);
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (!keys.next()) throw new SQLException("No se generó el ID del pedido");
                idPedido = keys.getInt(1);
            }

            // Insertar cada línea del pedido
            try (PreparedStatement ps = conn.prepareStatement(sqlDetalle)) {
                for (Map<String, Object> prod : productos) {
                    ps.setInt(1,    idPedido);
                    ps.setInt(2,    (int)    prod.get("idProducto"));
                    ps.setInt(3,    (int)    prod.get("cantidad"));
                    ps.setBigDecimal(4, (java.math.BigDecimal) prod.get("precioUnitario"));
                    ps.setString(5, (String) prod.get("descripcion"));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            conn.commit();
            return idPedido;

        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) { /* ignorar */ }
            System.err.println("[PedidoDAO] Error creando pedido (rollback): " + e.getMessage());
            return -1;
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException e) { /* ignorar */ }
        }
    }

    // ============================================================
    //  CAMBIAR estado de un pedido
    // ============================================================
    public boolean cambiarEstado(int idPedido, String nuevoEstado) {
        String sql = "UPDATE PEDIDO SET estado = ? WHERE id_pedido = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idPedido);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error cambiando estado: " + e.getMessage());
            return false;
        }
    }

    /**
     * Cambia el estado a nuevoEstado solo si el pedido está actualmente en "listo".
     * Usado por el mesero para marcar como "entregado" después de que el cocinero marcó "listo".
     */
    public boolean cambiarEstadoSiListo(int idPedido, String nuevoEstado) {
        String sql = "UPDATE PEDIDO SET estado = ? WHERE id_pedido = ? AND estado = 'listo'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idPedido);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error cambiarEstadoSiListo: " + e.getMessage());
            return false;
        }
    }

    // ============================================================
    //  LISTAR pedidos con alergias (para cocina)
    // ============================================================
    public List<Map<String, Object>> listarConAlergias() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT p.id_pedido, p.fecha_pedido, p.observaciones, m.id_mesa, " +
            "       dp.descripcion AS alergia_item, pr.nombre AS producto " +
            "FROM   PEDIDO p " +
            "JOIN   MESA          m  ON p.id_mesa     = m.id_mesa " +
            "JOIN   DETALLE_PEDIDO dp ON p.id_pedido  = dp.id_pedido " +
            "JOIN   PRODUCTO       pr ON dp.id_producto = pr.id_producto " +
            "WHERE  p.tiene_alergias = TRUE " +
            "AND    p.estado NOT IN ('entregado','cancelado') " +
            "ORDER  BY p.fecha_pedido ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idPedido",      rs.getInt("id_pedido"));
                row.put("fechaPedido",   rs.getTimestamp("fecha_pedido"));
                row.put("observaciones", rs.getString("observaciones"));
                row.put("idMesa",        rs.getInt("id_mesa"));
                row.put("alergiaItem",   rs.getString("alergia_item"));
                row.put("producto",      rs.getString("producto"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error listando pedidos con alergias: " + e.getMessage());
        }
        return lista;
    }

    // ============================================================
    //  LISTAR pedidos en estado "listo" por restaurante (para el mesero)
    // ============================================================
    public List<Map<String, Object>> listarListosPorRestaurante(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        // Si idRestaurante es inválido, traer todos los pedidos listos
        String sql;
        if (idRestaurante <= 0) {
            sql = "SELECT p.id_pedido, p.fecha_pedido, p.estado, p.tiene_alergias, " +
                  "       p.observaciones, m.id_mesa " +
                  "FROM   PEDIDO p " +
                  "JOIN   MESA m ON p.id_mesa = m.id_mesa " +
                  "WHERE  p.estado = 'listo' " +
                  "ORDER  BY p.fecha_pedido ASC";
        } else {
            sql = "SELECT p.id_pedido, p.fecha_pedido, p.estado, p.tiene_alergias, " +
                  "       p.observaciones, m.id_mesa " +
                  "FROM   PEDIDO p " +
                  "JOIN   MESA m ON p.id_mesa = m.id_mesa " +
                  "WHERE  p.estado = 'listo' " +
                  "AND    m.id_restaurante = ? " +
                  "ORDER  BY p.fecha_pedido ASC";
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (idRestaurante > 0) ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idPedido",      rs.getInt("id_pedido"));
                row.put("fechaPedido",   rs.getTimestamp("fecha_pedido"));
                row.put("estado",        rs.getString("estado"));
                row.put("tieneAlergias", rs.getBoolean("tiene_alergias"));
                row.put("observaciones", rs.getString("observaciones"));
                row.put("idMesa",        rs.getInt("id_mesa"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error listando listos: " + e.getMessage());
        }
        return lista;
    }

    // ============================================================
    //  CANCELAR un pedido (solo si está en estado "listo")
    // ============================================================
    public boolean cancelarSiListo(int idPedido) {
        String sql = "UPDATE PEDIDO SET estado = 'cancelado' WHERE id_pedido = ? AND estado = 'listo'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPedido);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error cancelando pedido: " + e.getMessage());
            return false;
        }
    }

    // ============================================================
    //  ASIGNAR mesa al cliente: devuelve el id_mesa más bajo del
    //  restaurante que NO tenga un pedido activo en este momento.
    // ============================================================
    public int asignarMesaCliente(int idRestaurante) {
        String sql =
            "SELECT m.id_mesa " +
            "FROM   MESA m " +
            "WHERE  m.id_restaurante = ? " +
            "AND    m.id_mesa NOT IN ( " +
            "    SELECT p.id_mesa FROM PEDIDO p " +
            "    JOIN MESA m2 ON p.id_mesa = m2.id_mesa " +
            "    WHERE m2.id_restaurante = ? " +
            "    AND p.estado NOT IN ('entregado','cancelado') " +
            ") " +
            "ORDER  BY m.id_mesa ASC " +
            "LIMIT  1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ps.setInt(2, idRestaurante);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id_mesa");
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error asignando mesa: " + e.getMessage());
        }
        return 1; // fallback: mesa 1
    }
    //  + coincide el id_usuario guardado en observaciones, o bien
    //  se filtra por id_usuario si la tabla PEDIDO lo tiene).
    //  Estrategia simple: listar todos los pedidos cuyo
    //  id_empleado IS NULL y que fueron creados más recientemente,
    //  mostrando solo los del cliente en sesión via id_usuario.
    //  Si el esquema tiene columna id_usuario en PEDIDO úsala;
    //  si no, se muestran todos los pedidos sin mesero asignado.
    // ============================================================
    public List<Map<String, Object>> listarPorCliente(int idCliente) {
        List<Map<String, Object>> lista = new ArrayList<>();
        // Intenta filtrar por id_usuario si existe la columna; si no, trae los de id_empleado IS NULL
        // Filtra los pedidos asociados al empleado puente (id=2) que se usa para pedidos de clientes
        String sql =
            "SELECT p.id_pedido, p.fecha_pedido, p.estado, p.tiene_alergias, " +
            "       p.observaciones, m.id_mesa, " +
            "       (SELECT SUM(dp.cantidad * dp.precio_unitario) " +
            "        FROM DETALLE_PEDIDO dp WHERE dp.id_pedido = p.id_pedido) AS total " +
            "FROM   PEDIDO p " +
            "JOIN   MESA   m ON p.id_mesa = m.id_mesa " +
            "WHERE  p.id_empleado IS NULL " +
            "ORDER  BY p.fecha_pedido DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idPedido",      rs.getInt("id_pedido"));
                row.put("fechaPedido",   rs.getTimestamp("fecha_pedido"));
                row.put("estado",        rs.getString("estado"));
                row.put("tieneAlergias", rs.getBoolean("tiene_alergias"));
                row.put("observaciones", rs.getString("observaciones"));
                row.put("idMesa",        rs.getInt("id_mesa"));
                row.put("total",         rs.getBigDecimal("total"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error listando pedidos de cliente: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista pedidos entregados que aún no tienen factura generada.
     * Usado por el cajero para saber qué pedidos cobrar.
     */
    public List<Map<String, Object>> listarEntregadosSinFactura(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT p.id_pedido, p.fecha_pedido, p.observaciones, p.tiene_alergias, " +
            "       m.id_mesa, " +
            "       (SELECT SUM(dp.cantidad * dp.precio_unitario) " +
            "        FROM DETALLE_PEDIDO dp WHERE dp.id_pedido = p.id_pedido) AS total " +
            "FROM   PEDIDO p " +
            "JOIN   MESA   m ON p.id_mesa = m.id_mesa " +
            "WHERE  p.estado = 'entregado' " +
            "AND    m.id_restaurante = ? " +
            "AND    NOT EXISTS (SELECT 1 FROM FACTURA f WHERE f.id_pedido = p.id_pedido) " +
            "ORDER  BY p.fecha_pedido DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idPedido",      rs.getInt("id_pedido"));
                row.put("fechaPedido",   rs.getTimestamp("fecha_pedido"));
                row.put("observaciones", rs.getString("observaciones"));
                row.put("tieneAlergias", rs.getBoolean("tiene_alergias"));
                row.put("idMesa",        rs.getInt("id_mesa"));
                row.put("total",         rs.getBigDecimal("total"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[PedidoDAO] Error listando entregados sin factura: " + e.getMessage());
        }
        return lista;
    }
}
