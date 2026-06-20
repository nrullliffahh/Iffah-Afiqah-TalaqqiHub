<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Student" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Students - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        @media print { .filters, .export-btns, .filter-actions, .btn-action { display: none !important; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="manage-students"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Manage Students"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Manage Students</h1>
            <p class="page-subtitle">View and monitor all registered student profiles and account information</p>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="stat-value"><%= request.getAttribute("totalStudents") %></div>
                        <div class="stat-label">Total Students</div>
                        <div class="stat-hint">Registered learners</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#10B981;"><%= request.getAttribute("totalActive") %></div>
                        <div class="stat-label">Active Students</div>
                        <div class="stat-hint">Currently learning</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red"><i class="fas fa-times-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#EF4444;"><%= ((Integer)request.getAttribute("totalStudents")!=null?((Integer)request.getAttribute("totalStudents")).intValue():0) - ((Integer)request.getAttribute("totalActive")!=null?((Integer)request.getAttribute("totalActive")).intValue():0) %></div>
                        <div class="stat-label">Inactive Students</div>
                        <div class="stat-hint">Not currently active</div>
                    </div>
                </div>
            </div>

            <div class="records-panel">
                <div class="records-header">
                    <div class="records-title">Student List</div>
                    <div class="export-btns no-print">
                        <button type="button" onclick="exportPDF()" class="btn-primary"><i class="fas fa-file-export"></i> Export PDF</button>
                        <button type="button" onclick="exportCSV()" class="btn-secondary">CSV</button>
                        <button type="button" onclick="exportExcel()" class="btn-secondary">Excel</button>
                        <button type="button" onclick="window.print()" class="btn-secondary"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>

                <form method="get" action="<%= request.getContextPath() %>/admin/manage-students" class="no-print">
                    <div class="filters">
                        <div>
                            <label class="filter-label">Search</label>
                            <div class="search-wrap">
                                <i class="fas fa-search"></i>
                                <input type="text" name="search" value="<%= request.getAttribute("filterSearch") %>" placeholder="Search by name or email..." class="filter-input">
                            </div>
                        </div>
                        <div>
                            <label class="filter-label">Account Status</label>
                            <select name="status" class="filter-select">
                                <% String _fStatus = (String) request.getAttribute("filterStatus"); %>
                                <option value="">All Status</option>
                                <option value="Active"<%= "Active".equals(_fStatus) ? " selected" : "" %>>Active</option>
                                <option value="Inactive"<%= "Inactive".equals(_fStatus) ? " selected" : "" %>>Inactive</option>
                                <option value="Suspended"<%= "Suspended".equals(_fStatus) ? " selected" : "" %>>Suspended</option>
                            </select>
                        </div>
                        <div>
                            <label class="filter-label">Registration From</label>
                            <input type="date" name="regFrom" value="<%= request.getAttribute("filterRegFrom") %>" class="filter-input">
                        </div>
                    </div>
                    <div class="filter-actions">
                        <button type="submit" class="btn-primary">Apply Filters</button>
                        <a href="<%= request.getContextPath() %>/admin/manage-students" class="btn-secondary" style="text-decoration:none;display:inline-flex;align-items:center;">Clear</a>
                    </div>
                </form>

                <p class="records-info">Showing <%= request.getAttribute("totalStudents") %> students</p>

                <div class="table-responsive">
                    <table id="studentsTable" class="records-table">
                        <thead>
                            <tr>
                                <th>Student Name</th>
                                <th>Email</th>
                                <th>Phone Number</th>
                                <th>Date of Birth</th>
                                <th>Registration Date</th>
                                <th>Account Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<Student> students = (List<Student>) request.getAttribute("students");
                                if (students != null) {
                                    for (Student s : students) {
                            %>
                            <tr>
                                <td style="font-weight:600;"><%= s.getStudentName() != null ? s.getStudentName() : s.getName() %></td>
                                <td><%= s.getStudentEmail() != null ? s.getStudentEmail() : s.getEmail() %></td>
                                <td><%= s.getPhoneNumber() %></td>
                                <td><%= s.getDateOfBirth() %></td>
                                <td><%= s.getRegistrationDate() %></td>
                                <td>
                                    <%
                                        boolean __sActive = "Active".equalsIgnoreCase(s.getStudentStatus()) || "Active".equalsIgnoreCase(s.getStatus());
                                        String __sStatusText = s.getStudentStatus() != null ? s.getStudentStatus() : s.getStatus();
                                    %>
                                    <span class="status-badge <%= __sActive ? "status-active" : "status-inactive" %>"><%= __sStatusText %></span>
                                </td>
                                <td>
                                    <form method="get" action="<%= request.getContextPath() %>/admin/student-profile">
                                        <input type="hidden" name="studentId" value="<%= s.getStudentId() %>" />
                                        <button type="submit" class="btn-action">View Profile</button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7">No students found.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        function getTableData() {
            const table = document.getElementById('studentsTable');
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

        function exportCSV() {
            const data = getTableData();
            const csv = data.map(r => r.map(c => '"' + c.replace(/"/g,'""') + '"').join(',')).join('\n');
            const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'students.csv';
            link.click();
        }

        function exportExcel() {
            const data = getTableData();
            const csv = data.map(r => r.map(c => '"' + c.replace(/"/g,'""') + '"').join('\t')).join('\n');
            const blob = new Blob([csv], { type: 'application/vnd.ms-excel;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'students.xls';
            link.click();
        }

        function exportPDF() { window.print(); }
    </script>
</body>
</html>
