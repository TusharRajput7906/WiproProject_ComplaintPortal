<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Dashboard - Smart Complaint Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
    <style>
        .action-area {
            background-color: #f8f9fa;
            border: 1px solid #e2e8f0;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 6px;
            display: none;
        }
    </style>
</head>
<body>
    <header>
        <h1>Smart Complaint Portal</h1>
        <nav>
            Welcome, <span id="navUserName">Agent</span>
            <button id="logoutBtn">Logout</button>
        </nav>
    </header>

    <div class="container">
        <h2>Complaints Assigned to You</h2>

        <!-- Action Panel for Updating Status -->
        <div id="actionPanel" class="action-area">
            <h3>Update Status for Complaint #<span id="selectedComplaintId"></span></h3>
            <div id="formError" class="alert alert-danger"></div>
            
            <form id="statusUpdateForm">
                <input type="hidden" id="complaintIdField">
                
                <div class="form-group">
                    <label for="statusSelect">Select New Status</label>
                    <select id="statusSelect" required>
                        <option value="IN_PROGRESS">IN_PROGRESS</option>
                        <option value="RESOLVED">RESOLVED</option>
                        <option value="CLOSED">CLOSED</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="remarksField">Remarks / Update Notes</label>
                    <textarea id="remarksField" rows="3" required placeholder="Describe the update or resolution steps..."></textarea>
                </div>

                <button type="submit" class="btn">Apply Status Change</button>
                <button type="button" class="btn" style="background-color: #6c757d;" onclick="hideActionPanel()">Cancel</button>
            </form>
        </div>

        <div class="table-responsive">
            <table id="agentComplaintsTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Details</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="7" style="text-align: center;">Loading assigned complaints...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // Check session storage
        const userId = sessionStorage.getItem('userId');
        const userName = sessionStorage.getItem('userName');
        const userRole = sessionStorage.getItem('userRole');

        if (!userId || userRole !== 'AGENT') {
            window.location.href = '/login';
        } else {
            document.getElementById('navUserName').textContent = userName;
        }

        // Fetch Complaints
        function loadAgentComplaints() {
            fetch('/api/agent/' + userId + '/complaints')
                .then(res => res.json())
                .then(complaints => {
                    const tbody = document.querySelector('#agentComplaintsTable tbody');
                    tbody.innerHTML = '';

                    if (complaints.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center;">No complaints assigned to you at the moment.</td></tr>';
                        return;
                    }

                    complaints.forEach(c => {
                        const tr = document.createElement('tr');
                        tr.innerHTML = `
                            <td>\${c.id}</td>
                            <td><strong>\${c.customerName}</strong><br><small>ID: \${c.customerId}</small></td>
                            <td><strong>\${c.title}</strong><br><small>\${c.description}</small></td>
                            <td>\${c.category}</td>
                            <td><span style="font-weight: bold; color: \${getStatusColor(c.status)};">\${c.status}</span></td>
                            <td>\${c.createdAt ? new Date(c.createdAt).toLocaleString() : 'Just now'}</td>
                            <td>
                                <button class="btn" style="padding: 5px 10px; font-size: 0.85rem;" onclick="showActionPanel(\${c.id}, '\${c.status}')">Update Status</button>
                            </td>
                        `;
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    console.error("Error loading agent complaints:", err);
                    alert("Failed to load complaints list.");
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

        // Action Panel controls
        function showActionPanel(complaintId, currentStatus) {
            document.getElementById('selectedComplaintId').textContent = complaintId;
            document.getElementById('complaintIdField').value = complaintId;
            document.getElementById('statusSelect').value = currentStatus === 'OPEN' ? 'IN_PROGRESS' : currentStatus;
            document.getElementById('remarksField').value = '';
            document.getElementById('formError').style.display = 'none';
            document.getElementById('actionPanel').style.display = 'block';
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function hideActionPanel() {
            document.getElementById('actionPanel').style.display = 'none';
        }

        // Form Submit for Status Change
        document.getElementById('statusUpdateForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const complaintId = document.getElementById('complaintIdField').value;
            const newStatus = document.getElementById('statusSelect').value;
            const remarks = document.getElementById('remarksField').value;
            const formError = document.getElementById('formError');

            formError.style.display = 'none';

            fetch('/api/complaints/' + complaintId + '/status', {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    status: newStatus,
                    remarks: remarks,
                    changedByUserId: parseInt(userId)
                })
            })
            .then(res => {
                if (res.ok) return res.json();
                throw new Error("Failed to update status. Please try again.");
            })
            .then(data => {
                hideActionPanel();
                loadAgentComplaints();
                alert("Status updated successfully!");
            })
            .catch(err => {
                formError.textContent = err.message;
                formError.style.display = 'block';
            });
        });

        // Logout
        document.getElementById('logoutBtn').addEventListener('click', function() {
            sessionStorage.clear();
            window.location.href = '/login';
        });

        // Initial Load
        loadAgentComplaints();
    </script>
</body>
</html>
