<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Talaqqi Sessions - TalaqqiHub Admin Portal</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        @media print {
            .sidebar, .top-navbar, .no-print { display: none !important; }
            .main-content { margin-left: 0 !important; }
            #sessionsTable td:last-child, #sessionsTable th:last-child { display: none; }
        }
    </style>
    <script src="<%= request.getContextPath() %>/js/admin-talaqqi-sessions.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="talaqqi-sessions"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Talaqqi Sessions"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Talaqqi Session Management</h1>
            <p class="page-subtitle">Monitor completed Talaqqi sessions across the TalaqqiHub platform</p>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="stat-value">${completedSessionsCount}</div>
                        <div class="stat-label">Total Completed Sessions</div>
                        <div class="stat-hint">All time completions</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-chalkboard-user"></i></div>
                    <div>
                        <div class="stat-value">${activeTeachersCount}</div>
                        <div class="stat-label">Total Active Teachers</div>
                        <div class="stat-hint">Currently teaching</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-book-reader"></i></div>
                    <div>
                        <div class="stat-value" style="color:#3B82F6;">${activeStudentsCount}</div>
                        <div class="stat-label">Total Active Students</div>
                        <div class="stat-hint">Currently enrolled</div>
                    </div>
                </div>
            </div>

            <div class="records-panel">
                <div class="records-header">
                    <div class="records-title">Completed Talaqqi Sessions</div>
                    <div class="export-btns no-print">
                        <button type="button" id="exportPdfBtn" class="btn-primary"><i class="fas fa-file-export"></i> Export PDF</button>
                        <button type="button" id="exportCsvBtn" class="btn-secondary">CSV</button>
                        <button type="button" id="exportExcelBtn" class="btn-secondary">Excel</button>
                        <button type="button" id="printBtn" class="btn-secondary"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>

                <div class="filters-5 no-print">
                    <div>
                        <label class="filter-label">Search</label>
                        <div class="search-wrap">
                            <i class="fas fa-search"></i>
                            <input id="filterSearch" type="text" placeholder="Search student or teacher..." class="filter-input">
                        </div>
                    </div>
                    <div>
                        <label class="filter-label">Teacher</label>
                        <select id="filterTeacher" class="filter-select">
                            <option value="">All Teachers</option>
                            <c:forEach var="teacher" items="${teachers}">
                                <option value="${teacher}"><c:out value="${teacher}" /></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="filter-label">Date From</label>
                        <input id="filterDateFrom" type="date" class="filter-input">
                    </div>
                    <div>
                        <label class="filter-label">Date To</label>
                        <input id="filterDateTo" type="date" class="filter-input">
                    </div>
                    <div>
                        <label class="filter-label">&nbsp;</label>
                        <button type="button" onclick="applyFilters()" class="btn-primary" style="width:100%;justify-content:center;">Apply Filters</button>
                    </div>
                </div>

                <p id="recordCount" class="records-info">
                    <c:choose>
                        <c:when test="${not empty sessions}">
                            Showing <c:out value="${fn:length(sessions)}" /> sessions
                        </c:when>
                        <c:otherwise>No sessions available</c:otherwise>
                    </c:choose>
                </p>

                <div style="overflow-x:auto;">
                    <table id="sessionsTable" class="records-table">
                        <thead>
                            <tr>
                                <th>Session ID</th>
                                <th>Student Name</th>
                                <th>Teacher Name</th>
                                <th>Class Type</th>
                                <th>Session Date</th>
                                <th>Time</th>
                                <th>Duration</th>
                                <th>Status</th>
                                <th>Completed At</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty sessions}">
                                    <c:forEach var="s" items="${sessions}">
                                        <tr data-student="${fn:toLowerCase(s['studentName'])}"
                                            data-teacher="${fn:toLowerCase(s['teacherName'])}">
                                            <td style="font-weight:600;"><c:out value="${s['sessionId']}" /></td>
                                            <td><c:out value="${s['studentName']}" /></td>
                                            <td><c:out value="${s['teacherName']}" /></td>
                                            <td><c:out value="${s['classType']}" /></td>
                                            <td><fmt:formatDate value="${s['sessionDate']}" pattern="MMM dd, yyyy" /></td>
                                            <td><c:out value="${s['timeStart']}" /> - <c:out value="${s['timeEnd']}" /></td>
                                            <td><c:out value="${s['duration']}" /> minutes</td>
                                            <td><span class="status-pill completed"><c:out value="${s['status']}" /></span></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty s['completedAt']}">
                                                        <fmt:formatDate value="${s['completedAt']}" pattern="MMM dd, yyyy" />
                                                    </c:when>
                                                    <c:otherwise>—</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="?viewId=${s['sessionId']}" class="btn-action">View</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr id="noDataRow">
                                        <td colspan="10" class="empty-state">No sessions found</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <c:if test="${not empty selectedSession}">
        <div id="sessionModal" class="modal-overlay show">
            <div class="modal-box wide">
                <div class="modal-header">
                    <h2 class="modal-title">Talaqqi Session Details</h2>
                    <button type="button" onclick="closeModal()" class="modal-close" aria-label="Close">&times;</button>
                </div>

                <div class="detail-section">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:16px;">
                        <div>
                            <p class="detail-label">Session ID</p>
                            <p class="detail-value" style="font-size:18px;"><c:out value="${selectedSession['sessionId']}" /></p>
                        </div>
                        <span class="status-pill completed"><c:out value="${selectedSession['status']}" /></span>
                    </div>
                </div>

                <div class="detail-section">
                    <h3 class="detail-section-title">Participants</h3>
                    <div class="detail-grid">
                        <div>
                            <p class="detail-label">Student Name</p>
                            <p class="detail-value"><c:out value="${selectedSession['studentName']}" /></p>
                        </div>
                        <div>
                            <p class="detail-label">Teacher Name</p>
                            <p class="detail-value"><c:out value="${selectedSession['teacherName']}" /></p>
                        </div>
                    </div>
                </div>

                <div class="detail-section">
                    <h3 class="detail-section-title">Schedule Details</h3>
                    <div class="detail-grid">
                        <div>
                            <p class="detail-label">Session Date</p>
                            <p class="detail-value"><fmt:formatDate value="${selectedSession['sessionDate']}" pattern="MMM dd, yyyy" /></p>
                            <p class="detail-label" style="margin-top:16px;">Duration</p>
                            <p class="detail-value"><c:out value="${selectedSession['duration']}" /> minutes</p>
                        </div>
                        <div>
                            <p class="detail-label">Time</p>
                            <p class="detail-value"><c:out value="${selectedSession['timeStart']}" /> - <c:out value="${selectedSession['timeEnd']}" /></p>
                            <p class="detail-label" style="margin-top:16px;">Attendance Status</p>
                            <span class="status-pill completed"><c:out value="${selectedSession['attendanceStatus']}" /></span>
                        </div>
                    </div>
                </div>

                <div class="detail-section">
                    <h3 class="detail-section-title">Quran Coverage</h3>
                    <div class="detail-grid">
                        <div>
                            <p class="detail-label">Surah</p>
                            <p class="detail-value">
                                <c:choose>
                                    <c:when test="${selectedSession['surahNumber'] > 0}">
                                        <c:out value="${selectedSession['surahName']}" />
                                    </c:when>
                                    <c:otherwise>Not Set</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div>
                            <p class="detail-label">Ayah</p>
                            <p class="detail-value">
                                <c:choose>
                                    <c:when test="${selectedSession['ayahNumber'] > 0}">
                                        <c:choose>
                                            <c:when test="${selectedSession['ayahEndNumber'] > 0 && selectedSession['ayahEndNumber'] != selectedSession['ayahNumber']}">
                                                Ayah <c:out value="${selectedSession['ayahNumber']}" /> - Ayah <c:out value="${selectedSession['ayahEndNumber']}" />
                                            </c:when>
                                            <c:otherwise>
                                                Ayah <c:out value="${selectedSession['ayahNumber']}" />
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>Not Set</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </div>

                <div class="detail-section">
                    <h3 class="detail-section-title">Completion Details</h3>
                    <p class="detail-label">Session Completed At</p>
                    <p class="detail-value"><fmt:formatDate value="${selectedSession['completedAt']}" pattern="MMM dd, yyyy hh:mm a" /></p>
                </div>

                <div style="text-align:center;">
                    <button type="button" onclick="closeModal()" class="btn-secondary">Close</button>
                </div>
            </div>
        </div>
    </c:if>

</body>
</html>
