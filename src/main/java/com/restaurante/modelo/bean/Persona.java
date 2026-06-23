package com.restaurante.modelo.bean;

import java.util.Date;

/**
 * ============================================================
 *  Persona.java — Bean de la tabla PERSONA
 *  Representa la clase padre de Cliente y Empleado (herencia)
 * ============================================================
 */
public class Persona {
    private long idPersona;       // = documento de identidad (PK)
    private String nombre;
    private String apellido;
    private String telefono;
    private String correo;
    private Date   fechaNacimiento;
    private String direccion;
    private String tipoPersona;   // 'empleado' | 'cliente' (columna extra)

    public Persona() {}

    public Persona(long idPersona, String nombre, String apellido,
                   String telefono, String correo, Date fechaNacimiento, String direccion) {
        this.idPersona = idPersona;
        this.nombre = nombre;
        this.apellido = apellido;
        this.telefono = telefono;
        this.correo = correo;
        this.fechaNacimiento = fechaNacimiento;
        this.direccion = direccion;
    }

    // ---- Getters y Setters ----
    public long   getIdPersona()       { return idPersona; }
    public void   setIdPersona(long v) { this.idPersona = v; }

    public String getNombre()          { return nombre; }
    public void   setNombre(String v)  { this.nombre = v; }

    public String getApellido()        { return apellido; }
    public void   setApellido(String v){ this.apellido = v; }

    public String getTelefono()        { return telefono; }
    public void   setTelefono(String v){ this.telefono = v; }

    public String getCorreo()          { return correo; }
    public void   setCorreo(String v)  { this.correo = v; }

    public Date   getFechaNacimiento()      { return fechaNacimiento; }
    public void   setFechaNacimiento(Date v){ this.fechaNacimiento = v; }

    public String getDireccion()       { return direccion; }
    public void   setDireccion(String v){ this.direccion = v; }

    public String getTipoPersona()     { return tipoPersona; }
    public void   setTipoPersona(String v){ this.tipoPersona = v; }

    public String getNombreCompleto()  { return nombre + " " + apellido; }
}
