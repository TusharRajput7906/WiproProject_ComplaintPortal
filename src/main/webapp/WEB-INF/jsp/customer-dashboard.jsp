<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard - Smart Complaint Portal</title>
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body>
    <header>
        <h1>Smart Complaint Portal</h1>
        <nav>
            Welcome, <span id="navUserName">Customer</span>
            <button id="logoutBtn">Logout</button>
        </nav>
    </header>

    <div class="container">
        <h2>Raise a New Complaint</h2>
        <div id="errorAlert" class="alert alert-danger"></div>
        <div id="successAlert" class="alert alert-success"></div>

        <form id="complaintForm">
            <div class="form-group">
                <label for="title">Complaint Title</label>
                <input type="text" id="title" required placeholder="Brief title of the issue">
            </div>

            <div class="form-group">
                <label for="category">Category</label>
                <select id="category" required>
                    <option value="Broadband">Broadband/Internet</option>
                    <option value="Billing">Billing/Finance</option>
                    <option value="Hardware">Hardware/Device</option>
                    <option value="General">General Enquiry</option>
                </select>
            </div>

            <div class="form-group">
                <label for="description">Detailed Description</label>
                <textarea id="description" rows="5" required placeholder="Explain your issue in detail..."></textarea>
            </div>

            <button type="submit" class="btn">Submit Complaint</button>
        </form>

        <h2>Your Complaints History</h2>
        <table id="complaintsTable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Status</th>
                    <th>Agent Assigned</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="6" style="text-align: center;">Loading your complaints...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <script>
        // Check session storage
        const userId = sessionStorage.getItem('userId');
        const userName = sessionStorage.getItem('userName');
        const userRole = sessionStorage.getItem('userRole');

        if (!userId || userRole !== 'CUSTOMER') {
            window.location.href = '/login';
        } else {
            document.getElementById('navUserName').textContent = userName;
        }

        // Fetch Complaints
        function loadComplaints() {
            fetch('/api/complaints/customer/' + userId)
                .then(res => res.json())
                .then(complaints => {
                    const tbody = document.querySelector('#complaintsTable tbody');
                    tbody.innerHTML = '';
                    
                    if (complaints.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">You have not registered any complaints yet.</td></tr>';
                        return;
                    }

                    complaints.forEach(c => {
                        const tr = document.createElement('tr');
                        tr.innerHTML = `
                            <td>\${c.id}</td>
                            <td><strong>\${c.title}</strong><br><small>\${c.description}</small></td>
                            <td>\${c.category}</td>
                            <td><span style="font-weight: bold; color: \${getStatusColor(c.status)};">\${c.status}</span></td>
                            <td>\${c.assignedAgentName ? c.assignedAgentName : '<em>Not Assigned Yet</em>'}</td>
                            <td>\${c.createdAt ? new Date(c.createdAt).toLocaleString() : 'Just now'}</td>
                        `;
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    console.error("Error loading complaints:", err);
                    alert("Failed to load complaints history.");
                });
        }

        function getStatusColor(status) {
            switch(status) {
                case 'OPEN': return '#dc3545';
                case 'IN_PROGRESS': return '#ffc107';
                case 'RESOLVED': return '#28a745';
                case 'CLOSED': return '#6c757d';
                default: return '#333';
            }
        }

        // Handle Complaint Submission
        document.getElementById('complaintForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const title = document.getElementById('title').value;
            const category = document.getElementById('category').value;
            const description = document.getElementById('description').value;

            const errorAlert = document.getElementById('errorAlert');
            const successAlert = document.getElementById('successAlert');
            
            errorAlert.style.display = 'none';
            successAlert.style.display = 'none';

            fetch('/api/complaints', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    title: title,
                    category: category,
                    description: description,
                    customerId: parseInt(userId)
                })
            })
            .then(res => {
                if (res.ok) return res.json();
                throw new Error("Failed to submit complaint. Try again.");
            })
            .then(data => {
                successAlert.textContent = "Complaint registered successfully!";
                successAlert.style.display = 'block';
                document.getElementById('complaintForm').reset();
                loadComplaints();
            })
            .catch(err => {
                errorAlert.textContent = err.message;
                errorAlert.style.display = 'block';
            });
        });

        // Logout
        document.getElementById('logoutBtn').addEventListener('click', function() {
            sessionStorage.clear();
            window.location.href = '/login';
        });

        // Initial Load
        loadComplaints();
    </script>
</body>
</html>
