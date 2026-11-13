-- Inventario de Traductores e Intérpretes II
-- Ejecutar en SQL Editor de Supabase (PostgreSQL).
-- Productos sigue la estructura del docente. Proveedores adapta el modelo
-- MySQL del equipo y conserva el RTN como dato opcional.

begin;

create table if not exists public.productos (
    id serial primary key,
    nombre text not null check (length(btrim(nombre)) between 1 and 160),
    cantidad integer not null default 0 check (cantidad >= 0),
    precio numeric(10, 2) not null default 0.00 check (precio >= 0),
    creado_en timestamptz default now()
);

create table if not exists public.personal (
    identidad text primary key check (length(btrim(identidad)) between 1 and 40),
    nombres text not null check (length(btrim(nombres)) between 1 and 100),
    apellidos text not null check (length(btrim(apellidos)) between 1 and 100),
    genero text not null check (length(btrim(genero)) between 1 and 40),
    telefono text not null check (length(btrim(telefono)) between 1 and 40),
    direccion text not null check (length(btrim(direccion)) between 1 and 250)
);

create table if not exists public.proveedores (
    codigo bigint generated always as identity primary key,
    empresa text not null check (length(btrim(empresa)) between 1 and 160),
    encargado text not null check (length(btrim(encargado)) between 1 and 160),
    telefono text not null check (length(btrim(telefono)) between 1 and 40),
    direccion text not null check (length(btrim(direccion)) between 1 and 250),
    correo text not null check (length(btrim(correo)) between 3 and 254)
);

-- Agregar RTN si ya se instaló la versión anterior del proyecto.
alter table public.proveedores add column if not exists rtn text
    check (rtn is null or length(btrim(rtn)) between 1 and 30);

alter table public.productos enable row level security;
alter table public.personal enable row level security;
alter table public.proveedores enable row level security;

revoke all on public.productos, public.personal, public.proveedores from public, anon, authenticated;
grant select, insert, update, delete on public.productos to authenticated;
grant select, insert on public.personal, public.proveedores to authenticated;
grant usage on sequence public.productos_id_seq, public.proveedores_codigo_seq to authenticated;

drop policy if exists inventario_productos on public.productos;
create policy inventario_productos on public.productos
    for all to authenticated using (true) with check (true);

drop policy if exists inventario_personal_lectura on public.personal;
create policy inventario_personal_lectura on public.personal
    for select to authenticated using (true);
drop policy if exists inventario_personal_registro on public.personal;
create policy inventario_personal_registro on public.personal
    for insert to authenticated with check (true);

drop policy if exists inventario_proveedores_lectura on public.proveedores;
create policy inventario_proveedores_lectura on public.proveedores
    for select to authenticated using (true);
drop policy if exists inventario_proveedores_registro on public.proveedores;
create policy inventario_proveedores_registro on public.proveedores
    for insert to authenticated with check (true);

commit;
