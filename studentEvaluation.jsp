<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Evaluation" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evaluation & Progress - TalaqqiHub</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Chart.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #F8FAFC;
            overflow-x: hidden;
        }
        
        .sidebar {
            background: linear-gradient(135deg, #1F4D36 0%, #355E3B 100%);
            width: 263px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
            color: white;
            padding: 24px 0;
        }
        
        .main-wrapper {
            margin-left: 263px;
            min-height: 100vh;
        }
        
        .sidebar-header {
            padding: 0 24px 40px 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .sidebar-brand {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 4px;
        }
        
        .sidebar-subtitle {
            font-size: 12px;
            opacity: 0.8;
        }
        
        .sidebar-menu {
            margin-top: 24px;
        }
        
        .sidebar-menu-item {
            padding: 12px 24px;
            margin: 4px 12px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s;
            color: rgba(255, 255, 255, 0.7);
            font-size: 14px;
            display: flex;
            align-items: center;
            text-decoration: none;
        }
        
        .sidebar-menu-item i {
            margin-right: 12px;
            width: 18px;
        }
        
        .sidebar-menu-item:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }
        
        .sidebar-menu-item.active {
            background: rgba(255, 255, 255, 0.15);
            color: white;
        }
        
        .sidebar-logout {
            position: absolute;
            bottom: 24px;
            width: calc(100% - 24px);
            padding: 12px 24px;
            margin: 0 12px;
            border-radius: 12px;
            cursor: pointer;
            color: rgba(255, 255, 255, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.2);
            text-decoration: none;
            text-align: left;
            font-size: 14px;
        }
        
        .sidebar-logout:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }
        
        .top-header {
            background: white;
            padding: 16px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #E2E8F0;
        }
        
        .header-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .notification-bell {
            position: relative;
            cursor: pointer;
            font-size: 20px;
            color: #64748B;
        }
        
        .notification-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #EC4899;
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 600;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4ECDC4 0%, #44A08D 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 14px;
        }
        
        .user-name {
            font-size: 14px;
            font-weight: 500;
            color: #1E293B;
        }
        
        .dropdown-arrow {
            color: #64748B;
            font-size: 12px;
        }
        
        .content-area {
            padding: 32px;
        }
        
        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: #1E293B;
            margin-bottom: 8px;
        }
        
        .page-subtitle {
            color: #64748B;
            font-size: 14px;
            margin-bottom: 32px;
        }
        
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
            background: #A78BFA;
        }
        
        .score-card-icon.fluency {
            background: #34D399;
        }
        
        .score-card-icon.accuracy {
            background: #6366F1;
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
        
        .submitted-eval-item {
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
        
        .submitted-eval-item:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .eval-info {
            flex: 1;
        }
        
        .eval-teacher {
            font-size: 14px;
            font-weight: 600;
            color: #1E293B;
            margin-bottom: 4px;
        }
        
        .eval-dates {
            font-size: 12px;
            color: #64748B;
        }
        
        .stars {
            word-spacing: 4px;
        }
        
        .star {
            color: #FCD34D;
            font-size: 16px;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
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
            background: #D1A1E6;
        }
        
        .section-icon.green {
            background: #4ECDC4;
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
            .sidebar {
                width: 200px;
            }
            
            .main-wrapper {
                margin-left: 200px;
            }
            
            .content-area {
                padding: 20px;
            }
            
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
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-brand">TalaqqiHub</div>
            <div class="sidebar-subtitle">Student Portal</div>
        </div>
        
        <nav class="sidebar-menu">
            <a href="<%= request.getContextPath() %>/student/dashboard" class="sidebar-menu-item">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <a href="<%= request.getContextPath() %>/student/class-booking" class="sidebar-menu-item">
                <i class="fas fa-calendar-alt"></i>
                <span>Class Booking</span>
            </a>
            <a href="<%= request.getContextPath() %>/student/attendance" class="sidebar-menu-item">
                <i class="fas fa-clipboard-check"></i>
                <span>Attendance</span>
            </a>
            <a href="<%= request.getContextPath() %>/student/sessions" class="sidebar-menu-item">
                <i class="fas fa-book"></i>
                <span>Talaqqi Sessions</span>
            </a>
            <a href="<%= request.getContextPath() %>/student/evaluation" class="sidebar-menu-item active">
                <i class="fas fa-star"></i>
                <span>Evaluation</span>
            </a>
            <a href="<%= request.getContextPath() %>/student/announcements" class="sidebar-menu-item">
                <i class="fas fa-bell"></i>
                <span>Announcements</span>
            </a>
            <a href="<%= request.getContextPath() %>/student/ai-assistance" class="sidebar-menu-item">
                <i class="fas fa-wand-magic-sparkles"></i>
                <span>AI Assistance</span>
            </a>
        </nav>
        
        <a href="<%= request.getContextPath() %>/student/logout" class="sidebar-logout">
            <i class="fas fa-sign-out-alt" style="margin-right: 12px; width: 18px;"></i>
            <span>Logout</span>
        </a>
    </div>
    
    <!-- MAIN WRAPPER -->
    <div class="main-wrapper">
        <!-- TOP HEADER -->
        <div class="top-header">
            <h1 style="font-size: 24px; font-weight: 600; color: #1E293B;">Evaluation & Progress</h1>
            
            <div class="header-right">
                <div class="notification-bell">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge">3</span>
                </div>
                
                <div class="user-profile">
                    <div class="user-avatar">AH</div>
                    <span class="user-name">Ahmad</span>
                    <span class="dropdown-arrow"><i class="fas fa-chevron-down"></i></span>
                </div>
            </div>
        </div>
        
        <!-- CONTENT AREA -->
        <div class="content-area">
            
            <!-- PAGE HEADER -->
            <div class="page-title">Evaluation & Progress</div>
            <div class="page-subtitle">Track your learning progress and provide feedback on your learning experience</div>
            
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
                        <div class="score-value">${latestEvaluation.overallScore}%</div>
                        <div class="score-label">Overall Score</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon tajweed">
                            <i class="fas fa-book"></i>
                        </div>
                        <div class="score-value">${latestEvaluation.tajweedScore}%</div>
                        <div class="score-label">Tajweed</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon fluency">
                            <i class="fas fa-wave-square"></i>
                        </div>
                        <div class="score-value">${latestEvaluation.fluencyScore}%</div>
                        <div class="score-label">Fluency</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon accuracy">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <div class="score-value">${latestEvaluation.accuracyScore}%</div>
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
                        <div class="score-value">92%</div>
                        <div class="score-label">Overall Score</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon tajweed">
                            <i class="fas fa-book"></i>
                        </div>
                        <div class="score-value">92%</div>
                        <div class="score-label">Tajweed</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon fluency">
                            <i class="fas fa-wave-square"></i>
                        </div>
                        <div class="score-value">88%</div>
                        <div class="score-label">Fluency</div>
                    </div>
                    
                    <div class="score-card">
                        <div class="score-card-icon accuracy">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <div class="score-value">95%</div>
                        <div class="score-label">Accuracy</div>
                    </div>
                </div>
            </c:if>
            
            <!-- SECTION 2: CHARTS -->
            <div class="charts-container">
                <!-- PERFORMANCE TREND CHART -->
                <div class="chart-card">
                    <div class="chart-title">Performance Trend</div>
                    <canvas id="performanceTrendChart" height="300"></canvas>
                </div>
                
                <!-- SKILLS ASSESSMENT CHART -->
                <div class="chart-card">
                    <div class="chart-title">Skills Assessment</div>
                    <canvas id="skillsAssessmentChart" height="300"></canvas>
                </div>
            </div>
            
            <!-- SECTION 3: EVALUATION HISTORY -->
            <div class="section-divider"></div>
            
            <div style="margin-bottom: 24px;">
                <div class="history-title">Evaluation History</div>
                <div class="history-count">${totalEvaluations} Total Evaluations</div>
            </div>
            
            <c:forEach var="evaluation" items="${historyList}" begin="0" end="1">
                <div class="evaluation-card">
                    <div class="evaluation-avatar avatar-ik">
                        ${evaluation.teacherName.charAt(0)}${evaluation.teacherName.split(' ')[1].charAt(0)}
                    </div>
                    
                    <div class="evaluation-content">
                        <div style="flex: 1;">
                            <div class="evaluation-title">${evaluation.surahName} - Ayah ${evaluation.ayahRange}</div>
                            <div class="evaluation-meta">${evaluation.sessionDate} • Ustadh ${evaluation.teacherName}</div>
                            <div class="evaluation-badges">
                                <span class="badge badge-score">Overall: ${evaluation.overallScore}%</span>
                                <span class="badge badge-success">Completed</span>
                            </div>
                        </div>
                    </div>
                    
                    <button class="evaluation-button">View Details</button>
                </div>
            </c:forEach>
            
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
                <div class="session-card">
                    <div class="evaluation-avatar avatar-ik">
                        ${session.teacherName.charAt(0)}${session.teacherName.split(' ')[1].charAt(0)}
                    </div>
                    
                    <div style="flex: 1;">
                        <div class="evaluation-title">${session.teacherName}</div>
                        <div class="session-time">${session.sessionDate} • ${session.startTime} - ${session.endTime} AM</div>
                        <div class="session-surah">${session.surahName} - Ayah ${session.ayahRange}</div>
                    </div>
                    
                    <button class="evaluation-button" onclick="evaluateTeacher()">Evaluate</button>
                </div>
            </c:forEach>
            
            <c:if test="${empty completedSessions}">
                <div class="session-card">
                    <div class="evaluation-avatar avatar-fa">FA</div>
                    
                    <div style="flex: 1;">
                        <div class="evaluation-title">Ustadha Fatima Ali</div>
                        <div class="session-time">Dec 29, 2024 • 09:00 AM - 09:15 AM</div>
                        <div class="session-surah">Al-Baqarah - Ayah 6-10</div>
                    </div>
                    
                    <button class="evaluation-button" onclick="evaluateTeacher()">Evaluate</button>
                </div>
                
                <div class="session-card">
                    <div class="evaluation-avatar avatar-ik">IK</div>
                    
                    <div style="flex: 1;">
                        <div class="evaluation-title">Ustadh Ibrahim Khan</div>
                        <div class="session-time">Dec 27, 2024 • 10:00 AM - 10:15 AM</div>
                        <div class="session-surah">Al-Fatihah - Ayah 1-7</div>
                    </div>
                    
                    <button class="evaluation-button" onclick="evaluateTeacher()">Evaluate</button>
                </div>
            </c:if>
            
            <!-- SECTION 5: MY SUBMITTED EVALUATIONS -->
            <div class="section-divider"></div>
            
            <div class="session-title" style="margin-top: 32px;">My Submitted Evaluations</div>
            
            <c:forEach var="submitted" items="${submittedList}">
                <div class="submitted-eval-item">
                    <div class="evaluation-avatar avatar-ik">
                        ${submitted.teacherName.charAt(0)}${submitted.teacherName.split(' ')[1].charAt(0)}
                    </div>
                    
                    <div class="eval-info">
                        <div class="eval-teacher">${submitted.teacherName}</div>
                        <div class="eval-dates">Session: ${submitted.sessionDate} • Evaluated: ${submitted.evaluatedDate}</div>
                    </div>
                    
                    <div class="stars">
                        <c:forEach var="i" begin="1" end="${submitted.rating}">
                            <span class="star">★</span>
                        </c:forEach>
                    </div>
                    
                    <div class="action-buttons">
                        <button class="btn-view">View</button>
                        <button class="btn-edit">Edit</button>
                    </div>
                </div>
            </c:forEach>
            
            <c:if test="${empty submittedList}">
                <div class="submitted-eval-item">
                    <div class="evaluation-avatar avatar-ik">IK</div>
                    
                    <div class="eval-info">
                        <div class="eval-teacher">Ustadh Ibrahim Khan</div>
                        <div class="eval-dates">Session: Dec 30, 2024 • Evaluated: Dec 31, 2024</div>
                    </div>
                    
                    <div class="stars">
                        <span class="star">★</span>
                        <span class="star">★</span>
                        <span class="star">★</span>
                        <span class="star">★</span>
                        <span class="star">★</span>
                    </div>
                    
                    <div class="action-buttons">
                        <button class="btn-view">View</button>
                        <button class="btn-edit">Edit</button>
                    </div>
                </div>
            </c:if>
            
        </div>
    </div>
    
    <script>
        // Performance Trend Chart
        const trendCtx = document.getElementById('performanceTrendChart');
        if (trendCtx && trendCtx.getContext) {
            const trendData = <c:out value="${trendData}" default="[]" escapeXml="false"/>;
            
            let months = ['Nov', 'Mid-Dec', 'Late-Dec'];
            let tajweedData = [80, 85, 92];
            let fluencyData = [78, 83, 88];
            let accuracyData = [85, 90, 95];
            let overallData = [81, 86, 92];
            
            if (trendData && trendData.length > 0) {
                months = trendData.map(d => d.month);
                tajweedData = trendData.map(d => d.tajweed);
                fluencyData = trendData.map(d => d.fluency);
                accuracyData = trendData.map(d => d.accuracy);
                overallData = trendData.map(d => d.overall);
            }
            
            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: months,
                    datasets: [
                        {
                            label: 'Tajweed',
                            data: tajweedData,
                            borderColor: '#A78BFA',
                            backgroundColor: 'rgba(167, 139, 250, 0.05)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: false,
                            pointRadius: 5,
                            pointBackgroundColor: '#A78BFA',
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
                        },
                        {
                            label: 'Overall',
                            data: overallData,
                            borderColor: '#10B981',
                            backgroundColor: 'rgba(16, 185, 129, 0.05)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: false,
                            pointRadius: 5,
                            pointBackgroundColor: '#10B981',
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
            const skillsData = <c:out value="${skillsData}" default="{}" escapeXml="false"/>;
            
            let labels = ['Tajweed', 'Fluency', 'Accuracy', 'Makharij', 'Madd Rules', 'Memorization'];
            let data = [92, 88, 95, 85, 80, 75];
            
            if (skillsData && Object.keys(skillsData).length > 0) {
                labels = Object.keys(skillsData);
                data = Object.values(skillsData);
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
