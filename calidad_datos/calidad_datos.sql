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