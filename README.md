# Sistema de Inventario Web con Supabase

Estructura inicial para un equipo de tres personas, basada en la rúbrica de Traductores e Intérpretes II, Parcial II.

**Esta entrega contiene únicamente archivos base y comentarios de tareas. No implementa módulos, tablas ni conexión; todavía no constituye un sistema funcional ni cumple la evaluación por sí sola.**

## Archivos

| Archivo o carpeta | Uso previsto |
| --- | --- |
| index.html | Inicio y enlace al login |
| login.html | Formulario de autenticación |
| inventario.html | Formulario y tabla de productos |
| personal.html | Formulario y tabla de personal |
| proveedores.html | Formulario y tabla de proveedores |
| app.js | Conexión Supabase e integración compartida |
| css/styles.css | Estética neón y diseño responsivo |
| js/auth.js | Autenticación y sesión |
| js/inventario.js | CRUD de productos |
| js/personal.js | Registro y listado de personal |
| js/proveedores.js | Registro y consulta de proveedores |
| js/notificaciones.js | Alertas visuales compartidas |
| sql/ | Definiciones pendientes de las tres tablas |
| docs/equipo.md | Reparto sugerido y coordinación |

## Criterios de evaluación

- Participación y asistencia: 5%.
- Repositorio público ordenado, commits claros, Vercel activo y conexión Supabase en app.js: 15%.
- Login funcional y flujo index.html → login.html → inventario.html: 15%.
- Inventario responsivo, CRUD y notificaciones visuales: 20%.
- Personal, tabla SQL, interfaz, registro y listado: 22.5%.
- Proveedores, tabla SQL, interfaz, registro y consulta mediante integración en app.js: 22.5%.

## Preparación del repositorio

1. Extraer el ZIP y subir el CONTENIDO de inventario-supabase al repositorio público. index.html debe quedar en la raíz.
2. Agregar como colaboradores a los dos compañeros.
3. Cada integrante trabaja en su rama y propone sus cambios mediante un pull request.
4. Revisar e integrar en main antes de conectar el repositorio a Vercel.
5. Completar todos los archivos y registrar en este README los enlaces finales del repositorio y del despliegue.

La rúbrica no exige un framework, un package.json ni un vercel.json; no se agregan para esta estructura HTML/CSS/JavaScript.
