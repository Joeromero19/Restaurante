package com.restaurante.modelo.dao;

import com.restaurante.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InventarioDAO {
    private final Connection conn;
    public InventarioDAO() { this.conn = ConexionDB.getInstancia().getConexion(); }

    /** Listar inventario completo de un restaurante con proveedor */
    public List<Map<String, Object>> listar(int idRestaurante) {
        List<Map<String, Object>> lista = new ArrayList<>();
        // El inventario está ligado al producto, que está ligado al proveedor
        String sql =
            "SELECT i.id_inventario, pr.nombre AS producto, pr.precio, " +
            "       i.cantidad_disponible, i.fecha_vencimiento, " +
            "       DATEDIFF(i.fecha_vencimiento, CURDATE()) AS dias_para_vencer, " +
            "       pv.nombre_empresa AS proveedor " +
            "FROM   INVENTARIO i " +
            "JOIN   PRODUCTO   pr ON i.id_producto  = pr.id_producto " +
            "LEFT JOIN PROVEEDOR pv ON i.id_proveedor = pv.id_proveedor " +
            "WHERE  pr.activo = TRUE " +
            "ORDER  BY i.fecha_vencimiento ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idInventario",       rs.getInt("id_inventario"));
                row.put("producto",           rs.getString("producto"));
                row.put("precio",             rs.getBigDecimal("precio"));
                row.put("cantidadDisponible", rs.getBigDecimal("cantidad_disponible"));
                row.put("fechaVencimiento",   rs.getDate("fecha_vencimiento"));
                row.put("diasParaVencer",     rs.getInt("dias_para_vencer"));
                row.put("proveedor",          rs.getString("proveedor"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error listando: " + e.getMessage());
        }
        return lista;
    }

    /** Productos que vencen en los próximos N días */
    public List<Map<String, Object>> proximosAVencer(int dias) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT i.id_inventario, pr.nombre, i.cantidad_disponible, i.fecha_vencimiento, " +
            "       DATEDIFF(i.fecha_vencimiento, CURDATE()) AS dias_restantes " +
            "FROM   INVENTARIO i " +
            "JOIN   PRODUCTO   pr ON i.id_producto = pr.id_producto " +
            "WHERE  i.fecha_vencimiento <= DATE_ADD(CURDATE(), INTERVAL ? DAY) " +
            "AND    i.fecha_vencimiento >= CURDATE() " +
            "ORDER  BY i.fecha_vencimiento ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dias);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idInventario",    rs.getInt("id_inventario"));
                row.put("producto",         rs.getString("nombre"));
                row.put("cantidad",         rs.getBigDecimal("cantidad_disponible"));
                row.put("fechaVencimiento", rs.getDate("fecha_vencimiento"));
                row.put("diasRestantes",    rs.getInt("dias_restantes"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error próximos a vencer: " + e.getMessage());
        }
        return lista;
    }

    /** Elimina (retira) un ítem de inventario por su id */
    public boolean eliminarItem(int idInventario) {
        String sql = "DELETE FROM INVENTARIO WHERE id_inventario = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idInventario);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error eliminando item: " + e.getMessage());
            return false;
        }
    }

    /** Productos con stock bajo el umbral */
    public List<Map<String, Object>> stockBajo(double umbral) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT pr.nombre, i.cantidad_disponible " +
            "FROM   INVENTARIO i " +
            "JOIN   PRODUCTO   pr ON i.id_producto = pr.id_producto " +
            "WHERE  i.cantidad_disponible <= ? " +
            "ORDER  BY i.cantidad_disponible ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, umbral);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("producto", rs.getString("nombre"));
                row.put("cantidad", rs.getBigDecimal("cantidad_disponible"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error stock bajo: " + e.getMessage());
        }
        return lista;
    }

    /** Registrar nuevo producto al inventario */
    public boolean registrar(int idProducto, int idProveedor, double cantidad, java.sql.Date fechaVencimiento) {
        String sql = "INSERT INTO INVENTARIO (id_producto, id_proveedor, cantidad_disponible, fecha_vencimiento) VALUES (?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idProducto);
            ps.setInt(2, idProveedor);
            ps.setDouble(3, cantidad);
            ps.setDate(4, new java.sql.Date(fechaVencimiento.getTime()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error registrando: " + e.getMessage());
            return false;
        }
    }

    /** Lista todos los proveedores */
    public List<Map<String, Object>> listarProveedores() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT id_proveedor, nombre_empresa FROM PROVEEDOR ORDER BY nombre_empresa";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idProveedor", rs.getInt("id_proveedor"));
                row.put("nombre",      rs.getString("nombre_empresa"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error listando proveedores: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Calcula cuántos platos se pueden preparar con el stock actual,
     * dejando un margen de error del 2% sobre los ingredientes.
     */
    public List<Map<String, Object>> disponibilidadPlatos() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql =
            "SELECT pr.id_producto, pr.nombre AS plato, " +
            "       MIN(FLOOR( (ing.stock * 0.98) / r.cantidad )) AS platos_posibles " +
            "FROM   PRODUCTO   pr " +
            "JOIN   RECETA     r   ON pr.id_producto  = r.id_producto " +
            "JOIN   INGREDIENTE ing ON r.id_ingrediente = ing.id_ingrediente " +
            "WHERE  pr.activo = TRUE " +
            "GROUP  BY pr.id_producto, pr.nombre";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idProducto",    rs.getInt("id_producto"));
                row.put("plato",         rs.getString("plato"));
                row.put("platosPosibles", rs.getInt("platos_posibles"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[InventarioDAO] Error disponibilidad platos: " + e.getMessage());
        }
        return lista;
    }
}
