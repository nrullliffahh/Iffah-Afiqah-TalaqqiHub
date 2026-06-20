<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.AiInteraction" %>
<%
    if (session == null || session.getAttribute("adminId") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    String ctx = request.getContextPath();
    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";

    int totalQuestions = request.getAttribute("totalQuestions") != null ? (Integer) request.getAttribute("totalQuestions") : 0;
    int studentQuestions = request.getAttribute("studentQuestions") != null ? (Integer) request.getAttribute("studentQuestions") : 0;
    int teacherQuestions = request.getAttribute("teacherQuestions") != null ? (Integer) request.getAttribute("teacherQuestions") : 0;
    String mostActiveRole = request.getAttribute("mostActiveRole") != null ? (String) request.getAttribute("mostActiveRole") : "—";

    @SuppressWarnings("unchecked")
    List<AiInteraction> interactions = (List<AiInteraction>) request.getAttribute("interactions");
    if (interactions == null) interactions = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Assistance - TalaqqiHub Admin</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        .stats-grid { grid-template-columns: repeat(4, 1fr); }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; }
        .stat-icon.purple { background: #f0fdfa; color: #0d9488; }
        .stat-icon.blue { background: #DBEAFE; color: #2563EB; }
        .stat-icon.green { background: #D1FAE5; color: #059669; }
        .stat-icon.yellow { background: #FEF3C7; color: #D97706; }
        .stat-value { font-size: 28px; font-weight: 700; line-height: 1.2; }
        .stat-value.blue { color: #2563EB; }
        .stat-value.green { color: #059669; }
        .stat-value.orange { color: #D97706; }
        .export-btns { display: flex; gap: 10px; flex-wrap: wrap; }
        .btn-export { padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1px solid #E2E8F0; background: white; color: #64748B; cursor: pointer; }
        .btn-export.primary { background: var(--admin-gradient); color: white; border: none; }
        .filters { display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 16px; margin-bottom: 16px; }
        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #94A3B8; }
        .search-wrap input { padding-left: 36px; }
        .records-info { font-size: 13px; color: #64748B; margin-bottom: 12px; }
        .records-table tbody tr:hover { background: #FAF5FF; }
        .role-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .role-student { background: #DBEAFE; color: #1D4ED8; }
        .role-teacher { background: #D1FAE5; color: #047857; }
        .btn-view { padding: 8px 16px; border-radius: 8px; background: var(--admin-gradient); color: white; border: none; font-size: 12px; font-weight: 600; cursor: pointer; }
        .preview-text { color: #64748B; max-width: 220px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,0.5); z-index: 200; display: none; align-items: center; justify-content: center; padding: 24px; }
        .modal-overlay.open { display: flex; }
        .modal { background: white; border-radius: 16px; width: 100%; max-width: 640px; max-height: 90vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
        .modal-header { padding: 24px 28px 16px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #E2E8F0; }
        .modal-title { font-size: 20px; font-weight: 700; }
        .modal-close { background: none; border: none; font-size: 22px; color: #94A3B8; cursor: pointer; }
        .modal-body { padding: 24px 28px; }
        .modal-meta { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px; }
        .meta-label { font-size: 12px; color: #64748B; margin-bottom: 4px; }
        .meta-value { font-size: 14px; font-weight: 600; }
        .section-label { display: flex; align-items: center; gap: 8px; font-size: 15px; font-weight: 700; margin-bottom: 10px; }
        .section-icon { width: 28px; height: 28px; border-radius: 50%; background: #f0fdfa; color: #0d9488; display: flex; align-items: center; justify-content: center; font-size: 13px; }
        .question-box { border: 1px solid #E2E8F0; border-radius: 12px; padding: 16px; margin-bottom: 20px; font-size: 14px; line-height: 1.6; }
        .response-box { border: 1px solid #C4B5FD; background: #FAF5FF; border-radius: 12px; padding: 16px; font-size: 14px; line-height: 1.7; white-space: pre-wrap; }
        .modal-footer { padding: 16px 28px 24px; }
        .btn-close-modal { width: 100%; padding: 14px; border-radius: 12px; border: 1px solid #E2E8F0; background: white; color: #64748B; font-size: 14px; font-weight: 600; cursor: pointer; }
        @media (max-width: 1100px) { .stats-grid, .filters { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 768px) { .stats-grid, .filters { grid-template-columns: 1fr; } }
        @media print { .export-btns, .filters, .btn-view { display: none !important; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="ai-assistance"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="AI Assistance"/>
        </jsp:include>

        <div class="page-content">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-circle-question"></i></div>
                    <div>
                        <div class="stat-value"><%= totalQuestions %></div>
                        <div class="stat-label">Total AI Questions</div>
                        <div class="stat-hint">Platform-wide queries</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-user-graduate"></i></div>
                    <div>
                        <div class="stat-value blue"><%= studentQuestions %></div>
                        <div class="stat-label">Student Questions</div>
                        <div class="stat-hint">From learners</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-book-open"></i></div>
                    <div>
                        <div class="stat-value green"><%= teacherQuestions %></div>
                        <div class="stat-label">Teacher Questions</div>
                        <div class="stat-hint">From educators</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon yellow"><i class="fas fa-star"></i></div>
                    <div>
                        <div class="stat-value orange"><%= mostActiveRole %></div>
                        <div class="stat-label">Most Active Role</div>
                        <div class="stat-hint">Primary users</div>
                    </div>
                </div>
            </div>

            <div class="records-panel" id="printArea">
                <div class="records-header">
                    <div class="records-title">AI Interaction History</div>
                    <div class="export-btns">
                        <button class="btn-export primary" onclick="exportCsv()"><i class="fas fa-file-pdf"></i> Export PDF</button>
                        <button class="btn-export" onclick="exportCsv()">CSV</button>
                        <button class="btn-export" onclick="exportCsv()">Excel</button>
                        <button class="btn-export" onclick="window.print()">Print</button>
                    </div>
                </div>

                <div class="filters">
                    <div>
                        <label class="filter-label">Search</label>
                        <div class="search-wrap">
                            <i class="fas fa-search"></i>
                            <input type="text" id="searchInput" class="filter-input" placeholder="Search by user or question..." oninput="filterTable()">
                        </div>
                    </div>
                    <div>
                        <label class="filter-label">User Role</label>
                        <select id="roleFilter" class="filter-select" onchange="filterTable()">
                            <option value="">All Roles</option>
                            <option value="Student">Student</option>
                            <option value="Teacher">Teacher</option>
                        </select>
                    </div>
                    <div>
                        <label class="filter-label">Category</label>
                        <select id="categoryFilter" class="filter-select" onchange="filterTable()">
                            <option value="">All Categories</option>
                            <option value="Tajweed Rules">Tajweed Rules</option>
                            <option value="Pronunciation">Pronunciation</option>
                            <option value="Memorization">Memorization</option>
                            <option value="Teaching Tips">Teaching Tips</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    <div>
                        <label class="filter-label">Date From</label>
                        <input type="date" id="dateFilter" class="filter-input" onchange="filterTable()">
                    </div>
                </div>

                <div class="records-info" id="recordsInfo">Showing 1-<%= interactions.size() %> of <%= interactions.size() %> interactions</div>

                <table class="records-table">
                    <thead>
                        <tr>
                            <th>User Role</th>
                            <th>User Name</th>
                            <th>Category</th>
                            <th>Question Preview</th>
                            <th>Response Preview</th>
                            <th>Date &amp; Time</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="interactionTable">
                        <% for (AiInteraction item : interactions) { %>
                        <tr data-role="<%= item.getUserRole() %>"
                            data-category="<%= item.getCategory() %>"
                            data-date="<%= item.getDateTime() %>"
                            data-search="<%= (item.getUserName() + " " + item.getQuestion() + " " + item.getCategory()).toLowerCase().replace("\"", "") %>"
                            data-question="<%= item.getQuestion().replace("\"", "&quot;") %>"
                            data-response="<%= item.getResponse().replace("\"", "&quot;").replace("\n", "&#10;") %>"
                            data-username="<%= item.getUserName() %>"
                            data-datetime="<%= item.getDateTime() %>">
                            <td><span class="role-badge <%= "Teacher".equals(item.getUserRole()) ? "role-teacher" : "role-student" %>"><%= item.getUserRole() %></span></td>
                            <td><strong><%= item.getUserName() %></strong></td>
                            <td><%= item.getCategory() %></td>
                            <td><div class="preview-text"><%= item.getQuestion() %></div></td>
                            <td><div class="preview-text"><%= item.getResponse() %></div></td>
                            <td><%= item.getDateTime() %></td>
                            <td><button class="btn-view" onclick="openModal(this.closest('tr'))">View</button></td>
                        </tr>
                        <% } %>
                        <% if (interactions.isEmpty()) { %>
                        <tr id="emptyRow"><td colspan="7" style="text-align:center;color:#94A3B8;padding:40px;">No AI interactions recorded yet.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="modal-overlay" id="modalOverlay" onclick="closeModal(event)">
        <div class="modal" onclick="event.stopPropagation()">
            <div class="modal-header">
                <div class="modal-title">AI Interaction Details</div>
                <button class="modal-close" onclick="document.getElementById('modalOverlay').classList.remove('open')">&times;</button>
            </div>
            <div class="modal-body">
                <div class="modal-meta">
                    <div>
                        <div class="meta-label">User Role</div>
                        <div class="meta-value" id="modalRole"></div>
                    </div>
                    <div>
                        <div class="meta-label">User Name</div>
                        <div class="meta-value" id="modalName"></div>
                    </div>
                    <div>
                        <div class="meta-label">Category</div>
                        <div class="meta-value" id="modalCategory"></div>
                    </div>
                    <div>
                        <div class="meta-label">Date &amp; Time</div>
                        <div class="meta-value" id="modalDate"></div>
                    </div>
                </div>
                <div class="section-label"><span class="section-icon"><i class="fas fa-question"></i></span> Question</div>
                <div class="question-box" id="modalQuestion"></div>
                <div class="section-label"><span class="section-icon"><i class="fas fa-microchip"></i></span> AI Response</div>
                <div class="response-box" id="modalResponse"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-close-modal" onclick="document.getElementById('modalOverlay').classList.remove('open')">Close</button>
            </div>
        </div>
    </div>

    <script>
        function filterTable() {
            const search = document.getElementById('searchInput').value.toLowerCase();
            const role = document.getElementById('roleFilter').value;
            const category = document.getElementById('categoryFilter').value;
            const dateFrom = document.getElementById('dateFilter').value;
            const rows = document.querySelectorAll('#interactionTable tr[data-role]');
            let visible = 0;
            rows.forEach(row => {
                const matchSearch = !search || row.dataset.search.includes(search);
                const matchRole = !role || row.dataset.role === role;
                const matchCat = !category || row.dataset.category === category;
                let matchDate = true;
                if (dateFrom && row.dataset.date && row.dataset.date !== '—') {
                    const parsed = new Date(row.dataset.date);
                    const filter = new Date(dateFrom);
                    matchDate = !isNaN(parsed.getTime()) && parsed >= filter;
                }
                const show = matchSearch && matchRole && matchCat && matchDate;
                row.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            const total = rows.length;
            document.getElementById('recordsInfo').textContent =
                total === 0 ? 'No interactions' :
                'Showing ' + (visible > 0 ? '1' : '0') + '-' + visible + ' of ' + total + ' interactions';
        }

        function openModal(row) {
            const role = row.dataset.role;
            document.getElementById('modalRole').innerHTML =
                '<span class="role-badge ' + (role === 'Teacher' ? 'role-teacher' : 'role-student') + '">' + role + '</span>';
            document.getElementById('modalName').textContent = row.dataset.username;
            document.getElementById('modalCategory').textContent = row.dataset.category;
            document.getElementById('modalDate').textContent = row.dataset.datetime;
            document.getElementById('modalQuestion').textContent = row.dataset.question;
            document.getElementById('modalResponse').textContent = row.dataset.response.replace(/&#10;/g, '\n');
            document.getElementById('modalOverlay').classList.add('open');
        }

        function closeModal(e) {
            if (e && e.target !== document.getElementById('modalOverlay')) return;
            document.getElementById('modalOverlay').classList.remove('open');
        }

        function exportCsv() {
            const rows = document.querySelectorAll('#interactionTable tr[data-role]');
            let csv = 'User Role,User Name,Category,Question,Response,Date Time\n';
            rows.forEach(row => {
                if (row.style.display === 'none') return;
                const cols = [
                    row.dataset.role,
                    row.dataset.username,
                    row.dataset.category,
                    '"' + row.dataset.question.replace(/"/g, '""') + '"',
                    '"' + row.dataset.response.replace(/&#10;/g, ' ').replace(/"/g, '""') + '"',
                    row.dataset.datetime
                ];
                csv += cols.join(',') + '\n';
            });
            const blob = new Blob([csv], { type: 'text/csv' });
            const a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'ai-interactions.csv';
            a.click();
        }
    </script>
</body>
</html>
