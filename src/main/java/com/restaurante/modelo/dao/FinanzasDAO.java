package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FinanzasDAO {
    private final Connection conn;
    public FinanzasDAO() { this.conn = ConexionDB.getInstancia().getConexion(); }

    /** Resumen financiero de UN restaurante */
    public Map<String, Object> resumenRestaurante(int idRestaurante) {
        Map<String, Object> datos = new HashMap<>();
        String sql =
            "SELECT COALESCE(SUM(f.total), 0)       AS total_ingresos, " +
            "       COALESCE(SUM(f.iva),   0)        AS total_iva, " +
            "       COALESCE(SUM(pr.monto), 0)        AS total_propinas " +
            "FROM   RESTAURANTE r " +
            "LEFT JOIN MESA    m  ON r.id_restaurante = m.id_restaurante " +
            "LEFT JOIN PEDIDO  p  ON m.id_mesa        = p.id_mesa " +
            "LEFT JOIN FACTURA f  ON p.id_pedido      = f.id_pedido " +
            "LEFT JOIN PROPINA pr ON f.id_factura     = pr.id_factura " +
            "WHERE  r.id_restaurante = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                datos.put("totalIngresos", rs.getBigDecimal("total_ingresos"));
                datos.put("totalIva",      rs.getBigDecimal("total_iva"));
                datos.put("totalPropinas", rs.getBigDecimal("total_propinas"));
            }
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error resumen: " + e.getMessage());
        }

        // Gastos del restaurante
        String sqlGastos = "SELECT COALESCE(SUM(valor), 0) AS total_gastos FROM GASTO WHERE id_restaurante = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlGastos)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) datos.put("totalGastos", rs.getBigDecimal("total_gastos"));
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error gastos: " + e.getMessage());
        }

        // Calcular ganancia = ingresos - gastos
        BigDecimal ingresos = (BigDecimal) datos.getOrDefault("totalIngresos", BigDecimal.ZERO);
        BigDecimal gastos   = (BigDecimal) datos.getOrDefault("totalGastos",   BigDecimal.ZERO);
        datos.put("ganancia", ingresos.subtract(gastos));

        return datos;
    }

    /** Ingresos por método de pago en un restaurante (para admin de punto) */
    public List<Map<String, Object>> ingresosPorMetodoPago(int idRestaurante, java.sql.Date fecha) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT tp.nombre AS metodo, SUM(pa.monto) AS total " +
            "FROM   PAGO     pa " +
            "JOIN   TIPO_PAGO tp ON pa.id_tipo_pago = tp.id_tipo_pago " +
            "JOIN   FACTURA   f  ON pa.id_factura   = f.id_factura " +
            "JOIN   PEDIDO    p  ON f.id_pedido      = p.id_pedido " +
            "JOIN   MESA      m  ON p.id_mesa        = m.id_mesa " +
            "WHERE  m.id_restaurante = ? AND DATE(pa.fecha_pago) = ? " +
            "GROUP  BY tp.nombre";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ps.setDate(2, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("metodo", rs.getString("metodo"));
                row.put("total",  rs.getBigDecimal("total"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error ingresos por método: " + e.getMessage());
        }
        return lista;
    }

    /** Propinas totales por mes */
    public List<Map<String, Object>> propinasPorMes(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT DATE_FORMAT(pr.fecha, '%Y-%m') AS mes, SUM(pr.monto) AS total " +
            "FROM   PROPINA  pr " +
            "JOIN   FACTURA  f  ON pr.id_factura = f.id_factura " +
            "JOIN   PEDIDO   p  ON f.id_pedido   = p.id_pedido " +
            "JOIN   MESA     m  ON p.id_mesa     = m.id_mesa " +
            "WHERE  m.id_restaurante = ? " +
            "GROUP  BY mes ORDER BY mes DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("mes",   rs.getString("mes"));
                row.put("total", rs.getBigDecimal("total"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error propinas por mes: " + e.getMessage());
        }
        return lista;
    }

    /** Gastos detallados de un restaurante */
    public List<Map<String, Object>> gastosDetallados(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT id_gasto, descripcion, valor, fecha " +
            "FROM   GASTO WHERE id_restaurante = ? ORDER BY fecha DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idRestaurante);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idGasto",     rs.getInt("id_gasto"));
                row.put("descripcion", rs.getString("descripcion"));
                row.put("valor",       rs.getBigDecimal("valor"));
                row.put("fecha",       rs.getDate("fecha"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error gastos detallados: " + e.getMessage());
        }
        return lista;
    }

    /** Registrar un nuevo gasto */
    public boolean registrarGasto(String descripcion, BigDecimal valor, java.sql.Date fecha, int idRestaurante) {
        String sql = "INSERT INTO GASTO (descripcion, valor, fecha, id_restaurante) VALUES (?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, descripcion);
            ps.setBigDecimal(2, valor);
            ps.setDate(3, fecha);
            ps.setInt(4, idRestaurante);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error registrando gasto: " + e.getMessage());
            return false;
        }
    }

    /** Vista global: resumen financiero de TODAS las sedes (superadmin) */
    public List<Map<String, Object>> resumenGlobal() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT * FROM v_resumen_financiero ORDER BY restaurante";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idRestaurante",  rs.getInt("id_restaurante"));
                row.put("restaurante",    rs.getString("restaurante"));
                row.put("totalIngresos",  rs.getBigDecimal("total_ingresos"));
                row.put("totalGastos",    rs.getBigDecimal("total_gastos"));
                row.put("balance",        rs.getBigDecimal("balance"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[FinanzasDAO] Error resumen global: " + e.getMessage());
        }
        return lista;
    }
}
