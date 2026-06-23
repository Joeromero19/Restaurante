package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FacturaDAO {
    private final Connection conn;
    public FacturaDAO() { this.conn = ConexionDB.getInstancia().getConexion(); }

    /** Generar factura (inserta FACTURA + PAGO + PROPINA en transacción) */
    public int generarFactura(int idPedido, int idCliente, BigDecimal subtotal,
                               BigDecimal iva, int idTipoPago, BigDecimal propina) {
        try {
            conn.setAutoCommit(false);

            BigDecimal total = subtotal.add(iva);
            java.sql.Date hoy = new java.sql.Date(System.currentTimeMillis());
            String hora = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date());

            // Insertar FACTURA
            int idFactura;
            String sqlF = "INSERT INTO FACTURA (fecha, hora, subtotal, iva, total, id_pedido, id_cliente) VALUES (?,?,?,?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlF, Statement.RETURN_GENERATED_KEYS)) {
                ps.setDate(1, hoy);
                ps.setString(2, hora);
                ps.setBigDecimal(3, subtotal);
                ps.setBigDecimal(4, iva);
                ps.setBigDecimal(5, total);
                ps.setInt(6, idPedido);
                ps.setInt(7, idCliente);
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (!keys.next()) throw new SQLException("Sin ID de factura");
                idFactura = keys.getInt(1);
            }

            // Insertar PAGO
            String sqlP = "INSERT INTO PAGO (monto, id_tipo_pago, id_factura) VALUES (?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlP)) {
                ps.setBigDecimal(1, total.add(propina));
                ps.setInt(2, idTipoPago);
                ps.setInt(3, idFactura);
                ps.executeUpdate();
            }

            // Insertar PROPINA si hay
            if (propina != null && propina.compareTo(BigDecimal.ZERO) > 0) {
                String sqlPr = "INSERT INTO PROPINA (monto, fecha, id_factura) VALUES (?,?,?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlPr)) {
                    ps.setBigDecimal(1, propina);
                    ps.setDate(2, hoy);
                    ps.setInt(3, idFactura);
                    ps.executeUpdate();
                }
            }

            // Marcar pedido como entregado
            String sqlEst = "UPDATE PEDIDO SET estado = 'entregado' WHERE id_pedido = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlEst)) {
                ps.setInt(1, idPedido);
                ps.executeUpdate();
            }

            conn.commit();
            return idFactura;

        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            System.err.println("[FacturaDAO] Error generando factura: " + e.getMessage());
            return -1;
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException e) {}
        }
    }

    /** Listar facturas de un restaurante */
    public List<Map<String, Object>> listarPorRestaurante(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT f.id_factura, f.fecha, f.hora, f.subtotal, f.iva, f.total, " +
            "       p.nombre AS cliente_nombre, p.apellido AS cliente_apellido, " +
            "       tp.nombre AS metodo_pago, pr.monto AS propina " +
            "FROM   FACTURA    f " +
            "JOIN   CLIENTE    c  ON f.id_cliente  = c.id_cliente " +
            "JOIN   PERSONA    p  ON c.id_persona  = p.id_persona " +
            "JOIN   PEDIDO     pd ON f.id_pedido   = pd.id_pedido " +
            "JOIN   MESA       m  ON pd.id_mesa    = m.id_mesa " +
            "JOIN   PAGO       pa ON f.id_factura  = pa.id_factura " +
            "JOIN   TIPO_PAGO  tp ON pa.id_tipo_pago = tp.id_tipo_pago " +
            "LEFT JOIN PROPINA pr ON f.id_factura  = pr.id_factura " +
            "WHERE  m.id_restaurante = ? " +
            "ORDER  BY f.fecha DESC, f.hora DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idFactura",    rs.getInt("id_factura"));
                row.put("fecha",        rs.getDate("fecha"));
                row.put("hora",         rs.getString("hora"));
                row.put("subtotal",     rs.getBigDecimal("subtotal"));
                row.put("iva",          rs.getBigDecimal("iva"));
                row.put("total",        rs.getBigDecimal("total"));
                row.put("cliente",      rs.getString("cliente_nombre") + " " + rs.getString("cliente_apellido"));
                row.put("metodoPago",   rs.getString("metodo_pago"));
                row.put("propina",      rs.getBigDecimal("propina"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[FacturaDAO] Error listando: " + e.getMessage());
        }
        return lista;
    }

    // Facturas filtradas por mesero (sus propios pedidos)
    public java.util.List<java.util.Map<String, Object>> listarPorMesero(int idEmpleado) {
        java.util.List<java.util.Map<String, Object>> lista = new java.util.ArrayList<>();
        String sql =
            "SELECT f.id_factura, f.fecha, f.hora, f.subtotal, f.iva, f.total, " +
            "       p2.nombre AS cliente_nombre, p2.apellido AS cliente_apellido, " +
            "       tp.nombre AS metodo_pago, pr.monto AS propina " +
            "FROM   FACTURA    f " +
            "JOIN   CLIENTE    c   ON f.id_cliente   = c.id_cliente " +
            "JOIN   PERSONA    p2  ON c.id_persona   = p2.id_persona " +
            "JOIN   PEDIDO     pd  ON f.id_pedido    = pd.id_pedido " +
            "JOIN   PAGO       pa  ON f.id_factura   = pa.id_factura " +
            "JOIN   TIPO_PAGO  tp  ON pa.id_tipo_pago = tp.id_tipo_pago " +
            "LEFT JOIN PROPINA pr  ON f.id_factura   = pr.id_factura " +
            "WHERE  pd.id_empleado = ? " +
            "ORDER  BY f.fecha DESC, f.hora DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idEmpleado);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> row = new java.util.HashMap<>();
                row.put("idFactura",  rs.getInt("id_factura"));
                row.put("fecha",      rs.getDate("fecha"));
                row.put("hora",       rs.getString("hora"));
                row.put("subtotal",   rs.getBigDecimal("subtotal"));
                row.put("iva",        rs.getBigDecimal("iva"));
                row.put("total",      rs.getBigDecimal("total"));
                row.put("cliente",    rs.getString("cliente_nombre") + " " + rs.getString("cliente_apellido"));
                row.put("metodoPago", rs.getString("metodo_pago"));
                row.put("propina",    rs.getBigDecimal("propina"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[FacturaDAO] Error listarPorMesero: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista todas las facturas del restaurante (historial del cajero).
     * El cajero ve todas las facturas de su sede, no solo las suyas.
     */
    public List<Map<String, Object>> listarPorCajero(int idCajero, int idRestaurante) {
        return listarPorRestaurante(idRestaurante);
    }
}
