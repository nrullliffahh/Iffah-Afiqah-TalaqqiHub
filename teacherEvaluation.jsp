<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    if (request.getAttribute("loadedFromServlet") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/evaluation");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evaluation - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/teacherLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .score-slider {
            -webkit-appearance: none;
            appearance: none;
            width: 100%;
            height: 8px;
            border-radius: 9999px;
            background: linear-gradient(to right, #e9d5ff 0%, #c4b5fd 100%);
            outline: none;
            cursor: pointer;
        }

        .score-slider::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: linear-gradient(135deg, #7c3aed, #6d28d9);
            border: 3px solid #ffffff;
            box-shadow: 0 2px 8px rgba(124, 58, 237, 0.35);
            cursor: grab;
        }

        .score-slider::-moz-range-thumb {
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: linear-gradient(135deg, #7c3aed, #6d28d9);
            border: 3px solid #ffffff;
            box-shadow: 0 2px 8px rgba(124, 58, 237, 0.35);
            cursor: grab;
        }

        .score-slider:focus::-webkit-slider-thumb {
            box-shadow: 0 0 0 4px rgba(167, 139, 250, 0.35);
        }

        .score-slider:focus::-moz-range-thumb {
            box-shadow: 0 0 0 4px rgba(167, 139, 250, 0.35);
        }

        .eval-score-card {
            min-width: 0;
        }

        .eval-session-grid > div {
            min-width: 0;
        }

        .eval-readonly-input {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        #evaluateModal,
        #viewModal {
            z-index: 1200;
        }

        body.modal-open {
            overflow: hidden;
        }

        .teacher-modal-overlay {
            position: fixed;
            inset: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.25rem;
            background: rgba(15, 23, 42, 0.45);
            backdrop-filter: blur(4px);
        }

        .teacher-modal-dialog {
            width: 100%;
            max-width: 42rem;
            height: 82vh;
            height: min(82vh, calc(100dvh - 2.5rem));
            max-height: min(82vh, calc(100dvh - 2.5rem));
            display: flex;
            flex-direction: column;
            background: #fff;
            border-radius: 1rem;
            box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.28);
            overflow: hidden;
        }

        .teacher-modal-header {
            flex-shrink: 0;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #f1f5f9;
            background: linear-gradient(135deg, #faf5ff 0%, #ffffff 55%, #fdf2f8 100%);
        }

        .teacher-modal-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            padding: 1.25rem 1.5rem;
        }

        .teacher-modal-footer {
            flex-shrink: 0;
            display: flex;
            gap: 0.75rem;
            padding: 1rem 1.5rem;
            border-top: 1px solid #f1f5f9;
            background: #fff;
            box-shadow: 0 -6px 20px rgba(15, 23, 42, 0.06);
        }

        .view-score-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.75rem;
        }

        @media (min-width: 640px) {
            .view-score-grid {
                grid-template-columns: repeat(4, minmax(0, 1fr));
            }
        }

        .view-score-card {
            border-radius: 1rem;
            padding: 0.875rem 0.75rem;
            text-align: center;
            border: 1px solid transparent;
        }

        .view-score-card.tajweed { background: #ecfdf5; border-color: #a7f3d0; }
        .view-score-card.fluency { background: #f5f3ff; border-color: #ddd6fe; }
        .view-score-card.accuracy { background: #eff6ff; border-color: #bfdbfe; }
        .view-score-card.overall { background: #fdf4ff; border-color: #f5d0fe; }

        .view-feedback-block {
            border-radius: 1rem;
            padding: 1rem 1.125rem;
            border-left: 4px solid;
        }

        #evaluateModal .eval-modal-dialog {
            height: 82vh;
            height: min(82vh, calc(100dvh - 2.5rem));
            max-height: min(82vh, calc(100dvh - 2.5rem));
            display: flex;
            flex-direction: column;
        }

        #evaluateModal #evalForm {
            flex: 1 1 auto;
            min-height: 0;
            display: flex;
            flex-direction: column;
        }

        #evaluateModal .eval-modal-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        #evaluateModal .eval-modal-footer {
            flex-shrink: 0;
            box-shadow: 0 -6px 20px rgba(15, 23, 42, 0.08);
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/teacherSidebar.jsp">
        <jsp:param name="activePage" value="evaluation"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/teacherTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Evaluation"/>
            <jsp:param name="notifPrefix" value="evalNotif"/>
        </jsp:include>

        <div class="page-content">
            <c:if test="${empty completedEvaluations && empty studentFeedbackList && empty pendingEvaluations}">
                <div class="mx-0 mb-6 bg-amber-50 border border-amber-200 rounded-lg p-4 text-amber-900 text-sm">
                    Logged in as <strong><c:out value="${teacherName}"/></strong> (<c:out value="${teacherId}"/>).
                    No pending evaluations yet. After you <strong>End Session</strong> in Talaqqi Session, the student will appear here for you to evaluate (Tajweed, Fluency, Accuracy).
                </div>
            </c:if>

            <h1 class="page-title">Student Evaluation</h1>
            <p class="page-subtitle">Evaluate student performance and track progress in Quran recitation</p>

            <div>
                    
                    <div class="grid grid-cols-3 gap-6 mb-8">
                        <!-- Total Students -->
                        <div class="bg-white rounded-xl p-6 shadow-md border-l-4 border-pink-400">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-gray-600 text-sm font-medium">Total Students Evaluated</p>
                                    <p class="text-3xl font-bold text-gray-800 mt-2">${dashboardSummary.totalStudentsEvaluated != null ? dashboardSummary.totalStudentsEvaluated : 0}</p>
                                </div>
                                <div class="w-16 h-16 bg-pink-50 rounded-full flex items-center justify-center">
                                    <i class="fas fa-users text-2xl text-pink-400"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Total Sessions -->
                        <div class="bg-white rounded-xl p-6 shadow-md border-l-4 border-teal-400">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-gray-600 text-sm font-medium">Total Sessions Evaluated</p>
                                    <p class="text-3xl font-bold text-gray-800 mt-2">${dashboardSummary.totalSessionsEvaluated != null ? dashboardSummary.totalSessionsEvaluated : 0}</p>
                                </div>
                                <div class="w-16 h-16 bg-teal-100 rounded-full flex items-center justify-center">
                                    <i class="fas fa-calendar-check text-2xl text-teal-500"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Average Overall Score -->
                        <div class="bg-white rounded-xl p-6 shadow-md border-l-4 border-purple-400">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-gray-600 text-sm font-medium">Average Overall Score</p>
                                    <p class="text-3xl font-bold text-gray-800 mt-2">${dashboardSummary.avgOverallScore != null ? dashboardSummary.avgOverallScore : 0}%</p>
                                </div>
                                <div class="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center">
                                    <i class="fas fa-chart-pie text-2xl text-purple-500"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Performance Metrics -->
                    <div class="grid grid-cols-3 gap-6">
                        <!-- Avg Tajweed -->
                        <div class="bg-white rounded-xl p-6 shadow-md">
                            <div class="flex items-center justify-between mb-2">
                                <p class="text-gray-600 text-sm font-medium">Avg Tajweed Score</p>
                                <i class="fas fa-book-quran text-purple-500"></i>
                            </div>
                            <p class="text-3xl font-bold text-purple-600">${dashboardSummary.avgTajweedScore != null ? dashboardSummary.avgTajweedScore : 0}%</p>
                        </div>

                        <!-- Avg Fluency -->
                        <div class="bg-white rounded-xl p-6 shadow-md">
                            <div class="flex items-center justify-between mb-2">
                                <p class="text-gray-600 text-sm font-medium">Avg Fluency Score</p>
                                <i class="fas fa-microphone text-blue-500"></i>
                            </div>
                            <p class="text-3xl font-bold text-blue-600">${dashboardSummary.avgFluencyScore != null ? dashboardSummary.avgFluencyScore : 0}%</p>
                        </div>

                        <!-- Avg Accuracy -->
                        <div class="bg-white rounded-xl p-6 shadow-md">
                            <div class="flex items-center justify-between mb-2">
                                <p class="text-gray-600 text-sm font-medium">Avg Accuracy Score</p>
                                <i class="fas fa-target text-teal-500"></i>
                            </div>
                            <p class="text-3xl font-bold text-teal-600">${dashboardSummary.avgAccuracyScore != null ? dashboardSummary.avgAccuracyScore : 0}%</p>
                        </div>
                    </div>
                </div>

                <!-- Pending Evaluations -->
                <div class="mb-12">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Pending Evaluations</h3>
                    <div id="pendingList" class="space-y-6">
                        <c:if test="${empty pendingEvaluations}">
                            <p class="text-gray-600 italic bg-yellow-50 p-4 rounded">No pending evaluations at this time.</p>
                        </c:if>
                        <c:forEach var="evaluation" items="${pendingEvaluations}">
                               <div class="bg-white rounded-xl p-6 shadow-md border-l-4 border-yellow-400 flex items-center justify-between mx-4"
                                   data-eval-id="${evaluation.evaluationId > 0 ? evaluation.evaluationId : ''}"
                                   data-session-id="${evaluation.sessionId}"
                                   data-student-id="${evaluation.studentId}"
                                   data-student-name="${empty evaluation.studentName or evaluation.studentName == 'false' ? '' : evaluation.studentName}"
                                   data-class-name="${evaluation.className}"
                                   data-session-date="${evaluation.sessionDate}"
                                   data-session-time="${evaluation.startTime} - ${evaluation.endTime}"
                                   data-surah="${evaluation.surah}"
                                  data-surah-number="${evaluation.surahNumber}"
                                  data-ayah-number="${evaluation.ayahNumber}"
                                  data-ayah-range="${evaluation.ayahRange}"
                                data-teacher-name="${evaluation.teacherName}">
                                <span class="hidden-surah-label" style="display:none">
                                    <c:choose>
                                        <c:when test="${not empty evaluation.surah}">
                                            <c:out value="${evaluation.surah}" /><c:if test="${not empty evaluation.ayahRange}">, Ayah <c:out value="${evaluation.ayahRange}" /></c:if>
                                        </c:when>
                                        <c:when test="${not empty evaluation.ayahRange}">
                                            Ayah <c:out value="${evaluation.ayahRange}" />
                                        </c:when>
                                    </c:choose>
                                </span>
                                <div class="flex items-center space-x-4">
                                    <div class="w-16 h-16 bg-gradient-to-br from-purple-300 to-pink-300 rounded-xl flex items-center justify-center">
                                        <span class="text-white font-bold text-xl">${evaluation.studentName.charAt(0)}${fn:length(evaluation.studentName.split(' ')) > 1 ? evaluation.studentName.split(' ')[1].charAt(0) : ''}</span>
                                    </div>
                                    <div>
                                        <h4 class="text-lg font-bold text-gray-800">${evaluation.studentName}</h4>
                                        <p class="text-gray-600 text-sm">
                                            <c:choose>
                                                <c:when test="${not empty evaluation.sessionDate}">
                                                    ${evaluation.sessionDate}<c:if test="${not empty evaluation.startTime}"> • ${evaluation.startTime}<c:if test="${not empty evaluation.endTime}"> - ${evaluation.endTime}</c:if></c:if>
                                                </c:when>
                                                <c:when test="${not empty evaluation.startTime}">
                                                    ${evaluation.startTime}<c:if test="${not empty evaluation.endTime}"> - ${evaluation.endTime}</c:if>
                                                </c:when>
                                                <c:otherwise>Date/time not set</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p class="text-gray-600 text-sm">
                                            <c:choose>
                                                <c:when test="${not empty evaluation.surah}">
                                                    Surah ${evaluation.surah}<c:if test="${not empty evaluation.ayahRange}">, Ayah ${evaluation.ayahRange}</c:if>
                                                </c:when>
                                                <c:when test="${not empty evaluation.ayahRange}">
                                                    Ayah ${evaluation.ayahRange}
                                                </c:when>
                                                <c:otherwise>Surah not set</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <span class="inline-block bg-yellow-100 text-yellow-800 text-xs font-semibold px-3 py-1 rounded-full mt-2">Pending Evaluation</span>
                                        
                                    </div>
                                </div>
                                <button onclick="openEvaluateModal('${evaluation.evaluationId > 0 ? evaluation.evaluationId : ''}', null, null, '${evaluation.sessionId}')" class="bg-purple-500 hover:bg-purple-600 text-white px-6 py-2 rounded-lg font-semibold transition my-4">
                                    Evaluate Now
                                </button>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Completed Evaluations -->
                <div class="mb-12">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Completed Evaluations</h3>
                    
                    <!-- Filters -->
                    <form method="GET" action="./teacher/evaluation" class="flex gap-4 mb-6">
                        <input type="text" name="search" placeholder="Search by student name or surah..." 
                               value="${searchTerm}" 
                               class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
                        <select name="filterClass" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
                            <option value="">Class: All</option>
                            <c:forEach var="className" items="${classNames}">
                                <option value="${className}" ${filterClass == className ? 'selected' : ''}>Class: ${className}</option>
                            </c:forEach>
                        </select>
                        <select name="sort" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
                            <option value="newest" ${sortBy == 'newest' ? 'selected' : ''}>Sort: Newest</option>
                            <option value="oldest" ${sortBy == 'oldest' ? 'selected' : ''}>Sort: Oldest</option>
                            <option value="best" ${sortBy == 'best' ? 'selected' : ''}>Sort: Best Score</option>
                            <option value="lowest" ${sortBy == 'lowest' ? 'selected' : ''}>Sort: Lowest Score</option>
                        </select>
                    </form>

                    <!-- Evaluations List -->
                    <div id="completedList" class="space-y-6">
                        <c:if test="${empty completedEvaluations}">
                            <p class="text-gray-600 italic bg-blue-50 p-4 rounded">No completed evaluations yet.</p>
                        </c:if>
                        <c:forEach var="evaluation" items="${completedEvaluations}">
                            <div class="bg-white rounded-xl p-6 shadow-md border-l-4 mx-4"
                                style="border-color: ${evaluation.overallScore >= 90 ? '#10b981' : evaluation.overallScore >= 80 ? '#8b5cf6' : '#f59e0b'};"
                                data-eval-id="${evaluation.evaluationId}"
                                data-student-name="${evaluation.studentName}"
                                data-session-date="${evaluation.sessionDate}"
                                data-start-time="${evaluation.startTime}"
                                data-end-time="${evaluation.endTime}"
                                data-surah="${evaluation.surah}"
                                data-ayah-range="${evaluation.ayahRange}"
                                data-class-name="${evaluation.className}"
                                data-tajweed="${evaluation.tajweedScore}"
                                data-fluency="${evaluation.fluencyScore}"
                                data-accuracy="${evaluation.accuracyScore}"
                                data-overall="${evaluation.overallScore}"
                                data-rating="${evaluation.rating}"
                                data-comments="${fn:escapeXml(evaluation.comments)}"
                                data-areas-improvement="${fn:escapeXml(evaluation.areasForImprovement)}"
                                data-suggestions="${fn:escapeXml(evaluation.suggestions)}"
                                data-next-target="${fn:escapeXml(evaluation.nextTarget)}"
                                data-teacher-comments="${fn:escapeXml(evaluation.teacherComments)}"
                                data-performance-tag="${evaluation.performanceTag}"
                                data-student-id="${evaluation.studentId}"
                                data-session-id="${evaluation.sessionId}">
                                <div class="flex items-start justify-between">
                                    <div class="flex items-start space-x-4">
                                        <div class="w-16 h-16 bg-gradient-to-br from-teal-300 to-cyan-300 rounded-xl flex items-center justify-center flex-shrink-0">
                                            <span class="text-white font-bold text-xl">${evaluation.studentName.charAt(0)}${fn:length(evaluation.studentName.split(' ')) > 1 ? evaluation.studentName.split(' ')[1].charAt(0) : ''}</span>
                                        </div>
                                        <div class="flex-1">
                                            <div class="flex items-center space-x-3 mb-2">
                                                <h4 class="text-lg font-bold text-gray-800">${evaluation.studentName}</h4>
                                                <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold" 
                                                    style="background-color: ${evaluation.overallScore >= 90 ? '#d1fae5' : evaluation.overallScore >= 80 ? '#ede9fe' : '#fef3c7'}; color: ${evaluation.overallScore >= 90 ? '#047857' : evaluation.overallScore >= 80 ? '#6d28d9' : '#b45309'};">
                                                    ${evaluation.overallScore >= 90 ? 'Excellent' : evaluation.overallScore >= 80 ? 'Good' : 'Fair'}
                                                </span>
                                            </div>
                                            <p class="text-gray-600 text-sm mb-3">
                                                <c:choose>
                                                    <c:when test="${not empty evaluation.sessionDate and not empty evaluation.startTime}">
                                                        ${evaluation.sessionDate} • ${evaluation.startTime} - ${evaluation.endTime}
                                                    </c:when>
                                                    <c:when test="${not empty evaluation.sessionDate}">
                                                        ${evaluation.sessionDate}
                                                    </c:when>
                                                    <c:when test="${not empty evaluation.startTime}">
                                                        ${evaluation.startTime}<c:if test="${not empty evaluation.endTime}"> - ${evaluation.endTime}</c:if>
                                                    </c:when>
                                                    <c:otherwise>Date/time not set</c:otherwise>
                                                </c:choose>
                                            </p>
                                            <p class="text-gray-600 text-sm">
                                            <c:choose>
                                                <c:when test="${not empty evaluation.surah}">
                                                    Surah ${evaluation.surah}<c:if test="${not empty evaluation.ayahRange}">, Ayah ${evaluation.ayahRange}</c:if>
                                                </c:when>
                                                <c:when test="${not empty evaluation.ayahRange}">
                                                    Ayah ${evaluation.ayahRange}
                                                </c:when>
                                                <c:otherwise>Surah not set</c:otherwise>
                                            </c:choose>
                                        </p>
                                            
                                            <!-- Performance Scores -->
                                            <div class="grid grid-cols-4 gap-4 mt-4">
                                                <div>
                                                    <p class="text-gray-600 text-xs mb-1">Tajweed</p>
                                                    <p class="text-lg font-bold text-teal-600">${evaluation.tajweedScore}%</p>
                                                </div>
                                                <div>
                                                    <p class="text-gray-600 text-xs mb-1">Fluency</p>
                                                    <p class="text-lg font-bold text-purple-600">${evaluation.fluencyScore}%</p>
                                                </div>
                                                <div>
                                                    <p class="text-gray-600 text-xs mb-1">Accuracy</p>
                                                    <p class="text-lg font-bold text-teal-600">${evaluation.accuracyScore}%</p>
                                                </div>
                                                <div>
                                                    <p class="text-gray-600 text-xs mb-1">Overall</p>
                                                    <p class="text-lg font-bold text-gray-800">${evaluation.overallScore}%</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Action Buttons -->
                                    <div class="flex gap-2">
                                        <button onclick="openViewModal(${evaluation.evaluationId})" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold transition text-sm">
                                            <i class="fas fa-eye"></i> View
                                        </button>
                                        <button onclick="openEditModal(${evaluation.evaluationId})" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg font-semibold transition text-sm">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Student Feedback -->
                <div>
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Student Feedback & Evaluation</h3>
                    <p class="text-gray-600 mb-6">View feedback and ratings submitted by your students about your teaching</p>
                    
                    <div class="space-y-6">
                        <c:if test="${empty studentFeedbackList}">
                            <p class="text-gray-600 italic bg-teal-50 p-4 rounded">No student feedback submitted yet.</p>
                        </c:if>
                        <c:forEach var="feedback" items="${studentFeedbackList}">
                            <div class="bg-white rounded-xl p-6 shadow-md mx-4">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="flex items-center space-x-4">
                                        <div class="w-14 h-14 bg-gradient-to-br from-teal-400 to-cyan-400 rounded-xl flex items-center justify-center">
                                            <span class="text-white font-bold text-lg">
                                                <c:set var="fbParts" value="${fn:split(feedback.studentName, ' ')}" />
                                                <c:out value="${fn:substring(fbParts[0], 0, 1)}${fn:substring(fbParts[fn:length(fbParts)-1], 0, 1)}" />
                                            </span>
                                        </div>
                                        <div>
                                            <h4 class="text-lg font-bold text-gray-800"><c:out value="${feedback.studentName}"/></h4>
                                            <p class="text-gray-600 text-sm">
                                                <c:out value="${feedback.sessionDate}"/>
                                                <c:if test="${not empty feedback.startTime}"> &bull; <c:out value="${feedback.startTime}"/></c:if>
                                                <c:if test="${not empty feedback.endTime}"> - <c:out value="${feedback.endTime}"/></c:if>
                                            </p>
                                            <p class="text-gray-600 text-sm">
                                                <c:if test="${not empty feedback.surah}">Surah <c:out value="${feedback.surah}"/>, Ayah <c:out value="${feedback.ayahRange}"/></c:if>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="text-yellow-400 text-lg text-right">
                                        <c:forEach var="i" begin="1" end="5">
                                            <c:choose>
                                                <c:when test="${i <= feedback.rating}">&#9733;</c:when>
                                                <c:otherwise>&#9734;</c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                        <p class="text-gray-600 text-sm mt-2">${feedback.rating}/5</p>
                                    </div>
                                </div>

                                <c:if test="${not empty feedback.comments}">
                                    <div class="mb-4">
                                        <p class="text-gray-700 font-semibold mb-2"><i class="fas fa-comment text-blue-500 mr-2"></i>Comments</p>
                                        <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
                                            <p class="text-gray-700"><c:out value="${feedback.comments}"/></p>
                                        </div>
                                    </div>
                                </c:if>

                                <c:if test="${not empty feedback.suggestions}">
                                    <div>
                                        <p class="text-gray-700 font-semibold mb-2"><i class="fas fa-lightbulb text-purple-500 mr-2"></i>Suggestions</p>
                                        <div class="bg-purple-50 border-l-4 border-purple-500 p-4 rounded">
                                            <p class="text-gray-700"><c:out value="${feedback.suggestions}"/></p>
                                        </div>
                                    </div>
                                </c:if>

                                <p class="text-gray-500 text-sm mt-4"><i class="fas fa-calendar mr-2"></i>Submitted on <c:out value="${feedback.createdAt}"/></p>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Evaluate Modal with Enhanced Card Design -->
    <div id="evaluateModal" style="pointer-events:none" class="teacher-modal-overlay hidden">
        <div class="eval-modal-dialog teacher-modal-dialog bg-white">
            <!-- Modal Header -->
            <div class="teacher-modal-header flex justify-between items-center rounded-t-2xl">
                <div>
                    <h3 class="text-xl font-bold text-gray-900" id="evalModalTitle">Create Evaluation</h3>
                    <p class="text-sm text-gray-500 mt-0.5">Complete the evaluation form below</p>
                </div>
                <button type="button" onclick="closeModal('evaluateModal')" class="text-gray-400 hover:text-gray-600 transition p-2 hover:bg-white/80 rounded-lg">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>

            <form id="evalForm" method="POST" action="${pageContext.request.contextPath}/teacher/evaluation" class="flex flex-col flex-1 min-h-0">
                <div class="eval-modal-body teacher-modal-body px-6 py-5">
                <input type="hidden" name="action" id="evaluationAction" value="insert">
                <input type="hidden" name="evaluationId" id="evalId">
                <input type="hidden" name="sessionId" id="evalSessionId">
                <input type="hidden" name="studentId" id="evalStudentId">
                <input type="hidden" name="studentName" id="evalStudentName">
                <input type="hidden" name="className" id="evalClassName">
                <input type="hidden" name="surah" id="evalSurahValue">
                <input type="hidden" name="ayahRange" id="evalAyahRangeValue">
                <input type="hidden" name="sessionDate" id="evalSessionDateValue">
                <input type="hidden" name="startTime" id="evalStartTimeValue">
                <input type="hidden" name="endTime" id="evalEndTimeValue">
                <input type="hidden" name="overallScore" id="evalOverallScore" value="0">
                <input type="hidden" name="status" value="COMPLETED">

                <!-- Session Information Section -->
                <div class="mb-8">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 eval-session-grid">
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wide mb-2">Session Date</label>
                            <input type="text" id="sessionDate" readonly
                                   class="eval-readonly-input w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-700 font-medium">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wide mb-2">Session Time</label>
                            <input type="text" id="sessionTime" readonly
                                   class="eval-readonly-input w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-700 font-medium">
                        </div>
                        <div class="sm:col-span-2">
                            <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wide mb-2">Surah</label>
                            <input type="text" id="evalSurahDisplay" readonly
                                   class="eval-readonly-input w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-700 font-medium">
                        </div>
                        <div class="sm:col-span-2">
                            <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wide mb-2">Teacher</label>
                            <input type="text" id="teacherName" readonly
                                   class="eval-readonly-input w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-700 font-medium">
                        </div>
                    </div>
                </div>

                <!-- Performance Scores Section -->
                <div class="mb-6 pt-2">
                    <h4 class="text-sm font-bold text-gray-900 uppercase tracking-wider mb-4 flex items-center">
                        <span class="w-1 h-4 bg-purple-500 rounded mr-3"></span>
                        Performance Scores (/100%)
                    </h4>
                    <div class="grid grid-cols-3 gap-3">
                        <div class="eval-score-card rounded-xl border border-purple-100 bg-purple-50/40 p-3">
                            <label for="tajweedScoreSlider" class="block text-xs font-semibold text-gray-700 mb-1">Tajweed <span class="text-red-500">*</span></label>
                            <span id="tajweedScoreValue" class="block text-sm font-bold text-purple-600 mb-2 text-right">0%</span>
                            <input type="range" id="tajweedScoreSlider" name="tajweedScore" min="0" max="100" step="1" value="0"
                                   class="score-slider block w-full" required>
                        </div>
                        <div class="eval-score-card rounded-xl border border-purple-100 bg-purple-50/40 p-3">
                            <label for="fluencyScoreSlider" class="block text-xs font-semibold text-gray-700 mb-1">Fluency <span class="text-red-500">*</span></label>
                            <span id="fluencyScoreValue" class="block text-sm font-bold text-purple-600 mb-2 text-right">0%</span>
                            <input type="range" id="fluencyScoreSlider" name="fluencyScore" min="0" max="100" step="1" value="0"
                                   class="score-slider block w-full" required>
                        </div>
                        <div class="eval-score-card rounded-xl border border-purple-100 bg-purple-50/40 p-3">
                            <label for="accuracyScoreSlider" class="block text-xs font-semibold text-gray-700 mb-1">Accuracy <span class="text-red-500">*</span></label>
                            <span id="accuracyScoreValue" class="block text-sm font-bold text-purple-600 mb-2 text-right">0%</span>
                            <input type="range" id="accuracyScoreSlider" name="accuracyScore" min="0" max="100" step="1" value="0"
                                   class="score-slider block w-full" required>
                        </div>
                    </div>
                </div>

                <!-- Performance Tag Section -->
                <div class="mb-8">
                    <label class="block text-xs font-semibold text-gray-700 mb-3">Performance Tag (Optional - Auto-assigned if empty)</label>
                    <select name="performanceTag" class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-400 focus:border-transparent transition bg-white text-gray-700 font-medium">
                        <option value="">Auto-assign based on score</option>
                        <option value="Excellent">Excellent (90%+)</option>
                        <option value="Good">Good (80-89%)</option>
                        <option value="Fair">Fair (70-79%)</option>
                        <option value="Needs Improvement">Needs Improvement (<70%)</option>
                    </select>
                </div>

                <!-- Strengths Section -->
                <div class="mb-8 pt-4">
                    <h4 class="text-sm font-bold text-gray-900 uppercase tracking-wider mb-6 flex items-center">
                        <span class="w-1 h-4 bg-green-500 rounded mr-3"></span>
                        Feedback
                    </h4>
                    <div class="mb-6">
                        <label class="block text-xs font-semibold text-gray-700 mb-3">Strengths <span class="text-red-500">*</span></label>
                        <textarea name="comments" rows="3" placeholder="What did the student do well?"
                                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent transition resize-none" required></textarea>
                    </div>

                    <div class="mb-6">
                        <label class="block text-xs font-semibold text-gray-700 mb-3">Areas for Improvement <span class="text-red-500">*</span></label>
                        <textarea name="areasForImprovement" rows="3" placeholder="What needs improvement?"
                                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent transition resize-none" required></textarea>
                    </div>

                    <div class="mb-6">
                        <label class="block text-xs font-semibold text-gray-700 mb-3">Improvement Suggestions <span class="text-red-500">*</span></label>
                        <textarea name="suggestions" rows="3" placeholder="Specific recommendations for the student..."
                                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition resize-none" required></textarea>
                    </div>

                    <div class="mb-6">
                        <label class="block text-xs font-semibold text-gray-700 mb-3">Next Target (Surah & Ayah) <span class="text-red-500">*</span></label>
                        <input type="text" name="nextTarget" placeholder="e.g., Al-Baqarah 6-20"
                               class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-400 focus:border-transparent transition" required>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-gray-700 mb-3">Teacher Comments (Optional)</label>
                        <textarea name="teacherComments" rows="3" placeholder="Additional comments or feedback..."
                                  class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-400 focus:border-transparent transition resize-none"></textarea>
                    </div>
                </div>

                </div>

                <!-- Action Buttons (always visible) -->
                <div class="eval-modal-footer teacher-modal-footer justify-end rounded-b-2xl">
                    <button type="button" onclick="closeModal('evaluateModal')" 
                            class="px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-xl transition duration-200">
                        Cancel
                    </button>
                    <button type="submit" id="evalSubmitBtn"
                            class="px-8 py-3 bg-gradient-to-r from-purple-600 to-purple-700 hover:from-purple-700 hover:to-purple-800 text-white font-semibold rounded-xl transition duration-200 shadow-lg hover:shadow-xl">
                        Create Evaluation
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- View Modal -->
    <div id="viewModal" style="pointer-events:none" class="teacher-modal-overlay hidden">
        <div class="teacher-modal-dialog">
            <!-- Header -->
            <div class="teacher-modal-header flex justify-between items-start gap-4">
                <div class="min-w-0">
                    <p class="text-xs font-semibold uppercase tracking-wider text-purple-600 mb-1">Evaluation Details</p>
                    <h3 id="viewModalStudentName" class="text-xl font-bold text-gray-900 truncate">Student Evaluation</h3>
                    <p id="viewModalSessionMeta" class="text-sm text-gray-500 mt-1"></p>
                </div>
                <button type="button" onclick="closeModal('viewModal')" class="text-gray-400 hover:text-gray-600 transition p-2 hover:bg-white/80 rounded-lg shrink-0">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            <!-- Scrollable content -->
            <div id="viewContent" class="teacher-modal-body">
                <!-- Content injected by openViewModal() -->
            </div>
            <!-- Footer -->
            <div class="teacher-modal-footer">
                <button type="button" onclick="closeModal('viewModal')"
                        class="flex-1 py-3 border border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition">
                    Close
                </button>
                <button type="button" id="viewModalEditBtn"
                        class="flex-1 py-3 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-semibold rounded-xl transition shadow-md">
                    <i class="fas fa-edit mr-2"></i>Edit Evaluation
                </button>
            </div>
        </div>
    </div>

        <!-- Toast for AJAX feedback -->
        <div id="toast" class="hidden fixed bottom-8 right-8 px-6 py-3 rounded-lg text-white shadow-lg z-60"></div>

        <script>
        const scoreSliderConfig = [
            { sliderId: 'tajweedScoreSlider', valueId: 'tajweedScoreValue' },
            { sliderId: 'fluencyScoreSlider', valueId: 'fluencyScoreValue' },
            { sliderId: 'accuracyScoreSlider', valueId: 'accuracyScoreValue' }
        ];

        function updateOverallFromScores() {
            const tajweed = parseFloat(document.getElementById('tajweedScoreSlider')?.value || 0);
            const fluency = parseFloat(document.getElementById('fluencyScoreSlider')?.value || 0);
            const accuracy = parseFloat(document.getElementById('accuracyScoreSlider')?.value || 0);
            const overall = Math.round(((tajweed + fluency + accuracy) / 3) * 10) / 10;
            const overallInput = document.getElementById('evalOverallScore');
            if (overallInput) {
                overallInput.value = overall;
            }
        }

        function updateScoreSliderDisplay(sliderId, valueId) {
            const slider = document.getElementById(sliderId);
            const valueLabel = document.getElementById(valueId);
            if (!slider || !valueLabel) {
                return;
            }
            valueLabel.textContent = Math.round(parseFloat(slider.value || 0)) + '%';
        }

        function setScoreSliderValue(sliderId, valueId, value) {
            const slider = document.getElementById(sliderId);
            if (!slider) {
                return;
            }
            const numericValue = Math.max(0, Math.min(100, Math.round(parseFloat(value || 0))));
            slider.value = numericValue;
            updateScoreSliderDisplay(sliderId, valueId);
        }

        function syncAllScoreSliders() {
            scoreSliderConfig.forEach(function(config) {
                updateScoreSliderDisplay(config.sliderId, config.valueId);
            });
            updateOverallFromScores();
        }

        function initScoreSliders() {
            scoreSliderConfig.forEach(function(config) {
                const slider = document.getElementById(config.sliderId);
                if (!slider) {
                    return;
                }
                slider.addEventListener('input', function() {
                    updateScoreSliderDisplay(config.sliderId, config.valueId);
                    updateOverallFromScores();
                });
            });
            syncAllScoreSliders();
        }

        document.addEventListener('DOMContentLoaded', initScoreSliders);

        function openEvaluateModal(evaluationId, surahArg, ayahArg, sessionIdArg) {
            const hasExistingEval = evaluationId && evaluationId.toString().trim() !== '' && evaluationId.toString().trim() !== '0';
            document.getElementById('evaluationAction').value = hasExistingEval ? 'update' : 'insert';
            document.getElementById('evalId').value = evaluationId || '';

            const form = document.querySelector('#evaluateModal form');
            form.reset();
            const statusField = form.querySelector('input[name="status"]');
            if (statusField) statusField.value = 'COMPLETED';
            document.getElementById('evaluationAction').value = hasExistingEval ? 'update' : 'insert';
            document.getElementById('evalId').value = evaluationId || '';
            document.getElementById('evalSubmitBtn').textContent = hasExistingEval ? 'Save Evaluation' : 'Create Evaluation';
            document.getElementById('evalModalTitle').textContent = hasExistingEval ? 'Update Evaluation' : 'Create Evaluation';
            syncAllScoreSliders();
            
            // Log incoming args for debugging
            console.log('openEvaluateModal args ->', { evaluationId, surahArg, ayahArg, sessionIdArg });
            // Prefer DOM attributes from the pending card (authoritative). Only override with non-empty args.
            let evalData = null;
            const pendingCards = document.querySelectorAll('#pendingList [data-session-id]');
                    for (let card of pendingCards) {
                const cardEvalId = card.getAttribute('data-eval-id') || '';
                const cardSessionId = card.getAttribute('data-session-id') || '';
                const matchesEvalId = evaluationId && evaluationId.toString().trim() !== '' && cardEvalId === evaluationId.toString();
                const matchesSessionId = sessionIdArg && sessionIdArg.toString().trim() !== '' && cardSessionId === sessionIdArg.toString();
                if (matchesEvalId || matchesSessionId) {
                    evalData = {
                        sessionId: card.getAttribute('data-session-id') || '',
                        studentId: card.getAttribute('data-student-id') || '',
                        studentName: card.getAttribute('data-student-name') || '',
                        className: card.getAttribute('data-class-name') || '',
                        sessionDate: card.getAttribute('data-session-date') || '',
                        sessionTime: card.getAttribute('data-session-time') || '',
                        surah: card.getAttribute('data-surah') || '',
                            // read server-rendered composed label from hidden span if present
                            surahLabel: (function(){ const s = card.querySelector('.hidden-surah-label'); return s ? s.textContent.trim() : ''; })(),
                        surahNumber: card.getAttribute('data-surah-number') || '',
                        ayahNumber: card.getAttribute('data-ayah-number') || '',
                        ayahRange: card.getAttribute('data-ayah-range') || '',
                        teacherName: card.getAttribute('data-teacher-name') || ''
                    };
                    break;
                }
            }

            // If card wasn't found, initialize empty object (still allow overrides)
            if (!evalData) {
                evalData = { sessionId: '', studentId: '', studentName: '', className: '', sessionDate: '', sessionTime: '', surah: '', surahNumber: '', ayahNumber: '', ayahRange: '', teacherName: '' };
            }

            // Override only when non-empty args are provided (prevents empty-string args from wiping valid card data)
            if (surahArg && surahArg.toString().trim() !== '') evalData.surah = surahArg;
            if (ayahArg && ayahArg.toString().trim() !== '') evalData.ayahRange = ayahArg;
            if (sessionIdArg && sessionIdArg.toString().trim() !== '') evalData.sessionId = sessionIdArg;

            console.log('openEvaluateModal resolved evalData ->', evalData);

                if (evalData) {
                // Sanitize studentName: avoid literal 'false' or other non-useful values
                const studentNameSafe = (evalData.studentName && evalData.studentName.toString().toLowerCase() !== 'false') ? evalData.studentName : '';
                const titleText = studentNameSafe ? `Create Evaluation ${studentNameSafe}` : 'Create Evaluation';
                document.getElementById('evalModalTitle').textContent = titleText;
                document.getElementById('evalSessionId').value = evalData.sessionId || '';
                document.getElementById('evalStudentId').value = evalData.studentId || '';
                document.getElementById('evalStudentName').value = studentNameSafe || '';
                document.getElementById('evalClassName').value = evalData.className || '';
                document.getElementById('evalSurahValue').value = evalData.surah || '';
                document.getElementById('evalAyahRangeValue').value = evalData.ayahRange || '';
                document.getElementById('evalSessionDateValue').value = evalData.sessionDate || '';
                document.getElementById('evalStartTimeValue').value = (evalData.sessionTime || '').split(' - ')[0] || '';
                document.getElementById('evalEndTimeValue').value = (evalData.sessionTime || '').split(' - ')[1] || '';
                document.getElementById('sessionDate').value = evalData.sessionDate;
                document.getElementById('sessionTime').value = evalData.sessionTime;
                const surahLabel = getSurahNameFromNumber(evalData.surahNumber) || getSurahDisplayLabel(evalData.surah, evalData.surahNumber);
                const ayahLabel = (evalData.ayahRange || evalData.ayahNumber || '').toString().trim();
                const ayahLabelJson = JSON.stringify(ayahLabel);
                const ayahLabelCharCodes = (ayahLabel || '').split('').map(ch => ch.charCodeAt(0));
                console.log('Computed labels ->', { surahLabel, ayahLabel, surahLabel_json: JSON.stringify(surahLabel), ayahLabel_json: ayahLabelJson, ayahLabelCharCodes, surahType: typeof surahLabel, ayahType: typeof ayahLabel, surahLength: (surahLabel||'').length, ayahLength: (ayahLabel||'').length });
                // Prefer server-rendered composed label when available (authoritative). Otherwise compute client-side.
                let composedLabel = '';
                const serverSurahLabel = (evalData.surahLabel || '').toString().trim();
                const validServerLabel = serverSurahLabel && !/^,\s*(Ayah|$)/i.test(serverSurahLabel);
                if (validServerLabel) {
                    composedLabel = serverSurahLabel;
                    // If the server-rendered label doesn't already include the ayahRange, append it
                    if (evalData.ayahRange && evalData.ayahRange.toString().trim()) {
                        const ar = evalData.ayahRange.toString().trim();
                        if (!composedLabel.includes(ar) && !/Ayah/i.test(composedLabel)) {
                            composedLabel = `${composedLabel}, Ayah ${ar}`;
                        }
                    }
                } else if (surahLabel && surahLabel.toString().trim()) {
                    composedLabel = ayahLabel ? `${surahLabel.toString().trim()}, Ayah ${ayahLabel}` : surahLabel.toString().trim();
                } else {
                    composedLabel = ayahLabel ? `Ayah ${ayahLabel}` : '';
                }

                // Normalize whitespace, newlines and punctuation so final label looks like "Al-Baqarah, Ayah 1-4"
                try { composedLabel = normalizeLabel(composedLabel); } catch (e) { /* ignore */ }
                // Defensive final surah value for hidden form field (use raw surah name)
                const finalSurahValue = (surahLabel && surahLabel.toString().trim()) ? surahLabel.toString().trim() : (evalData.surah || '').toString().trim();
                // Detailed debug: show JSON and char codes to detect hidden/control characters
                const finalSurahJson = JSON.stringify(finalSurahValue);
                const composedJson = JSON.stringify(composedLabel);
                const finalSurahCharCodes = (finalSurahValue || '').split('').map(ch => ch.charCodeAt(0));
                console.log('Final surah build ->', { finalSurahValue, finalSurahJson, finalSurahCharCodes, composedLabel, composedJson });
                document.getElementById('evalSurahValue').value = finalSurahValue;
                // Retry helper to ensure the field isn't overwritten by other scripts/styles
                (function applySurahLabelRetry(label) {
                    const apply = () => {
                        const surahEl = document.getElementById('evalSurahDisplay');
                        if (!surahEl) return;
                        try {
                            try { console.log('Applying label ->', { label_json: JSON.stringify(label), labelChars: (label||'').split('').map(ch=>ch.charCodeAt(0)), labelType: typeof label, labelLength: (label||'').length }); } catch(e) { }
                            // set multiple ways to persist value
                            surahEl.value = label;
                            surahEl.defaultValue = label;
                            surahEl.setAttribute('value', label);
                            surahEl.placeholder = label;
                            try { surahEl.dispatchEvent(new Event('input', { bubbles: true })); } catch(e) {}
                        } catch (e) { /* ignore */ }
                    };

                    // Immediate
                    apply();
                    // Reapply after short delays to override later updates
                    setTimeout(apply, 100);
                    setTimeout(apply, 300);
                    setTimeout(apply, 600);
                    setTimeout(apply, 1200);
                    // Additional logging after updates to inspect final DOM state
                    setTimeout(() => {
                        try {
                            const el = document.getElementById('evalSurahDisplay');
                            if (!el) { console.log('Surah display element missing at final check'); return; }
                            console.log('FINAL SURAH CHECK -> value:', el.value);
                            console.log('FINAL SURAH CHECK -> attr value:', el.getAttribute('value'));
                            console.log('FINAL SURAH CHECK -> defaultValue:', el.defaultValue);
                            console.log('FINAL SURAH CHECK -> placeholder:', el.placeholder);
                            console.log('FINAL SURAH CHECK -> readonly:', el.readOnly);
                            console.log('FINAL SURAH CHECK -> outerHTML:', el.outerHTML);
                            console.log('FINAL SURAH CHECK -> all matches:', document.querySelectorAll('[id="evalSurahDisplay"]').length);
                        } catch (e) { console.log('FINAL SURAH CHECK error', e); }
                    }, 1500);
                })(composedLabel);
                document.getElementById('teacherName').value = evalData.teacherName || 'Teacher';
            }
            
            openModal('evaluateModal');
        }

        function openViewModal(evaluationId) {
            const card = document.querySelector('[data-eval-id="' + evaluationId + '"]');
            if (!card) {
                document.getElementById('viewContent').innerHTML = '<p class="text-gray-600 italic">Evaluation not found.</p>';
                openModal('viewModal');
                return;
            }
            const ev = {
                studentName:    card.getAttribute('data-student-name') || '',
                sessionDate:    card.getAttribute('data-session-date') || '',
                startTime:      card.getAttribute('data-start-time') || '',
                endTime:        card.getAttribute('data-end-time') || '',
                surah:          card.getAttribute('data-surah') || '',
                ayahRange:      card.getAttribute('data-ayah-range') || '',
                className:      card.getAttribute('data-class-name') || '',
                tajweed:        parseFloat(card.getAttribute('data-tajweed'))  || 0,
                fluency:        parseFloat(card.getAttribute('data-fluency'))  || 0,
                accuracy:       parseFloat(card.getAttribute('data-accuracy')) || 0,
                overall:        parseFloat(card.getAttribute('data-overall'))  || 0,
                rating:         parseInt(card.getAttribute('data-rating'))     || 0,
                comments:       card.getAttribute('data-comments') || '',
                areasImprovement: card.getAttribute('data-areas-improvement') || '',
                suggestions:    card.getAttribute('data-suggestions') || '',
                nextTarget:     normalizeAsciiDash(card.getAttribute('data-next-target') || ''),
                teacherComments: card.getAttribute('data-teacher-comments') || '',
                performanceTag: card.getAttribute('data-performance-tag') || ''
            };

            const perfTag   = ev.performanceTag || (ev.overall >= 90 ? 'Excellent' : ev.overall >= 80 ? 'Good' : ev.overall >= 70 ? 'Fair' : 'Needs Improvement');
            const perfColor = ev.overall >= 90 ? '#047857' : ev.overall >= 80 ? '#6d28d9' : '#b45309';
            const perfBg    = ev.overall >= 90 ? '#d1fae5' : ev.overall >= 80 ? '#ede9fe' : '#fef3c7';

            // Avatar initials
            const nameParts = ev.studentName.trim().split(/\s+/);
            const initials  = (nameParts[0] ? nameParts[0].charAt(0) : '') + (nameParts[1] ? nameParts[1].charAt(0) : '');

            // Format date nicely: "Dec 30, 2024 • 10:00 AM - 10:15 AM"
            let dateStr = escHtml(ev.sessionDate);
            try {
                const d = new Date(ev.sessionDate);
                if (!isNaN(d)) dateStr = d.toLocaleDateString('en-US', {year:'numeric',month:'short',day:'numeric'});
            } catch(e) {}
            const fmtTime = t => {
                if (!t) return '';
                const [h,m] = t.split(':');
                const hr = parseInt(h); const ampm = hr >= 12 ? 'PM' : 'AM';
                return ((hr % 12) || 12) + ':' + m + ' ' + ampm;
            };
            const timeStr = fmtTime(ev.startTime) + ' - ' + fmtTime(ev.endTime);

            const section = (iconClass, title, text, bg, border) => text
                ? `<div>
                     <p class="font-semibold text-gray-800 mb-2 flex items-center gap-2"><i class="fas \${iconClass} text-sm"></i>\${title}</p>
                     <div class="view-feedback-block text-sm text-gray-700 leading-relaxed" style="background:\${bg};border-color:\${border};">\${escHtml(text)}</div>
                   </div>`
                : '';

            document.getElementById('viewModalStudentName').textContent = ev.studentName || 'Student Evaluation';
            document.getElementById('viewModalSessionMeta').textContent =
                dateStr + ' • ' + timeStr + (ev.surah ? ' • Surah ' + ev.surah + (ev.ayahRange ? ', Ayah ' + ev.ayahRange : '') : '');

            document.getElementById('viewContent').innerHTML = `
                <div class="space-y-5">
                    <div class="flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-purple-50 to-pink-50 border border-purple-100">
                        <div class="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0 font-bold text-white text-lg shadow-sm"
                             style="background:linear-gradient(135deg,#7c3aed,#be185d);">\${escHtml(initials)}</div>
                        <div class="min-w-0">
                            <p class="text-lg font-bold text-gray-900 truncate">\${escHtml(ev.studentName)}</p>
                            <p class="text-gray-500 text-sm">\${escHtml(ev.className || 'Quran Recitation Session')}</p>
                        </div>
                    </div>

                    <div>
                        <p class="text-xs font-semibold uppercase tracking-wider text-gray-500 mb-3">Performance Scores</p>
                        <div class="view-score-grid">
                            <div class="view-score-card tajweed">
                                <p class="text-xs text-gray-500 mb-1">Tajweed</p>
                                <p class="text-2xl font-extrabold text-emerald-600">\${ev.tajweed}%</p>
                            </div>
                            <div class="view-score-card fluency">
                                <p class="text-xs text-gray-500 mb-1">Fluency</p>
                                <p class="text-2xl font-extrabold text-purple-600">\${ev.fluency}%</p>
                            </div>
                            <div class="view-score-card accuracy">
                                <p class="text-xs text-gray-500 mb-1">Accuracy</p>
                                <p class="text-2xl font-extrabold text-blue-600">\${ev.accuracy}%</p>
                            </div>
                            <div class="view-score-card overall">
                                <p class="text-xs text-gray-500 mb-1">Overall</p>
                                <p class="text-2xl font-extrabold text-fuchsia-600">\${ev.overall}%</p>
                            </div>
                        </div>
                    </div>

                    <div class="flex items-center gap-2 text-sm text-gray-600">
                        <span class="font-medium">Performance Level:</span>
                        <span class="px-3 py-1 rounded-full text-xs font-semibold" style="background:\${perfBg};color:\${perfColor};">\${escHtml(perfTag)}</span>
                    </div>

                    \${section('fa-check-circle', 'Strengths', ev.comments, '#ecfdf5', '#10b981')}
                    \${section('fa-exclamation-triangle', 'Areas for Improvement', ev.areasImprovement, '#fffbeb', '#f59e0b')}
                    \${section('fa-lightbulb', 'Recommendations', ev.suggestions, '#eff6ff', '#3b82f6')}
                    \${section('fa-bullseye', 'Next Learning Target', ev.nextTarget, '#f5f3ff', '#8b5cf6')}

                    \${ev.teacherComments ? '<div><p class="font-semibold text-gray-800 mb-2 flex items-center gap-2"><i class="fas fa-comment-dots text-sm"></i>Teacher Comments</p><div class="view-feedback-block text-sm text-gray-700 leading-relaxed" style="background:#f8fafc;border-color:#cbd5e1;">' + escHtml(ev.teacherComments) + '</div></div>' : ''}
                </div>
            `;

            // Wire "Edit Evaluation" button in the footer
            document.getElementById('viewModalEditBtn').onclick = function() {
                closeModal('viewModal');
                setTimeout(function() { openEditModal(evaluationId); }, 150);
            };

            openModal('viewModal');
        }

        function openModal(modalId) {
            const modal = document.getElementById(modalId);
            if (!modal) return;
            modal.classList.remove('hidden');
            modal.style.pointerEvents = 'auto';
            document.body.classList.add('modal-open');
            const body = modal.querySelector('.teacher-modal-body, .eval-modal-body');
            if (body) body.scrollTop = 0;
        }

        function escHtml(str) {
            if (!str) return '';
            return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
        }

        function normalizeAsciiDash(str) {
            if (!str) return '';
            let value = String(str)
                .replace(/\u2013|\u2014|\u2212/g, '-')
                .replace(/\u00e2\u0080[\u0093\u0094]/g, '-')
                .replace(/\u00c3\u00a2[\u00c2\u0080\u0093\u00a2]{1,6}/g, '-');
            return value.replace(/(\d)\s*[^0-9A-Za-z.\s]{1,8}\s*(\d)/g, '$1-$2').replace(/-{2,}/g, '-').trim();
        }

        function getSurahNameFromNumber(surahNumber) {
            const surahNames = {
                1: 'Al-Fatiha',
                2: 'Al-Baqarah',
                3: 'Al-Imran',
                4: 'An-Nisa',
                5: 'Al-Maidah',
                6: 'Al-Anam',
                7: 'Al-Araf',
                8: 'Al-Anfal',
                9: 'At-Tawbah',
                10: 'Yunus',
                11: 'Hud',
                12: 'Yusuf',
                13: 'Ar-Rad',
                14: 'Ibrahim',
                15: 'Al-Hijr',
                16: 'An-Nahl',
                17: 'Al-Isra',
                18: 'Al-Kahf',
                19: 'Maryam',
                20: 'Taha',
                21: 'Al-Anbiya',
                22: 'Al-Hajj',
                23: 'Al-Muminun',
                24: 'An-Nur',
                25: 'Al-Furqan',
                26: 'Ash-Shuara',
                27: 'An-Naml',
                28: 'Al-Qasas',
                29: 'Al-Ankabut',
                30: 'Ar-Rum',
                31: 'Luqman',
                32: 'As-Sajdah',
                33: 'Al-Ahzab',
                34: 'Saba',
                35: 'Fatir',
                36: 'Yasin',
                37: 'As-Saffat',
                38: 'Sad',
                39: 'Az-Zumar',
                40: 'Ghafir',
                41: 'Fussilat',
                42: 'Ash-Shura',
                43: 'Az-Zukhruf',
                44: 'Ad-Dukhan',
                45: 'Al-Jathiya',
                46: 'Al-Ahqaf',
                47: 'Muhammad',
                48: 'Al-Fath',
                49: 'Al-Hujurat',
                50: 'Qaf',
                51: 'Adh-Dhariyat',
                52: 'At-Tur',
                53: 'An-Najm',
                54: 'Al-Qamar',
                55: 'Ar-Rahman',
                56: 'Al-Waqiah',
                57: 'Al-Hadid',
                58: 'Al-Mujadalah',
                59: 'Al-Hashr',
                60: 'Al-Mumtahanah',
                61: 'As-Saff',
                62: 'Al-Jumuah',
                63: 'Al-Munafiqun',
                64: 'At-Taghabun',
                65: 'At-Talaq',
                66: 'At-Tahrim',
                67: 'Al-Mulk',
                68: 'Al-Qalam',
                69: 'Al-Haqqah',
                70: 'Al-Maarij',
                71: 'Nuh',
                72: 'Al-Jinn',
                73: 'Al-Muzzammil',
                74: 'Al-Muddaththir',
                75: 'Al-Qiyamah',
                76: 'Al-Insan',
                77: 'Al-Mursalat',
                78: 'An-Naba',
                79: 'An-Naziat',
                80: 'Abasa',
                81: 'At-Takwir',
                82: 'Al-Infitar',
                83: 'Al-Mutaffifin',
                84: 'Al-Inshiqaq',
                85: 'Al-Buruj',
                86: 'At-Tariq',
                87: 'Al-Ala',
                88: 'Al-Ghashiyah',
                89: 'Al-Fajr',
                90: 'Al-Balad',
                91: 'Ash-Shams',
                92: 'Al-Layl',
                93: 'Ad-Duha',
                94: 'Ash-Sharh',
                95: 'At-Tin',
                96: 'Al-Alaq',
                97: 'Al-Qadr',
                98: 'Al-Bayyinah',
                99: 'Az-Zalzalah',
                100: 'Al-Adiyat',
                101: 'Al-Qariah',
                102: 'At-Takathur',
                103: 'Al-Asr',
                104: 'Al-Humazah',
                105: 'Al-Fil',
                106: 'Quraysh',
                107: 'Al-Maun',
                108: 'Al-Kawthar',
                109: 'Al-Kafirun',
                110: 'An-Nasr',
                111: 'Al-Masad',
                112: 'Al-Ikhlas',
                113: 'Al-Falaq',
                114: 'An-Nas'
            };

            const numericValue = parseInt(surahNumber, 10);
            return surahNames[numericValue] || '';
        }

        function getSurahDisplayLabel(surahText, surahNumber) {
            const trimmedText = (surahText || '').trim();
            if (trimmedText && !/^\d+$/.test(trimmedText)) {
                return trimmedText;
            }

            const numericValue = parseInt(trimmedText || surahNumber, 10);
            if (!Number.isNaN(numericValue) && numericValue > 0) {
                return getSurahNameFromNumber(numericValue);
            }

            return trimmedText;
        }

        function normalizeLabel(label) {
            if (!label) return '';
            // collapse all whitespace (spaces, newlines, tabs) to single space
            let t = label.replace(/\s+/g, ' ').trim();
            // remove space(s) before commas
            t = t.replace(/\s+,/g, ',');
            // ensure there is a space after comma
            t = t.replace(/,([^\s])/g, ', $1');
            // Only prefix with comma when a surah name precedes Ayah
            if (/^Ayah\s/i.test(t)) {
                return t.replace(/\s*Ayah\s*/i, 'Ayah ').trim();
            }
            if (t.includes(',')) {
                t = t.replace(/\s*Ayah\s*/i, ', Ayah ');
            } else {
                t = t.replace(/\s*Ayah\s*/i, 'Ayah ');
            }
            // collapse any duplicate commas/spaces
            t = t.replace(/,\s*,/g, ',');
            t = t.replace(/^,\s*/, '').trim();
            return t;
        }

        function openEditModal(evaluationId) {
            const card = document.querySelector('[data-eval-id="' + evaluationId + '"]');
            if (!card) return;

            const form = document.querySelector('#evaluateModal form');
            form.reset();

            document.getElementById('evaluationAction').value = 'update';
            document.getElementById('evalId').value = evaluationId;
            document.getElementById('evalStudentId').value = card.getAttribute('data-student-id') || '';
            document.getElementById('evalStudentName').value = card.getAttribute('data-student-name') || '';
            document.getElementById('evalSessionId').value = card.getAttribute('data-session-id') || '';
            document.getElementById('evalClassName').value = card.getAttribute('data-class-name') || '';
            document.getElementById('evalSurahValue').value = card.getAttribute('data-surah') || '';
            document.getElementById('evalAyahRangeValue').value = card.getAttribute('data-ayah-range') || '';
            const sessionDate = card.getAttribute('data-session-date') || '';
            const startTime = card.getAttribute('data-start-time') || '';
            const endTime = card.getAttribute('data-end-time') || '';
            document.getElementById('evalSessionDateValue').value = sessionDate;
            document.getElementById('evalStartTimeValue').value = startTime;
            document.getElementById('evalEndTimeValue').value = endTime;
            document.getElementById('sessionDate').value = sessionDate;
            document.getElementById('sessionTime').value = startTime + (endTime ? ' - ' + endTime : '');

            const surah = card.getAttribute('data-surah') || '';
            const ayah = card.getAttribute('data-ayah-range') || '';
            document.getElementById('evalSurahDisplay').value = surah + (ayah ? ', Ayah ' + ayah : '');

            const studentName = card.getAttribute('data-student-name') || '';
            document.getElementById('evalModalTitle').textContent = 'Edit Evaluation' + (studentName ? ' – ' + studentName : '');
            document.getElementById('evalSubmitBtn').textContent = 'Update Evaluation';

            // Populate scores
            setScoreSliderValue('tajweedScoreSlider', 'tajweedScoreValue', card.getAttribute('data-tajweed') || 0);
            setScoreSliderValue('fluencyScoreSlider', 'fluencyScoreValue', card.getAttribute('data-fluency') || 0);
            setScoreSliderValue('accuracyScoreSlider', 'accuracyScoreValue', card.getAttribute('data-accuracy') || 0);
            updateOverallFromScores();

            // Populate feedback fields
            form.querySelector('[name="comments"]').value = card.getAttribute('data-comments') || '';
            form.querySelector('[name="areasForImprovement"]').value = card.getAttribute('data-areas-improvement') || '';
            form.querySelector('[name="suggestions"]').value = card.getAttribute('data-suggestions') || '';
            form.querySelector('[name="nextTarget"]').value = card.getAttribute('data-next-target') || '';
            form.querySelector('[name="teacherComments"]').value = card.getAttribute('data-teacher-comments') || '';

            const perfTagSelect = form.querySelector('[name="performanceTag"]');
            if (perfTagSelect) perfTagSelect.value = card.getAttribute('data-performance-tag') || '';

            document.getElementById('teacherName').value = card.getAttribute('data-teacher-name') || 'Teacher';
            openModal('evaluateModal');
        }

        function closeModal(modalId) {
            const m = document.getElementById(modalId);
            if (!m) return;
            m.classList.add('hidden');
            try { m.style.pointerEvents = 'none'; } catch(e) {}
            const anyOpen = !document.getElementById('evaluateModal').classList.contains('hidden')
                || !document.getElementById('viewModal').classList.contains('hidden');
            if (!anyOpen) {
                document.body.classList.remove('modal-open');
            }
            // Reset evaluate modal title/button when closed
            if (modalId === 'evaluateModal') {
                document.getElementById('evalModalTitle').textContent = 'Create Evaluation';
                document.getElementById('evalSubmitBtn').textContent = 'Create Evaluation';
            }
        }

        document.addEventListener('click', function(event) {
            ['evaluateModal', 'viewModal'].forEach(modalId => {
                const modal = document.getElementById(modalId);
                if (event.target === modal) {
                    closeModal(modalId);
                }
            });
        });

        // Show a small toast notification
        function showToast(message, isError) {
            const toast = document.getElementById('toast');
            toast.textContent = message || '';
            toast.style.transition = 'opacity 200ms ease';
            toast.classList.remove('hidden');
            toast.style.opacity = '1';
            if (isError) {
                toast.className = 'fixed bottom-8 right-8 px-6 py-3 rounded-lg text-white shadow-lg bg-red-600 z-60';
            } else {
                toast.className = 'fixed bottom-8 right-8 px-6 py-3 rounded-lg text-white shadow-lg bg-green-600 z-60';
            }
            setTimeout(() => {
                try { toast.style.opacity = '0'; } catch (e) {}
                setTimeout(() => { toast.classList.add('hidden'); }, 250);
            }, 2500);
        }

        // AJAX form submit for evaluation form
        (function attachAjaxSubmit() {
            const form = document.getElementById('evalForm');
            if (!form) return;
            form.addEventListener('submit', function (e) {
                e.preventDefault();
                updateOverallFromScores();

                const nextTargetInput = form.querySelector('[name="nextTarget"]');
                if (nextTargetInput) {
                    nextTargetInput.value = normalizeAsciiDash(nextTargetInput.value);
                }

                const studentId = document.getElementById('evalStudentId').value || '';
                const sessionId = document.getElementById('evalSessionId').value || '';
                if (!studentId.trim()) {
                    showToast('Student info is missing. Close the form and click Evaluate Now again.', true);
                    return;
                }
                if (!sessionId.trim()) {
                    showToast('Session info is missing. Close the form and click Evaluate Now again.', true);
                    return;
                }

                // Use getAttribute to avoid shadowing by inputs named 'action'
                const url = form.getAttribute('action') || window.location.href;
                const formData = new FormData(form);
                formData.append('ajax', 'true');

                // Convert FormData to URL-encoded string so Tomcat can read parameters
                // without needing @MultipartConfig, and set X-Requested-With header
                const urlEncoded = new URLSearchParams(formData).toString();

                fetch(url, {
                    method: 'POST',
                    body: urlEncoded,
                    credentials: 'same-origin',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                }).then(response => {
                    const ct = response.headers.get('content-type') || '';
                    if (ct.indexOf('application/json') !== -1) {
                        return response.json();
                    }
                    // fallback: server returned non-JSON (e.g. HTML error page)
                    return response.text().then(() => ({ success: false, message: 'Server error. Please try again.' }));
                }).then(data => {
                    if (data && data.success) {
                        showToast(data.message || 'Evaluation saved');
                        const evalData = data.evaluation || {};
                        const formAction = document.getElementById('evaluationAction').value;
                        const evalId = document.getElementById('evalId').value;

                        closeModal('evaluateModal');

                        try {
                            if (formAction === 'update' && evalId) {
                                const updated = updateCompletedEvaluationCard(evalId, evalData);
                                if (!updated) {
                                    appendCompletedEvaluation(evalData);
                                }
                            } else {
                                appendCompletedEvaluation(evalData);
                                removePendingEvaluationCard(evalId, evalData.sessionId);
                            }
                        } catch (e) {
                            console.error('update UI error', e);
                        }
                    } else {
                        showToast(data && data.message ? data.message : 'Failed to save evaluation', true);
                    }
                }).catch(err => {
                    console.error('AJAX submit error', err);
                    showToast('Network or server error', true);
                });
            });
        })();

        // Append a completed evaluation card to the completed list (mirrors server-rendered cards)
        function getCompletedEvaluationMeta(ev) {
            const overallScore = parseFloat(ev.overallScore || 0);
            const borderColor = overallScore >= 90 ? '#10b981' : (overallScore >= 80 ? '#8b5cf6' : '#f59e0b');
            const perfBg = overallScore >= 90 ? '#d1fae5' : (overallScore >= 80 ? '#ede9fe' : '#fef3c7');
            const perfColor = overallScore >= 90 ? '#047857' : (overallScore >= 80 ? '#6d28d9' : '#b45309');
            const perfTag = ev.performanceTag || (overallScore >= 90 ? 'Excellent' : (overallScore >= 80 ? 'Good' : 'Fair'));
            const name = ev.studentName || '';
            const parts = name.split(' ');
            return {
                overallScore: overallScore,
                borderColor: borderColor,
                perfBg: perfBg,
                perfColor: perfColor,
                perfTag: perfTag,
                name: name,
                initial1: name.charAt(0) || '',
                initial2: parts.length > 1 ? parts[1].charAt(0) : '',
                evalId: ev.evaluationId || 0
            };
        }

        function buildCompletedEvaluationCardHtml(ev, meta) {
            return `
                <div class="flex items-start justify-between">
                    <div class="flex items-start space-x-4">
                        <div class="w-16 h-16 bg-gradient-to-br from-teal-300 to-cyan-300 rounded-xl flex items-center justify-center flex-shrink-0">
                            <span class="text-white font-bold text-xl">\${escHtml(meta.initial1)}\${escHtml(meta.initial2)}</span>
                        </div>
                        <div class="flex-1">
                            <div class="flex items-center space-x-3 mb-2">
                                <h4 class="text-lg font-bold text-gray-800">\${escHtml(meta.name)}</h4>
                                <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold"
                                      style="background-color:\${meta.perfBg};color:\${meta.perfColor};">\${escHtml(meta.perfTag)}</span>
                            </div>
                            <p class="text-gray-600 text-sm mb-3">\${escHtml(ev.sessionDate || '')} • \${escHtml(ev.startTime || '')} - \${escHtml(ev.endTime || '')}</p>
                            <p class="text-gray-600 text-sm">Surah \${escHtml(ev.surah || '')}, Ayah \${escHtml(ev.ayahRange || '')}</p>
                            <div class="grid grid-cols-4 gap-4 mt-4">
                                <div><p class="text-gray-600 text-xs mb-1">Tajweed</p><p class="text-lg font-bold text-teal-600">\${ev.tajweedScore || 0}%</p></div>
                                <div><p class="text-gray-600 text-xs mb-1">Fluency</p><p class="text-lg font-bold text-purple-600">\${ev.fluencyScore || 0}%</p></div>
                                <div><p class="text-gray-600 text-xs mb-1">Accuracy</p><p class="text-lg font-bold text-teal-600">\${ev.accuracyScore || 0}%</p></div>
                                <div><p class="text-gray-600 text-xs mb-1">Overall</p><p class="text-lg font-bold text-gray-800">\${ev.overallScore || 0}%</p></div>
                            </div>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button onclick="openViewModal(\${meta.evalId})" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold transition text-sm"><i class="fas fa-eye"></i> View</button>
                        <button onclick="openEditModal(\${meta.evalId})" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg font-semibold transition text-sm"><i class="fas fa-edit"></i> Edit</button>
                    </div>
                </div>
            `;
        }

        function applyCompletedEvaluationCardData(card, ev, meta) {
            card.setAttribute('data-eval-id', meta.evalId);
            card.setAttribute('data-student-name', meta.name);
            card.setAttribute('data-student-id', ev.studentId || '');
            card.setAttribute('data-session-id', ev.sessionId || '');
            card.setAttribute('data-session-date', ev.sessionDate || '');
            card.setAttribute('data-start-time', ev.startTime || '');
            card.setAttribute('data-end-time', ev.endTime || '');
            card.setAttribute('data-surah', ev.surah || '');
            card.setAttribute('data-ayah-range', ev.ayahRange || '');
            card.setAttribute('data-class-name', ev.className || '');
            card.setAttribute('data-tajweed', ev.tajweedScore || 0);
            card.setAttribute('data-fluency', ev.fluencyScore || 0);
            card.setAttribute('data-accuracy', ev.accuracyScore || 0);
            card.setAttribute('data-overall', ev.overallScore || 0);
            card.setAttribute('data-rating', ev.rating || 0);
            card.setAttribute('data-comments', ev.comments || '');
            card.setAttribute('data-areas-improvement', ev.areasForImprovement || '');
            card.setAttribute('data-suggestions', ev.suggestions || '');
            card.setAttribute('data-next-target', ev.nextTarget || '');
            card.setAttribute('data-teacher-comments', ev.teacherComments || '');
            card.setAttribute('data-performance-tag', meta.perfTag);
            card.style.borderColor = meta.borderColor;
            card.innerHTML = buildCompletedEvaluationCardHtml(ev, meta);
        }

        function mergeEvalWithExistingCard(card, ev) {
            if (!card) {
                return ev;
            }

            return {
                evaluationId: ev.evaluationId || card.getAttribute('data-eval-id') || 0,
                studentId: ev.studentId || card.getAttribute('data-student-id') || '',
                studentName: ev.studentName || card.getAttribute('data-student-name') || '',
                sessionId: ev.sessionId || card.getAttribute('data-session-id') || '',
                sessionDate: ev.sessionDate || card.getAttribute('data-session-date') || '',
                startTime: ev.startTime || card.getAttribute('data-start-time') || '',
                endTime: ev.endTime || card.getAttribute('data-end-time') || '',
                surah: ev.surah || card.getAttribute('data-surah') || '',
                ayahRange: ev.ayahRange || card.getAttribute('data-ayah-range') || '',
                className: ev.className || card.getAttribute('data-class-name') || '',
                tajweedScore: ev.tajweedScore != null ? ev.tajweedScore : (parseFloat(card.getAttribute('data-tajweed')) || 0),
                fluencyScore: ev.fluencyScore != null ? ev.fluencyScore : (parseFloat(card.getAttribute('data-fluency')) || 0),
                accuracyScore: ev.accuracyScore != null ? ev.accuracyScore : (parseFloat(card.getAttribute('data-accuracy')) || 0),
                overallScore: ev.overallScore != null ? ev.overallScore : (parseFloat(card.getAttribute('data-overall')) || 0),
                rating: ev.rating != null ? ev.rating : (parseInt(card.getAttribute('data-rating'), 10) || 0),
                comments: ev.comments != null ? ev.comments : (card.getAttribute('data-comments') || ''),
                areasForImprovement: ev.areasForImprovement != null ? ev.areasForImprovement : (card.getAttribute('data-areas-improvement') || ''),
                suggestions: ev.suggestions != null ? ev.suggestions : (card.getAttribute('data-suggestions') || ''),
                nextTarget: ev.nextTarget != null ? ev.nextTarget : (card.getAttribute('data-next-target') || ''),
                teacherComments: ev.teacherComments != null ? ev.teacherComments : (card.getAttribute('data-teacher-comments') || ''),
                performanceTag: ev.performanceTag || card.getAttribute('data-performance-tag') || ''
            };
        }

        function findCompletedEvaluationCard(evalId) {
            const container = document.getElementById('completedList');
            if (!container || !evalId) {
                return null;
            }

            const cards = container.querySelectorAll('[data-eval-id]');
            for (let i = 0; i < cards.length; i++) {
                if (cards[i].getAttribute('data-eval-id') === String(evalId)) {
                    return cards[i];
                }
            }

            return null;
        }

        function updateCompletedEvaluationCard(evalId, ev) {
            const card = findCompletedEvaluationCard(evalId);
            if (!card) {
                return false;
            }

            const merged = mergeEvalWithExistingCard(card, ev);
            const meta = getCompletedEvaluationMeta(merged);
            applyCompletedEvaluationCardData(card, merged, meta);
            return true;
        }

        function removePendingEvaluationCard(evalId, sessionId) {
            const container = document.getElementById('pendingList');
            if (!container) {
                return;
            }

            const cards = container.querySelectorAll('[data-eval-id], [data-session-id]');
            for (let i = 0; i < cards.length; i++) {
                const card = cards[i];
                const cardEvalId = card.getAttribute('data-eval-id') || '';
                const cardSessionId = card.getAttribute('data-session-id') || '';
                const matchesEvalId = evalId && cardEvalId === String(evalId);
                const matchesSessionId = sessionId && cardSessionId === String(sessionId);

                if (matchesEvalId || matchesSessionId) {
                    card.parentNode.removeChild(card);
                    break;
                }
            }
        }

        function appendCompletedEvaluation(ev) {
            if (!ev) return;
            const container = document.getElementById('completedList');
            if (!container) return;

            const meta = getCompletedEvaluationMeta(ev);

            // Remove any "no evaluations" placeholder
            const placeholder = container.querySelector('p.italic');
            if (placeholder) placeholder.remove();

            const card = document.createElement('div');
            card.className = 'bg-white rounded-xl p-6 shadow-md border-l-4 mx-4';
            applyCompletedEvaluationCardData(card, ev, meta);

            if (container.firstChild) container.insertBefore(card, container.firstChild);
            else container.appendChild(card);
        }
    </script>
</body>
</html>