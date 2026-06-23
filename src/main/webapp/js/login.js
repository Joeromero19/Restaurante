/* ============================================================
   login.js — Validaciones para login y registro de cliente
   Sabor Distrital
============================================================ */

/* ---- Utilidades de validación ---- */
const V = {
    // Muestra error inline bajo el campo
    setError(input, msg) {
        input.classList.add('input-error');
        input.classList.remove('input-ok');
        let hint = input.closest('.input-wrapper, .form-group').querySelector('.v-error');
        if (!hint) {
            hint = document.createElement('span');
            hint.className = 'v-error';
            input.closest('.input-wrapper, .form-group').appendChild(hint);
        }
        hint.textContent = msg;
    },
    // Limpia error y pone check verde
    setOk(input) {
        input.classList.remove('input-error');
        input.classList.add('input-ok');
        const hint = input.closest('.input-wrapper, .form-group').querySelector('.v-error');
        if (hint) hint.textContent = '';
    },
    clearAll(form) {
        form.querySelectorAll('.input-error, .input-ok').forEach(el => {
            el.classList.remove('input-error', 'input-ok');
        });
        form.querySelectorAll('.v-error').forEach(el => el.remove());
    },

    // Reglas
    required(val)     { return val.trim().length > 0; },
    email(val)        { return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(val.trim()); },
    soloLetras(val)   { return /^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s'-]+$/.test(val.trim()); },
    soloNumeros(val)  { return /^\d+$/.test(val.trim()); },
    longMin(val, n)   { return val.trim().length >= n; },
    longMax(val, n)   { return val.trim().length <= n; },
    telefono(val)     { return val.trim() === '' || /^\d{7,15}$/.test(val.trim()); },
    documento(val)    { return /^\d{6,12}$/.test(val.trim()); },
    fechaPasado(val)  {
        if (!val) return false;
        const d = new Date(val);
        return d < new Date();
    },
    mayorEdad(val) {
        if (!val) return false;
        const hoy  = new Date();
        const nac  = new Date(val);
        const edad = hoy.getFullYear() - nac.getFullYear() -
            (hoy < new Date(hoy.getFullYear(), nac.getMonth(), nac.getDate()) ? 1 : 0);
        return edad >= 13; // Mínimo 13 años para registrarse
    }
};

/* ============================================================
   FORMULARIO DE LOGIN
============================================================ */
document.addEventListener('DOMContentLoaded', function () {

    /* ---- Toggle mostrar/ocultar contraseña ---- */
    const togglePwd = document.getElementById('togglePwd');
    const pwdInput  = document.getElementById('password');
    if (togglePwd && pwdInput) {
        togglePwd.addEventListener('click', function () {
            const tipo = pwdInput.type === 'password' ? 'text' : 'password';
            pwdInput.type = tipo;
            togglePwd.textContent = tipo === 'password' ? '👁' : '🙈';
        });
    }

    /* ---- Validación login ---- */
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        const correoInput = document.getElementById('correo');
        const passInput   = document.getElementById('password');
        const btnLogin    = document.getElementById('btnLogin');

        // Validar al perder foco
        correoInput && correoInput.addEventListener('blur', () => {
            const val = correoInput.value;
            if (!V.required(val))      V.setError(correoInput, 'El correo es obligatorio.');
            else if (!V.email(val))    V.setError(correoInput, 'Ingrese un correo con formato válido (ej: nombre@dominio.com).');
            else                       V.setOk(correoInput);
        });

        passInput && passInput.addEventListener('blur', () => {
            const val = passInput.value;
            if (!V.required(val))      V.setError(passInput, 'La contraseña es obligatoria.');
            else if (!V.longMin(val,6)) V.setError(passInput, 'La contraseña debe tener al menos 6 caracteres.');
            else                       V.setOk(passInput);
        });

        loginForm.addEventListener('submit', function (e) {
            V.clearAll(loginForm);
            let ok = true;

            const correo = correoInput.value;
            const pass   = passInput.value;

            if (!V.required(correo))       { V.setError(correoInput, 'El correo es obligatorio.'); ok = false; }
            else if (!V.email(correo))     { V.setError(correoInput, 'Correo con formato inválido (ej: nombre@dominio.com).'); ok = false; }
            else                           { V.setOk(correoInput); }

            if (!V.required(pass))         { V.setError(passInput, 'La contraseña es obligatoria.'); ok = false; }
            else if (!V.longMin(pass, 6))  { V.setError(passInput, 'La contraseña debe tener al menos 6 caracteres.'); ok = false; }
            else                           { V.setOk(passInput); }

            if (!ok) { e.preventDefault(); return; }

            // Feedback visual de carga
            if (btnLogin) {
                btnLogin.querySelector('.btn-text').textContent = 'Verificando...';
                btnLogin.disabled = true;
            }
        });
    }

    /* ============================================================
       FORMULARIO DE REGISTRO
    ============================================================ */
    const regForm = document.getElementById('registroForm');
    if (!regForm) return;

    const campos = {
        nombre:          regForm.querySelector('[name="nombre"]'),
        apellido:        regForm.querySelector('[name="apellido"]'),
        idPersona:       regForm.querySelector('[name="idPersona"]'),
        correo:          regForm.querySelector('[name="correo"]'),
        telefono:        regForm.querySelector('[name="telefono"]'),
        fechaNacimiento: regForm.querySelector('[name="fechaNacimiento"]'),
    };

    /* Validadores por campo */
    function validarCampo(campo, nombre) {
        switch(nombre) {
            case 'nombre':
            case 'apellido': {
                const label = nombre === 'nombre' ? 'El nombre' : 'El apellido';
                const val = campo.value;
                if (!V.required(val))            { V.setError(campo, label + ' es obligatorio.'); return false; }
                if (!V.longMin(val, 2))          { V.setError(campo, label + ' debe tener al menos 2 caracteres.'); return false; }
                if (!V.soloLetras(val))          { V.setError(campo, label + ' solo puede contener letras y espacios.'); return false; }
                if (!V.longMax(val, 80))         { V.setError(campo, label + ' no puede superar 80 caracteres.'); return false; }
                V.setOk(campo); return true;
            }
            case 'idPersona': {
                const val = campo.value;
                if (!V.required(val))            { V.setError(campo, 'El número de documento es obligatorio.'); return false; }
                if (!V.soloNumeros(val))         { V.setError(campo, 'El documento solo debe contener números, sin puntos ni guiones.'); return false; }
                if (!V.documento(val))           { V.setError(campo, 'El documento debe tener entre 6 y 12 dígitos.'); return false; }
                V.setOk(campo); return true;
            }
            case 'correo': {
                const val = campo.value;
                if (!V.required(val))            { V.setError(campo, 'El correo es obligatorio.'); return false; }
                if (!V.email(val))               { V.setError(campo, 'Ingrese un correo válido (ej: nombre@dominio.com).'); return false; }
                if (!V.longMax(val, 120))        { V.setError(campo, 'El correo no puede superar 120 caracteres.'); return false; }
                V.setOk(campo); return true;
            }
            case 'telefono': {
                const val = campo.value;
                if (val.trim() !== '' && !V.soloNumeros(val)) { V.setError(campo, 'El teléfono solo debe contener números.'); return false; }
                if (val.trim() !== '' && !V.telefono(val))    { V.setError(campo, 'Ingrese un teléfono válido (7 a 15 dígitos).'); return false; }
                V.setOk(campo); return true;
            }
            case 'fechaNacimiento': {
                const val = campo.value;
                if (!V.required(val))            { V.setError(campo, 'La fecha de nacimiento es obligatoria.'); return false; }
                if (!V.fechaPasado(val))         { V.setError(campo, 'La fecha de nacimiento no puede ser hoy ni en el futuro.'); return false; }
                if (!V.mayorEdad(val))           { V.setError(campo, 'Debe tener al menos 13 años para registrarse.'); return false; }
                V.setOk(campo); return true;
            }
        }
        return true;
    }

    // Validar al perder foco en cada campo
    Object.entries(campos).forEach(([nombre, campo]) => {
        if (campo) {
            campo.addEventListener('blur', () => validarCampo(campo, nombre));
            campo.addEventListener('input', () => {
                // Limpiar error mientras el usuario escribe (no mostrar nuevo)
                if (campo.classList.contains('input-error')) {
                    const hint = campo.closest('.input-wrapper, .form-group').querySelector('.v-error');
                    if (hint) hint.textContent = '';
                    campo.classList.remove('input-error');
                }
            });
        }
    });

    // Validar al enviar
    regForm.addEventListener('submit', function (e) {
        V.clearAll(regForm);
        let ok = true;

        Object.entries(campos).forEach(([nombre, campo]) => {
            if (campo && !validarCampo(campo, nombre)) ok = false;
        });

        if (!ok) {
            e.preventDefault();
            // Hacer scroll al primer campo con error
            const primerError = regForm.querySelector('.input-error');
            if (primerError) primerError.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });
});
