<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Teachers - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        .modal-body { padding: 24px; text-align: center; }
        .modal-icon { width: 48px; height: 48px; border-radius: 50%; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; }
        .modal-text { font-size: 14px; color: #64748B; margin-bottom: 16px; line-height: 1.5; }
        .modal-textarea { width: 100%; margin-top: 8px; padding: 12px; border: 1px solid #E2E8F0; border-radius: 10px; font-size: 13px; font-family: inherit; resize: vertical; }
        .modal-textarea-label { display: block; text-align: left; font-size: 13px; color: #374151; font-weight: 600; }
        .modal-footer { display: flex; justify-content: center; gap: 12px; margin-top: 20px; }
        .profile-modal-box { background: white; border-radius: 20px; width: 75%; max-width: 768px; max-height: 80vh; overflow: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
        @media print { .filters, .export-btns, .filter-actions, .action-btns, .modal-overlay { display: none !important; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="manage-teachers"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Manage Teachers"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Manage Teachers</h1>
            <p class="page-subtitle">View teacher profiles and manage registration approvals</p>

            <div class="stats-grid-4">
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-chalkboard-user"></i></div>
                    <div>
                        <div class="stat-value"><%= request.getAttribute("totalTeachers") != null ? request.getAttribute("totalTeachers") : 0 %></div>
                        <div class="stat-label">Total Teachers</div>
                        <div class="stat-hint">All registered</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber"><i class="fas fa-clock"></i></div>
                    <div>
                        <div class="stat-value" style="color:#F59E0B;"><%= request.getAttribute("pendingTeachers") != null ? request.getAttribute("pendingTeachers") : 0 %></div>
                        <div class="stat-label">Pending Approval</div>
                        <div class="stat-hint">Awaiting review</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#10B981;"><%= request.getAttribute("approvedTeachers") != null ? request.getAttribute("approvedTeachers") : 0 %></div>
                        <div class="stat-label">Approved Teachers</div>
                        <div class="stat-hint">Active instructors</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red"><i class="fas fa-times-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#EF4444;"><%= request.getAttribute("rejectedTeachers") != null ? request.getAttribute("rejectedTeachers") : 0 %></div>
                        <div class="stat-label">Rejected</div>
                        <div class="stat-hint">Not approved</div>
                    </div>
                </div>
            </div>

            <div class="records-panel">
                <div class="records-header">
                    <div class="records-title">Teacher List</div>
                    <div class="export-btns no-print">
                        <button type="button" onclick="exportTeacherPDF()" class="btn-primary"><i class="fas fa-file-export"></i> Export PDF</button>
                        <button type="button" onclick="exportTeacherCSV()" class="btn-secondary">CSV</button>
                        <button type="button" onclick="exportTeacherExcel()" class="btn-secondary">Excel</button>
                        <button type="button" onclick="window.print()" class="btn-secondary"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>

                <form method="get" action="<%= request.getContextPath() %>/admin/manage-teachers" class="no-print">
                    <div class="filters">
                        <div>
                            <label class="filter-label">Search</label>
                            <div class="search-wrap">
                                <i class="fas fa-search"></i>
                                <input type="text" name="search" value="<%= request.getAttribute("filterSearch") %>" placeholder="Search by name or email..." class="filter-input">
                            </div>
                        </div>
                        <div>
                            <label class="filter-label">Approval Status</label>
                            <% String _tfStatus = (String) request.getAttribute("filterStatus"); %>
                            <select name="status" class="filter-select">
                                <option value="">All Status</option>
                                <option value="Approved"<%= "Approved".equals(_tfStatus) ? " selected" : "" %>>Approved</option>
                                <option value="Pending"<%= "Pending".equals(_tfStatus) ? " selected" : "" %>>Pending</option>
                                <option value="Rejected"<%= "Rejected".equals(_tfStatus) ? " selected" : "" %>>Rejected</option>
                            </select>
                        </div>
                        <div>
                            <label class="filter-label">Registration From</label>
                            <input type="date" name="regFrom" value="<%= request.getAttribute("filterRegFrom") %>" class="filter-input">
                        </div>
                    </div>
                    <div class="filter-actions">
                        <button type="submit" class="btn-primary">Apply Filters</button>
                        <a href="<%= request.getContextPath() %>/admin/manage-teachers" class="btn-secondary" style="text-decoration:none;display:inline-flex;align-items:center;">Clear</a>
                    </div>
                </form>

                <p class="records-info">Showing <%= request.getAttribute("totalTeachers") != null ? request.getAttribute("totalTeachers") : 0 %> teachers</p>

                <div class="table-responsive">
                    <table id="teachersTable" class="records-table">
                        <thead>
                            <tr>
                                <th>Teacher Name</th>
                                <th>Email</th>
                                <th>Phone Number</th>
                                <th>Specialty Area</th>
                                <th>Qualifications</th>
                                <th>Registration Date</th>
                                <th>Approval Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% java.util.List<model.Teacher> tlist = (java.util.List<model.Teacher>) request.getAttribute("teachers");
                               if (tlist != null && !tlist.isEmpty()) {
                                   for (model.Teacher t : tlist) {
                            %>
                            <tr data-teacher-id="<%= t.getTeacherId() != null ? t.getTeacherId() : "" %>" data-teacher-name="<%= t.getFullName() != null ? t.getFullName() : "" %>">
                                <td style="font-weight:600;"><%= t.getFullName() != null ? t.getFullName() : "-" %></td>
                                <td><%= t.getEmail() != null ? t.getEmail() : "-" %></td>
                                <td><%= t.getPhone() != null ? t.getPhone() : "-" %></td>
                                <td><%= t.getSpecialty() != null ? t.getSpecialty() : "-" %></td>
                                <td><%= t.getQualification() != null ? t.getQualification() : "-" %></td>
                                <td><%= t.getDateOfBirth() != null ? t.getDateOfBirth().toString() : "-" %></td>
                                <td>
                                    <% String st = t.getStatus() != null ? t.getStatus() : ""; %>
                                    <% if ("approved".equalsIgnoreCase(st)) { %>
                                        <span class="status-badge status-approved">Approved</span>
                                    <% } else if ("pending".equalsIgnoreCase(st)) { %>
                                        <span class="status-badge status-pending">Pending</span>
                                    <% } else if ("rejected".equalsIgnoreCase(st)) { %>
                                        <span class="status-badge status-rejected">Rejected</span>
                                    <% } else { %>
                                        <span class="status-badge status-default">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-btns">
                                        <form method="post" action="<%= request.getContextPath() %>/admin/manage-teachers" style="display:inline-block;">
                                            <input type="hidden" name="teacherId" value="<%= t.getTeacherId() != null ? t.getTeacherId() : "" %>" />
                                            <button type="button" class="js-action-btn btn-action" data-action="view">View</button>
                                        </form>
                                        <% if ("pending".equalsIgnoreCase(st)) { %>
                                            <button type="button" class="js-action-btn btn-action btn-approve" data-action="approve">Approve</button>
                                            <button type="button" class="js-action-btn btn-action btn-reject" data-action="reject">Reject</button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%   }
                               } else { %>
                            <tr>
                                <td colspan="8" style="text-align:center;color:#64748B;">No teachers found</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <form id="teacherActionForm" method="post" action="<%= request.getContextPath() %>/admin/manage-teachers" style="display:none;">
        <input type="hidden" name="teacherId" id="_act_teacherId" value="" />
        <input type="hidden" name="action" id="_act_action" value="" />
        <input type="hidden" name="reason" id="_act_reason" value="" />
    </form>

    <div id="teacherModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-body">
                <div id="modalIcon" class="modal-icon"></div>
                <h3 id="modalTitle" class="modal-title">Approve Teacher Registration</h3>
                <p id="modalBody" class="modal-text">Are you sure you want to approve <strong id="modalTeacherName"></strong> to start teaching on TalaqqiHub?</p>
                <div id="rejectionArea" style="display:none;">
                    <label class="modal-textarea-label">Rejection Reason (Optional)</label>
                    <textarea id="rejectionReason" class="modal-textarea" rows="4" placeholder="Provide a reason for rejection..."></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" id="modalCancel" class="btn-secondary">Cancel</button>
                    <button type="button" id="modalConfirm" class="btn-primary" style="background:#10B981;">Confirm</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function getTeacherTableData() {
            const table = document.getElementById('teachersTable');
            const rows = [];
            const headers = [];
            table.querySelectorAll('thead th').forEach(th => {
                const text = th.innerText.trim();
                if (text !== 'Actions') headers.push(text);
            });
            rows.push(headers);
            table.querySelectorAll('tbody tr').forEach(tr => {
                const cells = tr.querySelectorAll('td');
                if (cells.length > 1) {
                    const row = [];
                    cells.forEach((td, i) => { if (i < cells.length - 1) row.push(td.innerText.trim()); });
                    rows.push(row);
                }
            });
            return rows;
        }
        function exportTeacherCSV() {
            const data = getTeacherTableData();
            const csv = data.map(r => r.map(c => '"' + c.replace(/"/g,'""') + '"').join(',')).join('\n');
            const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'teachers.csv';
            link.click();
        }
        function exportTeacherExcel() {
            const data = getTeacherTableData();
            const tsv = data.map(r => r.map(c => '"' + c.replace(/"/g,'""') + '"').join('\t')).join('\n');
            const blob = new Blob([tsv], { type: 'application/vnd.ms-excel;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'teachers.xls';
            link.click();
        }
        function exportTeacherPDF() { window.print(); }

        (function(){
            const modal = document.getElementById('teacherModal');
            const modalTitle = document.getElementById('modalTitle');
            const modalBody = document.getElementById('modalBody');
            const modalTeacherName = document.getElementById('modalTeacherName');
            const modalIcon = document.getElementById('modalIcon');
            const rejectionArea = document.getElementById('rejectionArea');
            const rejectionReason = document.getElementById('rejectionReason');
            const modalCancel = document.getElementById('modalCancel');
            const modalConfirm = document.getElementById('modalConfirm');
            const actForm = document.getElementById('teacherActionForm');
            const actTeacherId = document.getElementById('_act_teacherId');
            const actAction = document.getElementById('_act_action');
            const actReason = document.getElementById('_act_reason');

            function openModal(action, teacherId, teacherName) {
                if (action === 'view') {
                    const ctx = '<%= request.getContextPath() %>';
                    fetch(ctx + '/admin/teacher-profile?teacherId=' + encodeURIComponent(teacherId || ''))
                        .then(res => {
                            if (!res.ok) throw new Error('Failed to load profile');
                            return res.text();
                        })
                        .then(html => {
                            let profileModal = document.getElementById('teacherProfileModal');
                            if (!profileModal) {
                                profileModal = document.createElement('div');
                                profileModal.id = 'teacherProfileModal';
                                profileModal.className = 'modal-overlay';
                                document.body.appendChild(profileModal);
                            }
                            profileModal.innerHTML = '<div class="profile-modal-box">' + html + '</div>';
                            profileModal.classList.add('open');
                        })
                        .catch(err => { alert('Could not load profile: ' + err.message); });
                    return;
                }

                modal.classList.add('open');
                modalTeacherName.textContent = teacherName || '';
                actTeacherId.value = teacherId || '';
                actAction.value = action || '';
                actReason.value = '';
                rejectionReason.value = '';

                if (action === 'approve') {
                    modalTitle.textContent = 'Approve Teacher Registration';
                    modalBody.innerHTML = 'Are you sure you want to approve <strong>' + (teacherName || '') + '</strong> to start teaching on TalaqqiHub?';
                    rejectionArea.style.display = 'none';
                    modalIcon.style.background = '#ecfdf5';
                    modalIcon.innerHTML = '<i class="fas fa-check" style="color:#10B981;font-size:20px;"></i>';
                    modalConfirm.style.background = 'linear-gradient(135deg, #10B981, #059669)';
                    modalConfirm.textContent = 'Approve';
                } else if (action === 'reject') {
                    modalTitle.textContent = 'Reject Teacher Registration';
                    modalBody.innerHTML = 'Are you sure you want to reject <strong>' + (teacherName || '') + '</strong>\'s registration?';
                    rejectionArea.style.display = 'block';
                    modalIcon.style.background = '#fff1f0';
                    modalIcon.innerHTML = '<i class="fas fa-times" style="color:#EF4444;font-size:20px;"></i>';
                    modalConfirm.style.background = 'linear-gradient(135deg, #EF4444, #DC2626)';
                    modalConfirm.textContent = 'Reject';
                }
            }

            function closeModal() {
                modal.classList.remove('open');
            }

            document.querySelectorAll('.js-action-btn').forEach(btn => {
                btn.addEventListener('click', function(){
                    const action = btn.getAttribute('data-action');
                    const row = btn.closest('tr');
                    const teacherId = row ? row.getAttribute('data-teacher-id') : '';
                    const teacherName = row ? row.getAttribute('data-teacher-name') : '';
                    openModal(action, teacherId, teacherName);
                });
            });

            modalCancel.addEventListener('click', function(){ closeModal(); });

            modalConfirm.addEventListener('click', function(){
                const action = actAction.value;
                if (action === 'reject') {
                    actReason.value = rejectionReason.value || '';
                }
                actForm.submit();
            });

            modal.addEventListener('click', function(e){
                if (e.target === modal) closeModal();
            });

            document.addEventListener('click', function(e){
                const profileModal = document.getElementById('teacherProfileModal');
                if (profileModal && e.target === profileModal) {
                    profileModal.classList.remove('open');
                }
            });
        })();
    </script>
</body>
</html>
