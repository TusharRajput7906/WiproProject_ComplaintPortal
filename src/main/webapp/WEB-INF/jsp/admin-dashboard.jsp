<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
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
            <span>Admin: <strong id="navUserName">Admin</strong></span>
            <button id="logoutBtn" class="btn-logout">Logout</button>
        </nav>
    </header>

    <div class="container">
        <h2>Dashboard Summary</h2>
        <div class="stats-container">
            <div class="stat-card">
                <h3>Total Complaints</h3>
                <p id="statTotalComplaints">0</p>
            </div>
            <div class="stat-card stat-open">
                <h3>Open</h3>
                <p id="statOpen">0</p>
            </div>
            <div class="stat-card stat-in-prog">
                <h3>In Progress</h3>
                <p id="statInProgress">0</p>
            </div>
            <div class="stat-card stat-resolved">
                <h3>Resolved</h3>
                <p id="statResolved">0</p>
            </div>
        </div>

        <h2>All Registered Complaints</h2>
        
        <div class="toolbar">
            <input type="text" id="complaintSearch" class="search-input" placeholder="Search by customer, title or category..." onkeyup="filterAdminComplaints()">
            <div>
                <label for="adminStatusFilter" style="font-weight: 600; font-size: 0.88rem; margin-right: 6px;">Status Filter:</label>
                <select id="adminStatusFilter" onchange="filterAdminComplaints()" style="padding: 6px 12px; border-radius: 6px; border: 1px solid var(--border-color);">
                    <option value="ALL">All Statuses</option>
                    <option value="OPEN">Open</option>
                    <option value="IN_PROGRESS">In Progress</option>
                    <option value="RESOLVED">Resolved</option>
                    <option value="CLOSED">Closed</option>
                </select>
            </div>
        </div>

        <div class="table-responsive">
            <table id="allComplaintsTable">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Customer</th>
                        <th>Complaint Details</th>
                        <th style="width: 120px;">Category</th>
                        <th style="width: 120px;">Status</th>
                        <th>Assigned Agent</th>
                        <th style="width: 200px;">Assign Agent</th>
                        <th style="width: 100px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="8" style="text-align: center;">Loading complaints...</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h2>Registered Users Management</h2>
        
        <div class="toolbar">
            <input type="text" id="userSearch" class="search-input" placeholder="Search users by name, email or role..." onkeyup="filterUsers()">
        </div>

        <div class="table-responsive">
            <table id="allUsersTable">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Full Name</th>
                        <th>Email Address</th>
                        <th style="width: 120px;">Role</th>
                        <th style="width: 180px;">Registered At</th>
                        <th style="width: 100px;">Actions</th>
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

    <!-- Complaint History Modal -->
    <div id="historyModal" class="modal-backdrop">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Complaint Audit Timeline</h3>
                <button class="modal-close" onclick="closeHistoryModal()">&times;</button>
            </div>
            <div id="modalDetails"></div>
            <div id="modalTimeline" class="timeline"></div>
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
        let allComplaints = [];
        let allUsers = [];

        // Fetch agents first to populate dropdowns
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
                    document.getElementById('statOpen').textContent = (stats.complaintsByStatus && stats.complaintsByStatus.OPEN) || 0;
                    document.getElementById('statInProgress').textContent = (stats.complaintsByStatus && stats.complaintsByStatus.IN_PROGRESS) || 0;
                    document.getElementById('statResolved').textContent = (stats.complaintsByStatus && stats.complaintsByStatus.RESOLVED) || 0;
                })
                .catch(err => console.error("Error fetching statistics:", err));
        }

        // Fetch All Complaints
        function loadAllComplaints() {
            return fetch('/api/admin/complaints')
                .then(res => res.json())
                .then(complaints => {
                    allComplaints = complaints;
                    renderAdminComplaints(complaints);
                })
                .catch(err => {
                    console.error("Error loading complaints:", err);
                    alert("Failed to load all complaints.");
                });
        }

        function renderAdminComplaints(complaints) {
            const tbody = document.querySelector('#allComplaintsTable tbody');
            tbody.innerHTML = '';

            if (complaints.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; color: var(--text-muted); padding: 24px;">No complaints registered in the system.</td></tr>';
                return;
            }

            complaints.forEach(c => {
                const tr = document.createElement('tr');
                const badge = getBadgeClass(c.status);
                
                // Build agent select dropdown
                let selectHtml = `<select onchange="assignAgent(\${c.id}, this.value)" style="width: 100%; padding: 6px; border-radius: 6px; border: 1px solid var(--border-color); font-size: 0.85rem;">`;
                selectHtml += '<option value="">-- Assign Agent --</option>';
                agentsList.forEach(agent => {
                    const selected = (c.assignedAgentId === agent.id) ? 'selected' : '';
                    selectHtml += `<option value="\${agent.id}" \${selected}>\${escapeHtml(agent.name)}</option>`;
                });
                selectHtml += '</select>';

                tr.innerHTML = `
                    <td><strong>#\${c.id}</strong></td>
                    <td><strong>\${escapeHtml(c.customerName || 'Customer')}</strong><br><small style="color: var(--text-muted);">User ID: \${c.customerId}</small></td>
                    <td><strong>\${escapeHtml(c.title)}</strong><br><small style="color: var(--text-muted);">\${escapeHtml(c.description)}</small></td>
                    <td><span class="tag-category">\${escapeHtml(c.category)}</span></td>
                    <td><span class="badge \${badge}">\${c.status}</span></td>
                    <td>\${c.assignedAgentName ? escapeHtml(c.assignedAgentName) : '<em style="color: var(--text-muted);">Unassigned</em>'}</td>
                    <td>\${selectHtml}</td>
                    <td>
                        <button class="btn btn-secondary btn-sm" onclick="viewHistory(\${c.id}, '\${escapeHtml(c.title)}')">Timeline</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function filterAdminComplaints() {
            const query = document.getElementById('complaintSearch').value.toLowerCase();
            const statusFilter = document.getElementById('adminStatusFilter').value;

            const filtered = allComplaints.filter(c => {
                const matchesQuery = (c.title && c.title.toLowerCase().includes(query)) || 
                                     (c.customerName && c.customerName.toLowerCase().includes(query)) ||
                                     (c.category && c.category.toLowerCase().includes(query)) ||
                                     (c.description && c.description.toLowerCase().includes(query));
                const matchesStatus = (statusFilter === 'ALL') || (c.status === statusFilter);
                return matchesQuery && matchesStatus;
            });

            renderAdminComplaints(filtered);
        }

        // Assign Agent
        function assignAgent(complaintId, agentId) {
            if (!agentId) return;

            fetch(`/api/admin/complaints/\${complaintId}/assign/\${agentId}`, {
                method: 'PUT'
            })
            .then(async res => {
                const data = await res.json();
                if (res.ok) return data;
                throw new Error(data.message || "Assignment failed.");
            })
            .then(data => {
                loadAllComplaints();
                loadStats();
            })
            .catch(err => {
                alert(err.message);
                loadAllComplaints();
            });
        }

        // Fetch All Users
        function loadAllUsers() {
            return fetch('/api/admin/users')
                .then(res => res.json())
                .then(users => {
                    allUsers = users;
                    renderUsersTable(users);
                })
                .catch(err => console.error("Error loading users:", err));
        }

        function renderUsersTable(users) {
            const tbody = document.querySelector('#allUsersTable tbody');
            tbody.innerHTML = '';

            users.forEach(u => {
                const tr = document.createElement('tr');
                const isSelf = String(u.id) === String(userId);
                const deleteBtnHtml = isSelf 
                    ? `<button class="btn btn-sm" style="background-color: #cbd5e1; color: #64748b; cursor: not-allowed;" disabled>Self</button>`
                    : `<button class="btn btn-danger btn-sm" onclick="deleteUser(\${u.id}, '\${escapeHtml(u.name)}')">Delete</button>`;

                tr.innerHTML = `
                    <td><strong>#\${u.id}</strong></td>
                    <td><strong>\${escapeHtml(u.name)}</strong></td>
                    <td>\${escapeHtml(u.email)}</td>
                    <td><span class="tag-category">\${u.role}</span></td>
                    <td>\${u.createdAt ? new Date(u.createdAt).toLocaleString() : 'N/A'}</td>
                    <td>\${deleteBtnHtml}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function filterUsers() {
            const query = document.getElementById('userSearch').value.toLowerCase();
            const filtered = allUsers.filter(u => 
                (u.name && u.name.toLowerCase().includes(query)) ||
                (u.email && u.email.toLowerCase().includes(query)) ||
                (u.role && u.role.toLowerCase().includes(query))
            );
            renderUsersTable(filtered);
        }

        // Delete User
        function deleteUser(targetUserId, targetName) {
            if (!confirm(`Are you sure you want to delete user "\${targetName}" (ID: \${targetUserId})?`)) {
                return;
            }

            fetch('/api/admin/users/' + targetUserId, {
                method: 'DELETE'
            })
            .then(async res => {
                if (res.ok) {
                    alert("User deleted successfully.");
                    loadAllUsers();
                    loadAllComplaints();
                    loadStats();
                } else {
                    const data = await res.json();
                    throw new Error(data.message || "Failed to delete user.");
                }
            })
            .catch(err => {
                alert(err.message);
            });
        }

        // View Complaint History Timeline
        function viewHistory(complaintId, title) {
            fetch('/api/complaints/' + complaintId + '/history')
                .then(res => res.json())
                .then(history => {
                    document.getElementById('modalDetails').innerHTML = `
                        <p><strong>Complaint #\${complaintId}:</strong> \${title}</p>
                    `;
                    const timelineEl = document.getElementById('modalTimeline');
                    timelineEl.innerHTML = '';

                    if (history.length === 0) {
                        timelineEl.innerHTML = '<p style="color: var(--text-muted);">No history logged yet.</p>';
                    } else {
                        history.forEach(h => {
                            const item = document.createElement('div');
                            item.className = 'timeline-item';
                            const badge = getBadgeClass(h.status);
                            const changedDate = h.changedAt ? new Date(h.changedAt).toLocaleString() : 'Recent';

                            item.innerHTML = `
                                <div class="timeline-time">\${changedDate} &bull; Updated by <strong>\${escapeHtml(h.changedByUserName || 'System')}</strong></div>
                                <div class="timeline-content">
                                    <span class="badge \${badge}">\${h.status}</span>
                                    <p style="margin-top: 6px;">\${escapeHtml(h.remarks || 'No remarks provided.')}</p>
                                </div>
                            `;
                            timelineEl.appendChild(item);
                        });
                    }

                    document.getElementById('historyModal').style.display = 'flex';
                })
                .catch(err => {
                    console.error(err);
                    alert("Unable to fetch complaint history.");
                });
        }

        function closeHistoryModal() {
            document.getElementById('historyModal').style.display = 'none';
        }

        function getBadgeClass(status) {
            switch(status) {
                case 'OPEN': return 'badge-open';
                case 'IN_PROGRESS': return 'badge-in-progress';
                case 'RESOLVED': return 'badge-resolved';
                case 'CLOSED': return 'badge-closed';
                default: return '';
            }
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        // Logout
        document.getElementById('logoutBtn').addEventListener('click', function() {
            sessionStorage.clear();
            window.location.href = '/login';
        });

        // Initialize Page
        loadAgents().then(() => {
            loadStats();
            loadAllComplaints();
            loadAllUsers();
        });
    </script>
</body>
</html>
