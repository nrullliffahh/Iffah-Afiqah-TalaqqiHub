<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Announcements - TalaqqiHub Teacher Portal</title>
    <%@ include file="/WEB-INF/views/includes/teacherLayoutStyles.jsp" %>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { overflow-x: hidden; }
        .toolbar {
            display: flex; align-items: center; gap: 12px; margin-bottom: 24px; flex-wrap: wrap;
        }
        .search-box {
            flex: 1; min-width: 240px; position: relative;
        }
        .search-box input {
            width: 100%; padding: 12px 16px 12px 42px;
            border: 1px solid #E5E7EB; border-radius: 12px;
            font-size: 14px; outline: none; background: white;
        }
        .search-box input:focus { border-color: #a855f7; box-shadow: 0 0 0 3px rgba(168,85,247,0.12); }
        .search-box i {
            position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
            color: #9CA3AF; font-size: 14px;
        }
        .filter-btn {
            display: flex; align-items: center; gap: 8px;
            padding: 12px 18px; border: 1px solid #E5E7EB; border-radius: 12px;
            background: white; color: #374151; font-size: 14px; font-weight: 500;
            cursor: pointer; white-space: nowrap;
        }
        .filter-btn:hover { background: #F9FAFB; }
        .filter-dropdown {
            position: absolute; top: calc(100% + 6px); right: 0;
            background: white; border: 1px solid #E5E7EB; border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.08); min-width: 180px;
            z-index: 50; display: none; overflow: hidden;
        }
        .filter-dropdown.open { display: block; }
        .filter-option {
            padding: 10px 16px; font-size: 14px; color: #374151; cursor: pointer;
        }
        .filter-option:hover { background: #F5F3FF; color: #7c3aed; }
        .filter-option.active { background: #F5F3FF; color: #7c3aed; font-weight: 600; }
        .create-btn {
            display: flex; align-items: center; gap: 8px;
            padding: 12px 22px; border: none; border-radius: 12px;
            background: linear-gradient(135deg, #a78bfa 0%, #f687b3 100%);
            color: white; font-size: 14px; font-weight: 600; cursor: pointer;
            white-space: nowrap; transition: opacity 0.2s;
        }
        .create-btn:hover { opacity: 0.92; }
        .announcement-card {
            background: white; border-radius: 16px; padding: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 16px;
            border: 1px solid #F3F4F6; transition: box-shadow 0.2s;
        }
        .announcement-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        .card-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
        .card-title-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; flex: 1; }
        .card-title { font-size: 16px; font-weight: 700; color: #111827; }
        .tag {
            display: inline-flex; align-items: center;
            padding: 4px 12px; border-radius: 999px;
            font-size: 12px; font-weight: 600;
        }
        .tag-cancelled { background: #FEE2E2; color: #DC2626; }
        .tag-rescheduled { background: #FFEDD5; color: #EA580C; }
        .tag-holiday { background: #FEF3C7; color: #D97706; }
        .tag-general { background: #F3F4F6; color: #4B5563; }
        .tag-author-teacher { background: #DBEAFE; color: #2563EB; }
        .tag-author-admin { background: #EDE9FE; color: #7C3AED; }
        .card-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .btn-view {
            padding: 6px 16px; border-radius: 8px; border: none;
            background: #3B82F6; color: white; font-size: 13px; font-weight: 600; cursor: pointer;
        }
        .btn-view:hover { background: #2563EB; }
        .btn-edit {
            padding: 6px 16px; border-radius: 8px; border: none;
            background: #F59E0B; color: white; font-size: 13px; font-weight: 600; cursor: pointer;
        }
        .btn-edit:hover { background: #D97706; }
        .btn-delete {
            width: 34px; height: 34px; border-radius: 8px; border: none;
            background: #FEE2E2; color: #EF4444; font-size: 14px; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
        }
        .btn-delete:hover { background: #FECACA; }
        .card-description {
            font-size: 14px; color: #6B7280; line-height: 1.6;
            margin: 14px 0 16px;
        }
        .card-meta {
            display: flex; align-items: center; gap: 20px; flex-wrap: wrap;
            font-size: 13px; color: #9CA3AF;
        }
        .card-meta span { display: flex; align-items: center; gap: 6px; }
        .empty-state {
            text-align: center; padding: 60px 20px; color: #9CA3AF;
        }
        .empty-state i { font-size: 48px; margin-bottom: 16px; color: #D1D5DB; }
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.4);
            z-index: 200; display: none; align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: white; border-radius: 16px; width: 100%; max-width: 520px;
            max-height: 90vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        }
        .modal-header {
            padding: 20px 24px; border-bottom: 1px solid #E5E7EB;
            display: flex; justify-content: space-between; align-items: center;
        }
        .modal-header h2 { font-size: 18px; font-weight: 700; color: #111827; }
        .modal-close {
            width: 32px; height: 32px; border: none; background: #F3F4F6;
            border-radius: 8px; cursor: pointer; color: #6B7280; font-size: 16px;
        }
        .modal-body { padding: 24px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 10px 14px; border: 1px solid #E5E7EB;
            border-radius: 10px; font-size: 14px; font-family: inherit; outline: none;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #a855f7; box-shadow: 0 0 0 3px rgba(168,85,247,0.12);
        }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-group select {
            appearance: none;
            -webkit-appearance: none;
            background: white url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%239CA3AF' d='M6 8L1 3h10z'/%3E%3C/svg%3E") no-repeat right 14px center;
            padding-right: 36px;
            cursor: pointer;
        }
        .audience-picker { position: relative; }
        .audience-trigger {
            width: 100%; padding: 10px 14px; border: 1px solid #E5E7EB; border-radius: 10px;
            background: white; font-size: 14px; font-family: inherit; color: #111827;
            display: flex; align-items: center; justify-content: space-between;
            cursor: pointer; text-align: left; transition: border-color 0.15s, box-shadow 0.15s;
        }
        .audience-trigger:hover { border-color: #D1D5DB; }
        .audience-trigger.open, .audience-trigger:focus {
            border-color: #a855f7; box-shadow: 0 0 0 3px rgba(168,85,247,0.12); outline: none;
        }
        .audience-trigger i { font-size: 11px; color: #9CA3AF; transition: transform 0.2s; }
        .audience-trigger.open i { transform: rotate(180deg); }
        .audience-menu {
            position: absolute; top: calc(100% + 4px); left: 0; right: 0;
            background: white; border: 1px solid #E5E7EB; border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1); z-index: 60;
            max-height: 200px; overflow-y: auto; display: none;
        }
        .audience-menu.open { display: block; }
        .audience-option {
            padding: 10px 14px; font-size: 14px; color: #374151; cursor: pointer;
            transition: background 0.15s;
        }
        .audience-option:hover { background: #F5F3FF; color: #7c3aed; }
        .audience-option.active { background: #F5F3FF; color: #7c3aed; font-weight: 600; }
        .audience-option:first-child { border-radius: 10px 10px 0 0; }
        .audience-option:last-child { border-radius: 0 0 10px 10px; }
        .modal-footer {
            padding: 16px 24px; border-top: 1px solid #E5E7EB;
            display: flex; justify-content: flex-end; gap: 10px;
        }
        .btn-cancel {
            padding: 10px 20px; border: 1px solid #E5E7EB; border-radius: 10px;
            background: white; color: #374151; font-size: 14px; font-weight: 500; cursor: pointer;
        }
        .btn-save {
            padding: 10px 20px; border: none; border-radius: 10px;
            background: linear-gradient(135deg, #a78bfa 0%, #f687b3 100%);
            color: white; font-size: 14px; font-weight: 600; cursor: pointer;
        }
        .view-detail { margin-bottom: 14px; }
        .view-detail label { font-size: 12px; font-weight: 600; color: #9CA3AF; text-transform: uppercase; letter-spacing: 0.05em; }
        .view-detail p { font-size: 14px; color: #374151; margin-top: 4px; line-height: 1.5; }
        .toast {
            position: fixed; bottom: 24px; right: 24px; z-index: 300;
            background: #111827; color: white; padding: 14px 20px;
            border-radius: 12px; font-size: 14px; display: none;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        }
        .toast.show { display: block; animation: slideUp 0.3s ease; }
        @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    </style>
</head>
<body>
<%
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }
%>

<jsp:include page="/WEB-INF/views/includes/teacherSidebar.jsp">
    <jsp:param name="activePage" value="announcements"/>
</jsp:include>

<div class="main-content">
    <jsp:include page="/WEB-INF/views/includes/teacherTopNavbar.jsp">
        <jsp:param name="pageTitle" value="Announcements"/>
        <jsp:param name="notifPrefix" value="announceNotif"/>
    </jsp:include>

    <div class="page-content">
        <h2 class="page-title">Announcements</h2>
        <p class="page-subtitle">Create and manage announcements for your students.</p>

        <c:if test="${not empty flashMessage}">
            <div style="background:#ECFDF5;border:1px solid #A7F3D0;color:#065F46;padding:12px 16px;border-radius:10px;margin-bottom:16px;font-size:14px;">
                <i class="fas fa-check-circle"></i> ${flashMessage}
            </div>
        </c:if>
        <c:if test="${not empty flashError}">
            <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:10px;margin-bottom:16px;font-size:14px;">
                <i class="fas fa-exclamation-circle"></i> ${flashError}
            </div>
        </c:if>

        <div class="toolbar">
            <div class="search-box">
                <i class="fas fa-search"></i>
                <input type="text" id="searchInput" placeholder="Search announcements...">
            </div>
            <div style="position:relative;">
                <button class="filter-btn" id="filterBtn" type="button">
                    <i class="fas fa-filter"></i>
                    <span id="filterLabel">All</span>
                    <i class="fas fa-chevron-down" style="font-size:11px;"></i>
                </button>
                <div class="filter-dropdown" id="filterDropdown">
                    <div class="filter-option active" data-filter="all">All</div>
                    <div class="filter-option" data-filter="mine">My Announcements</div>
                    <div class="filter-option" data-filter="admin">Admin Announcements</div>
                    <div class="filter-option" data-filter="Class Cancelled">Class Cancelled</div>
                    <div class="filter-option" data-filter="Class Rescheduled">Class Rescheduled</div>
                    <div class="filter-option" data-filter="Holiday">Holiday</div>
                </div>
            </div>
            <button class="create-btn" id="createBtn" type="button">
                <i class="fas fa-plus"></i>
                Create Announcement
            </button>
        </div>

        <div id="announcementList">
            <c:choose>
                <c:when test="${not empty announcements}">
                    <c:forEach var="ann" items="${announcements}">
                        <c:set var="isAdmin" value="${ann.author eq 'Talaqqi Admin'}" />
                        <c:set var="categoryClass" value="tag-general" />
                        <c:if test="${ann.category eq 'Class Cancelled'}"><c:set var="categoryClass" value="tag-cancelled" /></c:if>
                        <c:if test="${ann.category eq 'Class Rescheduled'}"><c:set var="categoryClass" value="tag-rescheduled" /></c:if>
                        <c:if test="${ann.category eq 'Holiday'}"><c:set var="categoryClass" value="tag-holiday" /></c:if>
                        <div class="announcement-card"
                             data-id="${ann.announcementId}"
                             data-title="${fn:escapeXml(ann.title)}"
                             data-description="${fn:escapeXml(ann.description)}"
                             data-category="${fn:escapeXml(ann.category)}"
                             data-author="${fn:escapeXml(ann.author)}"
                             data-date="${fn:escapeXml(ann.date)}"
                             data-audience="${fn:escapeXml(ann.targetAudience)}"
                             data-admin="${isAdmin}"
                             data-search="${fn:toLowerCase(ann.title)} ${fn:toLowerCase(ann.description)} ${fn:toLowerCase(ann.category)} ${fn:toLowerCase(ann.author)}">
                            <div class="card-header">
                                <div class="card-title-row">
                                    <span class="card-title">${ann.title}</span>
                                    <span class="tag ${categoryClass}">${ann.category}</span>
                                    <span class="tag ${isAdmin ? 'tag-author-admin' : 'tag-author-teacher'}">${ann.author}</span>
                                </div>
                                <div class="card-actions">
                                    <button class="btn-view" type="button" onclick="viewAnnouncement(this)">View</button>
                                    <c:if test="${not isAdmin}">
                                        <button class="btn-edit" type="button" onclick="editAnnouncement(this)">Edit</button>
                                        <button class="btn-delete" type="button" onclick="deleteAnnouncement(this)" title="Delete">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                            <p class="card-description">${ann.description}</p>
                            <div class="card-meta">
                                <span><i class="far fa-calendar"></i> ${ann.date}</span>
                                <span><i class="fas fa-users"></i> ${ann.targetAudience}</span>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state" id="emptyState">
                        <i class="far fa-bell"></i>
                        <p style="font-size:16px;font-weight:600;color:#6B7280;">No announcements yet</p>
                        <p style="font-size:14px;margin-top:8px;">Create your first announcement to notify your students.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="empty-state" id="noResults" style="display:none;">
            <i class="fas fa-search"></i>
            <p style="font-size:16px;font-weight:600;color:#6B7280;">No matching announcements</p>
            <p style="font-size:14px;margin-top:8px;">Try adjusting your search or filter.</p>
        </div>
    </div>
</div>

<!-- View Modal -->
<div class="modal-overlay" id="viewModal">
    <div class="modal">
        <div class="modal-header">
            <h2 id="viewTitle">Announcement</h2>
            <button class="modal-close" type="button" onclick="closeModal('viewModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div class="view-detail">
                <label>Category</label>
                <p id="viewCategory"></p>
            </div>
            <div class="view-detail">
                <label>Author</label>
                <p id="viewAuthor"></p>
            </div>
            <div class="view-detail">
                <label>Description</label>
                <p id="viewDescription"></p>
            </div>
            <div class="view-detail">
                <label>Date</label>
                <p id="viewDate"></p>
            </div>
            <div class="view-detail">
                <label>Audience</label>
                <p id="viewAudience"></p>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" type="button" onclick="closeModal('viewModal')">Close</button>
        </div>
    </div>
</div>

<!-- Create / Edit Modal -->
<div class="modal-overlay" id="formModal">
    <div class="modal">
        <div class="modal-header">
            <h2 id="formModalTitle">Create Announcement</h2>
            <button class="modal-close" type="button" onclick="closeModal('formModal')"><i class="fas fa-times"></i></button>
        </div>
        <form id="announcementForm" method="post" action="<%= request.getContextPath() %>/teacher/announcements">
            <input type="hidden" name="action" id="formAction" value="create">
            <input type="hidden" name="announcementId" id="editId" value="">
            <input type="hidden" name="targetAudience" id="formAudience" value="All My Students">
            <div class="modal-body">
                <div class="form-group">
                    <label for="formTitle">Title</label>
                    <input type="text" id="formTitle" name="title" placeholder="Enter announcement title" required>
                </div>
                <div class="form-group">
                    <label for="formCategory">Category</label>
                    <select id="formCategory" name="category">
                        <option value="Class Cancelled">Class Cancelled</option>
                        <option value="Class Rescheduled">Class Rescheduled</option>
                        <option value="Holiday">Holiday</option>
                        <option value="General">General</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="audienceTrigger">Target Audience</label>
                    <div class="audience-picker" id="audiencePicker">
                        <button type="button" class="audience-trigger" id="audienceTrigger" aria-haspopup="listbox" aria-expanded="false">
                            <span id="audienceLabel">All My Students</span>
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div class="audience-menu" id="audienceMenu" role="listbox">
                            <div class="audience-option active" data-value="All My Students" role="option">All My Students</div>
                            <c:forEach var="student" items="${students}">
                                <div class="audience-option" data-value="Student: ${student}" role="option">Student: ${student}</div>
                            </c:forEach>
                            <c:if test="${empty students}">
                                <div class="audience-option" style="color:#9CA3AF;cursor:default;" data-value="" role="option">No students assigned yet</div>
                            </c:if>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label for="formDescription">Description</label>
                    <textarea id="formDescription" name="description" placeholder="Write your announcement message..." required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" type="button" onclick="closeModal('formModal')">Cancel</button>
                <button class="btn-save" type="submit">Save</button>
            </div>
        </form>
    </div>
</div>

<form id="deleteForm" method="post" action="<%= request.getContextPath() %>/teacher/announcements" style="display:none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="announcementId" id="deleteAnnouncementId">
</form>

<div class="toast" id="toast"></div>

<script>
    let currentFilter = 'all';

    function setAudience(value, label) {
        const displayLabel = label || value;
        document.getElementById('formAudience').value = value;
        document.getElementById('audienceLabel').textContent = displayLabel;
        document.querySelectorAll('.audience-option').forEach(opt => {
            opt.classList.toggle('active', opt.dataset.value === value);
        });
        let found = false;
        document.querySelectorAll('.audience-option').forEach(opt => {
            if (opt.dataset.value === value) found = true;
        });
        if (!found && value && !document.querySelector('.audience-option[data-value="' + value.replace(/"/g, '\\"') + '"]')) {
            const menu = document.getElementById('audienceMenu');
            const extra = document.createElement('div');
            extra.className = 'audience-option active';
            extra.dataset.value = value;
            extra.dataset.dynamic = 'true';
            extra.textContent = displayLabel;
            extra.setAttribute('role', 'option');
            extra.addEventListener('click', function() { selectAudienceOption(this); });
            menu.appendChild(extra);
        }
    }

    function closeAudienceMenu() {
        document.getElementById('audienceMenu').classList.remove('open');
        document.getElementById('audienceTrigger').classList.remove('open');
        document.getElementById('audienceTrigger').setAttribute('aria-expanded', 'false');
    }

    function selectAudienceOption(opt) {
        setAudience(opt.dataset.value, opt.textContent.trim());
        closeAudienceMenu();
    }

    function getCardData(btn) {
        const card = btn.closest('.announcement-card');
        return {
            card: card,
            id: card.dataset.id,
            title: card.dataset.title,
            description: card.dataset.description,
            category: card.dataset.category,
            author: card.dataset.author,
            date: card.dataset.date,
            audience: card.dataset.audience
        };
    }

    function viewAnnouncement(btn) {
        const d = getCardData(btn);
        document.getElementById('viewTitle').textContent = d.title;
        document.getElementById('viewCategory').textContent = d.category;
        document.getElementById('viewAuthor').textContent = d.author;
        document.getElementById('viewDescription').textContent = d.description;
        document.getElementById('viewDate').textContent = d.date;
        document.getElementById('viewAudience').textContent = d.audience;
        openModal('viewModal');
    }

    function editAnnouncement(btn) {
        const d = getCardData(btn);
        document.getElementById('formModalTitle').textContent = 'Edit Announcement';
        document.getElementById('formAction').value = 'update';
        document.getElementById('editId').value = d.id;
        document.getElementById('formTitle').value = d.title;
        document.getElementById('formCategory').value = d.category;
        setAudience(d.audience);
        document.getElementById('formDescription').value = d.description;
        openModal('formModal');
    }

    function deleteAnnouncement(btn) {
        if (!confirm('Are you sure you want to delete this announcement?')) return;
        const card = btn.closest('.announcement-card');
        document.getElementById('deleteAnnouncementId').value = card.dataset.id;
        document.getElementById('deleteForm').submit();
    }

    function openModal(id) {
        document.getElementById(id).classList.add('open');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('open');
    }

    function showToast(msg) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 3000);
    }

    function applyFilters() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        const cards = document.querySelectorAll('.announcement-card');
        let visible = 0;

        cards.forEach(card => {
            const matchesSearch = !query || card.dataset.search.includes(query);
            let matchesFilter = true;

            if (currentFilter === 'mine') {
                matchesFilter = card.dataset.admin !== 'true';
            } else if (currentFilter === 'admin') {
                matchesFilter = card.dataset.admin === 'true';
            } else if (currentFilter !== 'all') {
                matchesFilter = card.dataset.category === currentFilter;
            }

            const show = matchesSearch && matchesFilter;
            card.style.display = show ? '' : 'none';
            if (show) visible++;
        });

        const noResults = document.getElementById('noResults');
        const hasCards = cards.length > 0;
        noResults.style.display = (hasCards && visible === 0) ? '' : 'none';
    }

    document.getElementById('searchInput').addEventListener('input', applyFilters);

    document.getElementById('filterBtn').addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('filterDropdown').classList.toggle('open');
    });

    document.querySelectorAll('.filter-option').forEach(opt => {
        opt.addEventListener('click', function() {
            document.querySelectorAll('.filter-option').forEach(o => o.classList.remove('active'));
            this.classList.add('active');
            currentFilter = this.dataset.filter;
            document.getElementById('filterLabel').textContent = this.textContent;
            document.getElementById('filterDropdown').classList.remove('open');
            applyFilters();
        });
    });

    document.addEventListener('click', function() {
        document.getElementById('filterDropdown').classList.remove('open');
        closeAudienceMenu();
    });

    document.getElementById('audiencePicker').addEventListener('click', function(e) {
        e.stopPropagation();
    });

    document.getElementById('audienceTrigger').addEventListener('click', function(e) {
        e.stopPropagation();
        const menu = document.getElementById('audienceMenu');
        const trigger = document.getElementById('audienceTrigger');
        const isOpen = menu.classList.toggle('open');
        trigger.classList.toggle('open', isOpen);
        trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });

    document.querySelectorAll('.audience-option').forEach(opt => {
        opt.addEventListener('click', function() { selectAudienceOption(this); });
    });

    document.getElementById('createBtn').addEventListener('click', function() {
        document.getElementById('formModalTitle').textContent = 'Create Announcement';
        document.getElementById('formAction').value = 'create';
        document.getElementById('editId').value = '';
        document.getElementById('formTitle').value = '';
        document.getElementById('formCategory').value = 'General';
        document.querySelectorAll('.audience-option[data-dynamic="true"]').forEach(el => el.remove());
        setAudience('All My Students');
        document.getElementById('formDescription').value = '';
        closeAudienceMenu();
        openModal('formModal');
    });

    document.getElementById('announcementForm').addEventListener('submit', function(e) {
        const title = document.getElementById('formTitle').value.trim();
        const description = document.getElementById('formDescription').value.trim();
        if (!title || !description) {
            e.preventDefault();
            showToast('Please fill in title and description.');
        }
    });

    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) overlay.classList.remove('open');
        });
    });
</script>
</body>
</html>
