<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="model.Evaluation" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evaluation & Progress - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        .score-cards-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 32px;
        }
        
        .score-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: all 0.3s;
        }
        
        .score-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }
        
        .score-card-icon {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            color: white;
            font-size: 24px;
        }
        
        .score-card-icon.overall {
            background: #06B6D4;
        }
        
        .score-card-icon.tajweed {
            background: var(--student-green);
        }
        
        .score-card-icon.fluency {
            background: #34D399;
        }
        
        .score-card-icon.accuracy {
            background: #0d9488;
        }
        
        .score-value {
            font-size: 32px;
            font-weight: 700;
            color: #1E293B;
            margin-bottom: 8px;
        }
        
        .score-label {
            font-size: 14px;
            color: #64748B;
        }
        
        .charts-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 32px;
        }
        
        .chart-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .chart-title {
            font-size: 16px;
            font-weight: 600;
            color: #1E293B;
            margin-bottom: 20px;
        }
        
        .history-title {
            font-size: 20px;
            font-weight: 600;
            color: #1E293B;
            margin-bottom: 4px;
        }
        
        .history-count {
            font-size: 12px;
            color: #64748B;
            margin-bottom: 20px;
        }
        
        .evaluation-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 16px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            transition: all 0.3s;
        }
        
        .evaluation-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .evaluation-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 16px;
            flex-shrink: 0;
        }
        
        .avatar-ik {
            background: linear-gradient(135deg, #4ECDC4 0%, #44A08D 100%);
        }
        
        .avatar-fa {
            background: linear-gradient(135deg, #D1A1E6 0%, #C084FC 100%);
        }
        
        .evaluation-content {
            flex: 1;
        }
        
        .evaluation-title {
            font-size: 14px;
            font-weight: 600;
            color: #1E293B;
            margin-bottom: 4px;
        }
        
        .evaluation-meta {
            font-size: 12px;
            color: #64748B;
            margin-bottom: 8px;
        }
        
        .evaluation-badges {
            display: flex;
            gap: 8px;
        }
        
        .badge {
            font-size: 11px;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 500;
        }
        
        .badge-success {
            background: #D1FAE5;
            color: #065F46;
        }
        
        .badge-score {
            background: #DBEAFE;
            color: #0C4A6E;
        }
        
        .evaluation-button {
            background: #4ECDC4;
            color: white;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .evaluation-button:hover {
            background: #3EBAB2;
        }
        
        .session-title {
            font-size: 16px;
            font-weight: 700;
            color: #1E293B;
            margin-bottom: 20px;
        }
        
        .session-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 16px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .session-time {
            font-size: 13px;
            color: #64748B;
            min-width: 140px;
        }
        
        .session-content {
            flex: 1;
        }
        
        .session-surah {
            font-size: 14px;
            color: #64748B;
        }
        
        .teacher-feedback-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .teacher-feedback-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }

        .teacher-feedback-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .teacher-feedback-identity {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .teacher-feedback-avatar {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            background: linear-gradient(135deg, #2DD4BF, #22D3EE);
            color: white;
            font-weight: 700;
            font-size: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .teacher-feedback-name {
            font-size: 18px;
            font-weight: 700;
            color: #1E293B;
            margin-bottom: 4px;
        }

        .teacher-feedback-meta {
            font-size: 13px;
            color: #64748B;
            line-height: 1.5;
        }

        .teacher-feedback-rating {
            text-align: right;
        }

        .teacher-feedback-stars {
            color: #FCD34D;
            font-size: 18px;
            letter-spacing: 2px;
        }

        .teacher-feedback-score {
            font-size: 13px;
            color: #64748B;
            margin-top: 4px;
        }

        .teacher-feedback-section-title {
            font-size: 14px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 8px;
        }

        .teacher-feedback-comments {
            background: #EFF6FF;
            border-left: 4px solid #3B82F6;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 16px;
            color: #334155;
            line-height: 1.6;
            font-size: 14px;
        }

        .teacher-feedback-suggestions {
            background: #F5F3FF;
            border-left: 4px solid #8B5CF6;
            border-radius: 8px;
            padding: 16px;
            color: #334155;
            line-height: 1.6;
            font-size: 14px;
        }

        .teacher-feedback-footer {
            font-size: 12px;
            color: #94A3B8;
            margin-top: 16px;
        }

        .teacher-feedback-edit {
            background: #F97316;
            color: white;
            padding: 6px 14px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            margin-top: 8px;
        }

        .submitted-eval-empty {
            background: white;
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            color: #94a3b8;
        }

        .btn-view {
            background: #3B82F6;
            color: white;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-view:hover {
            background: #2563EB;
        }
        
        .btn-edit {
            background: #F59E0B;
            color: white;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-edit:hover {
            background: #D97706;
        }
        
        .section-divider {
            margin: 32px 0;
            border-top: 1px solid #E2E8F0;
        }
        
        .section-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }
        
        .section-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }
        
        .section-icon.purple {
            background: var(--student-teal);
        }
        
        .section-icon.green {
            background: var(--student-green);
        }
        
        .section-name {
            font-size: 18px;
            font-weight: 700;
            color: #1E293B;
        }
        
        @media (max-width: 1200px) {
            .score-cards-container {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .score-cards-container {
                grid-template-columns: 1fr;
            }
            
            .charts-container {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="evaluation"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Evaluation & Progress"/>
            <jsp:param name="notifPrefix" value="evalNotif"/>
        </jsp:include>

        <div class="page-content">
            <div class="page-title">Evaluation & Progress</div>
            <div class="page-subtitle">Track your learning progress and provide feedback on your learning experience</div>
            
            <!-- STUDENT INFO REFERENCE -->
            <%
                String studentId = (String) request.getAttribute("studentId");
                if (studentId == null) {
                    studentId = (String) session.getAttribute("studentId");
                }
                String studentName = (String) request.getAttribute("studentName");
                if (studentName == null) {
                    studentName = (String) session.getAttribute("studentName");
                }
                if (studentId != null) {
                    out.println("<!-- ==================================================== -->");
                    out.println("<!-- STUDENT DATA REFERENCE FROM STUDENT TABLE -->");
                    out.println("<!-- Student ID: " + studentId);
                    if (studentName != null) {
                        out.println(" | Student Name: " + studentName);
                    }
                    out.println(" -->");
                    out.println("<!-- All evaluation data below is filtered by this studentId -->");
                    out.println("<!-- Data source: studentevaluation table (INNER JOIN with student table) -->");
                    out.println("<!-- ==================================================== -->");
                }
            %>
            
            <!-- SECTION 1: MY EVALUATION (FROM TEACHER) -->
            <div class="section-header">
                <div class="section-icon green">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="section-name">My Evaluation (From Teacher)</div>
            </div>
            
            <c:if test="${not empty latestEvaluation}">
                <div class="score-cards-container">
                    <div class="score-card">
                        <div class="score-card-icon overall">
                            <i class="fas fa-trophy"></i>
                        </div>
                        <div class="score-value"><fmt:formatNumber value="${latestEvaluation.overallScore}" maxFractionDigits="0"/>%</div>
                        <div class="score-label">Overall Score</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon tajweed">
                            <i class="fas fa-book"></i>
                        </div>
                        <div class="score-value"><fmt:formatNumber value="${latestEvaluation.tajweedScore}" maxFractionDigits="0"/>%</div>
                        <div class="score-label">Tajweed</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon fluency">
                            <i class="fas fa-wave-square"></i>
                        </div>
                        <div class="score-value"><fmt:formatNumber value="${latestEvaluation.fluencyScore}" maxFractionDigits="0"/>%</div>
                        <div class="score-label">Fluency</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon accuracy">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <div class="score-value"><fmt:formatNumber value="${latestEvaluation.accuracyScore}" maxFractionDigits="0"/>%</div>
                        <div class="score-label">Accuracy</div>
                    </div>
                </div>
            </c:if>
            
            <c:if test="${empty latestEvaluation}">
                <div class="score-cards-container">
                    <div class="score-card">
                        <div class="score-card-icon overall">
                            <i class="fas fa-trophy"></i>
                        </div>
                        <div class="score-value">--</div>
                        <div class="score-label">Overall Score</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon tajweed">
                            <i class="fas fa-book"></i>
                        </div>
                        <div class="score-value">--</div>
                        <div class="score-label">Tajweed</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon fluency">
                            <i class="fas fa-wave-square"></i>
                        </div>
                        <div class="score-value">--</div>
                        <div class="score-label">Fluency</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon accuracy">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <div class="score-value">--</div>
                        <div class="score-label">Accuracy</div>
                    </div>
                </div>
            </c:if>
            
            <!-- SECTION 2: CHARTS -->
            <div class="charts-container">
                <!-- PERFORMANCE TREND CHART -->
                <div class="chart-card" style="position:relative;">
                    <div class="chart-title">Performance Trend</div>
                    <canvas id="performanceTrendChart" height="300"></canvas>
                    <div id="trendNoData" style="display:none;position:absolute;inset:0;flex-direction:column;align-items:center;justify-content:center;gap:8px;background:rgba(255,255,255,0.85);border-radius:16px;">
                        <i class="fas fa-chart-line" style="font-size:32px;color:#CBD5E1;"></i>
                        <p style="color:#94A3B8;font-size:13px;font-weight:500;">No evaluation data yet</p>
                        <p style="color:#CBD5E1;font-size:11px;">Chart will update after your teacher evaluates you</p>
                    </div>
                </div>
                
                <!-- SKILLS ASSESSMENT CHART -->
                <div class="chart-card" style="position:relative;">
                    <div class="chart-title">Skills Assessment</div>
                    <canvas id="skillsAssessmentChart" height="300"></canvas>
                    <div id="skillsNoData" style="display:none;position:absolute;inset:0;flex-direction:column;align-items:center;justify-content:center;gap:8px;background:rgba(255,255,255,0.85);border-radius:16px;">
                        <i class="fas fa-star" style="font-size:32px;color:#CBD5E1;"></i>
                        <p style="color:#94A3B8;font-size:13px;font-weight:500;">No skill data yet</p>
                        <p style="color:#CBD5E1;font-size:11px;">Chart will update after your teacher evaluates you</p>
                    </div>
                </div>
            </div>
            
            <!-- SECTION 3: EVALUATION HISTORY -->
            <div class="section-divider"></div>
            
            <div style="margin-bottom: 24px;">
                <div class="history-title">Evaluation History</div>
                <div class="history-count">${totalEvaluations} Total Evaluations</div>
            </div>
            
            <c:if test="${not empty historyList}">
                <c:forEach var="evaluation" items="${historyList}">
                    <div class="evaluation-card">
                        <div class="evaluation-avatar avatar-ik">
                            <c:set var="initials" value="" />
                            <c:if test="${not empty evaluation.teacherName}">
                                <c:set var="nameParts" value="${fn:split(evaluation.teacherName, ' ')}" />
                                <c:out value="${fn:substring(nameParts[0], 0, 1)}${fn:substring(nameParts[fn:length(nameParts)-1], 0, 1)}" />
                            </c:if>
                        </div>
                        
                        <div class="evaluation-content">
                            <div style="flex: 1;">
                                <div class="evaluation-title">
                                    <c:choose>
                                        <c:when test="${not empty evaluation.surahName}">
                                            Quran Recitation (Surah <c:out value="${evaluation.surahName}"/><c:if test="${not empty evaluation.ayahRange}">, Ayah <c:out value="${evaluation.ayahRange}"/></c:if>)
                                        </c:when>
                                        <c:otherwise>
                                            Quran Recitation
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="evaluation-meta">
                                    <c:choose>
                                        <c:when test="${not empty evaluation.createdAt}">
                                            ${evaluation.createdAt}
                                        </c:when>
                                        <c:when test="${not empty evaluation.sessionDate}">
                                            ${evaluation.sessionDate}
                                        </c:when>
                                        <c:otherwise>
                                            Date not available
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${not empty evaluation.teacherName}"> • ${evaluation.teacherName}</c:if>
                                </div>
                                <div class="evaluation-badges">
                                    <span class="badge badge-score">Overall: <fmt:formatNumber value="${evaluation.overallScore}" maxFractionDigits="0"/>%</span>
                                    <span class="badge badge-success">Completed</span>
                                </div>
                            </div>
                        </div>
                        
                        <button type="button" class="evaluation-button history-view-btn" data-evaluation-id="${evaluation.evaluationId}">View Details</button>
                    </div>
                </c:forEach>
            </c:if>
            
            <c:if test="${empty historyList}">
                <div class="evaluation-card" style="justify-content: center; color: #94a3b8;">
                    <div>No evaluations yet. Your teacher evaluations will appear here.</div>
                </div>
            </c:if>
            
            <!-- SECTION 4: EVALUATE TEACHER -->
            <div class="section-divider"></div>
            
            <div class="section-header">
                <div class="section-icon purple">
                    <i class="fas fa-star"></i>
                </div>
                <div class="section-name">Evaluate Teacher</div>
            </div>
            
            <div class="session-title">Completed Sessions</div>
            
            <c:forEach var="session" items="${completedSessions}">
                <div class="session-card completed-session-card" data-session-id="${session.sessionId}">
                    <div class="evaluation-avatar avatar-ik">
                        <c:set var="nameParts" value="${fn:split(session.teacherName, ' ')}" />
                        <c:out value="${fn:substring(nameParts[0], 0, 1)}${fn:substring(nameParts[fn:length(nameParts)-1], 0, 1)}" />
                    </div>
                    
                    <div style="flex: 1;">
                        <div class="evaluation-title">${session.teacherName}</div>
                        <div class="session-time">${session.sessionDate} • ${session.startTime} - ${session.endTime}</div>
                        <div class="session-surah"><c:choose><c:when test="${not empty session.surahName}">${session.surahName}<c:if test="${not empty session.ayahRange}"> - Ayah ${session.ayahRange}</c:if></c:when><c:otherwise>Lesson not recorded</c:otherwise></c:choose></div>
                    </div>
                    
                    <c:set var="safeTeacherName"><c:out value="${session.teacherName}"/></c:set>
                    <button class="evaluation-button eval-session-btn"
                            data-session-id="${session.sessionId}"
                            data-schedule-id="${session.scheduleId}"
                            data-teacher-id="${session.teacherId}"
                            data-teacher-name="${safeTeacherName}"
                            data-session-date="${session.sessionDate}"
                            data-start-time="${session.startTime}"
                            data-end-time="${session.endTime}"
                            data-surah-name="${session.surahName}"
                            data-ayah-range="${session.ayahRange}">Evaluate</button>
                </div>
            </c:forEach>
            
            <c:if test="${empty completedSessions}">
                <div class="session-card" style="justify-content: center; color: #94a3b8;">
                    <div>No completed sessions available to evaluate yet.</div>
                </div>
            </c:if>
            
            <!-- SECTION 5: MY SUBMITTED EVALUATIONS -->
            <div class="section-divider"></div>
            
            <div class="session-title" style="margin-top: 32px;">My Submitted Evaluations</div>
            <p style="color:#64748B;font-size:13px;margin-bottom:20px;">Your feedback on teacher performance after completed sessions</p>
            
            <div id="submittedEvaluationsContainer">
            <c:forEach var="submitted" items="${submittedList}">
                <div class="teacher-feedback-card" data-feedback-id="${submitted.feedbackId}">
                    <div class="teacher-feedback-header">
                        <div class="teacher-feedback-identity">
                            <div class="teacher-feedback-avatar">
                                <c:set var="nameParts" value="${fn:split(submitted.teacherName, ' ')}" />
                                <c:out value="${fn:substring(nameParts[0], 0, 1)}${fn:substring(nameParts[fn:length(nameParts)-1], 0, 1)}" />
                            </div>
                            <div>
                                <div class="teacher-feedback-name"><c:out value="${submitted.teacherName}"/></div>
                                <div class="teacher-feedback-meta">
                                    <c:out value="${submitted.sessionDate}"/>
                                    <c:if test="${not empty submitted.startTime}"> &bull; <c:out value="${submitted.startTime}"/></c:if>
                                    <c:if test="${not empty submitted.endTime}"> - <c:out value="${submitted.endTime}"/></c:if>
                                    <br/>
                                    <c:if test="${not empty submitted.surahName}">Surah <c:out value="${submitted.surahName}"/>, Ayah <c:out value="${submitted.ayahRange}"/></c:if>
                                </div>
                            </div>
                        </div>
                        <div class="teacher-feedback-rating">
                            <div class="teacher-feedback-stars">
                                <c:forEach var="i" begin="1" end="5">
                                    <c:choose>
                                        <c:when test="${i <= submitted.rating}">&#9733;</c:when>
                                        <c:otherwise>&#9734;</c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </div>
                            <div class="teacher-feedback-score">${submitted.rating}/5</div>
                            <button type="button" class="teacher-feedback-edit eval-edit-btn"
                                    data-feedback-id="${submitted.feedbackId}"
                                    data-teacher-name="<c:out value='${submitted.teacherName}'/>"
                                    data-rating="${submitted.rating}"
                                    data-comments="<c:out value='${submitted.comments}'/>"
                                    data-suggestions="<c:out value='${submitted.suggestions}'/>"
                                    data-session-date="${submitted.sessionDate}">Edit</button>
                        </div>
                    </div>

                    <c:if test="${not empty submitted.comments}">
                        <div class="teacher-feedback-section-title"><i class="fas fa-comment" style="color:#3B82F6;margin-right:6px;"></i>Comments</div>
                        <div class="teacher-feedback-comments"><c:out value="${submitted.comments}"/></div>
                    </c:if>

                    <c:if test="${not empty submitted.suggestions}">
                        <div class="teacher-feedback-section-title"><i class="fas fa-lightbulb" style="color:#8B5CF6;margin-right:6px;"></i>Suggestions</div>
                        <div class="teacher-feedback-suggestions"><c:out value="${submitted.suggestions}"/></div>
                    </c:if>

                    <div class="teacher-feedback-footer">
                        <i class="fas fa-calendar" style="margin-right:6px;"></i>Evaluated on <c:out value="${submitted.createdAt}"/>
                    </div>
                </div>
            </c:forEach>
            
            <c:if test="${empty submittedList}">
                <div id="submittedEvaluationsEmpty" class="submitted-eval-empty">
                    No submitted evaluations yet. Rate your teacher after completing a session.
                </div>
            </c:if>
            </div>
            
        </div>
    </div>
    
    <!-- EVALUATION DETAILS MODAL -->
    <div id="evaluationModal" class="fixed inset-0 bg-black/70 z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl overflow-y-auto max-h-[95vh] w-full max-w-5xl relative">
            <!-- Close Button -->
            <button onclick="closeEvaluationModal()" class="absolute top-6 right-6 text-gray-500 hover:text-gray-700 z-10">
                <i class="fas fa-times text-2xl"></i>
            </button>
            
            <!-- Modal Content -->
            <div class="p-8">
                <!-- Header -->
                <div class="mb-8">
                    <h2 class="text-3xl font-bold text-gray-900 mb-2">Detailed Evaluation Report</h2>
                    <p class="text-gray-500" id="modalSubtitle">Select an evaluation to view details</p>
                </div>
                
                <!-- Lesson Covered -->
                <div class="mb-8">
                    <h3 class="text-lg font-semibold text-gray-900 mb-3">Lesson Covered</h3>
                    <p class="text-gray-700" id="modalLesson">--</p>
                </div>
                
                <!-- Scores Section -->
                <div class="mb-8">
                    <div class="grid grid-cols-4 gap-4">
                        <div class="text-center p-4 bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl">
                            <div class="text-sm text-gray-600 mb-2">Tajweed</div>
                            <div class="text-4xl font-bold text-blue-600" id="modalTajweed">--</div>
                        </div>
                        <div class="text-center p-4 bg-gradient-to-br from-purple-50 to-purple-100 rounded-xl">
                            <div class="text-sm text-gray-600 mb-2">Fluency</div>
                            <div class="text-4xl font-bold text-purple-600" id="modalFluency">--</div>
                        </div>
                        <div class="text-center p-4 bg-gradient-to-br from-green-50 to-green-100 rounded-xl">
                            <div class="text-sm text-gray-600 mb-2">Accuracy</div>
                            <div class="text-4xl font-bold text-green-600" id="modalAccuracy">--</div>
                        </div>
                        <div class="text-center p-4 bg-gradient-to-br from-teal-50 to-teal-100 rounded-xl">
                            <div class="text-sm text-gray-600 mb-2">Overall</div>
                            <div class="text-4xl font-bold text-teal-600" id="modalOverall">--</div>
                        </div>
                    </div>
                </div>
                
                <!-- Strengths -->
                <div class="mb-8">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-check text-green-600"></i>
                        </div>
                        <h3 class="text-lg font-bold text-gray-900">Strengths (MashaAllah!)</h3>
                    </div>
                    <div id="strengthsList" class="space-y-3"></div>
                </div>
                
                <!-- Areas for Improvement -->
                <div class="mb-8">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-exclamation-circle text-orange-600"></i>
                        </div>
                        <h3 class="text-lg font-bold text-gray-900">Areas for Improvement</h3>
                    </div>
                    <div id="improvementsList" class="space-y-3"></div>
                </div>
                
                <!-- Improvement Suggestions -->
                <div class="mb-8">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-lightbulb text-purple-600"></i>
                        </div>
                        <h3 class="text-lg font-bold text-gray-900">Improvement Suggestions</h3>
                    </div>
                    <div id="suggestionsList" class="space-y-3"></div>
                </div>
                
                <!-- Next Learning Target -->
                <div class="mb-8 bg-gradient-to-r from-teal-500 to-teal-600 rounded-2xl p-6 text-white">
                    <div class="flex items-start gap-3">
                        <i class="fas fa-arrow-right text-2xl mt-1"></i>
                        <div>
                            <h3 class="text-lg font-bold mb-2">Next Learning Target</h3>
                            <p id="modalNextTarget">--</p>
                        </div>
                    </div>
                </div>
                
                <!-- Teacher's Comments -->
                <div class="mb-8">
                    <h3 class="text-lg font-bold text-gray-900 mb-4">Teacher's Comments</h3>
                    <div class="bg-gray-50 border-l-4 border-blue-500 p-6 rounded-lg">
                        <p class="text-gray-700 italic mb-4" id="modalComments">--</p>
                        <div class="flex items-center gap-4 pt-4 border-t border-gray-200">
                            <div class="w-12 h-12 bg-gradient-to-br from-teal-400 to-teal-500 rounded-full flex items-center justify-center text-white font-bold text-lg" id="modalTeacherInitials">IK</div>
                            <div>
                                <p class="font-semibold text-gray-900" id="modalTeacherName">--</p>
                                <p class="text-sm text-gray-500" id="modalCommentDate">--</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Close Button -->
                <button onclick="closeEvaluationModal()" class="w-full bg-gradient-to-r from-teal-500 to-teal-600 hover:from-teal-600 hover:to-teal-700 text-white font-semibold py-3 rounded-xl transition-all">
                    Close
                </button>
            </div>
        </div>
    </div>
    
    <!-- TEACHER EVALUATION MODAL -->
    <div id="teacherEvaluationModal" class="fixed inset-0 bg-black/70 z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl overflow-y-auto max-h-[95vh] w-full max-w-3xl relative">
            <!-- Close Button -->
            <button onclick="closeTeacherEvaluationReportModal()" class="absolute top-6 right-6 text-gray-500 hover:text-gray-700 z-10">
                <i class="fas fa-times text-2xl"></i>
            </button>
            
            <!-- Modal Content -->
            <div class="p-8">
                <!-- Header -->
                <div class="mb-8">
                    <h2 class="text-3xl font-bold text-gray-900 mb-2">Evaluate Teacher</h2>
                    <p class="text-gray-500" id="modalTeacherSubtitle">Fatima Ali • Dec 29, 2024</p>
                </div>
                
                <!-- Session Info -->
                <div class="mb-8 bg-gray-50 rounded-2xl p-6">
                    <p class="text-sm text-gray-600 mb-2" id="modalSessionTime">Session: 09:00 AM - 09:15 AM</p>
                    <p class="text-lg font-semibold text-gray-900" id="modalSessionLesson">Al-Baqarah - Ayah 6-10</p>
                </div>
                
                <!-- Form -->
                <form id="teacherEvaluationForm" method="POST" action="${pageContext.request.contextPath}/student/evaluation">
                    <input type="hidden" name="action" value="submitTeacherEvaluation">
                    <input type="hidden" name="studentId" value="${sessionScope.studentId}">
                    <input type="hidden" id="teacherId" name="teacherId" value="">
                    <input type="hidden" id="sessionId" name="sessionId" value="">
                    <input type="hidden" id="ratingValue" name="rating" value="0">
                    
                    <!-- Teacher Rating -->
                    <div class="mb-8">
                        <label class="block text-lg font-semibold text-gray-900 mb-4">
                            Teacher Rating <span class="text-red-500">*</span>
                        </label>
                        <div class="flex gap-4" id="starRating">
                            <button type="button" class="star-btn text-4xl cursor-pointer transition-transform hover:scale-110" data-rating="1" onclick="setRating(1)">☆</button>
                            <button type="button" class="star-btn text-4xl cursor-pointer transition-transform hover:scale-110" data-rating="2" onclick="setRating(2)">☆</button>
                            <button type="button" class="star-btn text-4xl cursor-pointer transition-transform hover:scale-110" data-rating="3" onclick="setRating(3)">☆</button>
                            <button type="button" class="star-btn text-4xl cursor-pointer transition-transform hover:scale-110" data-rating="4" onclick="setRating(4)">☆</button>
                            <button type="button" class="star-btn text-4xl cursor-pointer transition-transform hover:scale-110" data-rating="5" onclick="setRating(5)">☆</button>
                        </div>
                    </div>
                    
                    <!-- Comments -->
                    <div class="mb-8">
                        <label for="comments" class="block text-lg font-semibold text-gray-900 mb-3">
                            Comments <span class="text-red-500">*</span>
                        </label>
                        <textarea id="comments" name="comments" required placeholder="Share your experience with this teacher..." rows="6" class="w-full px-4 py-3 rounded-2xl border-2 border-gray-200 focus:border-teal-400 focus:outline-none focus:ring-2 focus:ring-teal-400/30 resize-none" style="font-family: inherit;"></textarea>
                    </div>
                    
                    <!-- Suggestions -->
                    <div class="mb-8">
                        <label for="suggestions" class="block text-lg font-semibold text-gray-900 mb-3">
                            Suggestions <span class="text-gray-500 font-normal">(Optional)</span>
                        </label>
                        <textarea id="suggestions" name="suggestions" placeholder="Any suggestions for improvement?" rows="4" class="w-full px-4 py-3 rounded-2xl border-2 border-gray-200 focus:border-teal-400 focus:outline-none focus:ring-2 focus:ring-teal-400/30 resize-none" style="font-family: inherit;"></textarea>
                    </div>
                    
                    <!-- Buttons -->
                    <div class="flex gap-4">
                        <button type="button" onclick="closeTeacherEvaluationModal()" class="flex-1 px-6 py-3 rounded-2xl border-2 border-gray-300 text-gray-700 font-semibold hover:bg-gray-50 transition-colors">
                            Cancel
                        </button>
                        <button type="submit" class="flex-1 px-6 py-3 rounded-2xl bg-gradient-to-r from-teal-500 to-teal-600 hover:from-teal-600 hover:to-teal-700 text-white font-semibold transition-all">
                            Submit Evaluation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- SUBMITTED FEEDBACK MODAL -->
    <div id="submittedFeedbackModal" class="fixed inset-0 bg-black/70 z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl overflow-hidden w-full max-w-4xl relative">
            <!-- Close Button -->
            <button onclick="closeSubmittedFeedbackModal()" class="absolute top-6 right-6 text-gray-500 hover:text-gray-700 z-10">
                <i class="fas fa-times text-2xl"></i>
            </button>
            
            <!-- Modal Content -->
            <div class="p-8 overflow-y-auto max-h-[95vh]">
                <!-- Header -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <h2 class="text-3xl font-bold text-gray-900 mb-2">My Evaluation</h2>
                    <p class="text-gray-500" id="submittedTeacherInfo">Ibrahim Khan • Dec 30, 2024</p>
                </div>
                
                <!-- Your Rating -->
                <div class="mb-8">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">Your Rating</h3>
                    <div class="flex gap-2" id="submittedStars">
                        <span class="star text-4xl">★</span>
                        <span class="star text-4xl">★</span>
                        <span class="star text-4xl">★</span>
                        <span class="star text-4xl">★</span>
                        <span class="star text-4xl">★</span>
                    </div>
                </div>
                
                <!-- Comments -->
                <div class="mb-8">
                    <h3 class="text-lg font-semibold text-gray-900 mb-3">Comments</h3>
                    <div class="bg-gray-50 rounded-2xl p-5 text-gray-700 leading-relaxed" id="submittedComments">
                        Excellent teacher! Very patient and explains Tajweed rules clearly.
                    </div>
                </div>
                
                <!-- Suggestions -->
                <div class="mb-8">
                    <h3 class="text-lg font-semibold text-gray-900 mb-3">Suggestions</h3>
                    <div class="bg-gray-50 rounded-2xl p-5 text-gray-700 leading-relaxed" id="submittedSuggestions">
                        Would love more focus on Makharij practice.
                    </div>
                </div>
                
                <!-- Submitted Date -->
                <div class="text-center text-gray-500 text-sm mb-8">
                    Submitted on <span id="submittedDate">Dec 31, 2024</span>
                </div>
                
                <!-- Close Button -->
                <button onclick="closeSubmittedFeedbackModal()" class="w-full px-6 py-3 rounded-2xl bg-gradient-to-r from-teal-500 to-cyan-400 hover:from-teal-600 hover:to-cyan-500 text-white font-semibold transition-all">
                    Close
                </button>
            </div>
        </div>
    </div>
    
    <!-- EDIT FEEDBACK MODAL -->
    <div id="editFeedbackModal" class="fixed inset-0 bg-black/70 z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl overflow-y-auto max-h-[95vh] w-full max-w-4xl relative">
            <!-- Close Button -->
            <button onclick="closeEditFeedbackModal()" class="absolute top-6 right-6 text-gray-500 hover:text-gray-700 z-10">
                <i class="fas fa-times text-2xl"></i>
            </button>
            
            <!-- Modal Content -->
            <div class="p-8">
                <!-- Header -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <h2 class="text-3xl font-bold text-gray-900 mb-2">Edit Evaluation</h2>
                    <p class="text-gray-500" id="editTeacherInfo">Ibrahim Khan • Dec 30, 2024</p>
                </div>
                
                <!-- Edit Form -->
                <form id="editFeedbackForm" method="POST" action="${pageContext.request.contextPath}/student/evaluation">
                    <input type="hidden" name="action" value="updateTeacherEvaluation">
                    <input type="hidden" id="editFeedbackId" name="feedbackId" value="">
                    <input type="hidden" id="editRatingValue" name="rating" value="5">
                    
                    <!-- Teacher Rating -->
                    <div class="mb-8">
                        <label class="block text-lg font-semibold text-gray-900 mb-4">
                            Teacher Rating <span class="text-red-500">*</span>
                        </label>
                        <div class="flex gap-4" id="editStarRating">
                            <button type="button" class="edit-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="1" onclick="setEditRating(1)">★</button>
                            <button type="button" class="edit-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="2" onclick="setEditRating(2)">★</button>
                            <button type="button" class="edit-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="3" onclick="setEditRating(3)">★</button>
                            <button type="button" class="edit-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="4" onclick="setEditRating(4)">★</button>
                            <button type="button" class="edit-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="5" onclick="setEditRating(5)">★</button>
                        </div>
                    </div>
                    
                    <!-- Comments -->
                    <div class="mb-8">
                        <label for="editComments" class="block text-lg font-semibold text-gray-900 mb-3">
                            Comments <span class="text-red-500">*</span>
                        </label>
                        <textarea id="editComments" name="comments" required rows="6" class="w-full px-5 py-4 rounded-2xl border-2 border-gray-200 focus:border-teal-400 focus:outline-none focus:ring-2 focus:ring-teal-400/30 resize-none" style="font-family: inherit;"></textarea>
                    </div>
                    
                    <!-- Suggestions -->
                    <div class="mb-8">
                        <label for="editSuggestions" class="block text-lg font-semibold text-gray-900 mb-3">
                            Suggestions <span class="text-gray-500 font-normal">(Optional)</span>
                        </label>
                        <textarea id="editSuggestions" name="suggestions" rows="4" class="w-full px-5 py-4 rounded-2xl border-2 border-gray-200 focus:border-teal-400 focus:outline-none focus:ring-2 focus:ring-teal-400/30 resize-none" style="font-family: inherit;"></textarea>
                    </div>
                    
                    <!-- Buttons -->
                    <div class="flex gap-4">
                        <button type="button" onclick="closeEditFeedbackModal()" class="flex-1 px-6 py-3 rounded-2xl border-2 border-gray-300 text-gray-700 font-semibold hover:bg-gray-50 transition-colors">
                            Cancel
                        </button>
                        <button type="submit" class="flex-1 px-6 py-3 rounded-2xl bg-gradient-to-r from-teal-500 to-cyan-400 hover:from-teal-600 hover:to-cyan-500 text-white font-semibold transition-all">
                            Update Evaluation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- STUDENT TEACHER EVALUATION MODAL -->
    <div id="studentTeacherEvaluationModal" class="fixed inset-0 bg-black/70 z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl overflow-y-auto max-h-[95vh] w-full max-w-2xl relative">
            <button onclick="closeTeacherEvaluationModal()" class="absolute top-6 right-6 text-gray-500 hover:text-gray-700 z-10">
                <i class="fas fa-times text-2xl"></i>
            </button>

            <div class="p-8">
                <div class="mb-8">
                    <h2 class="text-3xl font-bold text-gray-900 mb-2">Evaluate Teacher</h2>
                    <p class="text-gray-500" id="studentTeacherEvalSubtitle">Share feedback for this completed session</p>
                </div>

                <div class="mb-8 rounded-2xl bg-teal-50 border border-teal-100 p-5">
                    <p class="text-sm text-teal-700 font-semibold mb-2">Session Details</p>
                    <p class="text-gray-900 font-semibold" id="studentTeacherEvalTeacher">Teacher</p>
                    <p class="text-gray-600 text-sm" id="studentTeacherEvalSession">Session</p>
                    <p class="text-gray-600 text-sm" id="studentTeacherEvalLesson">Lesson</p>
                </div>

                <form id="studentTeacherEvaluationForm" method="POST" action="${pageContext.request.contextPath}/student/evaluation">
                    <input type="hidden" name="action" value="submitTeacherEvaluation">
                    <input type="hidden" id="studentTeacherEvalSessionId" name="sessionId" value="">
                    <input type="hidden" id="studentTeacherEvalTeacherId" name="teacherId" value="">
                    <input type="hidden" id="studentTeacherEvalScheduleId" name="scheduleId" value="">

                    <div class="mb-8">
                        <label class="block text-lg font-semibold text-gray-900 mb-4">Teacher Rating <span class="text-red-500">*</span></label>
                        <div class="flex gap-4" id="studentTeacherStarRating">
                            <button type="button" class="student-teacher-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="1" onclick="setStudentTeacherRating(1)">★</button>
                            <button type="button" class="student-teacher-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="2" onclick="setStudentTeacherRating(2)">★</button>
                            <button type="button" class="student-teacher-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="3" onclick="setStudentTeacherRating(3)">★</button>
                            <button type="button" class="student-teacher-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="4" onclick="setStudentTeacherRating(4)">★</button>
                            <button type="button" class="student-teacher-star-btn text-5xl cursor-pointer transition-transform hover:scale-110" data-rating="5" onclick="setStudentTeacherRating(5)">★</button>
                        </div>
                        <input type="hidden" id="studentTeacherRatingValue" name="rating" value="0">
                    </div>

                    <div class="mb-8">
                        <label for="studentTeacherComments" class="block text-lg font-semibold text-gray-900 mb-3">Comments <span class="text-red-500">*</span></label>
                        <textarea id="studentTeacherComments" name="comments" required rows="5" class="w-full px-5 py-4 rounded-2xl border-2 border-gray-200 focus:border-teal-400 focus:outline-none focus:ring-2 focus:ring-teal-400/30 resize-none" style="font-family: inherit;" placeholder="What went well in this session?"></textarea>
                    </div>

                    <div class="mb-8">
                        <label for="studentTeacherSuggestions" class="block text-lg font-semibold text-gray-900 mb-3">Suggestions <span class="text-gray-500 font-normal">(Optional)</span></label>
                        <textarea id="studentTeacherSuggestions" name="suggestions" rows="4" class="w-full px-5 py-4 rounded-2xl border-2 border-gray-200 focus:border-teal-400 focus:outline-none focus:ring-2 focus:ring-teal-400/30 resize-none" style="font-family: inherit;" placeholder="How can the teacher improve?"></textarea>
                    </div>

                    <div class="flex gap-4">
                        <button type="button" onclick="closeTeacherEvaluationModal()" class="flex-1 px-6 py-3 rounded-2xl border-2 border-gray-300 text-gray-700 font-semibold hover:bg-gray-50 transition-colors">
                            Cancel
                        </button>
                        <button type="submit" class="flex-1 px-6 py-3 rounded-2xl bg-gradient-to-r from-teal-500 to-cyan-400 hover:from-teal-600 hover:to-cyan-500 text-white font-semibold transition-all">
                            Submit Evaluation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    </div>

    <script>
        // Evaluation data - built server-side to safely handle special characters
        const evaluationData = ${historyDataJson};
        
        // Open Evaluation Modal
        function openEvaluationModal(evaluationId) {
            const modal = document.getElementById('evaluationModal');
            const evalItem = evaluationData[evaluationId];
            
            if (!evalItem) {
                console.error('Evaluation not found: ' + evaluationId);
                return;
            }
            
            // Update modal content
            document.getElementById('modalSubtitle').textContent = evalItem.createdAt;
            document.getElementById('modalLesson').textContent = 'Quran Recitation (Surah ' + evalItem.surahName + (evalItem.ayahRange ? ', Ayah ' + evalItem.ayahRange : '') + ')';
            document.getElementById('modalTajweed').textContent = Math.round(evalItem.tajweedScore) + '%';
            document.getElementById('modalFluency').textContent = Math.round(evalItem.fluencyScore) + '%';
            document.getElementById('modalAccuracy').textContent = Math.round(evalItem.accuracyScore) + '%';
            document.getElementById('modalOverall').textContent = Math.round(evalItem.overallScore) + '%';
            
            // Strengths
            const strengthsList = document.getElementById('strengthsList');
            strengthsList.innerHTML = '';
            const strengths = (evalItem.strengths || '').split(' | ');
            strengths.forEach(strength => {
                const div = document.createElement('div');
                div.className = 'bg-green-50 border-l-4 border-green-500 p-4 rounded';
                div.innerHTML = '<p class="text-gray-700"><i class="fas fa-check-circle text-green-600 mr-2"></i>' + (strength.trim() || 'N/A') + '</p>';
                strengthsList.appendChild(div);
            });
            
            // Improvements
            const improvementsList = document.getElementById('improvementsList');
            improvementsList.innerHTML = '';
            const improvements = (evalItem.improvements || '').split(' | ');
            improvements.forEach(improvement => {
                const div = document.createElement('div');
                div.className = 'bg-orange-50 border-l-4 border-orange-500 p-4 rounded';
                div.innerHTML = '<p class="text-gray-700"><i class="fas fa-info-circle text-orange-600 mr-2"></i>' + (improvement.trim() || 'N/A') + '</p>';
                improvementsList.appendChild(div);
            });
            
            // Suggestions
            const suggestionsList = document.getElementById('suggestionsList');
            suggestionsList.innerHTML = '';
            const suggestions = (evalItem.suggestions || '').split(' | ');
            suggestions.forEach(suggestion => {
                const div = document.createElement('div');
                div.className = 'bg-purple-50 border-l-4 border-purple-500 p-4 rounded';
                div.innerHTML = '<p class="text-gray-700"><i class="fas fa-star text-purple-600 mr-2"></i>' + (suggestion.trim() || 'N/A') + '</p>';
                suggestionsList.appendChild(div);
            });
            
            // Next Target
            document.getElementById('modalNextTarget').textContent = evalItem.nextTarget || 'N/A';
            
            // Teacher Comments
            document.getElementById('modalComments').textContent = '"' + (evalItem.comments || '') + '"';
            document.getElementById('modalTeacherName').textContent = evalItem.teacherName || '';
            document.getElementById('modalCommentDate').textContent = evalItem.createdAt || '';
            
            // Teacher Initials
            const nameParts = (evalItem.teacherName || 'T').split(' ');
            const initials = nameParts[0].charAt(0) + (nameParts.length > 1 ? nameParts[nameParts.length - 1].charAt(0) : '');
            document.getElementById('modalTeacherInitials').textContent = initials.toUpperCase();
            
            // Show modal
            modal.classList.remove('hidden');
        }
        
        // Close Evaluation Modal
        function closeEvaluationModal() {
            const modal = document.getElementById('evaluationModal');
            modal.classList.add('hidden');
        }
        
        // Close modal when clicking outside
        document.getElementById('evaluationModal')?.addEventListener('click', function(e) {
            if (e.target === this) {
                closeEvaluationModal();
            }
        });
        
        // ================ TEACHER EVALUATION MODAL FUNCTIONS ================
        
        // Open Teacher Evaluation Modal
        function openTeacherEvaluationReportModal(sessionId, teacherId, teacherName, date, time, surah, ayah) {
            const modal = document.getElementById('teacherEvaluationModal');
            
            // Update modal content
            document.getElementById('modalTeacherSubtitle').textContent = teacherName + ' • ' + date;
            document.getElementById('modalSessionTime').textContent = 'Session: ' + time + ' AM';
            document.getElementById('modalSessionLesson').textContent = surah + ' - Ayah ' + ayah;
            
            // Set hidden form values
            document.getElementById('sessionId').value = sessionId;
            document.getElementById('teacherId').value = teacherId;
            document.getElementById('ratingValue').value = 0;
            
            // Reset form
            document.getElementById('teacherEvaluationForm').reset();
            resetStarRating();
            
            // Show modal
            modal.classList.remove('hidden');
        }
        
        // Close Teacher Evaluation Modal
        function closeTeacherEvaluationReportModal() {
            const modal = document.getElementById('teacherEvaluationModal');
            modal.classList.add('hidden');
        }
        
        // Set Rating Stars
        function setRating(stars) {
            document.getElementById('ratingValue').value = stars;
            const starBtns = document.querySelectorAll('#starRating .star-btn');
            starBtns.forEach((btn, index) => {
                if (index < stars) {
                    btn.textContent = '★';
                    btn.style.color = '#FCD34D';
                } else {
                    btn.textContent = '☆';
                    btn.style.color = '#D1D5DB';
                }
            });
        }
        
        // Reset Star Rating
        function resetStarRating() {
            const starBtns = document.querySelectorAll('#starRating .star-btn');
            starBtns.forEach(btn => {
                btn.textContent = '☆';
                btn.style.color = '#D1D5DB';
            });
        }
        
        // Add hover effects to stars
        document.querySelectorAll('#starRating .star-btn').forEach(btn => {
            btn.addEventListener('mouseover', function() {
                const rating = parseInt(this.dataset.rating);
                const starBtns = document.querySelectorAll('#starRating .star-btn');
                starBtns.forEach((b, index) => {
                    if (index < rating) {
                        b.style.color = '#FCD34D';
                        b.textContent = '★';
                    } else {
                        b.style.color = '#D1D5DB';
                        b.textContent = '☆';
                    }
                });
            });
        });
        
        document.getElementById('starRating').addEventListener('mouseout', function() {
            const currentRating = parseInt(document.getElementById('ratingValue').value);
            if (currentRating === 0) {
                resetStarRating();
            } else {
                setRating(currentRating);
            }
        });
        
        // Close modal when clicking outside
        document.getElementById('teacherEvaluationModal')?.addEventListener('click', function(e) {
            if (e.target === this) {
                closeTeacherEvaluationReportModal();
            }
        });
        
        // Handle form submission
        document.getElementById('teacherEvaluationForm')?.addEventListener('submit', function(e) {
            const ratingValue = parseInt(document.getElementById('ratingValue').value);
            if (ratingValue === 0) {
                e.preventDefault();
                alert('Please select a rating');
                return;
            }
            if (document.getElementById('comments').value.trim() === '') {
                e.preventDefault();
                alert('Please fill in the comments field');
                return;
            }
        });
        
        // ================ SUBMITTED FEEDBACK MODAL FUNCTIONS ================
        
        // Open Submitted Feedback Modal
        function openSubmittedFeedbackModal(feedbackId, teacherName, rating, comments, suggestions, createdAt) {
            const modal = document.getElementById('submittedFeedbackModal');
            
            // Update modal content
            document.getElementById('submittedTeacherInfo').textContent = teacherName + ' • ' + createdAt;
            document.getElementById('submittedDate').textContent = createdAt;
            document.getElementById('submittedComments').textContent = decodeURIComponent(comments);
            document.getElementById('submittedSuggestions').textContent = decodeURIComponent(suggestions);
            
            // Render stars
            const starsContainer = document.getElementById('submittedStars');
            starsContainer.innerHTML = '';
            for (let i = 0; i < 5; i++) {
                const span = document.createElement('span');
                span.className = 'text-4xl';
                if (i < rating) {
                    span.textContent = '★';
                    span.style.color = '#FCD34D';
                } else {
                    span.textContent = '☆';
                    span.style.color = '#D1D5DB';
                }
                starsContainer.appendChild(span);
            }
            
            // Show modal
            modal.classList.remove('hidden');
        }
        
        // Close Submitted Feedback Modal
        function closeSubmittedFeedbackModal() {
            const modal = document.getElementById('submittedFeedbackModal');
            modal.classList.add('hidden');
        }
        
        // Close modal when clicking outside
        document.getElementById('submittedFeedbackModal')?.addEventListener('click', function(e) {
            if (e.target === this) {
                closeSubmittedFeedbackModal();
            }
        });
        
        // ================ EDIT FEEDBACK MODAL FUNCTIONS ================
        
        // Open Edit Feedback Modal
        function openEditFeedbackModal(feedbackId, teacherName, rating, comments, suggestions, sessionDate) {
            const modal = document.getElementById('editFeedbackModal');
            
            // Update modal header
            document.getElementById('editTeacherInfo').textContent = teacherName + ' • ' + sessionDate;
            
            // Set hidden feedback ID
            document.getElementById('editFeedbackId').value = feedbackId;
            
            // Prefill comments and suggestions
            document.getElementById('editComments').value = decodeURIComponent(comments);
            document.getElementById('editSuggestions').value = decodeURIComponent(suggestions);
            
            // Set rating
            setEditRating(rating);
            
            // Show modal
            modal.classList.remove('hidden');
        }
        
        // Close Edit Feedback Modal
        function closeEditFeedbackModal() {
            const modal = document.getElementById('editFeedbackModal');
            modal.classList.add('hidden');
        }
        
        // Set Edit Rating Stars
        function setEditRating(stars) {
            document.getElementById('editRatingValue').value = stars;
            const starBtns = document.querySelectorAll('#editStarRating .edit-star-btn');
            starBtns.forEach((btn, index) => {
                if (index < stars) {
                    btn.style.color = '#FCD34D';
                } else {
                    btn.style.color = '#D1D5DB';
                }
            });
        }
        
        // Add hover effects to edit stars
        document.querySelectorAll('#editStarRating .edit-star-btn').forEach(btn => {
            btn.addEventListener('mouseover', function() {
                const rating = parseInt(this.dataset.rating);
                const starBtns = document.querySelectorAll('#editStarRating .edit-star-btn');
                starBtns.forEach((b, index) => {
                    if (index < rating) {
                        b.style.color = '#FCD34D';
                    } else {
                        b.style.color = '#D1D5DB';
                    }
                });
            });
        });
        
        document.getElementById('editStarRating').addEventListener('mouseout', function() {
            const currentRating = parseInt(document.getElementById('editRatingValue').value);
            setEditRating(currentRating);
        });
        
        // Close modal when clicking outside
        document.getElementById('editFeedbackModal')?.addEventListener('click', function(e) {
            if (e.target === this) {
                closeEditFeedbackModal();
            }
        });
        
        // Handle edit form submission
        document.getElementById('editFeedbackForm')?.addEventListener('submit', function(e) {
            const commentValue = document.getElementById('editComments').value.trim();
            if (commentValue === '') {
                e.preventDefault();
                alert('Please fill in the comments field');
                return;
            }
        });

        // ================ TEACHER EVALUATION MODAL FUNCTIONS ================

        let currentTeacherSession = {
            sessionId: '',
            teacherId: '',
            teacherName: '',
            sessionDate: '',
            sessionTime: '',
            surahName: '',
            ayahRange: ''
        };

        function openTeacherEvaluationModal(sessionId, teacherId, teacherName, sessionDate, startTime, endTime, surahName, ayahRange, scheduleId) {
            currentTeacherSession = {
                sessionId: sessionId || '',
                scheduleId: scheduleId || sessionId || '',
                teacherId: teacherId || '',
                teacherName: teacherName || 'Teacher',
                sessionDate: sessionDate || '',
                startTime: startTime || '',
                endTime: endTime || '',
                sessionTime: formatSessionTime(startTime, endTime),
                surahName: surahName || '',
                ayahRange: ayahRange || ''
            };

            const lessonText = currentTeacherSession.surahName
                ? (currentTeacherSession.surahName + (currentTeacherSession.ayahRange ? ' - Ayah ' + currentTeacherSession.ayahRange : ''))
                : 'Lesson not recorded';

            document.getElementById('studentTeacherEvalSessionId').value = currentTeacherSession.sessionId;
            document.getElementById('studentTeacherEvalTeacherId').value = currentTeacherSession.teacherId;
            document.getElementById('studentTeacherEvalScheduleId').value = currentTeacherSession.scheduleId;
            document.getElementById('studentTeacherEvalTeacher').textContent = currentTeacherSession.teacherName;
            document.getElementById('studentTeacherEvalSession').textContent = currentTeacherSession.sessionDate + ' • ' + currentTeacherSession.sessionTime;
            document.getElementById('studentTeacherEvalLesson').textContent = lessonText;
            document.getElementById('studentTeacherEvalSubtitle').textContent = 'Session completed with ' + currentTeacherSession.teacherName;

            document.getElementById('studentTeacherEvaluationForm').reset();
            document.getElementById('studentTeacherEvalSessionId').value = currentTeacherSession.sessionId;
            document.getElementById('studentTeacherEvalTeacherId').value = currentTeacherSession.teacherId;
            document.getElementById('studentTeacherEvalScheduleId').value = currentTeacherSession.scheduleId;
            setStudentTeacherRating(0);

            document.getElementById('studentTeacherEvaluationModal').classList.remove('hidden');
        }

        function formatSessionTime(startTime, endTime) {
            const formattedStart = formatTimeValue(startTime);
            const formattedEnd = formatTimeValue(endTime);

            if (formattedStart && formattedEnd) {
                return formattedStart + ' - ' + formattedEnd;
            }
            return formattedStart || formattedEnd || '--';
        }

        function formatTimeValue(timeValue) {
            if (!timeValue) {
                return '';
            }

            const rawValue = String(timeValue).trim();
            const match = rawValue.match(/^(\d{1,2}):(\d{2})(?::\d{2})?$/);
            if (!match) {
                return rawValue;
            }

            let hour = parseInt(match[1], 10);
            const minute = match[2];
            const period = hour >= 12 ? 'PM' : 'AM';
            hour = hour % 12;
            if (hour === 0) {
                hour = 12;
            }
            return hour + ':' + minute + ' ' + period;
        }

        // Delegate evaluate button clicks so apostrophes in names never break JS
        document.addEventListener('click', function(e) {
            const btn = e.target.closest('.eval-session-btn');
            if (!btn) return;
            openTeacherEvaluationModal(
                btn.dataset.sessionId,
                btn.dataset.teacherId,
                btn.dataset.teacherName,
                btn.dataset.sessionDate,
                btn.dataset.startTime,
                btn.dataset.endTime,
                btn.dataset.surahName,
                btn.dataset.ayahRange,
                btn.dataset.scheduleId
            );
        });

        document.addEventListener('click', function(e) {
            const btn = e.target.closest('.history-view-btn');
            if (!btn) return;
            openEvaluationModal(btn.dataset.evaluationId);
        });

        function closeTeacherEvaluationModal() {
            document.getElementById('studentTeacherEvaluationModal').classList.add('hidden');
        }

        function setStudentTeacherRating(stars) {
            document.getElementById('studentTeacherRatingValue').value = stars;
            const starBtns = document.querySelectorAll('#studentTeacherStarRating .student-teacher-star-btn');
            starBtns.forEach((btn, index) => {
                if (index < stars) {
                    btn.textContent = '★';
                    btn.style.color = '#FCD34D';
                } else {
                    btn.textContent = '☆';
                    btn.style.color = '#D1D5DB';
                }
            });
        }

        document.querySelectorAll('#studentTeacherStarRating .student-teacher-star-btn').forEach(btn => {
            btn.addEventListener('mouseover', function() {
                const rating = parseInt(this.dataset.rating);
                const starBtns = document.querySelectorAll('#studentTeacherStarRating .student-teacher-star-btn');
                starBtns.forEach((b, index) => {
                    if (index < rating) {
                        b.style.color = '#FCD34D';
                        b.textContent = '★';
                    } else {
                        b.style.color = '#D1D5DB';
                        b.textContent = '☆';
                    }
                });
            });
        });

        document.getElementById('studentTeacherStarRating')?.addEventListener('mouseout', function() {
            const currentRating = parseInt(document.getElementById('studentTeacherRatingValue').value);
            if (currentRating === 0) {
                setStudentTeacherRating(0);
            } else {
                setStudentTeacherRating(currentRating);
            }
        });

        document.getElementById('studentTeacherEvaluationModal')?.addEventListener('click', function(e) {
            if (e.target === this) {
                closeTeacherEvaluationModal();
            }
        });

        document.getElementById('studentTeacherEvaluationForm')?.addEventListener('submit', async function(e) {
            e.preventDefault();

            const ratingValue = parseInt(document.getElementById('studentTeacherRatingValue').value, 10);
            const commentsValue = document.getElementById('studentTeacherComments').value.trim();
            const submitButton = this.querySelector('button[type="submit"]');
            const submitUrl = this.getAttribute('action') || this.action;

            if (!ratingValue) {
                alert('Please select a rating');
                return;
            }

            if (commentsValue === '') {
                alert('Please fill in the comments field');
                return;
            }

            submitButton.disabled = true;
            const originalLabel = submitButton.textContent;
            submitButton.textContent = 'Submitting...';

            try {
                const formData = new URLSearchParams();
                new FormData(this).forEach(function(value, key) {
                    formData.append(key, value);
                });

                const response = await fetch(submitUrl, {
                    method: 'POST',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest',
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                    },
                    body: formData.toString()
                });

                const contentType = response.headers.get('content-type') || '';
                const data = contentType.includes('application/json') ? await response.json() : { success: false, error: await response.text() };

                if (!response.ok || !data.success) {
                    alert(data.error || 'Failed to submit evaluation');
                    return;
                }

                removeCompletedSessionCard(document.getElementById('studentTeacherEvalSessionId').value);
                data.comments = data.comments || commentsValue;
                data.suggestions = data.suggestions || document.getElementById('studentTeacherSuggestions').value.trim();
                if (currentTeacherSession) {
                    data.teacherName = data.teacherName || currentTeacherSession.teacherName;
                    data.sessionDate = data.sessionDate || currentTeacherSession.sessionDate;
                    data.startTime = data.startTime || currentTeacherSession.startTime;
                    data.endTime = data.endTime || currentTeacherSession.endTime;
                    data.surahName = data.surahName || currentTeacherSession.surahName;
                    data.ayahRange = data.ayahRange || currentTeacherSession.ayahRange;
                }
                prependSubmittedEvaluationItem(data);
                closeTeacherEvaluationModal();
                alert('Evaluation submitted successfully');
            } catch (error) {
                console.error('Error submitting teacher evaluation:', error);
                alert('Failed to submit evaluation');
            } finally {
                submitButton.disabled = false;
                submitButton.textContent = originalLabel;
            }
        });

        function removeCompletedSessionCard(sessionId) {
            if (!sessionId) {
                return;
            }

            const card = document.querySelector('.completed-session-card[data-session-id="' + sessionId + '"]');
            if (card) {
                card.remove();
            }
        }

        function buildTeacherFeedbackCard(data) {
            const card = document.createElement('div');
            card.className = 'teacher-feedback-card';
            if (data.feedbackId) {
                card.dataset.feedbackId = data.feedbackId;
            }

            const rating = parseInt(data.rating || 0, 10);
            const teacherName = data.teacherName || 'Teacher';
            const sessionLine = [
                data.sessionDate || '',
                data.startTime ? (data.sessionDate ? ' • ' : '') + data.startTime : '',
                data.endTime ? ' - ' + data.endTime : ''
            ].join('');
            const lessonLine = data.surahName
                ? 'Surah ' + data.surahName + (data.ayahRange ? ', Ayah ' + data.ayahRange : '')
                : '';

            let starsHtml = '';
            for (let i = 1; i <= 5; i++) {
                starsHtml += i <= rating ? '&#9733;' : '&#9734;';
            }

            let bodyHtml = '';
            if (data.comments) {
                bodyHtml += '<div class="teacher-feedback-section-title"><i class="fas fa-comment" style="color:#3B82F6;margin-right:6px;"></i>Comments</div>';
                bodyHtml += '<div class="teacher-feedback-comments"></div>';
            }
            if (data.suggestions) {
                bodyHtml += '<div class="teacher-feedback-section-title"><i class="fas fa-lightbulb" style="color:#8B5CF6;margin-right:6px;"></i>Suggestions</div>';
                bodyHtml += '<div class="teacher-feedback-suggestions"></div>';
            }

            card.innerHTML =
                '<div class="teacher-feedback-header">' +
                    '<div class="teacher-feedback-identity">' +
                        '<div class="teacher-feedback-avatar">' + getInitialsFromName(teacherName) + '</div>' +
                        '<div>' +
                            '<div class="teacher-feedback-name"></div>' +
                            '<div class="teacher-feedback-meta"></div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="teacher-feedback-rating">' +
                        '<div class="teacher-feedback-stars">' + starsHtml + '</div>' +
                        '<div class="teacher-feedback-score">' + rating + '/5</div>' +
                        '<button type="button" class="teacher-feedback-edit eval-edit-btn">Edit</button>' +
                    '</div>' +
                '</div>' +
                bodyHtml +
                '<div class="teacher-feedback-footer"><i class="fas fa-calendar" style="margin-right:6px;"></i>Evaluated on <span class="evaluated-on"></span></div>';

            card.querySelector('.teacher-feedback-name').textContent = teacherName;
            const meta = card.querySelector('.teacher-feedback-meta');
            meta.textContent = sessionLine;
            if (lessonLine) {
                meta.appendChild(document.createElement('br'));
                meta.appendChild(document.createTextNode(lessonLine));
            }
            const commentsEl = card.querySelector('.teacher-feedback-comments');
            if (commentsEl) commentsEl.textContent = data.comments;
            const suggestionsEl = card.querySelector('.teacher-feedback-suggestions');
            if (suggestionsEl) suggestionsEl.textContent = data.suggestions;
            card.querySelector('.evaluated-on').textContent = data.createdAt || 'Today';

            const editBtn = card.querySelector('.eval-edit-btn');
            editBtn.dataset.feedbackId = data.feedbackId || '';
            editBtn.dataset.teacherName = teacherName;
            editBtn.dataset.rating = String(rating);
            editBtn.dataset.comments = data.comments || '';
            editBtn.dataset.suggestions = data.suggestions || '';
            editBtn.dataset.sessionDate = data.sessionDate || '';

            return card;
        }

        function prependSubmittedEvaluationItem(data) {
            const container = document.getElementById('submittedEvaluationsContainer');
            if (!container) return;

            const emptyState = document.getElementById('submittedEvaluationsEmpty');
            if (emptyState) emptyState.remove();

            container.prepend(buildTeacherFeedbackCard(data));
        }

        document.addEventListener('click', function(e) {
            const btn = e.target.closest('.eval-edit-btn');
            if (!btn) return;
            openEditFeedbackModal(
                btn.dataset.feedbackId,
                btn.dataset.teacherName,
                parseInt(btn.dataset.rating || '0', 10),
                encodeURIComponent(btn.dataset.comments || ''),
                encodeURIComponent(btn.dataset.suggestions || ''),
                btn.dataset.sessionDate || ''
            );
        });

        function getInitialsFromName(name) {
            const parts = String(name || 'Teacher').trim().split(/\s+/).filter(Boolean);
            if (parts.length === 0) {
                return 'TE';
            }
            if (parts.length === 1) {
                return parts[0].charAt(0).toUpperCase();
            }
            return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
        }

        // Performance Trend Chart
        const trendCtx = document.getElementById('performanceTrendChart');
        if (trendCtx && trendCtx.getContext) {
            const trendDataRaw = ${trendDataJson};
            
            let months = [];
            let tajweedData = [];
            let fluencyData = [];
            let accuracyData = [];
            
            if (trendDataRaw && trendDataRaw.length > 0) {
                months = trendDataRaw.map(d => d.month);
                tajweedData = trendDataRaw.map(d => d.tajweed);
                fluencyData = trendDataRaw.map(d => d.fluency);
                accuracyData = trendDataRaw.map(d => d.accuracy);
            } else {
                // Show no-data overlay and hide canvas
                const overlay = document.getElementById('trendNoData');
                if (overlay) { overlay.style.display = 'flex'; }
                trendCtx.style.visibility = 'hidden';
            }
            
            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: months,
                    datasets: [
                        {
                            label: 'Tajweed',
                            data: tajweedData,
                            borderColor: '#047857',
                            backgroundColor: 'rgba(167, 139, 250, 0.05)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: false,
                            pointRadius: 5,
                            pointBackgroundColor: '#047857',
                            pointBorderWidth: 0
                        },
                        {
                            label: 'Fluency',
                            data: fluencyData,
                            borderColor: '#34D399',
                            backgroundColor: 'rgba(52, 211, 153, 0.05)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: false,
                            pointRadius: 5,
                            pointBackgroundColor: '#34D399',
                            pointBorderWidth: 0
                        },
                        {
                            label: 'Accuracy',
                            data: accuracyData,
                            borderColor: '#3B82F6',
                            backgroundColor: 'rgba(59, 130, 246, 0.05)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: false,
                            pointRadius: 5,
                            pointBackgroundColor: '#3B82F6',
                            pointBorderWidth: 0
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'bottom',
                            labels: {
                                boxWidth: 10,
                                padding: 20,
                                font: {
                                    size: 12
                                },
                                usePointStyle: true,
                                pointStyle: 'circle'
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                font: {
                                    size: 11
                                },
                                color: '#9CA3AF'
                            },
                            grid: {
                                color: '#f0f0f0'
                            }
                        },
                        x: {
                            ticks: {
                                font: {
                                    size: 12
                                },
                                color: '#9CA3AF'
                            },
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });
        }
        
        // Skills Assessment Radar Chart
        const skillsCtx = document.getElementById('skillsAssessmentChart');
        if (skillsCtx && skillsCtx.getContext) {
            const skillsDataRaw = ${skillsDataJson};
            
            let labels = [];
            let data = [];
            let hasSkillsData = false;
            
            if (skillsDataRaw && Object.keys(skillsDataRaw).length > 0) {
                const vals = Object.values(skillsDataRaw);
                const hasRealValues = vals.some(v => v > 0);
                if (hasRealValues) {
                    labels = Object.keys(skillsDataRaw);
                    data = vals;
                    hasSkillsData = true;
                }
            }
            
            if (!hasSkillsData) {
                const overlay = document.getElementById('skillsNoData');
                if (overlay) { overlay.style.display = 'flex'; }
                skillsCtx.style.visibility = 'hidden';
            }
            
            new Chart(skillsCtx, {
                type: 'radar',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Your Skills',
                            data: data,
                            borderColor: '#34D399',
                            backgroundColor: 'rgba(52, 211, 153, 0.15)',
                            borderWidth: 2,
                            pointRadius: 5,
                            pointBackgroundColor: '#34D399',
                            pointBorderWidth: 2,
                            pointBorderColor: '#fff'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'bottom'
                        }
                    },
                    scales: {
                        r: {
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                stepSize: 25,
                                color: '#9CA3AF',
                                font: {
                                    size: 10
                                }
                            },
                            grid: {
                                color: '#E5E7EB'
                            },
                            pointLabels: {
                                font: {
                                    size: 12
                                },
                                color: '#1F2937'
                            }
                        }
                    }
                }
            });
        }
        
        function evaluateTeacher() {
            alert('Evaluate Teacher functionality - Redirect to evaluation form');
        }
    </script>
</body>
</html>
