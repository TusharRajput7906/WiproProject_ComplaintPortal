<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Smart Complaint Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body>
    <div class="auth-container">
        <h2>Register Account</h2>
        <div id="errorAlert" class="alert alert-danger"></div>
        <div id="successAlert" class="alert alert-success"></div>
        
        <form id="registerForm">
            <div class="form-group">
                <label for="name">Full Name</label>
                <input type="text" id="name" required placeholder="Enter name">
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" required placeholder="Enter email">
            </div>
            
            <div class="form-group">
                <label for="password">Password (min 6 chars)</label>
                <input type="password" id="password" required minlength="6" placeholder="Enter password">
            </div>

            <div class="form-group">
                <label for="role">Register As</label>
                <select id="role" required>
                    <option value="CUSTOMER">Customer</option>
                    <option value="AGENT">Support Agent</option>
                    <option value="ADMIN">Administrator</option>
                </select>
            </div>
            
            <button type="submit" class="btn" style="width: 100%;">Register</button>
        </form>
        
        <a href="/login" class="auth-link">Already have an account? Login here</a>
    </div>

    <script>
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
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
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else if (response.status === 490 || response.status === 409) {
                    return response.json().then(data => {
                        throw new Error(data.message || "Email is already registered.");
                    });
                } else {
                    throw new Error("Registration failed. Please check inputs and try again.");
                }
            })
            .then(data => {
                successAlert.textContent = "Registration successful! Redirecting to login...";
                successAlert.style.display = 'block';
                document.getElementById('registerForm').reset();
                setTimeout(() => {
                    window.location.href = '/login';
                }, 2000);
            })
            .catch(error => {
                errorAlert.textContent = error.message;
                errorAlert.style.display = 'block';
            });
        });
    </script>
</body>
</html>
