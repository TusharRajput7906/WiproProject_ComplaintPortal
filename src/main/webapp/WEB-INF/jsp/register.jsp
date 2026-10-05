<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Smart Complaint & Service Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body style="display: flex; align-items: center; justify-content: center; min-height: 100vh; background: linear-gradient(135deg, #f0f4f8 0%, #d9e2ec 100%);">
    <div class="auth-container">
        <h2>Create an Account</h2>
        <p style="text-align: center; color: var(--text-muted); font-size: 0.9rem; margin-bottom: 20px;">Join the portal to log complaints or manage service operations</p>
        
        <div id="errorAlert" class="alert alert-danger"></div>
        <div id="successAlert" class="alert alert-success"></div>
        
        <form id="registerForm">
            <div class="form-group">
                <label for="name">Full Name</label>
                <input type="text" id="name" required placeholder="John Doe" maxlength="100">
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" required placeholder="john@example.com" maxlength="100">
            </div>
            
            <div class="form-group">
                <label for="password">Password (min 6 characters)</label>
                <input type="password" id="password" required minlength="6" maxlength="255" placeholder="Choose a secure password">
            </div>

            <div class="form-group">
                <label for="role">Select Account Role</label>
                <select id="role" required>
                    <option value="CUSTOMER">Customer (File & Track Complaints)</option>
                    <option value="AGENT">Support Agent (Resolve Issues)</option>
                    <option value="ADMIN">System Administrator (Manage Portal)</option>
                </select>
            </div>
            
            <button type="submit" class="btn" style="width: 100%; margin-top: 10px;">Register Account</button>
        </form>
        
        <a href="/login" class="auth-link">Already have an account? Sign in here</a>
    </div>

    <script>
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const name = document.getElementById('name').value.trim();
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            const role = document.getElementById('role').value;
            
            const errorAlert = document.getElementById('errorAlert');
            const successAlert = document.getElementById('successAlert');
            
            errorAlert.style.display = 'none';
            successAlert.style.display = 'none';

            fetch('/api/auth/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: name, email: email, password: password, role: role })
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok) {
                    return data;
                } else {
                    throw new Error(data.message || "Registration failed. Please check inputs.");
                }
            })
            .then(data => {
                successAlert.textContent = "Registration successful! Redirecting to login page...";
                successAlert.style.display = 'block';
                document.getElementById('registerForm').reset();
                setTimeout(() => {
                    window.location.href = '/login';
                }, 1500);
            })
            .catch(error => {
                errorAlert.textContent = error.message;
                errorAlert.style.display = 'block';
            });
        });
    </script>
</body>
</html>
