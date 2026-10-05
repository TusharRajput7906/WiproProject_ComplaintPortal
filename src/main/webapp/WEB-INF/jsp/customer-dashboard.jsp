<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - Smart Complaint Portal</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
</head>
<body>
    <header>
        <h1>Smart Complaint Portal</h1>
        <nav>
            <span>Customer: <strong id="navUserName">Customer</strong></span>
            <button id="logoutBtn" class="btn-logout">Logout</button>
        </nav>
    </header>

    <div class="container">
        <!-- Summary Stats -->
        <div class="stats-container">
            <div class="stat-card">
                <h3>Total Complaints</h3>
                <p id="totalCount">0</p>
            </div>
            <div class="stat-card stat-open">
                <h3>Open</h3>
                <p id="openCount">0</p>
            </div>
            <div class="stat-card stat-in-prog">
                <h3>In Progress</h3>
                <p id="inProgressCount">0</p>
            </div>
            <div class="stat-card stat-resolved">
                <h3>Resolved</h3>
                <p id="resolvedCount">0</p>
            </div>
        </div>

        <h2>Raise a New Complaint</h2>
        <div id="errorAlert" class="alert alert-danger"></div>
        <div id="successAlert" class="alert alert-success"></div>

        <form id="complaintForm">
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label for="title">Complaint Title *</label>
                    <input type="text" id="title" required placeholder="Brief title (e.g. Internet Disconnection)" maxlength="255">
                </div>

                <div class="form-group">
                    <label for="category">Category *</label>
                    <select id="category" required>
                        <option value="Broadband">Broadband / Internet</option>
                        <option value="Billing">Billing & Payments</option>
                        <option value="Hardware">Hardware & Equipment</option>
                        <option value="General">General Inquiries</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="description">Detailed Description *</label>
                <textarea id="description" rows="4" required placeholder="Provide clear details regarding the issue you are experiencing..."></textarea>
            </div>

            <button type="submit" class="btn">Submit Complaint</button>
        </form>

        <h2>Your Complaints History</h2>

        <div class="toolbar">
            <input type="text" id="searchInput" class="search-input" placeholder="Search by title or category..." onkeyup="filterComplaints()">
            <div>
                <label for="statusFilter" style="font-weight: 600; font-size: 0.88rem; margin-right: 6px;">Filter Status:</label>
                <select id="statusFilter" onchange="filterComplaints()" style="padding: 6px 12px; border-radius: 6px; border: 1px solid var(--border-color);">
                    <option value="ALL">All Statuses</option>
                    <option value="OPEN">Open</option>
                    <option value="IN_PROGRESS">In Progress</option>
                    <option value="RESOLVED">Resolved</option>
                    <option value="CLOSED">Closed</option>
                </select>
            </div>
        </div>

        <div class="table-responsive">
            <table id="complaintsTable">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Title & Description</th>
                        <th style="width: 130px;">Category</th>
                        <th style="width: 130px;">Status</th>
                        <th>Assigned Agent</th>
                        <th style="width: 170px;">Created At</th>
                        <th style="width: 110px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="7" style="text-align: center;">Loading your complaints...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Complaint History Modal -->
    <div id="historyModal" class="modal-backdrop">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Complaint Activity & Remarks Log</h3>
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

        if (!userId || userRole !== 'CUSTOMER') {
            window.location.href = '/login';
        } else {
            document.getElementById('navUserName').textContent = userName;
        }

        let allUserComplaints = [];

        // Fetch Complaints
        function loadComplaints() {
            fetch('/api/complaints/customer/' + userId)
                .then(res => res.json())
                .then(complaints => {
                    allUserComplaints = complaints;
                    updateStats(complaints);
                    renderComplaintsTable(complaints);
                })
                .catch(err => {
                    console.error("Error loading complaints:", err);
                    alert("Failed to load complaints history.");
                });
        }

        function updateStats(complaints) {
            let total = complaints.length;
            let open = complaints.filter(c => c.status === 'OPEN').length;
            let inProg = complaints.filter(c => c.status === 'IN_PROGRESS').length;
            let resolved = complaints.filter(c => c.status === 'RESOLVED').length;

            document.getElementById('totalCount').textContent = total;
            document.getElementById('openCount').textContent = open;
            document.getElementById('inProgressCount').textContent = inProg;
            document.getElementById('resolvedCount').textContent = resolved;
        }

        function renderComplaintsTable(complaints) {
            const tbody = document.querySelector('#complaintsTable tbody');
            tbody.innerHTML = '';
            
            if (complaints.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">No complaints found.</td></tr>';
                return;
            }

            complaints.forEach(c => {
                const tr = document.createElement('tr');
                const badgeClass = getBadgeClass(c.status);
                const createdDate = c.createdAt ? new Date(c.createdAt).toLocaleString() : 'Just now';

                tr.innerHTML = `
                    <td><strong>#\${c.id}</strong></td>
                    <td><strong>\${escapeHtml(c.title)}</strong><br><small style="color: var(--text-muted);">\${escapeHtml(c.description)}</small></td>
                    <td><span class="tag-category">\${escapeHtml(c.category)}</span></td>
                    <td><span class="badge \${badgeClass}">\${c.status}</span></td>
                    <td>\${c.assignedAgentName ? escapeHtml(c.assignedAgentName) : '<em style="color: var(--text-muted);">Unassigned</em>'}</td>
                    <td>\${createdDate}</td>
                    <td>
                        <button class="btn btn-secondary btn-sm" onclick="viewHistory(\${c.id}, '\${escapeHtml(c.title)}')">Timeline</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function filterComplaints() {
            const query = document.getElementById('searchInput').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;

            const filtered = allUserComplaints.filter(c => {
                const matchesQuery = c.title.toLowerCase().includes(query) || 
                                     c.category.toLowerCase().includes(query) ||
                                     c.description.toLowerCase().includes(query);
                const matchesStatus = (statusFilter === 'ALL') || (c.status === statusFilter);
                return matchesQuery && matchesStatus;
            });

            renderComplaintsTable(filtered);
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

        // View History
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

        // Handle Complaint Submission
        document.getElementById('complaintForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const title = document.getElementById('title').value.trim();
            const category = document.getElementById('category').value;
            const description = document.getElementById('description').value.trim();

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
            .then(async res => {
                const data = await res.json();
                if (res.ok) return data;
                throw new Error(data.message || "Failed to submit complaint.");
            })
            .then(data => {
                successAlert.textContent = "Complaint #" + data.id + " registered successfully!";
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
