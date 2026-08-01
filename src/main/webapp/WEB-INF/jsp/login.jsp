<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Smart Complaint Portal</title>
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body>
    <div class="auth-container">
        <h2>Portal Login</h2>
        <div id="errorAlert" class="alert alert-danger"></div>
        
        <form id="loginForm">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" required placeholder="Enter email">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" required placeholder="Enter password">
            </div>
            
            <button type="submit" class="btn" style="width: 100%;">Login</button>
        </form>
        
        <a href="/register" class="auth-link">Don't have an account? Register here</a>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
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
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else if (response.status === 401) {
                    throw new Error("Invalid email or password");
                } else {
                    throw new Error("Something went wrong. Please try again.");
                }
            })
            .then(data => {
                // Save user info in sessionStorage
                sessionStorage.setItem('userId', data.userId);
                sessionStorage.setItem('userName', data.name);
                sessionStorage.setItem('userRole', data.role);

                // Redirect based on role
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
