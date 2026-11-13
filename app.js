const SUPABASE_URL = "https://TU_PROYECTO.supabase.co";
const SUPABASE_ANON_KEY = "TU_CLAVE_PUBLICA";
let supabaseClient;

function mostrarNotificacion(mensaje, tipo = "success") {
    document.getElementById("notification")?.remove();
    const aviso = document.createElement("div");
    aviso.id = "notification";
    aviso.setAttribute("role", tipo === "success" ? "status" : "alert");
    const color = tipo === "success"
        ? "bg-emerald-950 border-emerald-500 text-emerald-200"
        : "bg-red-950 border-red-500 text-red-200";
    aviso.className = `fixed bottom-4 right-4 left-4 sm:left-auto z-50 rounded-xl border p-4 shadow-xl ${color}`;
    aviso.textContent = mensaje;
    document.body.append(aviso);
    setTimeout(() => aviso.remove(), 5000);
}

function crearCelda(fila, valor) {
    const celda = fila.insertCell();
    celda.className = "p-2 break-words";
    celda.textContent = valor ?? "";
    return celda;
}

function estadoTabla(tabla, columnas, mensaje) {
    tabla.replaceChildren();
    crearCelda(tabla.insertRow(), mensaje).colSpan = columnas;
}

function prepararLogin(formulario) {
    const boton = formulario.querySelector("button");
    const estado = document.getElementById("loginStatus");
    formulario.addEventListener("submit", async evento => {
        evento.preventDefault();
        boton.disabled = true;
        estado.textContent = "Verificando credenciales…";
        try {
            const { error } = await supabaseClient.auth.signInWithPassword({
                email: formulario.elements.email.value.trim(),
                password: formulario.elements.password.value
            });
            if (error) {
                estado.textContent = error.code === "invalid_credentials"
                    ? "El correo o la contraseña son incorrectos."
                    : "No se pudo iniciar sesión. Verifica la cuenta y la conexión.";
                mostrarNotificacion(estado.textContent, "error");
                return;
            }
            location.replace("inventario.html");
        } catch {
            estado.textContent = "No se pudo conectar con Supabase.";
            mostrarNotificacion(estado.textContent, "error");
        } finally {
            boton.disabled = false;
        }
    });
}

async function cargarInventario() {
    const tabla = document.getElementById("productTableBody");
    estadoTabla(tabla, 4, "Cargando inventario…");
    const { data, error } = await supabaseClient.from("productos")
        .select("id,nombre,cantidad,precio").order("id", { ascending: false });
    if (error || !data.length) {
        estadoTabla(tabla, 4, error ? "No se pudo cargar el inventario." : "No hay productos registrados.");
        return;
    }
    tabla.replaceChildren();
    for (const producto of data) {
        const fila = tabla.insertRow();
        crearCelda(fila, producto.nombre);
        crearCelda(fila, producto.cantidad);
        crearCelda(fila, `L ${Number(producto.precio).toFixed(2)}`);
        const acciones = crearCelda(fila, "");
        acciones.className = "p-2 flex flex-wrap gap-2";
        const editar = document.createElement("button");
        editar.type = "button";
        editar.className = "rounded border border-amber-500/40 px-2 py-1 text-amber-300";
        editar.textContent = "Editar";
        editar.addEventListener("click", () => prepararEdicion(producto));
        const eliminar = document.createElement("button");
        eliminar.type = "button";
        eliminar.className = "rounded border border-red-500/40 px-2 py-1 text-red-300";
        eliminar.textContent = "Eliminar";
        eliminar.addEventListener("click", () => eliminarProducto(producto.id));
        acciones.append(editar, eliminar);
    }
}

let idProductoEditando = null;

function prepararEdicion(producto) {
    const formulario = document.getElementById("productForm");
    if (formulario.querySelector('[type="submit"]').disabled) return;
    idProductoEditando = producto.id;
    for (const campo of ["nombre", "cantidad", "precio"]) {
        formulario.elements[campo].value = producto[campo];
    }
    formulario.querySelector('[type="submit"]').textContent = "Actualizar producto";
    document.getElementById("cancelEdit").hidden = false;
    formulario.elements.nombre.focus();
}

function restablecerProducto() {
    const formulario = document.getElementById("productForm");
    idProductoEditando = null;
    formulario.reset();
    formulario.querySelector('[type="submit"]').textContent = "Guardar producto";
    document.getElementById("cancelEdit").hidden = true;
}

function eliminarProducto(id) {
    const dialogo = document.getElementById("deleteDialog");
    dialogo.returnValue = "";
    dialogo.addEventListener("close", async () => {
        if (dialogo.returnValue !== "delete") return;
        const { data, error } = await supabaseClient.from("productos").delete().eq("id", id).select("id");
        if (error || !data.length) {
            mostrarNotificacion("No se pudo eliminar el producto.", "error");
            return;
        }
        if (idProductoEditando === id) restablecerProducto();
        mostrarNotificacion("Producto eliminado.");
        await cargarInventario();
    }, { once: true });
    dialogo.showModal();
}

function prepararInventario() {
    const formulario = document.getElementById("productForm");
    const boton = formulario.querySelector('[type="submit"]');
    document.getElementById("cancelEdit").addEventListener("click", () => {
        if (!boton.disabled) restablecerProducto();
    });
    formulario.addEventListener("submit", async evento => {
        evento.preventDefault();
        const producto = {
            nombre: formulario.elements.nombre.value.trim(),
            cantidad: formulario.elements.cantidad.valueAsNumber,
            precio: formulario.elements.precio.valueAsNumber
        };
        if (!producto.nombre) {
            mostrarNotificacion("Escribe el nombre del producto.", "error");
            return;
        }
        boton.disabled = true;
        try {
            const tabla = supabaseClient.from("productos");
            const operacion = idProductoEditando === null
                ? tabla.insert(producto)
                : tabla.update(producto).eq("id", idProductoEditando);
            const { data, error } = await operacion.select("id");
            if (error || !data.length) {
                mostrarNotificacion("No se pudo guardar el producto.", "error");
                return;
            }
            restablecerProducto();
            mostrarNotificacion("Producto guardado.");
            await cargarInventario();
        } finally {
            boton.disabled = false;
        }
    });
    return cargarInventario();
}

function prepararRegistros(modulo) {
    const formulario = document.getElementById("recordForm");
    const tabla = document.getElementById("recordTableBody");
    const boton = formulario.querySelector('[type="submit"]');
    const entradas = Array.from(formulario.querySelectorAll("input"));
    const campos = entradas.map(input => input.name);
    const columnas = modulo === "proveedores" ? ["codigo", ...campos] : campos;
    const orden = modulo === "proveedores" ? "codigo" : "apellidos";

    async function cargarRegistros() {
        estadoTabla(tabla, columnas.length, "Cargando registros…");
        const { data, error } = await supabaseClient.from(modulo).select(columnas.join(",")).order(orden);
        if (error || !data.length) {
            estadoTabla(tabla, columnas.length, error ? "No se pudieron cargar los registros." : "Aún no hay registros.");
            return;
        }
        tabla.replaceChildren();
        for (const registro of data) {
            const fila = tabla.insertRow();
            for (const campo of columnas) crearCelda(fila, registro[campo]);
        }
    }

    formulario.addEventListener("submit", async evento => {
        evento.preventDefault();
        const registro = Object.fromEntries(entradas.map(input => [input.name, input.value.trim() || null]));
        if (entradas.some(input => input.required && !registro[input.name])) {
            mostrarNotificacion("Completa todos los campos.", "error");
            return;
        }
        boton.disabled = true;
        try {
            const { error } = await supabaseClient.from(modulo).insert(registro);
            if (error) {
                const mensaje = error.code === "23505" && modulo === "personal"
                    ? "Ya existe un registro con esa identidad."
                    : "No se pudo guardar el registro.";
                mostrarNotificacion(mensaje, "error");
                return;
            }
            formulario.reset();
            mostrarNotificacion("Registro guardado.");
            await cargarRegistros();
        } finally {
            boton.disabled = false;
        }
    });
    return cargarRegistros();
}

async function iniciar() {
    const login = document.getElementById("loginForm");
    const estado = document.getElementById(login ? "loginStatus" : "sessionStatus");
    const logout = document.getElementById("logout");
    const boton = login ? login.querySelector("button") : logout;
    boton.disabled = true;
    if (!window.supabase || SUPABASE_ANON_KEY === "TU_CLAVE_PUBLICA") {
        estado.textContent = window.supabase
            ? "Configura la URL y la clave pública de Supabase en app.js."
            : "No se pudo cargar la biblioteca de Supabase. Recarga la página.";
        return;
    }
    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    if (login) prepararLogin(login);
    const { data, error } = await supabaseClient.auth.getSession();
    if (error) mostrarNotificacion("No se pudo recuperar la sesión.", "error");
    if (login) {
        if (data.session) location.replace("inventario.html");
        else boton.disabled = false;
        return;
    }
    if (!data.session) {
        location.replace("login.html");
        return;
    }
    supabaseClient.auth.onAuthStateChange(evento => {
        if (evento === "SIGNED_OUT") location.replace("login.html");
    });
    logout.addEventListener("click", async () => {
        logout.disabled = true;
        const { error: errorSalida } = await supabaseClient.auth.signOut({ scope: "local" });
        if (errorSalida) {
            mostrarNotificacion("No se pudo cerrar la sesión.", "error");
            logout.disabled = false;
        }
    });
    logout.disabled = false;
    estado.hidden = true;
    document.getElementById("panel").hidden = false;
    const modulo = document.body.dataset.module;
    await (modulo === "productos" ? prepararInventario() : prepararRegistros(modulo));
}

iniciar().catch(() => {
    const estado = document.querySelector("#loginStatus, #sessionStatus");
    estado.hidden = false;
    estado.textContent = "No se pudo iniciar el sistema. Revisa la configuración e inténtalo de nuevo.";
    mostrarNotificacion(estado.textContent, "error");
});
