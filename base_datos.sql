-- Creacion de Base Datos
--Tabla Inventario

create table public.productos (
  id serial primary key,
  nombre text not null,
  cantidad Integer not null default 0,
  precio numeric(10, 2) not null default 0.00,
  creado_en timestamp with TIME ZONE default timezone('utc'::text, now())
)
