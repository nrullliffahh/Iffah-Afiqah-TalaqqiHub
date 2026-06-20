<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Schedule - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        @media print {
            .sidebar, .top-navbar, .no-print { display: none !important; }
            .main-content { margin-left: 0 !important; }
            #classRecordsTable td:last-child, #classRecordsTable th:last-child { display: none; }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="class-schedule"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Class Schedule"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Class Schedule Management</h1>
            <p class="page-subtitle">Monitor all class activities across the TalaqqiHub platform</p>

            <div class="stats-grid-4">
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-calendar"></i></div>
                    <div>
                        <div class="stat-value"><%= request.getAttribute("totalClasses") != null ? request.getAttribute("totalClasses") : "0" %></div>
                        <div class="stat-label">Total Classes Created</div>
                        <div class="stat-hint">All time class slots</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#10B981;"><%= request.getAttribute("totalBooked") != null ? request.getAttribute("totalBooked") : "0" %></div>
                        <div class="stat-label">Total Booked Classes</div>
                        <div class="stat-hint">Reserved by students</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red"><i class="fas fa-times-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#EF4444;"><%= request.getAttribute("cancelledCount") != null ? request.getAttribute("cancelledCount") : "0" %></div>
                        <div class="stat-label">Cancelled Classes</div>
                        <div class="stat-hint">Cancelled sessions</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber"><i class="fas fa-clock"></i></div>
                    <div>
                        <div class="stat-value" style="color:#F59E0B;"><%= request.getAttribute("rescheduledCount") != null ? request.getAttribute("rescheduledCount") : "0" %></div>
                        <div class="stat-label">Rescheduled Classes</div>
                        <div class="stat-hint">Modified schedules</div>
                    </div>
                </div>
            </div>

            <div class="records-panel">
                <div class="records-header">
                    <div class="records-title">Class Records</div>
                    <div class="export-btns no-print">
                        <button type="button" onclick="exportPDF()" class="btn-primary"><i class="fas fa-file-export"></i> Export PDF</button>
                        <button type="button" onclick="exportCSV()" class="btn-secondary">CSV</button>
                        <button type="button" onclick="exportExcel()" class="btn-secondary">Excel</button>
                        <button type="button" onclick="printTable()" class="btn-secondary"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>

                <div class="filters-5 no-print">
                    <div>
                        <label class="filter-label">Search</label>
                        <div class="search-wrap">
                            <i class="fas fa-search"></i>
                            <input id="filterSearch" type="text" placeholder="Search teacher or student..." oninput="applyFilters()" class="filter-input">
                        </div>
                    </div>
                    <div>
                        <label class="filter-label">Status</label>
                        <select id="filterStatus" onchange="applyFilters()" class="filter-select">
                            <option value="">All Status</option>
                            <option value="upcoming">Upcoming</option>
                            <option value="completed">Completed</option>
                            <option value="rescheduled">Rescheduled</option>
                            <option value="cancelled">Cancelled</option>
                        </select>
                    </div>
                    <div>
                        <label class="filter-label">Teacher</label>
                        <select id="filterTeacher" onchange="applyFilters()" class="filter-select">
                            <option value="">All Teachers</option>
                            <% java.util.List<java.util.Map<String, Object>> teacherList = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("teacherList");
                               if (teacherList != null) {
                                   for (java.util.Map<String, Object> t : teacherList) {
                                       String tn = t.get("teacherName") != null ? (String) t.get("teacherName") : "";
                            %>
                            <option value="<%= tn.toLowerCase() %>"><%= tn %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div>
                        <label class="filter-label">Date From</label>
                        <input id="filterDateFrom" type="date" onchange="applyFilters()" class="filter-input">
                    </div>
                    <div>
                        <label class="filter-label">Date To</label>
                        <input id="filterDateTo" type="date" onchange="applyFilters()" class="filter-input">
                    </div>
                </div>

                <p id="recordCount" class="records-info">Showing database class records</p>

                <div style="overflow-x:auto;">
                    <table id="classRecordsTable" class="records-table">
                        <thead>
                            <tr>
                                <th>Teacher Name</th>
                                <th>Student Name</th>
                                <th>Class Type</th>
                                <th>Date</th>
                                <th>Time</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                                        <% java.util.List<java.util.Map<String, Object>> records = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("classRecords");
                                           if (records != null && !records.isEmpty()) {
                                               for (java.util.Map<String, Object> r : records) {
                                                   String teacherName = r.get("teacherName") != null ? (String) r.get("teacherName") : "-";
                                                   String studentName = r.get("studentName") != null ? (String) r.get("studentName") : "-";
                                                   String className = r.get("className") != null ? (String) r.get("className") : "-";
                                                   java.util.Date schedDate = (java.util.Date) r.get("scheduleDate");
                                                   java.sql.Time start = (java.sql.Time) r.get("startTime");
                                                   java.sql.Time end = (java.sql.Time) r.get("endTime");
                                                   String status = r.get("status") != null ? (String) r.get("status") : "-";
                                                   String displayStatus = "-";
                                                   if (status != null) {
                                                       String s = status.trim().toLowerCase();
                                                       if (s.equals("booked") || s.equals("scheduled") || s.equals("available") || s.equals("confirmed") || s.equals("approved") || s.equals("upcoming")) {
                                                           displayStatus = "Upcoming";
                                                       } else if (s.equals("completed")) {
                                                           displayStatus = "Completed";
                                                       } else if (s.equals("rescheduled") || s.equals("reschedule")) {
                                                           displayStatus = "Rescheduled";
                                                       } else if (s.equals("cancelled") || s.equals("canceled")) {
                                                           displayStatus = "Cancelled";
                                                       } else {
                                                           // fallback: show status as-is but capitalized
                                                           displayStatus = status.substring(0,1).toUpperCase() + (status.length()>1?status.substring(1):"");
                                                       }
                                                   }
                                        %>
                                        <tr data-teacher="<%= teacherName.toLowerCase().replace("\"", "&quot;") %>"
                                            data-student="<%= studentName.toLowerCase().replace("\"", "&quot;") %>"
                                            data-status="<%= displayStatus.toLowerCase() %>"
                                            data-date="<%= schedDate != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(schedDate) : "" %>">
                                            <td style="font-weight:600;"><%= teacherName %></td>
                                            <td><%= studentName %></td>
                                            <td><%= className %></td>
                                            <td><%= schedDate != null ? new java.text.SimpleDateFormat("MMM d, yyyy").format(schedDate) : "-" %></td>
                                            <td><%= (start != null ? new java.text.SimpleDateFormat("h:mm a").format(start) : "-") + (end != null ? " - " + new java.text.SimpleDateFormat("h:mm a").format(end) : "") %></td>
                                            <td>
                                                <% if ("Upcoming".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="status-pill upcoming"><%= displayStatus %></span>
                                                <% } else if ("Completed".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="status-pill completed"><%= displayStatus %></span>
                                                <% } else if ("Rescheduled".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="status-pill rescheduled"><%= displayStatus %></span>
                                                <% } else if ("Cancelled".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="status-pill cancelled"><%= displayStatus %></span>
                                                <% } else { %>
                                                    <span class="status-pill default"><%= displayStatus %></span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <button type="button" onclick="viewAdminClassDetails('<%= r.get("scheduleId") %>')" class="btn-action">View</button>
                                            </td>
                                        </tr>
                                        <%   }
                                           } else { %>
                                        <tr id="noDataRow">
                                            <td colspan="7" class="empty-state">No class records found</td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
            </div>
        </div>
    </div>

<div id="adminClassDetailsModal" class="modal-overlay">
    <div class="modal-box wide" role="dialog" aria-modal="true">
        <div class="modal-header">
            <h3 class="modal-title">Class Details</h3>
            <button type="button" onclick="closeAdminClassDetails()" class="modal-close" aria-label="Close">&times;</button>
        </div>

        <div class="detail-grid">
            <div>
                <p class="detail-label">Teacher Name</p>
                <p id="admin-teacher-name" class="detail-value">-</p>
            </div>
            <div>
                <p class="detail-label">Student Name</p>
                <p id="admin-student-name" class="detail-value">-</p>
            </div>
            <div>
                <p class="detail-label">Class Type</p>
                <p id="admin-class-type" class="detail-value">-</p>
            </div>
            <div>
                <p class="detail-label">Status</p>
                <p id="admin-status" class="status-pill default">-</p>
            </div>
            <div>
                <p class="detail-label">Date</p>
                <p id="admin-date" class="detail-value">-</p>
            </div>
            <div>
                <p class="detail-label">Time</p>
                <p id="admin-time" class="detail-value">-</p>
            </div>
        </div>

        <div id="admin-cancellation-reason" class="alert-box" style="display:none;">
            <p class="alert-box-title">Cancellation Reason</p>
            <p id="admin-cancellation-text" class="alert-box-text"></p>
        </div>

        <div style="margin-top:24px;">
            <button type="button" onclick="closeAdminClassDetails()" class="btn-secondary" style="width:100%;justify-content:center;">Close</button>
        </div>
    </div>
</div>

<script>
    function viewAdminClassDetails(scheduleId) {
        fetch('<%= request.getContextPath() %>/teacher/class-details?scheduleId=' + encodeURIComponent(scheduleId))
            .then(res => {
                if (!res.ok) {
                    return res.text().then(text => { console.error('Details fetch failed', res.status, text); alert('Failed to load details (status ' + res.status + ')'); throw new Error('HTTP ' + res.status); });
                }
                const ct = res.headers.get('content-type') || '';
                if (ct.indexOf('application/json') === -1) {
                    return res.text().then(text => { console.error('Unexpected content-type for details:', ct, text); alert('Failed to load details (invalid response)'); throw new Error('Invalid content'); });
                }
                return res.json();
            })
            .then(data => {
                if (!data.success || !data.details) {
                    alert('Failed to load details');
                    return;
                }
                const d = data.details;
                document.getElementById('admin-teacher-name').textContent = d.teacherName || '-';
                document.getElementById('admin-student-name').textContent = d.studentName || '-';
                document.getElementById('admin-class-type').textContent = d.className || '-';

                // Status pill styling based on normalized status
                const statusEl = document.getElementById('admin-status');
                const status = d.status || '-';
                statusEl.textContent = status;
                statusEl.className = 'status-pill';
                if (status === 'Upcoming') {
                    statusEl.classList.add('upcoming');
                } else if (status === 'Completed') {
                    statusEl.classList.add('completed');
                } else if (status === 'Rescheduled') {
                    statusEl.classList.add('rescheduled');
                } else if (status === 'Cancelled') {
                    statusEl.classList.add('cancelled');
                } else {
                    statusEl.classList.add('default');
                }

                document.getElementById('admin-date').textContent = d.scheduleDate || '-';
                document.getElementById('admin-time').textContent = (d.startTime && d.endTime) ? d.startTime + ' - ' + d.endTime : (d.startTime || '-');

                if (status === 'Cancelled' && d.cancellationReason) {
                    document.getElementById('admin-cancellation-text').textContent = d.cancellationReason;
                    document.getElementById('admin-cancellation-reason').style.display = 'block';
                } else {
                    document.getElementById('admin-cancellation-reason').style.display = 'none';
                }

                const modal = document.getElementById('adminClassDetailsModal');
                modal.classList.add('open');
            })
            .catch(err => { console.error(err); alert('Failed to load class details'); });
    }

    function closeAdminClassDetails() {
        const modal = document.getElementById('adminClassDetailsModal');
        modal.classList.remove('open');
    }

    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('adminClassDetailsModal').addEventListener('click', function(e) {
            if (e.target === this) closeAdminClassDetails();
        });
        applyFilters();
    });

    function applyFilters() {
        const search = (document.getElementById('filterSearch').value || '').toLowerCase().trim();
        const status = (document.getElementById('filterStatus').value || '').toLowerCase();
        const teacher = (document.getElementById('filterTeacher').value || '').toLowerCase();
        const dateFrom = document.getElementById('filterDateFrom').value;
        const dateTo = document.getElementById('filterDateTo').value;

        const rows = document.querySelectorAll('#classRecordsTable tbody tr[data-teacher]');
        let visibleCount = 0;

        rows.forEach(function(row) {
            const rowTeacher = (row.dataset.teacher || '');
            const rowStudent = (row.dataset.student || '');
            const rowStatus = (row.dataset.status || '');
            const rowDate = (row.dataset.date || '');

            const matchSearch = !search || rowTeacher.includes(search) || rowStudent.includes(search);
            const matchStatus = !status || rowStatus === status;
            const matchTeacher = !teacher || rowTeacher === teacher;
            const matchDateFrom = !dateFrom || rowDate >= dateFrom;
            const matchDateTo = !dateTo || rowDate <= dateTo;

            const visible = matchSearch && matchStatus && matchTeacher && matchDateFrom && matchDateTo;
            row.style.display = visible ? '' : 'none';
            if (visible) visibleCount++;
        });

        const noDataRow = document.getElementById('noDataRow');
        const countEl = document.getElementById('recordCount');
        if (rows.length === 0) {
            countEl.textContent = 'No class records found';
        } else if (visibleCount === 0) {
            countEl.textContent = 'No records match the current filters';
            if (noDataRow) noDataRow.style.display = '';
        } else {
            countEl.textContent = 'Showing ' + visibleCount + ' of ' + rows.length + ' record' + (rows.length !== 1 ? 's' : '');
            if (noDataRow) noDataRow.style.display = 'none';
        }
    }

    function getTableCSV(separator) {
        const headers = ['Teacher Name', 'Student Name', 'Class Type', 'Date', 'Time', 'Status'];
        let lines = [headers.join(separator)];
        const rows = document.querySelectorAll('#classRecordsTable tbody tr[data-teacher]');
        rows.forEach(function(row) {
            if (row.style.display === 'none') return;
            const cells = row.querySelectorAll('td');
            const rowData = [0, 1, 2, 3, 4, 5].map(function(i) {
                const text = cells[i] ? cells[i].textContent.trim() : '';
                return '"' + text.replace(/"/g, '""') + '"';
            });
            lines.push(rowData.join(separator));
        });
        return lines.join('\n');
    }

    function downloadFile(content, filename, mimeType) {
        const blob = new Blob([content], { type: mimeType });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    function exportCSV() {
        downloadFile(getTableCSV(','), 'class-schedule.csv', 'text/csv');
    }

    function exportExcel() {
        downloadFile(getTableCSV('\t'), 'class-schedule.xls', 'application/vnd.ms-excel');
    }

    function printTable() {
        window.print();
    }

    function exportPDF() {
        window.print();
    }
</script>
</body>
</html>
