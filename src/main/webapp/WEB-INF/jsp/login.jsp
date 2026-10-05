<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Smart Complaint & Service Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body style="display: flex; align-items: center; justify-content: center; min-height: 100vh; background: linear-gradient(135deg, #f0f4f8 0%, #d9e2ec 100%);">
    <div class="auth-container">
        <h2>Smart Complaint Portal</h2>
        <p style="text-align: center; color: var(--text-muted); font-size: 0.9rem; margin-bottom: 20px;">Sign in to manage and track your service requests</p>
        
        <div id="errorAlert" class="alert alert-danger"></div>
        
        <form id="loginForm">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" required placeholder="name@domain.com" autocomplete="email">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" required placeholder="Enter your password" autocomplete="current-password">
            </div>
            
            <button type="submit" class="btn" style="width: 100%; margin-top: 10px;">Sign In</button>
        </form>
        
        <a href="/register" class="auth-link">New user? Register an account</a>
    </div>

    <script>
        // If already logged in, redirect
        const savedRole = sessionStorage.getItem('userRole');
        if (savedRole === 'ADMIN') window.location.href = '/admin-dashboard';
        else if (savedRole === 'AGENT') window.location.href = '/agent-dashboard';
        else if (savedRole === 'CUSTOMER') window.location.href = '/customer-dashboard';

        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            const errorAlert = document.getElementById('errorAlert');
            
            errorAlert.style.display = 'none';

            fetch('/api/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email: email, password: password })
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok) {
                    return data;
                } else {
                    throw new Error(data.message || "Invalid email or password");
                }
            })
            .then(data => {
                sessionStorage.setItem('userId', data.userId);
                sessionStorage.setItem('userName', data.name);
                sessionStorage.setItem('userRole', data.role);

                if (data.role === 'ADMIN') {
                    window.location.href = '/admin-dashboard';
                } else if (data.role === 'AGENT') {
                    window.location.href = '/agent-dashboard';
                } else {
                    window.location.href = '/customer-dashboard';
                }
            })
            .catch(error => {
                errorAlert.textContent = error.message;
                errorAlert.style.display = 'block';
            });
        });
    </script>
</body>
</html>
