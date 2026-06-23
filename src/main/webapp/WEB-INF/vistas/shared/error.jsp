<%-- shared/error.jsp - Error 500 --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Error del servidor — Sabor Distrital</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans&display=swap" rel="stylesheet">
    <style>
        body{font-family:'DM Sans',sans-serif;background:#faf7f2;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;}
        .box{text-align:center;max-width:480px;padding:3rem 2rem;}
        .code{font-family:'Playfair Display',serif;font-size:6rem;font-weight:700;color:#c0392b;line-height:1;margin-bottom:1rem;}
        h2{font-size:1.4rem;margin-bottom:0.6rem;}
        p{color:#5a5a5a;margin-bottom:1rem;}
        .detail{background:#fde8e6;color:#c0392b;padding:0.8rem 1rem;border-radius:8px;font-size:0.8rem;text-align:left;margin-bottom:2rem;word-break:break-word;}
        a{display:inline-block;padding:0.75rem 1.5rem;background:#3b1f0a;color:#faf7f2;border-radius:8px;text-decoration:none;font-weight:500;}
        a:hover{background:#c8973a;}
    </style>
</head>
<body>
    <div class="box">
        <div class="code">500</div>
        <h2>Error interno del servidor</h2>
        <p>Ocurrió un error inesperado. Por favor contacte al administrador.</p>
        <% if (exception != null) { %>
        <div class="detail"><%= exception.getMessage() %></div>
        <% } %>
        <a href="${pageContext.request.contextPath}/dashboard">← Volver al panel</a>
    </div>
</body>
</html>
