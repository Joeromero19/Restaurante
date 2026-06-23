<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  footer.jsp — Cierra el layout principal (main-content + app-layout).
  Incluir siempre al final de cada vista interna.
--%>
    </main><!-- /.page-content -->
</div><!-- /.main-content -->
</div><!-- /.app-layout -->

<!-- Modal CSS para overlay -->
<style>
.modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
    z-index: 200;
    align-items: center;
    justify-content: center;
    padding: 1rem;
}
.modal-box {
    background: #fff;
    border-radius: 12px;
    padding: 2rem;
    width: 100%;
    max-width: 520px;
    box-shadow: 0 8px 40px rgba(0,0,0,0.2);
    position: relative;
}
.modal-title {
    font-family: 'Playfair Display', serif;
    font-size: 1.25rem;
    font-weight: 700;
    margin-bottom: 1.2rem;
    color: #0d0d0d;
}
.modal-close {
    position: absolute;
    top: 1rem;
    right: 1rem;
    background: none;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
    color: #888;
}
.modal-close:hover { color: #c0392b; }
</style>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
