# 🍽️ RestauranteApp — Sabor Distrital

Sistema de gestión web para una cadena internacional de restaurantes, desarrollado como proyecto académico de Programación Avanzada. Implementa una arquitectura MVC sobre Java EE, con control de acceso por roles para administración, operación de sede y clientes.

## 🎯 Objetivo

Desarrollar una aplicación web multirol que permitiera gestionar pedidos, facturación, inventario, reservas, reseñas y finanzas de múltiples sedes, utilizando una arquitectura cliente-servidor con conexión a base de datos MySQL.

## ⚙️ Tecnologías utilizadas

- Java 17
- Jakarta/Java Servlets (javax.servlet 4.0)
- JSP + JSTL
- JDBC
- MySQL (mysql-connector-j)
- Apache Maven
- Apache Tomcat 9/10
- HTML5, CSS3, JavaScript

## ✨ Funcionalidades principales

- Inicio de sesión con redirección según rol (Super Admin, Admin General, Admin de Punto, Cajero, Cocinero, Mesero, Cliente, Inversionista).
- Gestión de pedidos y su seguimiento (creación, cocina, entrega).
- Generación y consulta de facturas.
- Gestión de inventario, incluyendo alertas de stock bajo y productos por vencer.
- Gestión de productos y disponibilidad de platos.
- Reservas de mesas.
- Reseñas y encuestas de clientes.
- Gestión de empleados y administradores.
- Panel de finanzas y finanzas globales multisede.
- Gestión de sedes (restaurantes) a nivel de Super Admin.
- Páginas de error personalizadas (403, 404, 500).

## 👥 Roles del sistema

| Rol | Vista principal |
|--------|--------|
| Super Admin | Gestión de sedes, administradores generales y finanzas globales |
| Admin General | Dashboard, empleados, finanzas, clientes, contratos, reseñas, novedades, propinas |
| Admin de Punto | Dashboard de sede, inventario, productos, facturas, reservas, pedidos |
| Cajero | Generación de facturas, historial, pedidos listos |
| Cocinero | Pedidos, recetas, alergias |
| Mesero | Pedidos, facturas asociadas |
| Cliente | Menú, pedidos, reservas, reseñas, encuesta |
| Inversionista | Dashboard de indicadores |

## 📚 Aprendizajes obtenidos

Durante este proyecto fortalecí conocimientos en:

- Arquitectura MVC con Servlets y JSP.
- Control de acceso y sesiones por rol.
- Patrón DAO para acceso a datos con JDBC.
- Diseño y gestión de bases de datos relacionales en MySQL.
- Arquitectura cliente-servidor.
- Manejo de errores y páginas de error personalizadas.
- Trabajo colaborativo mediante Git y GitHub.

## 👥 Autores

| **Nombre** | **Código** |
|--------|--------|
| Johan Emanuel Rodriguez Romero | 20222578102 |
| Juan Esteban Garcia Parra | _(pendiente de código)_ |

---

## 📁 Estructura del proyecto

```
RestauranteApp/
├── pom.xml                      ← Configuración Maven (dependencias y build)
├── nb-configuration.xml         ← Configuración del proyecto en NetBeans
│
└── src/main/
    ├── java/com/restaurante/
    │   ├── controlador/         ← Servlets (un servlet por módulo/rol)
    │   │   ├── LoginServlet.java
    │   │   ├── LogoutServlet.java
    │   │   ├── DashboardServlet.java
    │   │   ├── SuperAdminServlet.java
    │   │   ├── AdminGenServlet.java
    │   │   ├── EmpleadoServlet.java
    │   │   ├── ClienteServlet.java
    │   │   ├── ProductoServlet.java
    │   │   ├── PedidoServlet.java
    │   │   ├── FacturaServlet.java
    │   │   ├── CajeroServlet.java
    │   │   ├── InventarioServlet.java
    │   │   ├── ReservaServlet.java
    │   │   ├── ResenaServlet.java
    │   │   └── FinanzasServlet.java
    │   │
    │   ├── modelo/
    │   │   ├── bean/             ← Beans de datos (POJO)
    │   │   │   ├── Persona.java
    │   │   │   ├── Empleado.java
    │   │   │   └── BeansPrincipales.java
    │   │   └── dao/              ← Acceso a datos (patrón DAO + JDBC)
    │   │       ├── UsuarioDAO.java
    │   │       ├── EmpleadoDAO.java
    │   │       ├── ProductoDAO.java
    │   │       ├── PedidoDAO.java
    │   │       ├── FacturaDAO.java
    │   │       ├── InventarioDAO.java
    │   │       ├── ReservaDAO.java
    │   │       └── FinanzasDAO.java
    │   │
    │   └── util/
    │       ├── ConexionDB.java   ← Conexión JDBC a MySQL (Singleton)
    │       └── SesionUtil.java   ← Utilidades de manejo de sesión
    │
    └── webapp/
        ├── index.jsp
        ├── META-INF/context.xml
        ├── WEB-INF/
        │   ├── web.xml
        │   └── vistas/
        │       ├── shared/          ← login, error, acceso-denegado, etc.
        │       ├── superadmin/
        │       ├── admingen/
        │       ├── adminpunto/
        │       ├── cajero/
        │       ├── cocinero/
        │       ├── mesero/
        │       ├── cliente/
        │       └── inversionista/
        ├── css/
        │   ├── style.css
        │   └── login.css
        └── js/
            ├── main.js
            └── login.js
```

---

## 🚀 Pasos para correr el proyecto

### 1. Instalar Java 17 y Maven
Verifica las versiones:
```bash
java -version
mvn -version
```

### 2. Instalar Apache Tomcat (9 o 10)
Descarga desde https://tomcat.apache.org y configúralo en tu IDE (NetBeans/Eclipse) o de forma standalone.

### 3. Crear la base de datos en MySQL
Abre MySQL Workbench o la terminal de MySQL y ejecuta:
```sql
CREATE DATABASE restaurante_db;
```
> Importa el script de creación de tablas (PERSONA, EMPLEADO, TIPO_USUARIO, RESTAURANTE, PRODUCTO, PEDIDO, FACTURA, etc.) si se incluye en el proyecto.

### 4. Configurar credenciales de conexión
Edita `src/main/java/com/restaurante/util/ConexionDB.java`:
```java
private static final String URL      = "jdbc:mysql://localhost:3306/restaurante_db?useSSL=false&serverTimezone=America/Bogota&characterEncoding=UTF-8";
private static final String USUARIO  = "root";
private static final String PASSWORD = "tu_contraseña_aqui";
```

### 5. Compilar el proyecto
```bash
mvn clean package
```
Esto genera el archivo `RestauranteApp.war` en la carpeta `target/`.

### 6. Desplegar en Tomcat
Copia el `.war` generado a la carpeta `webapps/` de Tomcat, o despliega directamente desde tu IDE (NetBeans: "Run" sobre el proyecto con el servidor configurado).

### 7. Abrir en el navegador
```
http://localhost:8080/RestauranteApp/
```

---

## 🗄️ Tablas principales de la base de datos

```
PERSONA         → idPersona, nombre, apellido, telefono, correo,
                  fechaNacimiento, direccion, tipoPersona
EMPLEADO        → idEmpleado, idPersona, idTipoUsuario, idRestaurante,
                  salario, cargo, fechaIngreso, estado
TIPO_USUARIO    → id, nombre (rol: SUPERADMIN, ADMINGEN, ADMINPUNTO,
                  CAJERO, COCINERO, MESERO, CLIENTE, INVERSIONISTA)
RESTAURANTE     → id, nombre, sede, ...
PRODUCTO        → id, nombre, precio, disponibilidad, ...
PEDIDO          → id, idCliente, idProducto, estado, ...
FACTURA         → id, idPedido, idEmpleado, total, fecha, ...
RESERVA         → id, idCliente, fecha, mesa, ...
RESEÑA          → id, idCliente, comentario, calificación, ...
```

---
