package com.restaurante.modelo.bean;

import java.math.BigDecimal;
import java.util.Date;

/**
 * ============================================================
 *  Empleado.java — Bean de la tabla EMPLEADO
 * ============================================================
 */
public class Empleado {
    private int      idEmpleado;
    private long     idPersona;
    private int      idTipoUsuario;   // rol del sistema
    private int      idRestaurante;
    private BigDecimal salario;
    private String   cargo;
    private Date     fechaIngreso;
    private String   estado;          // ACTIVO | INACTIVO

    // Datos desnormalizados (JOIN con PERSONA y TIPO_USUARIO)
    private String   nombre;
    private String   apellido;
    private String   correo;
    private String   telefono;
    private String   rolNombre;
    private String   restauranteNombre;

    public Empleado() {}

    // ---- Getters y Setters ----
    public int    getIdEmpleado()          { return idEmpleado; }
    public void   setIdEmpleado(int v)     { this.idEmpleado = v; }

    public long   getIdPersona()           { return idPersona; }
    public void   setIdPersona(long v)     { this.idPersona = v; }

    public int    getIdTipoUsuario()       { return idTipoUsuario; }
    public void   setIdTipoUsuario(int v)  { this.idTipoUsuario = v; }

    public int    getIdRestaurante()       { return idRestaurante; }
    public void   setIdRestaurante(int v)  { this.idRestaurante = v; }

    public BigDecimal getSalario()         { return salario; }
    public void   setSalario(BigDecimal v) { this.salario = v; }

    public String getCargo()              { return cargo; }
    public void   setCargo(String v)      { this.cargo = v; }

    public Date   getFechaIngreso()        { return fechaIngreso; }
    public void   setFechaIngreso(Date v)  { this.fechaIngreso = v; }

    public String getEstado()             { return estado; }
    public void   setEstado(String v)     { this.estado = v; }

    public String getNombre()             { return nombre; }
    public void   setNombre(String v)     { this.nombre = v; }

    public String getApellido()           { return apellido; }
    public void   setApellido(String v)   { this.apellido = v; }

    public String getCorreo()             { return correo; }
    public void   setCorreo(String v)     { this.correo = v; }

    public String getTelefono()           { return telefono; }
    public void   setTelefono(String v)   { this.telefono = v; }

    public String getRolNombre()          { return rolNombre; }
    public void   setRolNombre(String v)  { this.rolNombre = v; }

    public String getRestauranteNombre()       { return restauranteNombre; }
    public void   setRestauranteNombre(String v){ this.restauranteNombre = v; }

    public String getNombreCompleto()     { return nombre + " " + apellido; }
}
