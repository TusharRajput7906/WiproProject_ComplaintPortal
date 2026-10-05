<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Dashboard - Smart Complaint Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body>
    <header>
        <h1>Smart Complaint Portal</h1>
        <nav>
            <span>Agent: <strong id="navUserName">Agent</strong></span>
            <button id="logoutBtn" class="btn-logout">Logout</button>
        </nav>
    </header>

    <div class="container">
        <!-- Summary Stats -->
        <div class="stats-container">
            <div class="stat-card">
                <h3>Assigned Tickets</h3>
                <p id="totalAssignedCount">0</p>
            </div>
            <div class="stat-card stat-open">
                <h3>Open</h3>
                <p id="openAssignedCount">0</p>
            </div>
            <div class="stat-card stat-in-prog">
                <h3>In Progress</h3>
                <p id="inProgAssignedCount">0</p>
            </div>
            <div class="stat-card stat-resolved">
                <h3>Resolved</h3>
                <p id="resolvedAssignedCount">0</p>
            </div>
        </div>

        <h2>Complaints Assigned to You</h2>

        <!-- Action Panel for Updating Status -->
        <div id="actionPanel" style="display: none; background-color: #f1f5f9; border: 1px solid var(--border-color); padding: 20px; margin-bottom: 24px; border-radius: var(--radius-md);">
            <h3 style="margin-bottom: 12px; color: var(--primary);">Update Status for Complaint #<span id="selectedComplaintId"></span></h3>
            <div id="formError" class="alert alert-danger"></div>
            
            <form id="statusUpdateForm">
                <input type="hidden" id="complaintIdField">
                
                <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 16px;">
                    <div class="form-group">
                        <label for="statusSelect">Select New Status *</label>
                        <select id="statusSelect" required>
                            <option value="IN_PROGRESS">IN_PROGRESS (Under Investigation)</option>
                            <option value="RESOLVED">RESOLVED (Issue Solved)</option>
                            <option value="CLOSED">CLOSED (Confirmed Closed)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="remarksField">Remarks / Resolution Notes *</label>
                        <textarea id="remarksField" rows="3" required placeholder="State details regarding action taken or resolution summary..."></textarea>
                    </div>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn">Apply Status Change</button>
                    <button type="button" class="btn btn-secondary" onclick="hideActionPanel()">Cancel</button>
                </div>
            </form>
        </div>

        <div class="toolbar">
            <input type="text" id="searchInput" class="search-input" placeholder="Search by customer, title or category..." onkeyup="filterAgentComplaints()">
            <div>
                <label for="statusFilter" style="font-weight: 600; font-size: 0.88rem; margin-right: 6px;">Filter Status:</label>
                <select id="statusFilter" onchange="filterAgentComplaints()" style="padding: 6px 12px; border-radius: 6px; border: 1px solid var(--border-color);">
                    <option value="ALL">All Statuses</option>
                    <option value="OPEN">Open</option>
                    <option value="IN_PROGRESS">In Progress</option>
                    <option value="RESOLVED">Resolved</option>
                    <option value="CLOSED">Closed</option>
                </select>
            </div>
        </div>

        <div class="table-responsive">
            <table id="agentComplaintsTable">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Customer</th>
                        <th>Complaint Details</th>
                        <th style="width: 130px;">Category</th>
                        <th style="width: 130px;">Status</th>
                        <th style="width: 170px;">Created At</th>
                        <th style="width: 200px;">Actions</th>
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

        if (!userId || userRole !== 'AGENT') {
            window.location.href = '/login';
        } else {
            document.getElementById('navUserName').textContent = userName;
        }

        let assignedComplaints = [];

        // Fetch Complaints
        function loadAgentComplaints() {
            fetch('/api/agent/' + userId + '/complaints')
                .then(res => res.json())
                .then(complaints => {
                    assignedComplaints = complaints;
                    updateAgentStats(complaints);
                    renderAgentTable(complaints);
                })
                .catch(err => {
                    console.error("Error loading agent complaints:", err);
                    alert("Failed to load complaints list.");
                });
        }

        function updateAgentStats(complaints) {
            document.getElementById('totalAssignedCount').textContent = complaints.length;
            document.getElementById('openAssignedCount').textContent = complaints.filter(c => c.status === 'OPEN').length;
            document.getElementById('inProgAssignedCount').textContent = complaints.filter(c => c.status === 'IN_PROGRESS').length;
            document.getElementById('resolvedAssignedCount').textContent = complaints.filter(c => c.status === 'RESOLVED').length;
        }

        function renderAgentTable(complaints) {
            const tbody = document.querySelector('#agentComplaintsTable tbody');
            tbody.innerHTML = '';

            if (complaints.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">No complaints assigned to you currently.</td></tr>';
                return;
            }

            complaints.forEach(c => {
                const tr = document.createElement('tr');
                const badge = getBadgeClass(c.status);
                const createdDate = c.createdAt ? new Date(c.createdAt).toLocaleString() : 'Just now';

                tr.innerHTML = `
                    <td><strong>#\${c.id}</strong></td>
                    <td><strong>\${escapeHtml(c.customerName || 'Customer')}</strong><br><small style="color: var(--text-muted);">User ID: \${c.customerId}</small></td>
                    <td><strong>\${escapeHtml(c.title)}</strong><br><small style="color: var(--text-muted);">\${escapeHtml(c.description)}</small></td>
                    <td><span class="tag-category">\${escapeHtml(c.category)}</span></td>
                    <td><span class="badge \${badge}">\${c.status}</span></td>
                    <td>\${createdDate}</td>
                    <td>
                        <div style="display: flex; gap: 6px;">
                            <button class="btn btn-sm" onclick="showActionPanel(\${c.id}, '\${c.status}')">Update</button>
                            <button class="btn btn-secondary btn-sm" onclick="viewHistory(\${c.id}, '\${escapeHtml(c.title)}')">Timeline</button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function filterAgentComplaints() {
            const query = document.getElementById('searchInput').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;

            const filtered = assignedComplaints.filter(c => {
                const matchesQuery = (c.title && c.title.toLowerCase().includes(query)) || 
                                     (c.customerName && c.customerName.toLowerCase().includes(query)) ||
                                     (c.category && c.category.toLowerCase().includes(query)) ||
                                     (c.description && c.description.toLowerCase().includes(query));
                const matchesStatus = (statusFilter === 'ALL') || (c.status === statusFilter);
                return matchesQuery && matchesStatus;
            });

            renderAgentTable(filtered);
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
            const remarks = document.getElementById('remarksField').value.trim();
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
            .then(async res => {
                const data = await res.json();
                if (res.ok) return data;
                throw new Error(data.message || "Failed to update status. Please try again.");
            })
            .then(data => {
                hideActionPanel();
                loadAgentComplaints();
            })
            .catch(err => {
                formError.textContent = err.message;
                formError.style.display = 'block';
            });
        });

        // View History Timeline
        function viewHistory(complaintId, title) {
            fetch('/api/agent/' + userId + '/complaints/' + complaintId + '/history')
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
                                <div class="timeline-time">\${changedDate} &bull; Logged by <strong>\${escapeHtml(h.changedByUserName || 'System')}</strong></div>
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
