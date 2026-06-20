<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    if (session == null || session.getAttribute("adminId") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Announcements - TalaqqiHub Admin</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        .page-heading { font-size:28px; font-weight:700; margin-bottom:6px; }
        .page-subtitle { font-size:14px; color:#64748B; margin-bottom:24px; }
        .toolbar-card { background:white; border-radius:16px; padding:20px 24px; box-shadow:0 2px 12px rgba(0,0,0,0.06); margin-bottom:20px; border:1px solid #F1F5F9; }
        .toolbar-row { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
        .search-wrap { flex:1; min-width:220px; position:relative; }
        .search-wrap i { position:absolute; left:14px; top:50%; transform:translateY(-50%); color:#94A3B8; }
        .search-input { width:100%; padding:11px 14px 11px 40px; border:1px solid #E2E8F0; border-radius:10px; font-size:14px; outline:none; }
        .search-input:focus { border-color:#6d28d9; box-shadow:0 0 0 3px rgba(109,40,217,0.1); }
        .filter-select { padding:11px 32px 11px 14px; border:1px solid #E2E8F0; border-radius:10px; font-size:14px; background:white; appearance:none; cursor:pointer;
            background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2394A3B8' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
            background-repeat:no-repeat; background-position:right 12px center; }
        .icon-btn { width:42px; height:42px; border:1px solid #E2E8F0; border-radius:10px; background:white; color:#64748B; cursor:pointer; display:flex; align-items:center; justify-content:center; }
        .icon-btn:hover { background:#F8FAFC; }
        .btn-create { display:flex; align-items:center; gap:8px; padding:11px 20px; border:none; border-radius:10px;
            background:linear-gradient(135deg,#0f766e 0%,#6d28d9 100%); color:white; font-size:14px; font-weight:600; cursor:pointer; white-space:nowrap; }
        .btn-create:hover { opacity:0.92; }
        .result-info { font-size:13px; color:#64748B; margin-top:14px; }
        .announcement-card { background:white; border-radius:16px; padding:24px; box-shadow:0 2px 12px rgba(0,0,0,0.06);
            border:1px solid #F1F5F9; margin-bottom:16px; display:flex; justify-content:space-between; gap:24px; align-items:flex-start; }
        .announcement-card:hover { box-shadow:0 4px 16px rgba(0,0,0,0.08); }
        .card-main { flex:1; min-width:0; }
        .card-title { font-size:17px; font-weight:700; color:#1E293B; margin-bottom:10px; }
        .tag-row { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:12px; }
        .tag { display:inline-flex; align-items:center; padding:4px 12px; border-radius:999px; font-size:12px; font-weight:600; }
        .tag-source-admin { background:#f0fdfa; color:#0d9488; }
        .tag-source-teacher { background:#DBEAFE; color:#2563EB; }
        .tag-maintenance { background:#FEF3C7; color:#D97706; }
        .tag-notice { background:#FEE2E2; color:#DC2626; }
        .tag-holiday { background:#FFEDD5; color:#EA580C; }
        .tag-general { background:#F1F5F9; color:#475569; }
        .tag-class { background:#DBEAFE; color:#2563EB; }
        .card-body { font-size:14px; color:#64748B; line-height:1.6; margin-bottom:16px; }
        .card-meta { display:flex; gap:18px; flex-wrap:wrap; font-size:13px; color:#94A3B8; }
        .card-meta span { display:flex; align-items:center; gap:6px; }
        .card-actions { display:flex; flex-direction:column; gap:8px; flex-shrink:0; min-width:110px; }
        .btn-view { padding:8px 16px; border-radius:8px; border:1px solid #E2E8F0; background:white; color:#334155; font-size:13px; font-weight:600; cursor:pointer; }
        .btn-view:hover { background:#F8FAFC; }
        .btn-edit { padding:8px 16px; border-radius:8px; border:none; background:linear-gradient(135deg,#0f766e 0%,#6d28d9 100%); color:white; font-size:13px; font-weight:600; cursor:pointer; }
        .btn-delete { padding:8px 16px; border-radius:8px; border:1px solid #FECACA; background:white; color:#EF4444; font-size:13px; font-weight:600; cursor:pointer; }
        .btn-delete:hover { background:#FEF2F2; }
        .empty-state { text-align:center; padding:60px 20px; color:#94A3B8; }
        .modal-overlay { position:fixed; inset:0; background:rgba(15,23,42,0.5); z-index:200; display:none; align-items:center; justify-content:center; padding:24px; }
        .modal-overlay.open { display:flex; }
        .modal { background:white; border-radius:16px; width:100%; max-width:560px; max-height:90vh; overflow-y:auto; box-shadow:0 20px 60px rgba(0,0,0,0.2); }
        .modal-header { padding:20px 24px; border-bottom:1px solid #E2E8F0; display:flex; justify-content:space-between; align-items:center; }
        .modal-title { font-size:18px; font-weight:700; }
        .modal-close { background:#F1F5F9; border:none; width:32px; height:32px; border-radius:8px; cursor:pointer; color:#64748B; }
        .modal-body { padding:24px; }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#374151; margin-bottom:6px; }
        .form-group input, .form-group select, .form-group textarea { width:100%; padding:10px 14px; border:1px solid #E2E8F0; border-radius:10px; font-size:14px; font-family:inherit; outline:none; }
        .form-group textarea { min-height:110px; resize:vertical; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color:#6d28d9; box-shadow:0 0 0 3px rgba(109,40,217,0.1); }
        .modal-footer { padding:16px 24px; border-top:1px solid #E2E8F0; display:flex; justify-content:flex-end; gap:10px; }
        .btn-cancel { padding:10px 20px; border:1px solid #E2E8F0; border-radius:10px; background:white; color:#64748B; font-size:14px; font-weight:500; cursor:pointer; }
        .btn-save { padding:10px 20px; border:none; border-radius:10px; background:linear-gradient(135deg,#0f766e 0%,#6d28d9 100%); color:white; font-size:14px; font-weight:600; cursor:pointer; }
        .view-detail { margin-bottom:14px; }
        .view-detail label { font-size:11px; font-weight:600; color:#94A3B8; text-transform:uppercase; letter-spacing:0.05em; }
        .view-detail p { font-size:14px; color:#334155; margin-top:4px; line-height:1.5; }
        @media print { .toolbar-card, .card-actions, .btn-create, .icon-btn { display:none !important; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="announcements"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Announcements"/>
        </jsp:include>

        <div class="page-content">
            <h2 class="page-heading">Announcements</h2>
            <p class="page-subtitle">Manage system announcements and monitor teacher announcements.</p>

            <c:if test="${not empty flashMessage}"><div class="flash-success"><i class="fas fa-check-circle"></i> ${flashMessage}</div></c:if>
            <c:if test="${not empty flashError}"><div class="flash-error"><i class="fas fa-exclamation-circle"></i> ${flashError}</div></c:if>

            <div class="toolbar-card">
                <div class="toolbar-row">
                    <div class="search-wrap">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" class="search-input" placeholder="Search announcements...">
                    </div>
                    <select id="sourceFilter" class="filter-select">
                        <option value="all">All Sources</option>
                        <option value="admin">Talaqqi Admin</option>
                        <option value="teacher">Teachers</option>
                    </select>
                    <select id="sortBy" class="filter-select">
                        <option value="newest">Newest First</option>
                        <option value="oldest">Oldest First</option>
                        <option value="title">Title A-Z</option>
                    </select>
                    <button type="button" class="icon-btn" onclick="window.print()" title="Print"><i class="fas fa-print"></i></button>
                    <button type="button" class="icon-btn" onclick="exportCsv()" title="Download"><i class="fas fa-download"></i></button>
                    <button type="button" class="btn-create" id="createBtn"><i class="fas fa-plus"></i> Create Announcement</button>
                </div>
                <p class="result-info">Showing <span id="rangeStart">1</span>-<span id="rangeEnd">${announcementCount}</span> of <span id="totalCount">${announcementCount}</span> announcements</p>
            </div>

            <div id="announcementList">
                <c:choose>
                    <c:when test="${not empty announcements}">
                        <c:forEach var="ann" items="${announcements}" varStatus="st">
                            <c:set var="isAdmin" value="${empty ann.teacherId}" />
                            <c:set var="sourceLabel" value="${isAdmin ? 'Talaqqi Admin' : ann.author}" />
                            <c:set var="sourceClass" value="${isAdmin ? 'tag-source-admin' : 'tag-source-teacher'}" />
                            <c:set var="catLabel" value="General" />
                            <c:set var="catClass" value="tag-general" />
                            <c:if test="${ann.category eq 'Maintenance' or ann.category eq 'System Maintenance'}">
                                <c:set var="catLabel" value="System Maintenance" /><c:set var="catClass" value="tag-maintenance" />
                            </c:if>
                            <c:if test="${ann.category eq 'Important Notice' or ann.category eq 'General'}">
                                <c:if test="${isAdmin and ann.category eq 'General'}"><c:set var="catLabel" value="General" /></c:if>
                                <c:if test="${ann.category eq 'Important Notice'}"><c:set var="catLabel" value="Important Notice" /><c:set var="catClass" value="tag-notice" /></c:if>
                            </c:if>
                            <c:if test="${ann.category eq 'Holiday'}"><c:set var="catLabel" value="Holiday" /><c:set var="catClass" value="tag-holiday" /></c:if>
                            <c:if test="${ann.category eq 'Class Cancelled' or ann.category eq 'Class Rescheduled'}"><c:set var="catLabel" value="Class Update" /><c:set var="catClass" value="tag-class" /></c:if>
                            <c:set var="audienceLabel" value="${ann.targetAudience}" />
                            <c:if test="${ann.targetAudience eq 'All Students & Teachers'}"><c:set var="audienceLabel" value="All Users" /></c:if>
                            <div class="announcement-card"
                                 data-index="${st.index}"
                                 data-title="${fn:toLowerCase(ann.title)}"
                                 data-description="${fn:toLowerCase(ann.description)}"
                                 data-author="${fn:toLowerCase(ann.author)}"
                                 data-date="${ann.date}"
                                 data-admin="${isAdmin}"
                                 data-id="${ann.announcementId}"
                                 data-raw-title="${fn:escapeXml(ann.title)}"
                                 data-raw-description="${fn:escapeXml(ann.description)}"
                                 data-raw-category="${fn:escapeXml(ann.category)}"
                                 data-raw-audience="${fn:escapeXml(ann.targetAudience)}"
                                 data-raw-author="${fn:escapeXml(ann.author)}">
                                <div class="card-main">
                                    <div class="card-title">${ann.title}</div>
                                    <div class="tag-row">
                                        <span class="tag ${sourceClass}">${sourceLabel}</span>
                                        <span class="tag ${catClass}">${catLabel}</span>
                                    </div>
                                    <p class="card-body">${ann.description}</p>
                                    <div class="card-meta">
                                        <span><i class="far fa-calendar"></i> ${ann.date}</span>
                                        <span><i class="fas fa-users"></i> ${audienceLabel}</span>
                                    </div>
                                </div>
                                <div class="card-actions">
                                    <button type="button" class="btn-view" onclick="viewAnnouncement(this)">View</button>
                                    <c:if test="${isAdmin}">
                                        <button type="button" class="btn-edit" onclick="editAnnouncement(this)">Edit</button>
                                        <button type="button" class="btn-delete" onclick="deleteAnnouncement(this)">Delete</button>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <i class="fas fa-bullhorn" style="font-size:48px;color:#CBD5E1;margin-bottom:16px;"></i>
                            <p style="font-size:16px;font-weight:600;color:#64748B;">No announcements yet</p>
                            <p style="font-size:14px;margin-top:8px;">Create your first system announcement.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="empty-state" id="noResults" style="display:none;">
                <i class="fas fa-search" style="font-size:48px;color:#CBD5E1;margin-bottom:16px;"></i>
                <p style="font-size:16px;font-weight:600;color:#64748B;">No matching announcements</p>
            </div>
        </div>
    </div>

    <!-- View Modal -->
    <div class="modal-overlay" id="viewModal">
        <div class="modal">
            <div class="modal-header">
                <div class="modal-title" id="viewTitle">Announcement</div>
                <button class="modal-close" type="button" onclick="closeModal('viewModal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="view-detail"><label>Source</label><p id="viewAuthor"></p></div>
                <div class="view-detail"><label>Category</label><p id="viewCategory"></p></div>
                <div class="view-detail"><label>Audience</label><p id="viewAudience"></p></div>
                <div class="view-detail"><label>Date</label><p id="viewDate"></p></div>
                <div class="view-detail"><label>Message</label><p id="viewDescription"></p></div>
            </div>
            <div class="modal-footer"><button class="btn-cancel" type="button" onclick="closeModal('viewModal')">Close</button></div>
        </div>
    </div>

    <!-- Form Modal -->
    <div class="modal-overlay" id="formModal">
        <div class="modal">
            <div class="modal-header">
                <div class="modal-title" id="formModalTitle">Create Announcement</div>
                <button class="modal-close" type="button" onclick="closeModal('formModal')"><i class="fas fa-times"></i></button>
            </div>
            <form id="announcementForm" method="post" action="<%= ctx %>/admin/announcements">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="announcementId" id="editId" value="">
                <div class="modal-body">
                    <div class="form-group">
                        <label for="formTitle">Title</label>
                        <input type="text" id="formTitle" name="title" placeholder="Enter announcement title" required>
                    </div>
                    <div class="form-group">
                        <label for="formCategory">Category</label>
                        <select id="formCategory" name="category">
                            <option value="System Maintenance">System Maintenance</option>
                            <option value="Important Notice">Important Notice</option>
                            <option value="Holiday">Holiday</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="formAudience">Target Audience</label>
                        <select id="formAudience" name="targetAudience">
                            <option value="All Students & Teachers">All Users</option>
                            <option value="All Students">All Students</option>
                            <option value="All Teachers">All Teachers</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="formDescription">Description</label>
                        <textarea id="formDescription" name="description" placeholder="Write announcement message..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-cancel" type="button" onclick="closeModal('formModal')">Cancel</button>
                    <button class="btn-save" type="submit">Save</button>
                </div>
            </form>
        </div>
    </div>

    <form id="deleteForm" method="post" action="<%= ctx %>/admin/announcements" style="display:none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="announcementId" id="deleteId">
    </form>

    <script>
        let currentSource = 'all', currentSort = 'newest';

        function getCard(btn) { return btn.closest('.announcement-card'); }

        function viewAnnouncement(btn) {
            const c = getCard(btn);
            document.getElementById('viewTitle').textContent = c.dataset.rawTitle;
            document.getElementById('viewAuthor').textContent = c.dataset.rawAuthor;
            document.getElementById('viewCategory').textContent = c.dataset.rawCategory;
            document.getElementById('viewAudience').textContent = c.dataset.rawAudience === 'All Students & Teachers' ? 'All Users' : c.dataset.rawAudience;
            document.getElementById('viewDate').textContent = c.dataset.date;
            document.getElementById('viewDescription').textContent = c.dataset.rawDescription;
            openModal('viewModal');
        }

        function editAnnouncement(btn) {
            const c = getCard(btn);
            if (c.dataset.admin !== 'true') {
                alert('You can only edit announcements created by Talaqqi Admin.');
                return;
            }
            document.getElementById('formModalTitle').textContent = 'Edit Announcement';
            document.getElementById('formAction').value = 'update';
            document.getElementById('editId').value = c.dataset.id;
            document.getElementById('formTitle').value = c.dataset.rawTitle;
            document.getElementById('formCategory').value = c.dataset.rawCategory;
            document.getElementById('formAudience').value = c.dataset.rawAudience;
            document.getElementById('formDescription').value = c.dataset.rawDescription;
            openModal('formModal');
        }

        function deleteAnnouncement(btn) {
            const c = getCard(btn);
            if (c.dataset.admin !== 'true') {
                alert('You can only delete announcements created by Talaqqi Admin.');
                return;
            }
            if (!confirm('Delete this announcement permanently?')) return;
            document.getElementById('deleteId').value = c.dataset.id;
            document.getElementById('deleteForm').submit();
        }

        function openModal(id) { document.getElementById(id).classList.add('open'); }
        function closeModal(id) { document.getElementById(id).classList.remove('open'); }

        function parseDate(str) { return str ? new Date(str).getTime() || 0 : 0; }

        function applyFilters() {
            const query = document.getElementById('searchInput').value.toLowerCase().trim();
            const cards = Array.from(document.querySelectorAll('.announcement-card'));
            const list = document.getElementById('announcementList');
            const visible = [];

            cards.forEach(card => {
                const matchSearch = !query || card.dataset.title.includes(query) || card.dataset.description.includes(query) || card.dataset.author.includes(query);
                let matchSource = true;
                if (currentSource === 'admin') matchSource = card.dataset.admin === 'true';
                if (currentSource === 'teacher') matchSource = card.dataset.admin !== 'true';
                const show = matchSearch && matchSource;
                card.style.display = show ? '' : 'none';
                if (show) visible.push(card);
            });

            if (currentSort === 'oldest') visible.sort((a,b) => parseDate(a.dataset.date) - parseDate(b.dataset.date));
            else if (currentSort === 'title') visible.sort((a,b) => a.dataset.title.localeCompare(b.dataset.title));
            else visible.sort((a,b) => parseDate(b.dataset.date) - parseDate(a.dataset.date));
            visible.forEach(card => list.appendChild(card));

            const count = visible.length;
            document.getElementById('rangeStart').textContent = count > 0 ? '1' : '0';
            document.getElementById('rangeEnd').textContent = count;
            document.getElementById('totalCount').textContent = cards.length;
            document.getElementById('noResults').style.display = (cards.length > 0 && count === 0) ? '' : 'none';
        }

        function exportCsv() {
            const rows = [['Title','Author','Category','Audience','Date','Description']];
            document.querySelectorAll('.announcement-card').forEach(c => {
                if (c.style.display === 'none') return;
                rows.push([c.dataset.rawTitle, c.dataset.rawAuthor, c.dataset.rawCategory, c.dataset.rawAudience, c.dataset.date, c.dataset.rawDescription.replace(/"/g,'""')]);
            });
            const csv = rows.map(r => r.map(v => '"' + (v||'') + '"').join(',')).join('\n');
            const blob = new Blob([csv], {type:'text/csv'});
            const a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'announcements.csv';
            a.click();
        }

        document.getElementById('searchInput').addEventListener('input', applyFilters);
        document.getElementById('sourceFilter').addEventListener('change', function() { currentSource = this.value; applyFilters(); });
        document.getElementById('sortBy').addEventListener('change', function() { currentSort = this.value; applyFilters(); });
        document.getElementById('createBtn').addEventListener('click', function() {
            document.getElementById('formModalTitle').textContent = 'Create Announcement';
            document.getElementById('formAction').value = 'create';
            document.getElementById('editId').value = '';
            document.getElementById('formTitle').value = '';
            document.getElementById('formCategory').value = 'System Maintenance';
            document.getElementById('formAudience').value = 'All Students & Teachers';
            document.getElementById('formDescription').value = '';
            openModal('formModal');
        });
        document.querySelectorAll('.modal-overlay').forEach(o => o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); }));
    </script>
</body>
</html>
