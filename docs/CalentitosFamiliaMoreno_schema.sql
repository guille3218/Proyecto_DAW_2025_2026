-- =====================================================
-- Base de datos: CalentitosFamiliaMoreno
-- Descripción: Sistema simple de gestión de usuarios, productos y pedidos
-- Fecha: 2026-02-13
-- =====================================================

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS CalentitosFamiliaMoreno
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE CalentitosFamiliaMoreno;

-- =====================================================
-- TABLA: usuarios
-- Descripción: Almacena información básica de los usuarios
-- =====================================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    rol ENUM('cliente', 'admin') DEFAULT 'cliente',
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_estado (estado)
) ENGINE=InnoDB;

-- =====================================================
-- TABLA: auth
-- Descripción: Gestiona la autenticación de usuarios (separada de datos personales)
-- =====================================================
CREATE TABLE auth (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    ultimo_login TIMESTAMP NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_username (username),
    INDEX idx_usuario_id (usuario_id)
) ENGINE=InnoDB;

-- =====================================================
-- TABLA: productos
-- Descripción: Catálogo de productos disponibles
-- =====================================================
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(100),
    codigo_sku VARCHAR(50) UNIQUE,
    stock_actual INT DEFAULT 0,
    imagen_url VARCHAR(500),
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (categoria),
    INDEX idx_codigo_sku (codigo_sku),
    INDEX idx_estado (estado)
) ENGINE=InnoDB;

-- =====================================================
-- TABLA: pedidos
-- Descripción: Gestiona los pedidos realizados por los usuarios
-- =====================================================
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    estado ENUM('pendiente', 'confirmado', 'preparando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    subtotal DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    metodo_pago ENUM('efectivo', 'tarjeta', 'transferencia', 'bizum') NOT NULL,
    direccion_envio TEXT,
    telefono_contacto VARCHAR(20),
    notas TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_numero_pedido (numero_pedido),
    INDEX idx_estado (estado),
    INDEX idx_fecha_creacion (fecha_creacion)
) ENGINE=InnoDB;

-- =====================================================
-- TABLA: pedido_detalles
-- Descripción: Detalles de los productos incluidos en cada pedido
-- =====================================================
CREATE TABLE pedido_detalles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    INDEX idx_pedido_id (pedido_id),
    INDEX idx_producto_id (producto_id)
) ENGINE=InnoDB;

-- =====================================================
-- DATOS DE EJEMPLO
-- =====================================================

-- Insertar usuarios de ejemplo
INSERT INTO usuarios (nombre, apellidos, email, telefono, direccion, rol) VALUES
('Juan', 'Pérez García', 'juan.perez@email.com', '612345678', 'Calle Mayor 123, Madrid', 'cliente'),
('María', 'González López', 'maria.gonzalez@email.com', '687654321', 'Avenida Libertad 45, Barcelona', 'cliente'),
('Admin', 'Sistema', 'admin@calentitos.com', '600000000', 'Sede Central', 'admin');

-- Insertar autenticación para los usuarios
INSERT INTO auth (usuario_id, username, password_hash) VALUES
(1, 'juanperez', '$2y$10$example_hash_1'),
(2, 'mariagonzalez', '$2y$10$example_hash_2'),
(3, 'admin', '$2y$10$example_hash_admin');

-- Insertar productos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, categoria, codigo_sku, stock_actual) VALUES
('Calentito Familiar Especial', 'Calentito casero con ingredientes tradicionales de la familia Moreno', 12.50, 'Platos Principales', 'CAL-FAM-001', 50),
('Calentito Vegetariano', 'Delicioso calentito con verduras frescas de temporada', 10.00, 'Platos Principales', 'CAL-VEG-001', 30),
('Bebida Tradicional', 'Bebida artesanal de la casa', 3.50, 'Bebidas', 'BEB-TRAD-001', 100),
('Postre Casero', 'Postre tradicional de la familia', 5.00, 'Postres', 'POS-CAS-001', 25);