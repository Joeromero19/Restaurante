/* ============================================================
   main.js — JavaScript global del sistema Sabor Distrital
============================================================ */

/* ---- Sidebar toggle en móvil ---- */
document.addEventListener('DOMContentLoaded', function () {

    // Botón hamburguesa (topbar)
    const toggleBtn = document.getElementById('sidebarToggle');
    const sidebar   = document.querySelector('.sidebar');
    const overlay   = document.getElementById('sidebarOverlay');

    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener('click', function () {
            sidebar.classList.toggle('open');
            if (overlay) overlay.classList.toggle('visible');
        });
    }
    if (overlay) {
        overlay.addEventListener('click', function () {
            sidebar.classList.remove('open');
            overlay.classList.remove('visible');
        });
    }

    /* ---- Marcar enlace activo en el sidebar ---- */
    const currentPath = window.location.pathname + window.location.search;
    document.querySelectorAll('.sidebar-nav a').forEach(function (link) {
        if (currentPath.includes(link.getAttribute('href'))) {
            link.classList.add('active');
        }
    });

    /* ---- Auto-ocultar mensajes de alerta después de 4 s ---- */
    document.querySelectorAll('.msg-success, .msg-info').forEach(function (el) {
        setTimeout(function () {
            el.style.transition = 'opacity 0.5s';
            el.style.opacity = '0';
            setTimeout(function () { el.remove(); }, 500);
        }, 4000);
    });

    /* ---- Confirmación antes de eliminar ---- */
    document.querySelectorAll('[data-confirm]').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            if (!confirm(btn.getAttribute('data-confirm') || '¿Está seguro?')) {
                e.preventDefault();
            }
        });
    });

    /* ---- Tooltips simples con title ---- */
    document.querySelectorAll('[title]').forEach(function (el) {
        el.setAttribute('aria-label', el.getAttribute('title'));
    });

    /* ---- Formato moneda colombiana en celdas marcadas ---- */
    document.querySelectorAll('.currency').forEach(function (el) {
        const val = parseFloat(el.textContent.replace(/[^0-9.-]/g, ''));
        if (!isNaN(val)) {
            el.textContent = formatCOP(val);
        }
    });
});

/* ---- Función global de formato COP ---- */
function formatCOP(valor) {
    return '$ ' + valor.toLocaleString('es-CO', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

/* ---- Filtro de tabla en tiempo real ---- */
function filtrarTabla(inputId, tablaId) {
    const filtro = document.getElementById(inputId).value.toLowerCase();
    const filas  = document.querySelectorAll('#' + tablaId + ' tbody tr');
    filas.forEach(function (fila) {
        const texto = fila.textContent.toLowerCase();
        fila.style.display = texto.includes(filtro) ? '' : 'none';
    });
}

/* ---- Abrir modal genérico ---- */
function abrirModal(id) {
    const modal = document.getElementById(id);
    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }
}

function cerrarModal(id) {
    const modal = document.getElementById(id);
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }
}

/* Cerrar modal al hacer clic fuera */
document.addEventListener('click', function (e) {
    if (e.target.classList.contains('modal-overlay')) {
        e.target.style.display = 'none';
        document.body.style.overflow = '';
    }
});
