-- =========================================================
-- SISTEMA DE INVENTARIO
-- Base de datos: bd_sistema_inventario
-- Motor: MySQL 8.0+
-- =========================================================

CREATE DATABASE IF NOT EXISTS bd_sistema_inventario
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bd_sistema_inventario;

-- 1. Roles
CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

-- 2. Usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_roles
      FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. Categorías
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

-- 4. Proveedores
CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    rtn VARCHAR(30),
    telefono VARCHAR(20),
    correo VARCHAR(120),
    direccion VARCHAR(255)
) ENGINE=InnoDB;

-- 5. Productos
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    stock_minimo INT NOT NULL DEFAULT 5,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    CONSTRAINT chk_productos_precios
      CHECK (precio_compra >= 0 AND precio_venta >= 0),
    CONSTRAINT chk_productos_stock
      CHECK (stock_minimo >= 0),
    CONSTRAINT fk_productos_categorias
      FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_productos_nombre (nombre)
) ENGINE=InnoDB;

-- 6. Almacenes
CREATE TABLE IF NOT EXISTS almacenes (
    id_almacen INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(255),
    descripcion TEXT
) ENGINE=InnoDB;

-- 7. Inventario: existencia por producto y almacén
CREATE TABLE IF NOT EXISTS inventario (
    id_inventario INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_almacen INT NOT NULL,
    existencia INT NOT NULL DEFAULT 0,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_inventario_producto_almacen
      UNIQUE (id_producto, id_almacen),
    CONSTRAINT chk_inventario_existencia CHECK (existencia >= 0),
    CONSTRAINT fk_inventario_productos
      FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_inventario_almacenes
      FOREIGN KEY (id_almacen) REFERENCES almacenes(id_almacen)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. Compras
CREATE TABLE IF NOT EXISTS compras (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_compra DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado ENUM('Pendiente','Recibida','Anulada') NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT chk_compras_total CHECK (total >= 0),
    CONSTRAINT fk_compras_proveedores
      FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_compras_usuarios
      FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 9. Detalle de compras
CREATE TABLE IF NOT EXISTS detalle_compras (
    id_detalle_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_detalle_compras_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_compras_importes
      CHECK (precio_unitario >= 0 AND subtotal >= 0),
    CONSTRAINT fk_detalle_compras_compras
      FOREIGN KEY (id_compra) REFERENCES compras(id_compra)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_compras_productos
      FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_compras_compra (id_compra)
) ENGINE=InnoDB;

-- 10. Ventas
CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    metodo_pago ENUM('Efectivo','Tarjeta','Transferencia') NOT NULL DEFAULT 'Efectivo',
    estado ENUM('Completada','Anulada') NOT NULL DEFAULT 'Completada',
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    CONSTRAINT fk_ventas_usuarios
      FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11. Detalle de ventas
CREATE TABLE IF NOT EXISTS detalle_ventas (
    id_detalle_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_detalle_ventas_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_ventas_importes
      CHECK (precio_unitario >= 0 AND subtotal >= 0),
    CONSTRAINT fk_detalle_ventas_ventas
      FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_ventas_productos
      FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_ventas_venta (id_venta)
) ENGINE=InnoDB;

-- 12. Movimientos de inventario
CREATE TABLE IF NOT EXISTS movimientos_inventario (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_almacen INT NOT NULL,
    id_usuario INT NOT NULL,
    tipo_movimiento ENUM('Entrada','Salida','Ajuste') NOT NULL,
    cantidad INT NOT NULL,
    motivo VARCHAR(255),
    fecha_movimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_movimientos_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_productos
      FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_almacenes
      FOREIGN KEY (id_almacen) REFERENCES almacenes(id_almacen)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_usuarios
      FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_fecha (fecha_movimiento)
) ENGINE=InnoDB;

-- =========================================================
-- DATOS INICIALES OPCIONALES
-- =========================================================
INSERT IGNORE INTO roles (nombre, descripcion) VALUES
('Administrador', 'Acceso completo al sistema'),
('Empleado', 'Registro de compras y ventas'),
('Supervisor', 'Supervisión de operaciones e inventario');

INSERT IGNORE INTO categorias (nombre, descripcion) VALUES
('General', 'Categoría general de productos');

INSERT INTO almacenes (nombre, ubicacion, descripcion)
SELECT 'Almacén principal', 'Por definir', 'Almacén principal del negocio'
WHERE NOT EXISTS (
    SELECT 1 FROM almacenes WHERE nombre = 'Almacén principal'
);

-- =========================================================
-- VISTAS DE CONSULTA
-- =========================================================

CREATE OR REPLACE VIEW vw_inventario_actual AS
SELECT
    p.id_producto,
    p.codigo,
    p.nombre AS producto,
    c.nombre AS categoria,
    a.nombre AS almacen,
    i.existencia,
    p.stock_minimo,
    CASE
      WHEN i.existencia <= p.stock_minimo THEN 'Stock bajo'
      ELSE 'Disponible'
    END AS estado_stock
FROM inventario i
INNER JOIN productos p ON p.id_producto = i.id_producto
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
INNER JOIN almacenes a ON a.id_almacen = i.id_almacen;

CREATE OR REPLACE VIEW vw_ventas_resumen AS
SELECT
    v.id_venta,
    v.fecha_venta,
    u.nombre AS usuario,
    v.metodo_pago,
    v.total,
    v.estado
FROM ventas v
INNER JOIN usuarios u ON u.id_usuario = v.id_usuario;

-- =========================================================
-- FIN DEL SCRIPT
-- Nota: la lógica para actualizar existencias al confirmar
-- compras/ventas debe implementarse mediante transacciones,
-- procedimientos o desde el backend.
-- =========================================================
