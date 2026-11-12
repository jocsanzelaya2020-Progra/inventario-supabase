# Base de datos — Sistema de Inventario

## Contenido
- `bd_sistema_inventario.sql`: crea la base de datos, sus 12 tablas, claves foráneas, índices, datos iniciales y vistas.

## Requisitos
- MySQL 8.0 o superior.
- MySQL Workbench, phpMyAdmin o cliente MySQL.

## Cómo instalar
1. Abrir MySQL Workbench y conectarse al servidor.
2. Abrir el archivo `bd_sistema_inventario.sql`.
3. Ejecutar el script completo.
4. Actualizar el panel **Schemas** y comprobar que aparece `bd_sistema_inventario`.

También puede ejecutarse desde la terminal:

```bash
mysql -u root -p < bd_sistema_inventario.sql
```

## Tablas incluidas
1. `roles`
2. `usuarios`
3. `categorias`
4. `proveedores`
5. `productos`
6. `almacenes`
7. `inventario`
8. `compras`
9. `detalle_compras`
10. `ventas`
11. `detalle_ventas`
12. `movimientos_inventario`

## Vistas incluidas
- `vw_inventario_actual`: existencia por producto y almacén, con indicador de stock bajo.
- `vw_ventas_resumen`: resumen de ventas con el usuario que registró cada operación.

## Relaciones principales
- Un rol puede estar asignado a muchos usuarios.
- Una categoría puede contener muchos productos.
- Un producto puede tener existencias en distintos almacenes.
- Una compra pertenece a un proveedor y a un usuario; contiene varios detalles.
- Una venta pertenece a un usuario; contiene varios detalles.
- Los movimientos registran producto, almacén, usuario, tipo y cantidad.

## Importante para el equipo
Este repositorio contiene únicamente la parte de base de datos. La actualización automática de existencias al recibir compras, completar ventas o anular operaciones debe implementarse con transacciones en el backend o mediante procedimientos y triggers acordados por el equipo.

No guardar contraseñas en texto plano. El backend debe almacenar hashes seguros (por ejemplo, Argon2 o bcrypt) en `usuarios.contrasena`.

## Trabajo en Git
Agregar esta carpeta al repositorio compartido y realizar commit:

```bash
git add BaseDeDatos/
git commit -m "Agregar base de datos del sistema de inventario"
git push
```
