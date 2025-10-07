CREATE DATABASE stg_jardineria;
USE stg_jardineria;

CREATE TABLE stg_empleado (
id_stg INT AUTO_INCREMENT PRIMARY KEY,
bk_empleado INT,
nombre VARCHAR(50),
apellido1 VARCHAR(50),
apellido2 VARCHAR(50),
extension VARCHAR(10),
email VARCHAR(100),
ID_oficina INT,
ID_jefe INTEGER,
puesto VARCHAR(50),
fecha_carga DATETIME,
origen VARCHAR(100),
estado_registro VARCHAR(100)
);

CREATE TABLE stg_cliente (
id_stg INT AUTO_INCREMENT PRIMARY KEY,
bk_cliente VARCHAR(50),
nombre_cliente VARCHAR(50),
nombre_contacto VARCHAR(30),
apellido_contacto VARCHAR(30),
telefono VARCHAR(15),
fax VARCHAR(15),
linea_direccion1 VARCHAR(50),
linea_direccion2 VARCHAR(50),
ciudad VARCHAR(50),
region VARCHAR(50),
pais VARCHAR(50),
codigo_postal VARCHAR(10),
ID_empleado_rep_ventas INTEGER,
limite_credito DECIMAL(15,2),
origen VARCHAR(50),
estado_registro VARCHAR(50),
fecha_carga DATETIME
);

CREATE TABLE stg_pedido (
id_stg INT AUTO_INCREMENT PRIMARY KEY,
bk_pedido INT,
fecha_pedido DATE,
fecha_esperada DATE,
fecha_entrega DATE,
estado VARCHAR(15),
comentarios TEXT,
bk_cliente INT,
origen VARCHAR(50),
fecha_carga DATETIME,
estado_registro VARCHAR(50)
);

CREATE TABLE stg_detalle_pedido (
id_stg INT AUTO_INCREMENT PRIMARY KEY,
bk_detalle_pedido INT,
bk_pedido INTEGER,
bk_producto VARCHAR(50),
cantidad INTEGER,
precio_unidad DECIMAL(15,2),
numero_linea SMALLINT,
origen VARCHAR(50),
fecha_carga DATETIME,
estado_registro VARCHAR(50)
);

CREATE TABLE stg_pago (
id_stg INT AUTO_INCREMENT PRIMARY KEY,
bk_pago INT,
bk_cliente INT,
forma_pago VARCHAR(40),
bk_transaccion VARCHAR(50),
fecha_pago DATE,	
total NUMERIC(15,2),
origen VARCHAR(50),
fecha_carga DATETIME,
estado_registro VARCHAR(50)
);

CREATE TABLE stg_producto (
id_stg INT AUTO_INCREMENT PRIMARY KEY,
bk_producto VARCHAR(50),
nombre VARCHAR(100),
Categoria int, 
dimensiones varchar(25), 
proveedor varchar(50), 
descripcion text, 
cantidad_en_stock smallint, 
precio_venta decimal(15,2), 
precio_proveedor decimal(15,2),
origen VARCHAR(50),
fecha_carga DATETIME,
estado_registro VARCHAR(50)
);
-- consultas de registros

INSERT INTO stg_empleado (bk_empleado, nombre, apellido1, apellido2, extension, email, ID_oficina, ID_jefe, puesto, fecha_carga, origen, estado_registro )
SELECT 
ID_empleado AS bk_empleado,
nombre, 
apellido1,
apellido2,
extension,
email,
ID_oficina,
ID_jefe,
puesto,
NOW() AS fecha_carga,
"OLAP jardineria" AS origen,
"activo" AS estado_registro
FROM jardineria.empleado;


INSERT INTO stg_cliente (bk_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, fax, linea_direccion1, linea_direccion2, ciudad, region, pais, codigo_postal, ID_empleado_rep_ventas, limite_credito, origen, estado_registro, fecha_carga)
SELECT 
ID_cliente AS bk_cliente,
nombre_cliente,
nombre_contacto,
apellido_contacto,
telefono,
fax,
linea_direccion1,
linea_direccion2,
ciudad, 
region,
pais,
codigo_postal,
ID_empleado_rep_ventas,
limite_credito,
"OLAP jardineria" AS origen,
"activo" AS estado_registro, 
NOW() AS fecha_carga
FROM jardineria.cliente; 

INSERT INTO stg_pedido (bk_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, bk_cliente, origen, fecha_carga, estado_registro)
SELECT 
ID_pedido AS bk_pedido,
fecha_pedido,
fecha_esperada,
fecha_entrega,
estado,
comentarios,
ID_cliente AS bk_cliente,
"OLAP jardineria" AS origen,
NOW() AS fecha_carga,
"activo" AS estado_registro
FROM jardineria.pedido;

INSERT INTO stg_detalle_pedido (bk_detalle_pedido, bk_pedido, bk_producto, cantidad, precio_unidad, numero_linea, origen, fecha_carga, estado_registro)
SELECT 
ID_pedido "-", ID_producto "-", numero_linea AS bk_detalle_pedido, 
cantidad,
precio_unidad,
numero_linea,
"OLAP jardineria" AS origen,
NOW() AS fecha_carga,
"activo" AS estado_registro
FROM jardineria.detalle_pedido;

INSERT INTO stg_pago (bk_pago, bk_cliente, forma_pago, bk_transaccion, fecha_pago, total, origen, fecha_carga, estado_registro)
SELECT 
ID_pago, ID_cliente, id_transaccion AS bk_pago,
forma_pago,
fecha_pago,
total,
"OLAP jardineria" AS origen,
NOW() AS fecha_carga,
"activo" AS estado_registro
FROM jardineria.pago;

INSERT INTO stg_producto (bk_producto, nombre, Categoria, dimensiones, proveedor, descripcion, cantidad_en_stock, precio_venta, precio_proveedor, origen, fecha_carga, estado_registro)
SELECT 
CodigoProducto AS bk_producto,
nombre,
Categoria,
dimensiones,
proveedor,
descripcion,
cantidad_en_stock,
precio_venta,
precio_proveedor,
"OLAP jardineria" AS origen,
NOW() AS fecha_carga,
"activo" AS estado_registro
FROM jardineria.producto;

SELECT * FROM stg_cliente;
SELECT * FROM stg_empleado;
SELECT * FROM stg_pedido;
SELECT * FROM stg_detalle_pedido;
SELECT * FROM dtg_pago;
SELECT * FROM stg_producto;