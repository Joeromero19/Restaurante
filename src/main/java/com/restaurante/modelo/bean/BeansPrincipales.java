package com.restaurante.modelo.bean;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

// ============================================================
//  Cliente.java
// ============================================================
class Cliente {
    private int    idCliente;
    private long   idPersona;
    private boolean activo;

    // Datos de PERSONA (desnormalizados)
    private String nombre;
    private String apellido;
    private String correo;
    private String telefono;
    private Date   fechaNacimiento;

    public Cliente() {}

    public int    getIdCliente()           { return idCliente; }
    public void   setIdCliente(int v)      { this.idCliente = v; }
    public long   getIdPersona()           { return idPersona; }
    public void   setIdPersona(long v)     { this.idPersona = v; }
    public boolean isActivo()              { return activo; }
    public void   setActivo(boolean v)     { this.activo = v; }
    public String getNombre()             { return nombre; }
    public void   setNombre(String v)     { this.nombre = v; }
    public String getApellido()           { return apellido; }
    public void   setApellido(String v)   { this.apellido = v; }
    public String getCorreo()             { return correo; }
    public void   setCorreo(String v)     { this.correo = v; }
    public String getTelefono()           { return telefono; }
    public void   setTelefono(String v)   { this.telefono = v; }
    public Date   getFechaNacimiento()     { return fechaNacimiento; }
    public void   setFechaNacimiento(Date v){ this.fechaNacimiento = v; }
    public String getNombreCompleto()     { return nombre + " " + apellido; }
}

// ============================================================
//  Restaurante.java
// ============================================================
class Restaurante {
    private int    idRestaurante;
    private String nombre;
    private int    capacidad;
    private int    idCiudad;
    private boolean activo;

    // Desnormalizados
    private String ciudadNombre;
    private String paisNombre;

    public Restaurante() {}

    public int    getIdRestaurante()       { return idRestaurante; }
    public void   setIdRestaurante(int v)  { this.idRestaurante = v; }
    public String getNombre()             { return nombre; }
    public void   setNombre(String v)     { this.nombre = v; }
    public int    getCapacidad()          { return capacidad; }
    public void   setCapacidad(int v)     { this.capacidad = v; }
    public int    getIdCiudad()           { return idCiudad; }
    public void   setIdCiudad(int v)      { this.idCiudad = v; }
    public boolean isActivo()             { return activo; }
    public void   setActivo(boolean v)    { this.activo = v; }
    public String getCiudadNombre()       { return ciudadNombre; }
    public void   setCiudadNombre(String v){ this.ciudadNombre = v; }
    public String getPaisNombre()         { return paisNombre; }
    public void   setPaisNombre(String v) { this.paisNombre = v; }
}

// ============================================================
//  Producto.java
// ============================================================
class Producto {
    private int        idProducto;
    private String     nombre;
    private BigDecimal precio;
    private int        idTipoProducto;
    private Integer    idProveedor;
    private boolean    activo;

    // Desnormalizados
    private String tipoNombre;
    private String proveedorNombre;

    public Producto() {}

    public int        getIdProducto()         { return idProducto; }
    public void       setIdProducto(int v)    { this.idProducto = v; }
    public String     getNombre()            { return nombre; }
    public void       setNombre(String v)    { this.nombre = v; }
    public BigDecimal getPrecio()            { return precio; }
    public void       setPrecio(BigDecimal v){ this.precio = v; }
    public int        getIdTipoProducto()    { return idTipoProducto; }
    public void       setIdTipoProducto(int v){ this.idTipoProducto = v; }
    public Integer    getIdProveedor()       { return idProveedor; }
    public void       setIdProveedor(Integer v){ this.idProveedor = v; }
    public boolean    isActivo()             { return activo; }
    public void       setActivo(boolean v)   { this.activo = v; }
    public String     getTipoNombre()        { return tipoNombre; }
    public void       setTipoNombre(String v){ this.tipoNombre = v; }
    public String     getProveedorNombre()        { return proveedorNombre; }
    public void       setProveedorNombre(String v){ this.proveedorNombre = v; }
}

// ============================================================
//  Pedido.java
// ============================================================
class Pedido {
    private int    idPedido;
    private String estado;          // pendiente, en_preparacion, entregado, cancelado
    private Date   fechaPedido;
    private String observaciones;
    private boolean tieneAlergias;
    private int    idEmpleado;
    private int    idMesa;

    // Desnormalizados
    private String empleadoNombre;
    private int    numeroMesa;
    private List<DetallePedido> detalles;

    public Pedido() {}

    public int    getIdPedido()            { return idPedido; }
    public void   setIdPedido(int v)       { this.idPedido = v; }
    public String getEstado()             { return estado; }
    public void   setEstado(String v)     { this.estado = v; }
    public Date   getFechaPedido()         { return fechaPedido; }
    public void   setFechaPedido(Date v)   { this.fechaPedido = v; }
    public String getObservaciones()      { return observaciones; }
    public void   setObservaciones(String v){ this.observaciones = v; }
    public boolean isTieneAlergias()      { return tieneAlergias; }
    public void   setTieneAlergias(boolean v){ this.tieneAlergias = v; }
    public int    getIdEmpleado()          { return idEmpleado; }
    public void   setIdEmpleado(int v)     { this.idEmpleado = v; }
    public int    getIdMesa()              { return idMesa; }
    public void   setIdMesa(int v)         { this.idMesa = v; }
    public String getEmpleadoNombre()     { return empleadoNombre; }
    public void   setEmpleadoNombre(String v){ this.empleadoNombre = v; }
    public int    getNumeroMesa()          { return numeroMesa; }
    public void   setNumeroMesa(int v)     { this.numeroMesa = v; }
    public List<DetallePedido> getDetalles() { return detalles; }
    public void   setDetalles(List<DetallePedido> v){ this.detalles = v; }
}

// ============================================================
//  DetallePedido.java
// ============================================================
class DetallePedido {
    private int        idDetallePedido;
    private int        idPedido;
    private int        idProducto;
    private int        cantidad;
    private BigDecimal precioUnitario;
    private String     descripcion;    // alergias específicas del ítem

    // Desnormalizados
    private String     productoNombre;

    public DetallePedido() {}

    public int        getIdDetallePedido()     { return idDetallePedido; }
    public void       setIdDetallePedido(int v){ this.idDetallePedido = v; }
    public int        getIdPedido()            { return idPedido; }
    public void       setIdPedido(int v)       { this.idPedido = v; }
    public int        getIdProducto()          { return idProducto; }
    public void       setIdProducto(int v)     { this.idProducto = v; }
    public int        getCantidad()            { return cantidad; }
    public void       setCantidad(int v)       { this.cantidad = v; }
    public BigDecimal getPrecioUnitario()      { return precioUnitario; }
    public void       setPrecioUnitario(BigDecimal v){ this.precioUnitario = v; }
    public String     getDescripcion()         { return descripcion; }
    public void       setDescripcion(String v) { this.descripcion = v; }
    public String     getProductoNombre()      { return productoNombre; }
    public void       setProductoNombre(String v){ this.productoNombre = v; }
    public BigDecimal getSubtotal() { return precioUnitario.multiply(BigDecimal.valueOf(cantidad)); }
}

// ============================================================
//  Factura.java
// ============================================================
class Factura {
    private int        idFactura;
    private Date       fecha;
    private String     hora;
    private BigDecimal subtotal;
    private BigDecimal iva;
    private BigDecimal total;
    private int        idPedido;
    private int        idCliente;

    // Desnormalizados
    private String  clienteNombre;
    private String  metodoPago;
    private BigDecimal propina;

    public Factura() {}

    public int        getIdFactura()           { return idFactura; }
    public void       setIdFactura(int v)      { this.idFactura = v; }
    public Date       getFecha()               { return fecha; }
    public void       setFecha(Date v)         { this.fecha = v; }
    public String     getHora()               { return hora; }
    public void       setHora(String v)        { this.hora = v; }
    public BigDecimal getSubtotal()            { return subtotal; }
    public void       setSubtotal(BigDecimal v){ this.subtotal = v; }
    public BigDecimal getIva()                 { return iva; }
    public void       setIva(BigDecimal v)     { this.iva = v; }
    public BigDecimal getTotal()               { return total; }
    public void       setTotal(BigDecimal v)   { this.total = v; }
    public int        getIdPedido()            { return idPedido; }
    public void       setIdPedido(int v)       { this.idPedido = v; }
    public int        getIdCliente()           { return idCliente; }
    public void       setIdCliente(int v)      { this.idCliente = v; }
    public String     getClienteNombre()       { return clienteNombre; }
    public void       setClienteNombre(String v){ this.clienteNombre = v; }
    public String     getMetodoPago()          { return metodoPago; }
    public void       setMetodoPago(String v)  { this.metodoPago = v; }
    public BigDecimal getPropina()             { return propina; }
    public void       setPropina(BigDecimal v) { this.propina = v; }
}

// ============================================================
//  Reserva.java
// ============================================================
class Reserva {
    private int    idReserva;
    private Date   fechaReserva;
    private String horaReserva;
    private int    cantidadPersonas;
    private String estado;          // pendiente, confirmada, cancelada, finalizada
    private int    idCliente;
    private int    idMesa;
    private int    idRestaurante;

    // Desnormalizados
    private String clienteNombre;
    private String restauranteNombre;

    public Reserva() {}

    public int    getIdReserva()            { return idReserva; }
    public void   setIdReserva(int v)       { this.idReserva = v; }
    public Date   getFechaReserva()         { return fechaReserva; }
    public void   setFechaReserva(Date v)   { this.fechaReserva = v; }
    public String getHoraReserva()         { return horaReserva; }
    public void   setHoraReserva(String v) { this.horaReserva = v; }
    public int    getCantidadPersonas()     { return cantidadPersonas; }
    public void   setCantidadPersonas(int v){ this.cantidadPersonas = v; }
    public String getEstado()             { return estado; }
    public void   setEstado(String v)     { this.estado = v; }
    public int    getIdCliente()           { return idCliente; }
    public void   setIdCliente(int v)      { this.idCliente = v; }
    public int    getIdMesa()              { return idMesa; }
    public void   setIdMesa(int v)         { this.idMesa = v; }
    public int    getIdRestaurante()       { return idRestaurante; }
    public void   setIdRestaurante(int v)  { this.idRestaurante = v; }
    public String getClienteNombre()      { return clienteNombre; }
    public void   setClienteNombre(String v){ this.clienteNombre = v; }
    public String getRestauranteNombre()       { return restauranteNombre; }
    public void   setRestauranteNombre(String v){ this.restauranteNombre = v; }
}
