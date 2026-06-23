package com.restaurante.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * ConexionDB.java
 * Clase utilitaria que administra la conexión JDBC a MySQL.
 * Implementa el patrón Singleton para reutilizar la misma instancia.
 *
 * Tecnología: Java + JDBC + MySQL
 * Compatible: Apache NetBeans + Tomcat 10
 */
public class ConexionDB {

    // ============================================================
    //  Parámetros de conexión — ajustar según el entorno local
    // ============================================================
    private static final String URL      = "jdbc:mysql://localhost:3306/restaurante_db?useSSL=false&serverTimezone=America/Bogota&characterEncoding=UTF-8";
    private static final String USUARIO  = "root";
    private static final String PASSWORD = "123456";          // Cambiar según configuración local
    private static final String DRIVER   = "com.mysql.cj.jdbc.Driver";

    // Instancia única (Singleton)
    private static ConexionDB instancia;

    // Objeto de conexión reutilizable
    private Connection conexion;

    // ============================================================
    //  Constructor privado: carga el driver y abre la conexión
    // ============================================================
    private ConexionDB() {
        try {
            Class.forName(DRIVER);
            this.conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD);
            System.out.println("[ConexionDB] ✓ Conexión a MySQL establecida correctamente.");
        } catch (ClassNotFoundException e) {
            System.err.println("[ConexionDB] ✗ Driver MySQL no encontrado: " + e.getMessage());
            throw new RuntimeException("Driver no encontrado", e);
        } catch (SQLException e) {
            System.err.println("[ConexionDB] ✗ Error al conectar con MySQL: " + e.getMessage());
            throw new RuntimeException("Error de conexión", e);
        }
    }

    // ============================================================
    //  getInstancia() — punto de acceso global
    // ============================================================
    public static ConexionDB getInstancia() {
        try {
            if (instancia == null || instancia.conexion.isClosed()) {
                instancia = new ConexionDB();
            }
        } catch (SQLException e) {
            System.err.println("[ConexionDB] Error verificando estado de la conexión: " + e.getMessage());
            instancia = new ConexionDB();
        }
        return instancia;
    }

    // ============================================================
    //  getConexion() — devuelve el objeto Connection activo
    // ============================================================
    public Connection getConexion() {
        try {
            // Si la conexión se perdió, reconectar automáticamente
            if (conexion == null || conexion.isClosed()) {
                conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD);
                System.out.println("[ConexionDB] ✓ Reconexión automática exitosa.");
            }
            // Garantizar que autoCommit esté en true (puede quedar en false si un DAO
            // llama setAutoCommit(false) y falla antes de restaurarlo)
            if (!conexion.getAutoCommit()) {
                try { conexion.rollback(); } catch (SQLException ignored) {}
                conexion.setAutoCommit(true);
                System.out.println("[ConexionDB] ⚠ autoCommit restaurado a true.");
            }
        } catch (SQLException e) {
            System.err.println("[ConexionDB] ✗ Error al reconectar: " + e.getMessage());
            throw new RuntimeException("No se pudo reconectar a la base de datos", e);
        }
        return conexion;
    }

    // ============================================================
    //  cerrar() — cierra la conexión (llamar al apagar la app)
    // ============================================================
    public void cerrar() {
        try {
            if (conexion != null && !conexion.isClosed()) {
                conexion.close();
                System.out.println("[ConexionDB] Conexión cerrada.");
            }
        } catch (SQLException e) {
            System.err.println("[ConexionDB] Error al cerrar la conexión: " + e.getMessage());
        }
    }
}
