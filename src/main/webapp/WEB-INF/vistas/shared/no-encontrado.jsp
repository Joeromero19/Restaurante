<%-- shared/no-encontrado.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Página no encontrada — Sabor Distrital</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans&display=swap" rel="stylesheet">
    <style>
        body{font-family:'DM Sans',sans-serif;background:#faf7f2;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;}
        .box{text-align:center;max-width:440px;padding:3rem 2rem;}
        .code{font-family:'Playfair Display',serif;font-size:6rem;font-weight:700;color:#3b1f0a;line-height:1;margin-bottom:1rem;}
        h2{font-size:1.4rem;margin-bottom:0.6rem;}
        p{color:#5a5a5a;margin-bottom:2rem;}
        a{display:inline-block;padding:0.75rem 1.5rem;background:#3b1f0a;color:#faf7f2;border-radius:8px;text-decoration:none;font-weight:500;}
        a:hover{background:#c8973a;}
    </style>
</head>
<body>
    <div class="box">
        <div class="code">404</div>
        <h2>Página no encontrada</h2>
        <p>La ruta solicitada no existe en el sistema.</p>
        <a href="${pageContext.request.contextPath}/dashboard">← Volver al panel</a>
    </div>
</body>
</html>
