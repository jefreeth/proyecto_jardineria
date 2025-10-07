	CREATE DATABASE dw_jardineria;
    USE dw_jardineria;
    
    #CREACION DE LAS TABLAS DIMENSIONALES Y TABLA HECHOS
    
    CREATE TABLE dim_empleado (
    id_empleado_dim INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    bk_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    id_jefe INT 
    );
    
    CREATE TABLE dim_cliente (
    id_cliente_dim INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    bk_cliente VARCHAR(50) NOT NULL,
    nombre_cliente VARCHAR(50) NOT NULL,
    nombre_contacto VARCHAR(50) NOT NULL,
    apellido_contacto VARCHAR(50) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    region VARCHAR(50) ,
    pais VARCHAR(20) NOT NULL,
    limite_credito DECIMAL(10,2) NOT NULL
    );
    
  CREATE TABLE dim_producto (
  id_producto_dim INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  bk_producto VARCHAR(50) NOT NULL,
  nombre VARCHAR(100),
  Categoria INT NOT NULL,
  dimensiones VARCHAR(25) NOT NULL,
  proveedor VARCHAR(50) NOT NULL,
  descripcion TEXT NOT NULL,
  cantidad_en_stock smallint,
  precio_venta DECIMAL(10,2) NOT NULL,
  precio_proveedor DECIMAL(10,2) NOT NULL
  );

CREATE TABLE dim_tiempo (
id_tiempo INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
fecha DATE NOT NULL UNIQUE,
anio INT NOT NULL,
semestre TINYINT NOT NULL,
trimestre TINYINT NOT NULL,
mes TINYINT NOT NULL,
nombre_mes VARCHAR(20) NOT NULL,
dia_mes TINYINT NOT NULL,
nombre_dia VARCHAR(20) NOT NULL,
numero_semana TINYINT NOT NULL
);

CREATE TABLE fact_pedido (
id_fact_pedido INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
bk_pedido VARCHAR(50) NOT NULL,
id_cliente_dim INT  NOT NULL,
id_producto_dim VARCHAR(50) NOT NULL ,
id_tiempo_pedido INT NOT NULL,
id_fecha_esperada INT NOT NULL,
id_fecha_entrega INT NOT NULL,
precio_unidad DECIMAL(10,2) NOT NULL,
total DECIMAL (10,2) NOT NULL,
descuento DECIMAL (10,2) NOT NULL,
cantidad INT NOT NULL,
estado VARCHAR(50) NOT NULL
); 

CREATE TABLE fact_pago (
id_pago_dim INT AUTO_INCREMENT PRIMARY KEy NOT NULL,
id_cliente_dim INT NOT NULL,
id_tiempo INT NOT NULL,
bk_pago VARCHAR(50) NOT NULL,
bk_cliente VARCHAR(50)NOT NULL,
bk_transaccion VARCHAR(50) NOT NULL,
forma_pago VARCHAR(40) NOT NULL,
monto_pago DECIMAL(10,2) NOT NULL
);

# CONSULTAS PARA INSERTAR LOS DATOS

INSERT INTO dim_cliente (bk_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, region, pais, limite_credito)
SELECT 
bk_cliente, 
nombre_cliente,
nombre_contacto,
apellido_contacto,
telefono,
ciudad,
region,
pais,
limite_credito
FROM stg_jardineria.stg_cliente;

INSERT INTO dim_empleado (bk_empleado, nombre, apellido1, apellido2, email, id_jefe)
SELECT 
bk_empleado,
nombre,
apellido1,
apellido2,
email,
id_jefe
FROM stg_jardineria.stg_empleado;

truncate dim_producto
INSERT INTO dim_producto (bk_producto, nombre, Categoria, dimensiones, proveedor, descripcion, cantidad_en_stock, precio_venta, precio_proveedor)
SELECT 
sp.bk_producto,
sp.nombre,
sp.Categoria,
sp.dimensiones,
sp.proveedor,
sp.descripcion,
sp.cantidad_en_stock,
sp.precio_venta,
sp.precio_proveedor
FROM stg_jardineria.stg_producto sp

DELIMITER $$

CREATE PROCEDURE poblar_dim_tiempo(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN 
DECLARE fecha_actual DATE;

SET fecha_actual = fecha_inicio;

WHILE fecha_actual <= fecha_fin DO 
INSERT INTO dim_tiempo (fecha, anio, semestre, trimestre, mes, nombre_mes, dia_mes, nombre_dia, numero_semana)
VALUES (
fecha_actual, 
YEAR (fecha_actual),
IF(MONTH(fecha_actual) <= 6, 1, 2),
QUARTER(fecha_actual),
MONTH(fecha_actual),
MONTHNAME(fecha_actual),
DAY(fecha_actual),
DAYNAME(fecha_actual),
WEEK(fecha_actual, 1)
);

SET fecha_actual = DATE_ADD(fecha_actual, INTERVAL 1 DAY);
END WHILE;
END $$

DELIMITER ;

INSERT INTO fact_pago (id_cliente_dim,id_tiempo, bk_pago, bk_cliente, bk_transaccion, forma_pago, monto_pago)
SELECT 
dc.id_cliente_dim,
dt.id_tiempo,
sp.bk_pago,
sp.bk_cliente,
sp.bk_transaccion,
sp.forma_pago,
sp.total
FROM stg_jardineria.stg_pago sp
JOIN dim_cliente dc
ON dc.id_cliente_dim = sp.bk_cliente
JOIN dim_tiempo dt
ON sp.fecha_pago = dt.fecha;

INSERT INTO fact_pedido (bk_pedido, id_cliente_dim, id_producto_dim, id_tiempo_pedido, id_fecha_esperada, id_fecha_entrega, precio_unidad, descuento, cantidad, total, estado)
SELECT 	
sp.bk_pedido,
dc.id_cliente_dim, 
dp.id_producto_dim,
dt_pedido.id_tiempo AS id_tiempo_pedido,
dt_esperada.id_tiempo AS id_fecha_esperada,
dt_entrega.id_tiempo AS id_fecha_entrega, 
sdp.precio_unidad,
0 AS descuento,
sdp.cantidad,
(sdp.cantidad * sdp.precio_unidad) AS total,
sp.estado
FROM stg_jardineria.stg_detalle_pedido sdp
JOIN stg_jardineria.stg_pedido sp
ON sdp.bk_pedido = sp.bk_pedido
JOIN dim_cliente dc
ON dc.bk_cliente = sp.bk_cliente
JOIN dim_producto dp
ON dp.id_producto_dim = sdp.bk_producto
JOIN dim_tiempo dt_pedido
ON sp.fecha_pedido = dt_pedido.fecha
JOIN dim_tiempo dt_esperada
ON sp.fecha_esperada = dt_esperada.fecha
JOIN dim_tiempo dt_entrega 
ON sp.fecha_entrega = dt_entrega.fecha;

SELECT * FROM dim_cliente;
SELECT * FROM dim_empleado;
SELECT * FROM dim_producto;
SELECT * FROM dim_tiempo;
SELECT * FROM fact_pago;
SELECT * FROM fact_pedido;


-- Verificar valores nulos en clientes
SELECT * FROM stg_cliente
WHERE nombre_cliente IS NULL OR telefono IS NULL;

-- Buscar duplicados en empleados
SELECT bk_empleado, COUNT(*) AS total
FROM stg_empleado
GROUP BY bk_empleado
HAVING COUNT(*) > 1;

-- Validar pedidos con fechas inconsistentes
SELECT bk_pedido, fecha_pedido, fecha_esperada, fecha_entrega
FROM stg_pedido
WHERE fecha_entrega < fecha_pedido;

-- Revisar precios negativos o nulos
SELECT * FROM stg_producto
WHERE precio_venta <= 0 OR precio_proveedor <= 0;