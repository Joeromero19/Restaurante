<%-- shared/acceso-denegado.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Acceso Denegado — Sabor Distrital</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans&display=swap" rel="stylesheet">
    <style>
        body { font-family:'DM Sans',sans-serif; background:#faf7f2; display:flex; align-items:center; justify-content:center; min-height:100vh; margin:0; }
        .error-box { text-align:center; max-width:440px; padding:3rem 2rem; }
        .error-code { font-family:'Playfair Display',serif; font-size:6rem; font-weight:700; color:#3b1f0a; line-height:1; margin-bottom:1rem; }
        .error-title { font-size:1.4rem; font-weight:600; color:#0d0d0d; margin-bottom:0.6rem; }
        .error-desc { color:#5a5a5a; margin-bottom:2rem; }
        .btn { display:inline-block; padding:0.75rem 1.5rem; background:#3b1f0a; color:#faf7f2; border-radius:8px; text-decoration:none; font-weight:500; transition:background 0.2s; }
        .btn:hover { background:#c8973a; }
    </style>
</head>
<body>
    <div class="error-box">
        <div class="error-code">403</div>
        <div class="error-title">Acceso denegado</div>
        <div class="error-desc">No tiene permiso para acceder a esta sección del sistema.</div>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn">← Volver al panel</a>
    </div>
</body>
</html>
