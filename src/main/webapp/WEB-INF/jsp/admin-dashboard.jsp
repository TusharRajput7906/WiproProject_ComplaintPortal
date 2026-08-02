<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Smart Complaint Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body>
    <header>
        <h1>Smart Complaint Portal</h1>
        <nav>
            Welcome, <span id="navUserName">Admin</span>
            <button id="logoutBtn">Logout</button>
        </nav>
    </header>

    <div class="container">
        <h2>Dashboard Summary</h2>
        <div class="stats-container">
            <div class="stat-card">
                <h3>Total Complaints</h3>
                <p id="statTotalComplaints">0</p>
            </div>
            <div class="stat-card">
                <h3>Open</h3>
                <p id="statOpen">0</p>
            </div>
            <div class="stat-card">
                <h3>In Progress</h3>
                <p id="statInProgress">0</p>
            </div>
            <div class="stat-card">
                <h3>Resolved</h3>
                <p id="statResolved">0</p>
            </div>
        </div>

        <h2>All Registered Complaints</h2>
        <div class="table-responsive">
            <table id="allComplaintsTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Details</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Assigned Agent</th>
                        <th>Assign Agent</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="7" style="text-align: center;">Loading complaints...</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h2>Registered Users</h2>
        <div class="table-responsive">
            <table id="allUsersTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="6" style="text-align: center;">Loading users...</td>
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

        if (!userId || userRole !== 'ADMIN') {
            window.location.href = '/login';
        } else {
            document.getElementById('navUserName').textContent = userName;
        }

        let agentsList = [];

        // Fetch agents first to populate dropdowns later
        function loadAgents() {
            return fetch('/api/admin/users/role/AGENT')
                .then(res => res.json())
                .then(agents => {
                    agentsList = agents;
                })
                .catch(err => console.error("Error fetching agents:", err));
        }

        // Fetch Stats
        function loadStats() {
            fetch('/api/admin/dashboard/stats')
                .then(res => res.json())
                .then(stats => {
                    document.getElementById('statTotalComplaints').textContent = stats.totalComplaints;
                    document.getElementById('statOpen').textContent = stats.complaintsByStatus.OPEN || 0;
                    document.getElementById('statInProgress').textContent = stats.complaintsByStatus.IN_PROGRESS || 0;
                    document.getElementById('statResolved').textContent = stats.complaintsByStatus.RESOLVED || 0;
                })
                .catch(err => console.error("Error fetching statistics:", err));
        }

        // Fetch All Complaints
        function loadAllComplaints() {
            fetch('/api/admin/complaints')
                .then(res => res.json())
                .then(complaints => {
                    const tbody = document.querySelector('#allComplaintsTable tbody');
                    tbody.innerHTML = '';

                    if (complaints.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center;">No complaints registered in the system.</td></tr>';
                        return;
                    }

                    complaints.forEach(c => {
                        const tr = document.createElement('tr');
                        
                        // Build agent select dropdown
                        let selectHtml = `<select onchange="assignAgent(\${c.id}, this.value)" style="padding: 4px; border-radius: 4px;">`;
                        selectHtml += '<option value="">-- Choose Agent --</option>';
                        agentsList.forEach(agent => {
                            const selected = c.assignedAgentId === agent.id ? 'selected' : '';
                            selectHtml += `<option value="\${agent.id}" \${selected}>\${agent.name}</option>`;
                        });
                        selectHtml += '</select>';

                        tr.innerHTML = `
                            <td>\${c.id}</td>
                            <td><strong>\${c.customerName}</strong><br><small>ID: \${c.customerId}</small></td>
                            <td><strong>\${c.title}</strong><br><small>\${c.description}</small></td>
                            <td>\${c.category}</td>
                            <td><span style="font-weight: bold; color: \${getStatusColor(c.status)};">\${c.status}</span></td>
                            <td>\${c.assignedAgentName ? c.assignedAgentName : '<em>Unassigned</em>'}</td>
                            <td>\${selectHtml}</td>
                        `;
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    console.error("Error loading complaints:", err);
                    alert("Failed to load all complaints.");
                });
        }

        // Assign Agent
        function assignAgent(complaintId, agentId) {
            if (!agentId) return;

            fetch(`/api/admin/complaints/\${complaintId}/assign/\${agentId}`, {
                method: 'PUT'
            })
            .then(res => {
                if (res.ok) return res.json();
                throw new Error("Assignment failed.");
            })
            .then(data => {
                alert("Agent assigned successfully!");
                loadAllComplaints();
                loadStats();
            })
            .catch(err => {
                alert(err.message);
            });
        }

        // Fetch All Users
        function loadAllUsers() {
            fetch('/api/admin/users')
                .then(res => res.json())
                .then(users => {
                    const tbody = document.querySelector('#allUsersTable tbody');
                    tbody.innerHTML = '';

                    users.forEach(u => {
                        const tr = document.createElement('tr');
                        const isSelf = String(u.id) === String(userId);
                        const deleteBtnHtml = isSelf 
                            ? `<button class="btn" style="background-color: #cbd5e1; color: #64748b; cursor: not-allowed; padding: 4px 8px; font-size: 0.85rem;" disabled>Delete</button>`
                            : `<button class="btn" style="background-color: #dc3545; padding: 4px 8px; font-size: 0.85rem;" onclick="deleteUser(\${u.id})">Delete</button>`;

                        tr.innerHTML = `
                            <td>\${u.id}</td>
                            <td>\${u.name}</td>
                            <td>\${u.email}</td>
                            <td><strong>\${u.role}</strong></td>
                            <td>\${u.createdAt ? new Date(u.createdAt).toLocaleString() : 'N/A'}</td>
                            <td>\${deleteBtnHtml}</td>
                        `;
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => console.error("Error loading users:", err));
        }

        // Delete User
        function deleteUser(targetUserId) {
            if (!confirm("Are you sure you want to delete this user?")) {
                return;
            }

            fetch('/api/admin/users/' + targetUserId, {
                method: 'DELETE'
            })
            .then(res => {
                if (res.ok) {
                    alert("User deleted successfully!");
                    loadAllUsers();
                    loadAllComplaints();
                    loadStats();
                } else {
                    return res.json().then(data => {
                        throw new Error(data.message || "Failed to delete user.");
                    });
                }
            })
            .catch(err => {
                alert(err.message);
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

        // Logout
        document.getElementById('logoutBtn').addEventListener('click', function() {
            sessionStorage.clear();
            window.location.href = '/login';
        });

        // Initialize Page
        loadAgents()
            .then(() => {
                loadStats();
                loadAllComplaints();
                loadAllUsers();
            });
    </script>
</body>
</html>
