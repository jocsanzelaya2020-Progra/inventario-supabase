# Inventario de Traductores e Intérpretes II

Proyecto del segundo parcial basado en el inicio, el panel neón y el módulo de productos del docente. El flujo de acceso es `index.html → login.html → inventario.html`. El panel enlaza a Personal y Proveedores.

## Configurar Supabase

1. Usa un proyecto de Supabase dedicado al inventario. En **SQL Editor**, ejecuta `bd_sistema_inventario.sql` completo. Si ya existe `productos` con la estructura del docente, el script conserva sus datos y agrega los permisos del sistema. Si ya instalaste el ZIP anterior, ejecuta el script actualizado para agregar el RTN opcional a proveedores.
2. En **Authentication**, desactiva el registro público de cuentas y crea las cuentas de evaluación desde **Users**. Habilita el inicio de sesión con correo y contraseña. Todas las cuentas autenticadas del proyecto comparten acceso a los registros de inventario, personal y proveedores.
3. Copia la URL del proyecto y la clave pública **publishable** o **anon** en `SUPABASE_URL` y `SUPABASE_ANON_KEY` dentro de `app.js`. Usa únicamente una clave pública del proyecto en el navegador.
4. Abre el proyecto con un servidor local, por ejemplo ejecutando `python -m http.server 8000` en esta carpeta. Abre `http://localhost:8000`.

Documentación de [inicio de sesión de Supabase](https://supabase.com/docs/reference/javascript/auth-signinwithpassword).

## Aporte del equipo y adaptación a Supabase

| Modelo MySQL del compañero | Esquema utilizado por la aplicación |
| --- | --- |
| `productos.id_producto`, `precio_venta` e inventario por almacén | `productos.id`, `precio` y `cantidad`, según el código del docente. |
| `proveedores.id_proveedor`, `nombre` y `rtn` | `codigo` autogenerado, `empresa` y RTN opcional. También incluye encargado, teléfono, dirección y correo. |
| Usuarios y roles en tablas propias | Cuentas administradas en Supabase Auth. |
| Compras, ventas, categorías, almacenes, movimientos y vistas | Se conservan en el diseño de referencia del equipo en `docs/modelo-mysql/`. |
| Sin tabla de personal | Tabla `personal` con identidad única de tipo texto y los campos de la rúbrica. |

Para la aplicación, ejecuta únicamente `bd_sistema_inventario.sql` de la raíz. Los archivos MySQL en `docs/modelo-mysql/` documentan el aporte original. El ZIP contiene definiciones de tablas y carece de registros para migrar.

## Publicar

1. Sube el contenido de esta carpeta a un repositorio público de GitHub con `index.html` en la raíz y conserva commits descriptivos.
2. Importa el repositorio en Vercel y selecciona **Other** en **Framework Preset**. Para servir los archivos de la raíz, deja vacío **Build Command** con la opción de anulación activada.
3. Guarda los enlaces del repositorio y del despliegue en este README.

Documentación de [configuración de proyectos estáticos en Vercel](https://vercel.com/docs/builds/configure-a-build).

## Verificación de la rúbrica

| Criterio | Prueba en el despliegue |
| --- | --- |
| GitHub, Vercel y Supabase (15 %) | Abre ambos enlaces, inicia sesión y comprueba que un registro de prueba aparece en Supabase. |
| Autenticación (15 %) | Intenta entrar con contraseña incorrecta, luego con la correcta. Cierra sesión y comprueba que el panel vuelve al login. |
| Inventario (20 %) | Crea un producto, recarga, edita su cantidad y elimínalo. Comprueba los avisos y la tabla en móvil. |
| Personal (22.5 %) | Registra y lista una identidad ficticia con ceros iniciales. Intenta registrarla de nuevo para comprobar el aviso de duplicado. |
| Proveedores (22.5 %) | Registra y lista un proveedor. Comprueba que la base de datos asigna el código. Prueba con y sin RTN. |

El 5 % de asistencia y participación lo evalúa el docente. Usa datos ficticios para las pruebas de evaluación.
