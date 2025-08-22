<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Sign Up - minifacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">

  <style>
    :root{
      --brand:#999fff;
      --brand-strong:#7f8cff;
      --text:#333333;
      --muted:#555;
      --border:#E2E2E2;
      --input:#ccc;
      --focus:#33B5E5;
      --bg:#f8f9fa;
      --ok:#2D6A2D;
      --error:#AA3333;
      --shadow:0 2px 10px rgba(0,0,0,.08);
      --shadow-lg:0 6px 24px rgba(0,0,0,.10);
      --radius:12px;
      --maxw:720px; /* MISMA ANCHURA para header y contenido */
    }

    * { box-sizing:border-box; margin:0; padding:0; }

    html, body { height:100%; }
    body {
      font-family: Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text);
      line-height:1.35;
    }

    /* ===== Top taskbar (alineada con el contenido) ===== */
    .taskbar {
      position: sticky;
      top: 0;
      z-index: 10;
      background-color: var(--brand);
      color: #fff;
      box-shadow: 0 1px 8px rgba(0,0,0,.08);
    }
    .bar-inner{
      max-width: var(--maxw);
      margin: 0 auto;
      padding: 12px 16px;
      display:flex;
      align-items:center;
      justify-content:center;
    }
    .taskbar h1{
      font-size: clamp(18px, 2.6vw, 22px);
      font-weight: 700;
      letter-spacing:.2px;
    }

    /* ===== Shell para alinear contenido con el header ===== */
    .shell{
      max-width: var(--maxw);
      margin: 0 auto;
      padding: 16px;
    }

    /* ===== Card container ===== */
    .container {
      background-color:#fff;
      border-radius: var(--radius);
      border:1px solid var(--border);
      box-shadow: var(--shadow);
      width:100%;
      padding: 20px;
      transition: box-shadow .2s ease, transform .2s ease;
    }
    @media (min-width: 640px){
      .container{ padding:28px; }
    }
    .container:hover { box-shadow: var(--shadow-lg); transform: translateY(-1px); }

    /* ===== Headings ===== */
    .title{
      text-align:center;
      margin-bottom: 8px;
      color:#333;
      font-size: clamp(20px, 3.5vw, 26px);
    }
    .subtitle{
      color:#333;
      font-size: 16px;
      margin: 6px 0 4px 0;
    }

    /* ===== Section como GRID responsivo ===== */
    .section{
      display:grid;
      grid-template-columns: 1fr;
      gap: 12px 16px;
      padding: 10px 0 18px 0;
      border-top: 1px dashed var(--border);
      margin-top: 12px;
    }
    .section:first-of-type{
      border-top: none;
      margin-top: 4px;
      padding-top: 6px;
    }
    .section .subtitle{ grid-column: 1 / -1; }

    @media (min-width: 768px){
      .section{
        grid-template-columns: repeat(2, minmax(0,1fr));
      }
    }

    /* ===== Form controls ===== */
    .form-group{ display:flex; flex-direction:column; gap:6px; }
    .form-group label{
      font-weight: 700;
      color: var(--muted);
      font-size: 13px;
    }
    .form-group input,
    .form-group select{
      width:100%;
      padding: 10px 12px;
      border:1px solid var(--input);
      border-radius:8px;
      font-size:14px;
      background-color:#fff;
      transition: border-color .15s ease, box-shadow .15s ease, background-color .15s ease, transform .05s ease;
    }

    /* HOVER/FOCUS para mouse y teclado */
    @media (hover:hover) and (pointer:fine){
      .form-group input:hover,
      .form-group select:hover{
        border-color: var(--focus);
        background-color:#fafcff;
      }
    }
    .form-group input:focus,
    .form-group select:focus{
      outline:none;
      border-color: var(--focus);
      box-shadow: 0 0 0 3px rgba(51,181,229,.20);
    }
    /* Táctil (tap feedback) */
    .form-group input:active,
    .form-group select:active{ transform: scale(.995); }

    /* ===== Mensajes ===== */
    .msg{
      text-align:center;
      margin: 10px 0 2px 0;
      font-weight:700;
      font-size: 13px;
    }
    .msg.error{ color: var(--error); }
    .msg.ok{ color: var(--ok); }

    /* ===== Botones ===== */
    .form-buttons{
      display:flex;
      flex-wrap: wrap;
      gap: 12px;
      justify-content: space-between;
      margin-top: 10px;
      padding-top: 6px;
      border-top: 1px dashed var(--border);
    }
    .btn{
      appearance: none;
      -webkit-appearance: none;
      border:none;
      border-radius: 10px;
      padding: 10px 18px;
      cursor:pointer;
      font-size:14px;
      font-weight:700;
      transition: background-color .15s ease, box-shadow .15s ease, transform .05s ease;
      box-shadow: var(--shadow);
      flex: 1 1 160px; /* se apilan en móvil, dos columnas cuando haya espacio */
    }
    .btn-primary{
      background-color: var(--focus);
      color:#fff;
    }
    .btn-primary:hover{ background-color:#0099CC; }
    .btn-secondary{
      background-color:#e9ecef;
      color:#333;
    }
    .btn-secondary:hover{ background-color:#dfe3e7; }
    .btn:active{ transform: translateY(1px); }

    /* ===== Helpers col (opcional) ===== */
    @media (min-width: 768px){
      .col-1  { grid-column: span 1; }
      .col-2  { grid-column: span 2; }
    }
  </style>
</head>

<body>

  <!-- HEADER alineado con el contenido -->
  <header class="taskbar">
    <div class="bar-inner">
      <h1>MiniFacebook</h1>
    </div>
  </header>

  <!-- SHELL centra y alinea todo con el header -->
  <main class="shell">
    <div class="container">
      <h2 class="title">Create Your Account</h2>

      <!-- feedback via querystring ?err=... / ?ok=1 -->
      <%
        String err = request.getParameter("err");
        String ok  = request.getParameter("ok");
        if (err != null && err.trim().length() > 0) {
      %>
          <div class="msg error"><%= err %></div>
      <% } else if ("1".equals(ok)) { %>
          <div class="msg ok">Account created successfully. Please sign in.</div>
      <% } %>

      <form id="singupForm" action="singupProcess.jsp" method="post" autocomplete="off">

        <!-- Section: Basic Info -->
        <div class="section">
          <h3 class="subtitle">Basic Info</h3>

          <div class="form-group">
            <label for="name">Full name</label>
            <input type="text" id="name" name="name" maxlength="100" required />
          </div>

          <div class="form-group">
            <label for="email">Email (must be unique)</label>
            <input type="email" id="email" name="email" maxlength="100" required />
          </div>

          <div class="form-group">
            <label for="password">Password (min 6 chars)</label>
            <input type="password" id="password" name="password" required />
          </div>

          <div class="form-group">
            <label for="confirm">Confirm Password</label>
            <input type="password" id="confirm" name="confirm" required />
          </div>

          <div class="form-group">
            <label for="birth">Birth date (YYYY-MM-DD)</label>
            <input type="date" id="birth" name="birth" required />
          </div>

          <div class="form-group">
            <label for="gender">Gender</label>
            <select id="gender" name="gender" required>
              <option value="">Select gender</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>

        <!-- Section: Address -->
        <div class="section">
          <h3 class="subtitle">Address</h3>

          <div class="form-group">
            <label for="street">Street</label>
            <input type="text" id="street" name="street" required />
          </div>

          <div class="form-group">
            <label for="town">Town</label>
            <input type="text" id="town" name="town" required />
          </div>

          <div class="form-group">
            <label for="state">State</label>
            <input type="text" id="state" name="state" required />
          </div>

          <div class="form-group">
            <label for="country">Country</label>
            <input type="text" id="country" name="country" required />
          </div>
        </div>

        <!-- Section: Education -->
        <div class="section">
          <h3 class="subtitle">Education</h3>

          <div class="form-group">
            <label for="degree">Degree</label>
            <select id="degree" name="degree" required>
              <option value="">(none)</option>
              <option value="High School Degree">High School Degree</option>
              <option value="Bachelor's Degree">Bachelor's Degree</option>
              <option value="Master's Degree">Master's Degree</option>
              <option value="Doctorate Degree">Doctorate Degree</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div class="form-group">
            <label for="school">School</label>
            <input type="text" id="school" name="school" required />
          </div>
        </div>

        <!-- Buttons -->
        <div class="form-buttons">
          <input class="btn btn-primary" type="submit" value="Create Account" />
          <input class="btn btn-secondary" type="reset" value="Reset" />
        </div>

      </form>
    </div>
  </main>
</body>
</html>
