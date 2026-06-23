package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductoDAO {
    private final Connection conn;
    public ProductoDAO() { this.conn = ConexionDB.getInstancia().getConexion(); }

    /** Listar todos los productos activos del menú */
    public List<Map<String, Object>> listarActivos() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT p.id_producto, p.nombre, p.precio, tp.nombre AS tipo, pv.nombre_empresa AS proveedor " +
            "FROM   PRODUCTO p " +
            "JOIN   TIPO_PRODUCTO tp ON p.id_tipo_producto = tp.id_tipo_producto " +
            "LEFT JOIN PROVEEDOR  pv ON p.id_proveedor     = pv.id_proveedor " +
            "WHERE  p.activo = TRUE ORDER BY tp.nombre, p.nombre";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idProducto", rs.getInt("id_producto"));
                row.put("nombre",     rs.getString("nombre"));
                row.put("precio",     rs.getBigDecimal("precio"));
                row.put("tipo",       rs.getString("tipo"));
                row.put("proveedor",  rs.getString("proveedor"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[ProductoDAO] Error listando: " + e.getMessage());
        }
        return lista;
    }

    /** Registrar nuevo producto */
    public boolean registrar(String nombre, BigDecimal precio, int idTipo, Integer idProveedor) {
        String sql = "INSERT INTO PRODUCTO (nombre, precio, id_tipo_producto, id_proveedor) VALUES (?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setBigDecimal(2, precio);
            ps.setInt(3, idTipo);
            if (idProveedor != null) ps.setInt(4, idProveedor); else ps.setNull(4, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ProductoDAO] Error registrando: " + e.getMessage());
            return false;
        }
    }

    /** Receta completa de un producto */
    public List<Map<String, Object>> receta(int idProducto) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT i.nombre AS ingrediente, r.cantidad, r.unidad " +
            "FROM   RECETA     r " +
            "JOIN   INGREDIENTE i ON r.id_ingrediente = i.id_ingrediente " +
            "WHERE  r.id_producto = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idProducto);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("ingrediente", rs.getString("ingrediente"));
                row.put("cantidad",    rs.getBigDecimal("cantidad"));
                row.put("unidad",      rs.getString("unidad"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[ProductoDAO] Error receta: " + e.getMessage());
        }
        return lista;
    }
}
