<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Announcements - TalaqqiHub Student Portal</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .filter-card {
            background: white; border-radius: 16px; padding: 20px 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 24px;
            border: 1px solid #F1F5F9;
        }
        .filter-grid {
            display: grid; grid-template-columns: 1fr 180px 180px; gap: 16px; align-items: end;
        }
        @media (max-width: 900px) { .filter-grid { grid-template-columns: 1fr; } }
        .filter-label { font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 6px; display: block; }
        .search-input-wrap { position: relative; }
        .search-input-wrap i {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: #94A3B8; font-size: 14px;
        }
        .search-input {
            width: 100%; padding: 11px 14px 11px 40px; border: 1px solid #E2E8F0;
            border-radius: 10px; font-size: 14px; outline: none; background: #F8FAFC;
        }
        .search-input:focus { border-color: var(--student-green); box-shadow: 0 0 0 3px rgba(4,120,87,0.15); }
        .filter-select {
            width: 100%; padding: 11px 14px; border: 1px solid #E2E8F0; border-radius: 10px;
            font-size: 14px; outline: none; background: white; appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2394A3B8' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 12px center;
            padding-right: 32px; cursor: pointer;
        }
        .filter-select:focus { border-color: var(--student-green); }
        .result-count { font-size: 13px; color: #94A3B8; margin-top: 14px; }
        .announcement-card {
            background: white; border-radius: 16px; padding: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 16px;
            border: 1px solid #F1F5F9; display: flex; justify-content: space-between;
            align-items: flex-start; gap: 20px; transition: box-shadow 0.2s;
        }
        .announcement-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        .card-body { flex: 1; min-width: 0; }
        .card-title-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 10px; }
        .card-title { font-size: 16px; font-weight: 700; color: #1E293B; }
        .new-badge {
            background: #F1F5F9; color: #64748B; font-size: 11px; font-weight: 600;
            padding: 3px 10px; border-radius: 999px;
        }
        .card-snippet {
            font-size: 14px; color: #64748B; line-height: 1.6; margin-bottom: 16px;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .card-meta { display: flex; align-items: center; gap: 18px; flex-wrap: wrap; font-size: 13px; color: #94A3B8; }
        .card-meta span { display: flex; align-items: center; gap: 6px; }
        .category-tag {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 12px; border-radius: 999px; font-size: 12px; font-weight: 600;
        }
        .tag-class-update { background: #DBEAFE; color: #2563EB; }
        .tag-holiday { background: #FEF3C7; color: #D97706; }
        .tag-maintenance { background: #FEF9C3; color: #CA8A04; }
        .tag-general { background: #F1F5F9; color: #475569; }
        .btn-view-details {
            padding: 10px 20px; border: none; border-radius: 10px; white-space: nowrap;
            background: var(--student-gradient);
            color: white; font-size: 14px; font-weight: 600; cursor: pointer; flex-shrink: 0;
            transition: opacity 0.2s;
        }
        .btn-view-details:hover { opacity: 0.92; }
        .empty-state { text-align: center; padding: 60px 20px; color: #94A3B8; }
        .empty-state i { font-size: 48px; margin-bottom: 16px; color: #CBD5E1; }
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 200;
            display: none; align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: white; border-radius: 16px; width: 100%; max-width: 560px;
            max-height: 90vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        }
        .modal-header {
            padding: 20px 24px; border-bottom: 1px solid #E2E8F0;
            display: flex; justify-content: space-between; align-items: center;
        }
        .modal-header h2 { font-size: 18px; font-weight: 700; color: #1E293B; }
        .modal-close {
            width: 32px; height: 32px; border: none; background: #F1F5F9;
            border-radius: 8px; cursor: pointer; color: #64748B;
        }
        .modal-body { padding: 24px; }
        .view-detail { margin-bottom: 16px; }
        .view-detail label {
            font-size: 11px; font-weight: 600; color: #94A3B8;
            text-transform: uppercase; letter-spacing: 0.05em;
        }
        .view-detail p { font-size: 14px; color: #334155; margin-top: 4px; line-height: 1.6; }
    </style>
</head>
<body>
<%
    if (session == null || session.getAttribute("studentId") == null) {
        response.sendRedirect(request.getContextPath() + "/student/login");
        return;
    }
%>

    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="announcements"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Announcements"/>
            <jsp:param name="notifPrefix" value="announceNotif"/>
        </jsp:include>

    <div class="page-content">
        <h2 class="page-title">Announcements</h2>
        <p class="page-subtitle">Stay updated with important information from your teacher and TalaqqiHub</p>

        <div class="filter-card">
            <div class="filter-grid">
                <div>
                    <label class="filter-label" for="searchInput">Search Announcements</label>
                    <div class="search-input-wrap">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" class="search-input" placeholder="Search by title or content...">
                    </div>
                </div>
                <div>
                    <label class="filter-label" for="sourceFilter">Filter by Source</label>
                    <select id="sourceFilter" class="filter-select">
                        <option value="all">All</option>
                        <option value="teacher">My Teachers</option>
                        <option value="admin">TalaqqiHub Admin</option>
                    </select>
                </div>
                <div>
                    <label class="filter-label" for="sortBy">Sort By</label>
                    <select id="sortBy" class="filter-select">
                        <option value="newest">Newest First</option>
                        <option value="oldest">Oldest First</option>
                        <option value="title">Title A-Z</option>
                    </select>
                </div>
            </div>
            <p class="result-count">Showing <span id="visibleCount">${announcementCount}</span> announcement<c:if test="${announcementCount != 1}">s</c:if></p>
        </div>

        <div id="announcementList">
            <c:choose>
                <c:when test="${not empty announcements}">
                    <c:forEach var="ann" items="${announcements}" varStatus="st">
                        <c:set var="isAdmin" value="${ann.author eq 'Talaqqi Admin' or ann.author eq 'TalaqqiHub Admin'}" />
                        <c:set var="tagLabel" value="General" />
                        <c:set var="tagClass" value="tag-general" />
                        <c:set var="tagIcon" value="fa-info-circle" />
                        <c:if test="${ann.category eq 'Class Cancelled' or ann.category eq 'Class Rescheduled'}">
                            <c:set var="tagLabel" value="Class Update" />
                            <c:set var="tagClass" value="tag-class-update" />
                            <c:set var="tagIcon" value="fa-calendar-alt" />
                        </c:if>
                        <c:if test="${ann.category eq 'Holiday'}">
                            <c:set var="tagLabel" value="Holiday" />
                            <c:set var="tagClass" value="tag-holiday" />
                            <c:set var="tagIcon" value="fa-sun" />
                        </c:if>
                        <c:if test="${ann.category eq 'Maintenance'}">
                            <c:set var="tagLabel" value="Maintenance" />
                            <c:set var="tagClass" value="tag-maintenance" />
                            <c:set var="tagIcon" value="fa-cog" />
                        </c:if>
                        <div class="announcement-card"
                             data-index="${st.index}"
                             data-title="${fn:toLowerCase(ann.title)}"
                             data-description="${fn:toLowerCase(ann.description)}"
                             data-author="${fn:toLowerCase(ann.author)}"
                             data-date="${ann.date}"
                             data-admin="${isAdmin}">
                            <div class="card-body">
                                <div class="card-title-row">
                                    <span class="card-title">${ann.title}</span>
                                    <c:if test="${ann.recent}"><span class="new-badge">New</span></c:if>
                                </div>
                                <p class="card-snippet">${ann.description}</p>
                                <div class="card-meta">
                                    <span><i class="fas fa-user"></i> ${ann.author}</span>
                                    <span><i class="far fa-calendar"></i> ${ann.date}</span>
                                    <span class="category-tag ${tagClass}"><i class="fas ${tagIcon}"></i> ${tagLabel}</span>
                                </div>
                            </div>
                            <button class="btn-view-details" type="button"
                                    onclick="viewDetails(this)"
                                    data-title="${fn:escapeXml(ann.title)}"
                                    data-description="${fn:escapeXml(ann.description)}"
                                    data-author="${fn:escapeXml(ann.author)}"
                                    data-date="${fn:escapeXml(ann.date)}"
                                    data-category="${fn:escapeXml(tagLabel)}">View Details</button>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="far fa-bell"></i>
                        <p style="font-size:16px;font-weight:600;color:#64748B;">No announcements yet</p>
                        <p style="font-size:14px;margin-top:8px;">Check back later for updates from your teachers.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="empty-state" id="noResults" style="display:none;">
            <i class="fas fa-search"></i>
            <p style="font-size:16px;font-weight:600;color:#64748B;">No matching announcements</p>
            <p style="font-size:14px;margin-top:8px;">Try adjusting your search or filter.</p>
        </div>
    </div>
    </div>

<div class="modal-overlay" id="viewModal">
    <div class="modal">
        <div class="modal-header">
            <h2 id="viewTitle">Announcement</h2>
            <button class="modal-close" type="button" onclick="closeModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div class="view-detail">
                <label>Posted by</label>
                <p id="viewAuthor"></p>
            </div>
            <div class="view-detail">
                <label>Date</label>
                <p id="viewDate"></p>
            </div>
            <div class="view-detail">
                <label>Category</label>
                <p id="viewCategory"></p>
            </div>
            <div class="view-detail">
                <label>Message</label>
                <p id="viewDescription"></p>
            </div>
        </div>
    </div>
</div>

<script>
    let currentSource = 'all';
    let currentSort = 'newest';

    function viewDetails(btn) {
        document.getElementById('viewTitle').textContent = btn.dataset.title;
        document.getElementById('viewAuthor').textContent = btn.dataset.author;
        document.getElementById('viewDate').textContent = btn.dataset.date;
        document.getElementById('viewCategory').textContent = btn.dataset.category;
        document.getElementById('viewDescription').textContent = btn.dataset.description;
        document.getElementById('viewModal').classList.add('open');
    }

    function closeModal() {
        document.getElementById('viewModal').classList.remove('open');
    }

    function parseDate(str) {
        if (!str) return 0;
        return new Date(str).getTime() || 0;
    }

    function applyFilters() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        const cards = Array.from(document.querySelectorAll('.announcement-card'));
        const list = document.getElementById('announcementList');
        let visible = 0;

        cards.forEach(card => {
            const matchesSearch = !query ||
                card.dataset.title.includes(query) ||
                card.dataset.description.includes(query) ||
                card.dataset.author.includes(query);

            let matchesSource = true;
            if (currentSource === 'teacher') matchesSource = card.dataset.admin !== 'true';
            if (currentSource === 'admin') matchesSource = card.dataset.admin === 'true';

            card.style.display = (matchesSearch && matchesSource) ? '' : 'none';
            if (matchesSearch && matchesSource) visible++;
        });

        if (currentSort === 'oldest') {
            cards.sort((a, b) => parseDate(a.dataset.date) - parseDate(b.dataset.date));
        } else if (currentSort === 'title') {
            cards.sort((a, b) => a.dataset.title.localeCompare(b.dataset.title));
        } else {
            cards.sort((a, b) => parseDate(b.dataset.date) - parseDate(a.dataset.date));
        }
        cards.forEach(card => list.appendChild(card));

        document.getElementById('visibleCount').textContent = visible;
        const noResults = document.getElementById('noResults');
        noResults.style.display = (cards.length > 0 && visible === 0) ? '' : 'none';
    }

    document.getElementById('searchInput').addEventListener('input', applyFilters);
    document.getElementById('sourceFilter').addEventListener('change', function() {
        currentSource = this.value;
        applyFilters();
    });
    document.getElementById('sortBy').addEventListener('change', function() {
        currentSort = this.value;
        applyFilters();
    });

    document.getElementById('viewModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
</script>
</body>
</html>
