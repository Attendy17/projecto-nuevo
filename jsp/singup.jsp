<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Sign Up - MiniFacebook</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    /* Global reset and typography */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html {
      font-family: "Lucida Sans", sans-serif;
    }

    body {
      background-color: #ffffff;
      color: #333333;
      margin: 0;
    }

    /* Float-based grid with mobile-first full-width columns */
    .row::after {
      content: "";
      display: table;
      clear: both;
    }

    [class*="col-"] {
      float: left;
      width: 100%;
      padding: 15px;
    }

    /* Desktop column widths */
    @media only screen and (min-width: 768px) {
      .col-1  { width: 8.33%; }
      .col-2  { width: 16.66%; }
      .col-3  { width: 25%; }
      .col-4  { width: 33.33%; }
      .col-5  { width: 41.66%; }
      .col-6  { width: 50%; }
      .col-7  { width: 58.33%; }
      .col-8  { width: 66.66%; }
      .col-9  { width: 75%; }
      .col-10 { width: 83.33%; }
      .col-11 { width: 91.66%; }
      .col-12 { width: 100%; }
    }

    /* Header */
    .header {
      background-color: #9933cc;
      color: #ffffff;
      text-align: center;
      padding: 15px;
    }

    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
    }

    /* Top taskbar with hover-enabled links */
    .taskbar {
      background-color: #33b5e5;
      padding: 10px 15px;
    }

    .taskbar-nav {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      list-style: none;
      margin: 0;
      padding: 0;
      justify-content: center;
    }

    .taskbar-nav li {
      display: inline-block;
    }

    .taskbar-nav a {
      display: inline-block;
      text-decoration: none;
      color: #ffffff;
      padding: 8px 12px;
      border-radius: 4px;
      transition: background-color 0.2s ease, transform 0.1s ease;
    }

    .taskbar-nav a:hover {
      background-color: #0099cc;
      transform: translateY(-1px);
    }

    /* Left navigation menu */
    .menu ul {
      list-style-type: none;
      margin: 0;
      padding: 0;
    }

    .menu li {
      padding: 8px;
      margin-bottom: 7px;
      background-color: #33b5e5;
      color: #ffffff;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
      transition: background-color 0.2s ease;
    }

    .menu li:hover {
      background-color: #0099cc;
    }

    .menu li a {
      color: #ffffff;
      text-decoration: none;
      display: block;
    }

    /* Right aside for tips */
    .aside {
      background-color: #33b5e5;
      padding: 15px;
      color: #ffffff;
      text-align: center;
      font-size: 14px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
      border-radius: 4px;
    }

    /* Signup card */
    .box {
      background-color: #f1f1f1;
      border: 1px solid #e2e2e2;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.10);
      padding: 20px;
    }

    .title {
      text-align: center;
      margin-bottom: 12px;
      color: #222222;
      font-size: 22px;
      font-weight: 700;
    }

    /* Sections inside the card for grouping fields */
    .section {
      margin-top: 18px;
      padding-top: 10px;
      border-top: 1px dashed #e2e2e2;
    }

    .section:first-of-type {
      margin-top: 8px;
      padding-top: 0;
      border-top: 0;
    }

    .subtitle {
      margin-bottom: 10px;
      font-size: 16px;
      color: #333333;
      font-weight: 700;
      text-align: left;
    }

    /* Form controls */
    .form-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 12px 16px;
    }

    @media only screen and (min-width: 768px) {
      .form-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    .form-group {
      display: flex;
      flex-direction: column;
    }

    .form-group label {
      font-weight: 700;
      color: #555555;
      margin-bottom: 5px;
      font-size: 13px;
    }

    .form-group input,
    .form-group select {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #cccccc;
      border-radius: 8px;
      font-size: 14px;
      background-color: #ffffff;
      transition: border-color 0.15s ease, box-shadow 0.15s ease, background-color 0.15s ease;
    }

    .form-group input:hover,
    .form-group select:hover {
      border-color: #33b5e5;
      background-color: #fafcff;
    }

    .form-group input:focus,
    .form-group select:focus {
      outline: none;
      border-color: #33b5e5;
      box-shadow: 0 0 0 3px rgba(51,181,229,0.20);
    }

    /* Action buttons */
    .form-buttons {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      justify-content: space-between;
      margin-top: 12px;
      padding-top: 10px;
      border-top: 1px dashed #e2e2e2;
    }

    .btn {
      appearance: none;
      border: none;
      border-radius: 10px;
      padding: 10px 18px;
      cursor: pointer;
      font-size: 14px;
      font-weight: 700;
      transition: background-color 0.15s ease, box-shadow 0.15s ease, transform 0.05s ease;
      box-shadow: 0 2px 10px rgba(0,0,0,0.08);
      flex: 1 1 160px;
    }

    .btn:active {
      transform: translateY(1px);
    }

    .btn-primary {
      background-color: #33b5e5;
      color: #ffffff;
    }

    .btn-primary:hover {
      background-color: #0099cc;
    }

    .btn-secondary {
      background-color: #e9ecef;
      color: #333333;
    }

    .btn-secondary:hover {
      background-color: #dfe3e7;
    }

    /* Feedback messages */
    .msg {
      text-align: center;
      margin: 10px 0 2px 0;
      font-weight: 700;
      font-size: 13px;
    }

    .msg.error { color: #AA3333; }
    .msg.ok    { color: #2D6A2D; }

    /* Footer */
    .footer {
      background-color: #0099cc;
      color: #ffffff;
      text-align: center;
      font-size: 12px;
      padding: 15px;
      margin-top: 10px;
    }
  </style>
</head>
<body>

  <!-- Header -->
  <div class="header">
    <h1>MiniFacebook</h1>
  </div>

  <!-- Taskbar with hover -->
  <nav class="taskbar">
    <ul class="taskbar-nav">
      <li><a href="welcomeMenu.jsp">Home</a></li>
      <li><a href="loginHashing.jsp">Login</a></li>
      <li><a href="friendList.jsp">Friends</a></li>
      <li><a href="searchFriends.jsp">Search</a></li>
    </ul>
  </nav>

  <!-- Three-column layout using the column classes -->
  <div class="row">

    <!-- Left navigation (col-3 on desktop; full width on mobile) -->
    <div class="col-3 menu">
      <ul>
        <li><a href="singup.jsp">Create Account</a></li>
        <li><a href="loginHashing.jsp">Login</a></li>
        <li><a href="welcomeMenu.jsp">Home</a></li>
        <li><a href="searchFriends.jsp">Find Friends</a></li>
      </ul>
    </div>

    <!-- Main content (col-6 on desktop; full width on mobile) -->
    <div class="col-6 content">
      <div class="box">
        <div class="title">Create Your Account</div>

        <%-- Optional status via querystring: ?err=... or ?ok=1 --%>
        <%
          String err = request.getParameter("err");
          String ok  = request.getParameter("ok");
          if (err != null && err.trim().length() > 0) {
        %>
          <div class="msg error"><%= err %></div>
        <% } else if ("1".equals(ok)) { %>
          <div class="msg ok">Account created successfully. Please sign in.</div>
        <% } %>

        <form id="signupForm" action="singupProcess.jsp" method="post" autocomplete="off">
          <!-- Basic Info -->
          <div class="section">
            <div class="subtitle">Basic Info</div>
            <div class="form-grid">
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
          </div>

          <!-- Address -->
          <div class="section">
            <div class="subtitle">Address</div>
            <div class="form-grid">
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
          </div>

          <!-- Education -->
          <div class="section">
            <div class="subtitle">Education</div>
            <div class="form-grid">
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
          </div>

          <!-- Buttons -->
          <div class="form-buttons">
            <input class="btn btn-primary" type="submit" value="Create Account" />
            <input class="btn btn-secondary" type="reset" value="Reset" />
          </div>
        </form>
      </div>
    </div>

    <!-- Right aside (col-3 on desktop; full width on mobile) -->
    <div class="col-3 right">
      <div class="aside">
        <h2>Tips</h2>
        <p>Use a valid email address you can access.</p>
        <h3>Password</h3>
        <p>Choose at least 6 characters with a mix of letters and numbers.</p>
        <h3>Next</h3>
        <p>After creating your account, you can log in from the Login page.</p>
      </div>
    </div>

  </div>

  <!-- Footer -->
  <div class="footer">
    <p>Resize the browser window to see how the content responds to the resizing.</p>
  </div>

</body>
</html>
