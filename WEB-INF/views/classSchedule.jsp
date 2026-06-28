<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }
    
    String teacherName = (String) session.getAttribute("teacherName");
    if (teacherName == null) teacherName = "Ustadh Ibrahim Khan";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Schedule - TalaqqiHub Teacher Portal</title>
    <%@ include file="/WEB-INF/views/includes/teacherLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .modal { display: none; }
        .modal.active { display: flex; }
        .slot-empty {
            padding: 1rem;
            border-radius: 0.75rem;
            border: 2px dashed #d1d5db;
            cursor: pointer;
            transition: all 0.2s;
            background: #fff;
        }
        .slot-empty:hover {
            border-color: #7c3aed;
            background: #faf8ff;
        }
        .slot-empty.selected {
            border-color: #7c3aed;
            border-style: solid;
            background: #ede9fe;
            box-shadow: 0 0 0 2px rgba(124, 58, 237, 0.15);
        }
        .slot-selection-bar {
            display: none;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            padding: 12px 14px;
            margin-bottom: 12px;
            border-radius: 12px;
            background: #f3efff;
            border: 1px solid #ddd6fe;
        }
        .slot-selection-bar.visible { display: flex; }
        .slot-action-btn {
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid #e2e8f0;
            background: white;
            color: #475569;
        }
        .slot-action-btn:hover { background: #f8fafc; }
        .slot-action-btn.primary {
            border: none;
            color: white;
            background: var(--teacher-gradient);
        }
        .slot-action-btn.primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .slot-filled {
            padding: 1rem;
            border-radius: 0.75rem;
            border: 1px solid #c4b5fd;
            background: #f3efff;
        }
        .slot-filled.booked {
            background: #7c3aed;
            border-color: #6d28d9;
            color: #fff;
        }
        .slot-badge {
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            background: #dbeafe;
            color: #2563eb;
        }
        .slot-status {
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            background: #ede9fe;
            color: #7c3aed;
        }
        .slot-filled.booked .slot-status {
            background: rgba(255,255,255,0.2);
            color: #fff;
        }
        .slot-disabled {
            padding: 1rem;
            border-radius: 0.75rem;
            border: 2px dashed #e5e7eb;
            background: #f9fafb;
            color: #9ca3af;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/teacherSidebar.jsp">
        <jsp:param name="activePage" value="class-schedule"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/teacherTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Class Schedule"/>
            <jsp:param name="notifPrefix" value="scheduleNotif"/>
        </jsp:include>

        <%
            Boolean canAccess = (request.getAttribute("canAccessSchedule") != null) ? (Boolean) request.getAttribute("canAccessSchedule") : Boolean.TRUE;
            String approvalStatus = (request.getAttribute("teacherApprovalStatus") != null) ? (String) request.getAttribute("teacherApprovalStatus") : "";
        %>
        <div class="page-content relative">
                <% if (!canAccess) { %>
                    <div class="absolute inset-0 bg-white bg-opacity-80 z-50 flex items-center justify-center">
                        <div class="text-center max-w-lg p-6">
                            <h3 class="text-lg font-semibold text-gray-900">Access Restricted</h3>
                            <p class="text-sm text-gray-600 mt-3">
                                <% if ("pending".equalsIgnoreCase(approvalStatus)) { %>
                                    Your account is pending approval. You cannot manage or view class schedule until your account is approved.
                                <% } else if ("rejected".equalsIgnoreCase(approvalStatus)) { %>
                                    Your registration has been rejected. Contact the administrator for assistance.
                                <% } else { %>
                                    You do not have access to the Class Schedule.
                                <% } %>
                            </p>
                        </div>
                    </div>
                <% } %>
                <div class="mb-8">
                    <h2 class="text-2xl font-bold text-gray-900 mb-2">Class Schedule</h2>
                    <p class="text-gray-600">Manage your availability and view scheduled Quran Recitation & Tajweed sessions</p>
                </div>
                
                <div class="mb-12">
                    <div class="flex items-center space-x-3 mb-6">
                        <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                            <i class="far fa-calendar text-purple-600 text-lg"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">Set Availability</h3>
                    </div>
                    
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- LEFT: Calendar -->
                        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                            <h4 class="text-lg font-semibold text-gray-900 mb-4">Select Date</h4>
                            
                            <!-- View Filters -->
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center space-x-2">
                                    <button id="monthViewBtn" onclick="setViewMode('month')" class="px-3 py-1 text-sm font-medium text-purple-600 bg-purple-100 rounded-lg hover:bg-purple-100 transition">
                                        Month View
                                    </button>
                                    <button id="weekViewBtn" onclick="setViewMode('week')" class="px-3 py-1 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition">
                                        Week View
                                    </button>
                                </div>
                            </div>

                            <!-- Month/Week Display with Navigation -->
                            <div class="flex items-center justify-between mb-4">
                                <button id="prevBtn" onclick="navigateDate(-1)" class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition">
                                    <i class="fas fa-chevron-left"></i>
                                </button>
                                <span id="currentMonth" class="text-base font-semibold text-gray-900"></span>
                                <button id="nextBtn" onclick="navigateDate(1)" class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition">
                                    <i class="fas fa-chevron-right"></i>
                                </button>
                            </div>
                            
                            <!-- Day Headers -->
                            <div class="grid grid-cols-7 gap-2 mb-3">
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Sun</div>
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Mon</div>
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Tue</div>
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Wed</div>
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Thu</div>
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Fri</div>
                                <div class="text-center text-xs font-medium text-gray-500 py-2">Sat</div>
                            </div>
                            
                            <!-- Calendar Grid -->
                            <div id="calendarGrid" class="grid grid-cols-7 gap-2 mb-4"></div>
                            
                            <!-- Legend -->
                            <div class="mt-4 pt-4 border-t border-gray-200 space-y-2 text-sm">
                                <div class="flex items-center space-x-2">
                                    <div class="w-4 h-4 bg-purple-100 rounded"></div>
                                    <span class="text-gray-600">Available (not booked)</span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <div class="w-4 h-4 bg-purple-600 rounded"></div>
                                    <span class="text-gray-600">Booked by student</span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <div class="w-4 h-4 border-2 border-gray-900 rounded"></div>
                                    <span class="text-gray-600">Today</span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- RIGHT: Time Slots -->
                        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                            <h4 class="text-lg font-semibold text-gray-900 mb-2">Time Slots (15 min each)</h4>
                            <p id="selectedDateDisplay" class="text-sm text-gray-500 mb-2">Please select a date</p>
                            <p class="text-xs text-gray-400 mb-3">Click empty slots to select multiple, then add them together.</p>

                            <div id="slotSelectionBar" class="slot-selection-bar">
                                <span id="selectedSlotCount" class="text-sm font-semibold" style="color:#6d28d9;">0 slots selected</span>
                                <div class="flex items-center gap-2 flex-wrap">
                                    <button type="button" class="slot-action-btn" onclick="selectAllEmptySlots()">Select All</button>
                                    <button type="button" class="slot-action-btn" onclick="clearSelectedSlots()">Clear</button>
                                    <button type="button" id="addSelectedBtn" class="slot-action-btn primary" onclick="openSelectedConfirmationModal()" disabled>Add Selected</button>
                                </div>
                            </div>
                            
                            <!-- Time Slots Container -->
                            <div id="timeSlotsContainer" class="space-y-3 max-h-[500px] overflow-y-auto pr-2">
                                <div class="text-center text-gray-400 py-12">
                                    <i class="far fa-calendar-alt text-5xl mb-3"></i>
                                    <p class="text-sm">Select a date to view available time slots</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="mb-8">
                    <div class="flex items-center space-x-3 mb-6">
                        <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                            <i class="far fa-calendar text-purple-600 text-lg"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">My Scheduled Classes</h3>
                    </div>
                </div>

                <div class="mb-8">
                    <div class="flex items-center justify-between mb-4">
                        <h4 class="text-lg font-bold text-gray-900">Upcoming Classes</h4>
                        <span class="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-semibold">${fn:length(upcomingClasses)} classes</span>
                    </div>
                    
                    <c:choose>
                        <c:when test="${empty upcomingClasses}">
                            <div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center">
                                <i class="far fa-calendar-times text-gray-400 text-4xl mb-3"></i>
                                <p class="text-gray-500">No upcoming classes scheduled</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="classItem" items="${upcomingClasses}">
                                <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-4">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center space-x-4">
                                            <c:choose>
                                                <c:when test="${not empty classItem.studentName}">
                                                    <div class="w-14 h-14 bg-purple-100 rounded-full flex items-center justify-center text-gray-700 font-bold text-lg">
                                                        <c:set var="initials" value="${fn:substring(classItem.studentName, 0, 1)}${fn:substring(fn:substringAfter(classItem.studentName, ' '), 0, 1)}" />
                                                        ${fn:toUpperCase(initials)}
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="w-14 h-14 bg-purple-100 rounded-full flex items-center justify-center text-purple-600 font-bold text-lg">
                                                        <i class="far fa-calendar-check"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <div>
                                                <c:choose>
                                                    <c:when test="${not empty classItem.studentName}">
                                                        <h5 class="font-bold text-gray-900 text-lg">${classItem.studentName}</h5>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <h5 class="font-bold text-purple-600 text-lg">Available Slot</h5>
                                                    </c:otherwise>
                                                </c:choose>
                                                <p class="text-gray-600 text-sm">${classItem.className}</p>
                                                <div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                                                    <div class="flex items-center space-x-1">
                                                        <i class="far fa-calendar text-gray-400"></i>
                                                        <span><fmt:formatDate value="${classItem.scheduleDate}" pattern="EEEE, MMMM d, yyyy" /></span>
                                                    </div>
                                                    <div class="flex items-center space-x-1">
                                                        <i class="far fa-clock text-gray-400"></i>
                                                        <span><fmt:formatDate value="${classItem.startTime}" pattern="hh:mm a" /> - <fmt:formatDate value="${classItem.endTime}" pattern="hh:mm a" /></span>
                                                    </div>
                                                    <span class="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-semibold">${classItem.duration} min</span>
                                                    <c:if test="${empty classItem.studentName}">
                                                        <span class="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs font-semibold">Available</span>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <c:choose>
                                            <c:when test="${not empty classItem.studentName}">
                                                <div class="flex items-center space-x-3">
                                                        <button onclick="showClassDetails(this)" 
                                                            data-student-name="${classItem.studentName}"
                                                            data-student-id="${classItem.studentId}"
                                                            data-class-name="${classItem.className}"
                                                            data-duration="${classItem.duration}"
                                                            data-schedule-date="<fmt:formatDate value='${classItem.scheduleDate}' pattern='EEEE, MMMM d, yyyy' />"
                                                            data-start-time="<fmt:formatDate value='${classItem.startTime}' pattern='HH:mm' />"
                                                            data-end-time="<fmt:formatDate value='${classItem.endTime}' pattern='HH:mm' />"
                                                            data-schedule-id="${classItem.scheduleId}"
                                                            data-booking-id="${classItem.bookingId}"
                                                            class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">
                                                        View Details
                                                    </button>
                                                    <button onclick="showCancelClass(this)"
                                                            data-student-name="${classItem.studentName}"
                                                            data-schedule-date="<fmt:formatDate value='${classItem.scheduleDate}' pattern='EEEE, MMMM d, yyyy' />"
                                                            data-schedule-iso="<fmt:formatDate value='${classItem.scheduleDate}' pattern='yyyy-MM-dd' />"
                                                            data-start-time="<fmt:formatDate value='${classItem.startTime}' pattern='HH:mm' />"
                                                            data-end-time="<fmt:formatDate value='${classItem.endTime}' pattern='HH:mm' />"
                                                            data-schedule-id="${classItem.scheduleId}"
                                                            data-booking-id="${classItem.bookingId}"
                                                            class="cancel-class-btn px-6 py-2 bg-red-600 text-white rounded-lg font-semibold hover:bg-red-700 transition">
                                                        Cancel Class
                                                    </button>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="flex items-center space-x-3">
                                                    <span class="text-sm text-gray-500 italic">Waiting for student booking...</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mb-8">
                    <div class="flex items-center justify-between mb-4">
                        <h4 class="text-lg font-bold text-gray-900">Rescheduled Classes</h4>
                        <span class="px-3 py-1 bg-teal-100 text-teal-700 rounded-full text-sm font-semibold" id="rescheduledClassesCount">${fn:length(rescheduledClasses)} classes</span>
                    </div>

                    <div id="rescheduledClassesContainer">
                        <c:choose>
                            <c:when test="${empty rescheduledClasses}">
                                <div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center">
                                    <i class="far fa-calendar-alt text-gray-400 text-4xl mb-3"></i>
                                    <p class="text-gray-500">No rescheduled classes</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="space-y-4">
                                    <c:forEach var="classItem" items="${rescheduledClasses}">
                                        <div class="bg-white rounded-xl shadow-sm border-l-4 border-teal-500 border-y border-r border-gray-200 p-6">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center space-x-4">
                                                    <div class="w-14 h-14 bg-teal-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                                                        <c:set var="initials" value="${fn:substring(classItem.studentName, 0, 1)}${fn:substring(fn:substringAfter(classItem.studentName, ' '), 0, 1)}" />
                                                        ${fn:toUpperCase(initials)}
                                                    </div>
                                                    <div>
                                                        <h5 class="font-bold text-gray-900 text-lg">${classItem.studentName}</h5>
                                                        <p class="text-gray-600 text-sm">${classItem.className}</p>
                                                        <div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                                                            <div class="flex items-center space-x-1">
                                                                <i class="far fa-calendar text-gray-400"></i>
                                                                <span><fmt:formatDate value="${classItem.scheduleDate}" pattern="EEEE, MMMM d, yyyy" /></span>
                                                            </div>
                                                            <div class="flex items-center space-x-1">
                                                                <i class="far fa-clock text-gray-400"></i>
                                                                <span><fmt:formatDate value="${classItem.startTime}" pattern="hh:mm a" /> - <fmt:formatDate value="${classItem.endTime}" pattern="hh:mm a" /></span>
                                                            </div>
                                                            <span class="px-2 py-1 bg-teal-100 text-teal-800 rounded text-xs font-semibold">Rescheduled</span>
                                                        </div>
                                                        <c:if test="${not empty classItem.cancellationReason}">
                                                            <p class="text-teal-700 text-sm mt-2">${classItem.cancellationReason}</p>
                                                        </c:if>
                                                    </div>
                                                </div>
                                                <button onclick="viewCompletedClassDetails('${classItem.scheduleId}')"
                                                        class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">
                                                    View Details
                                                </button>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="mb-8">
                    <div class="flex items-center justify-between mb-4">
                        <h4 class="text-lg font-bold text-gray-900">Completed Classes</h4>
                        <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-semibold" id="completedClassesCount">${fn:length(completedClasses)} classes</span>
                    </div>
                    
                    <div id="completedClassesContainer">
                        <c:choose>
                            <c:when test="${empty completedClasses}">
                                <div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center">
                                    <i class="far fa-calendar-check text-gray-400 text-4xl mb-3"></i>
                                    <p class="text-gray-500">No completed classes yet</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="space-y-4">
                                    <c:forEach var="classItem" items="${completedClasses}">
                                        <c:choose>
                                            <c:when test="${classItem.needsReschedule}">
                                                <c:set var="completedBorderClass" value="border-amber-500" />
                                                <c:set var="completedBadgeClass" value="bg-amber-100 text-amber-800" />
                                                <c:set var="completedBadgeLabel" value="Not Completed" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="completedBorderClass" value="border-green-500" />
                                                <c:set var="completedBadgeClass" value="bg-green-100 text-green-700" />
                                                <c:set var="completedBadgeLabel" value="Completed" />
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="bg-white rounded-xl shadow-sm border-l-4 ${completedBorderClass} border-y border-r border-gray-200 p-6">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center space-x-4">
                                                    <div class="w-14 h-14 bg-teal-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                                                        <c:set var="initials" value="${fn:substring(classItem.studentName, 0, 1)}${fn:substring(fn:substringAfter(classItem.studentName, ' '), 0, 1)}" />
                                                        ${fn:toUpperCase(initials)}
                                                    </div>
                                                    
                                                    <div>
                                                        <h5 class="font-bold text-gray-900 text-lg">${classItem.studentName}</h5>
                                                        <p class="text-gray-600 text-sm">${classItem.className}</p>
                                                        <div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                                                            <div class="flex items-center space-x-1">
                                                                <i class="far fa-calendar text-gray-400"></i>
                                                                <span><fmt:formatDate value="${classItem.scheduleDate}" pattern="EEEE, MMMM d, yyyy" /></span>
                                                            </div>
                                                            <div class="flex items-center space-x-1">
                                                                <i class="far fa-clock text-gray-400"></i>
                                                                <span><fmt:formatDate value="${classItem.startTime}" pattern="hh:mm a" /> - <fmt:formatDate value="${classItem.endTime}" pattern="hh:mm a" /></span>
                                                            </div>
                                                            <span class="px-2 py-1 ${completedBadgeClass} rounded text-xs font-semibold">${completedBadgeLabel}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <button onclick="viewCompletedClassDetails('${classItem.scheduleId}')"
                                                        class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">
                                                    View Details
                                                </button>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="mb-8">
                    <div class="flex items-center justify-between mb-4">
                        <h4 class="text-lg font-bold text-gray-900">Cancelled Classes</h4>
                        <span class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm font-semibold" id="cancelledClassesCount">${fn:length(cancelledClasses)} classes</span>
                    </div>
                    
                    <div id="cancelledClassesContainer">
                        <c:choose>
                            <c:when test="${empty cancelledClasses}">
                                <div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center">
                                    <i class="far fa-calendar-times text-gray-400 text-4xl mb-3"></i>
                                    <p class="text-gray-500">No cancelled classes</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="space-y-4">
                                    <c:forEach var="classItem" items="${cancelledClasses}">
                                        <div class="bg-white rounded-xl shadow-sm border-l-4 border-red-500 border-y border-r border-gray-200 p-6">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center space-x-4">
                                                    <div class="w-14 h-14 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 font-bold text-lg">
                                                        <c:set var="initials" value="${fn:substring(classItem.studentName, 0, 1)}${fn:substring(fn:substringAfter(classItem.studentName, ' '), 0, 1)}" />
                                                        ${fn:toUpperCase(initials)}
                                                    </div>
                                                    
                                                    <div>
                                                        <h5 class="font-bold text-gray-900 text-lg">${classItem.studentName}</h5>
                                                        <p class="text-gray-600 text-sm">${classItem.className}</p>
                                                        <div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                                                            <div class="flex items-center space-x-1">
                                                                <i class="far fa-calendar text-gray-400"></i>
                                                                <span><fmt:formatDate value="${classItem.scheduleDate}" pattern="EEEE, MMMM d, yyyy" /></span>
                                                            </div>
                                                            <div class="flex items-center space-x-1">
                                                                <i class="far fa-clock text-gray-400"></i>
                                                                <span><fmt:formatDate value="${classItem.startTime}" pattern="hh:mm a" /> - <fmt:formatDate value="${classItem.endTime}" pattern="hh:mm a" /></span>
                                                            </div>
                                                            <span class="px-2 py-1 bg-red-100 text-red-700 rounded text-xs font-semibold">Cancelled</span>
                                                        </div>
                                                        <c:if test="${not empty classItem.cancellationReason}">
                                                            <p class="text-gray-500 text-sm mt-1">Reason: ${classItem.cancellationReason}</p>
                                                        </c:if>
                                                    </div>
                                                </div>
                                                
                                                <button onclick="viewCancelledClassDetails('${classItem.scheduleId}')"
                                                        class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">
                                                    View Details
                                                </button>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div id="classDetailsModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4">
            <div class="p-6 border-b border-gray-200 flex items-center justify-between">
                <h3 class="text-xl font-bold text-gray-900">Class Details</h3>
                <button onclick="closeClassDetails()" class="text-gray-400 hover:text-gray-600">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            
            <div class="p-6 space-y-4">
                <div class="flex items-center space-x-3">
                    <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center text-gray-700 font-bold text-lg">
                        <span id="modalStudentInitials">AH</span>
                    </div>
                    <div>
                        <h4 class="font-bold text-gray-900" id="modalStudentName">Ahmad Hassan</h4>
                        <p class="text-sm text-gray-500" id="modalStudentId">Student ID: S-101</p>
                    </div>
                </div>
                
                <div class="space-y-4">
                    <div>
                        <p class="text-sm text-gray-500 mb-1">Class Type</p>
                        <p class="font-semibold text-gray-900" id="modalClassName">Quran Recitation & Tajweed</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 mb-1">Duration</p>
                        <p class="font-semibold text-gray-900" id="modalDuration">15 min</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 mb-1">Date</p>
                        <p class="font-semibold text-gray-900" id="modalDetailsDate">Monday, January 6, 2025</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 mb-1">Time</p>
                        <p class="font-semibold text-gray-900" id="modalDetailsTime">09:00 - 09:15</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 mb-1">Status</p>
                        <span class="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-semibold">Upcoming</span>
                    </div>
                </div>
                
                <div>
                    <p class="text-sm text-gray-500 mb-1">Notes</p>
                    <p class="text-gray-900">Focus on Makharij</p>
                </div>
            </div>
            
            <div class="p-6 border-t border-gray-200">
                <button onclick="closeClassDetails()" class="w-full px-6 py-2 bg-gradient-to-r from-purple-500 to-pink-400 text-white rounded-lg font-semibold hover:from-purple-600 hover:to-pink-500 transition">
                    Close
                </button>
            </div>
        </div>
    </div>
    
    <div id="cancelClassModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4">
            <div class="p-6 border-b border-gray-200">
                <h3 class="text-xl font-bold text-gray-900">Cancel Class?</h3>
            </div>
            
            <div class="p-6 space-y-4">
                <p class="text-gray-600">Are you sure you want to cancel this class with <span id="cancelStudentName">Ahmad Hassan</span>?</p>
                
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-sm font-semibold text-gray-900" id="cancelClassDate">Monday, January 6, 2025</p>
                    <p class="text-sm text-gray-600" id="cancelClassTime">09:00 - 09:15</p>
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        Cancellation Reason <span class="text-red-500">*</span>
                    </label>
                    <textarea id="cancellationReason" rows="3" placeholder="Please provide a reason for cancellation..." class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent resize-none"></textarea>
                </div>
                
                <div class="bg-red-50 border border-red-200 rounded-lg p-3">
                    <p class="text-sm text-red-700">
                        <strong>Note:</strong> Classes cannot be cancelled less than 12 hours before the start time. The student will be notified if cancellation is allowed.
                    </p>
                </div>
            </div>
            
            <div class="p-6 border-t border-gray-200 flex items-center justify-end space-x-3">
                <button onclick="closeCancelClass()" class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50 transition">
                    Keep Class
                </button>
                <button onclick="confirmCancelClass()" class="px-6 py-2 bg-red-500 text-white rounded-lg font-semibold hover:bg-red-600 transition">
                    Cancel Class
                </button>
            </div>
        </div>
    </div>
    
    <div id="availabilityModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4">
            <div class="p-6 border-b border-gray-200">
                <h3 class="text-xl font-bold text-gray-900">Add Availability</h3>
            </div>
            
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Date</label>
                    <input type="text" id="modalDate" readonly class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-900" data-raw-date="">
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Time Slot</label>
                    <input type="text" id="modalTimeSlot" readonly class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-900" data-start-time="" data-end-time="">
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Class Type</label>
                    <input type="text" id="modalClassType" value="Quran Recitation & Tajweed" readonly class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-900">
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Notes (Optional)</label>
                    <textarea id="modalNotes" rows="3" placeholder="Add any notes for this slot..." class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent resize-none"></textarea>
                </div>
            </div>
            
            <div class="p-6 border-t border-gray-200 flex items-center justify-end space-x-3">
                <button onclick="closeModal()" class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50 transition">
                    Cancel
                </button>
                <button onclick="submitAvailability()" class="px-6 py-2 text-white rounded-lg font-semibold hover:opacity-90 transition" style="background:var(--teacher-gradient);">
                    Add Availability
                </button>
            </div>
        </div>
    </div>

    <!-- Bulk selection confirmation modal -->
    <div id="bulkConfirmModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-lg w-full mx-4 max-h-[90vh] flex flex-col">
            <div class="p-6 border-b border-gray-200">
                <h3 class="text-xl font-bold text-gray-900">Confirm Selected Availability</h3>
                <p class="text-sm text-gray-500 mt-1">Review your selected time slots before adding.</p>
            </div>
            <div class="p-6 space-y-4 overflow-y-auto flex-1">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Date</label>
                    <p id="bulkConfirmDate" class="font-semibold text-gray-900"></p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Class Type</label>
                    <p class="text-gray-900">Quran Recitation & Tajweed</p>
                </div>
                <div>
                    <div class="flex items-center justify-between mb-2">
                        <label class="block text-sm font-medium text-gray-700">Selected Time Slots</label>
                        <span id="bulkConfirmCount" class="text-xs font-semibold px-2 py-1 rounded-full" style="background:#ede9fe;color:#6d28d9;">0 slots</span>
                    </div>
                    <ul id="bulkConfirmSlotList" class="space-y-2 max-h-56 overflow-y-auto border border-gray-200 rounded-lg p-3 bg-gray-50"></ul>
                </div>
            </div>
            <div class="p-6 border-t border-gray-200 flex items-center justify-end space-x-3">
                <button type="button" onclick="closeBulkConfirmModal()" class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50 transition">
                    Cancel
                </button>
                <button type="button" id="bulkConfirmBtn" onclick="confirmSelectedAvailability()" class="px-6 py-2 text-white rounded-lg font-semibold hover:opacity-90 transition" style="background:var(--teacher-gradient);">
                    Confirm & Add
                </button>
            </div>
        </div>
    </div>
    
    <!-- View Availability Details Modal -->
    <div id="viewAvailabilityModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4">
            <div class="p-6 border-b border-gray-200 flex items-center justify-between">
                <h3 class="text-xl font-bold text-gray-900">Availability Details</h3>
                <button onclick="closeViewAvailabilityModal()" class="text-gray-400 hover:text-gray-600">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            
            <div class="p-6 space-y-4">
                <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
                    <div class="flex items-center space-x-3 mb-3">
                        <div class="w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center">
                            <i class="fas fa-calendar-check text-white"></i>
                        </div>
                        <div>
                            <h4 class="font-semibold text-gray-900">Quran Recitation & Tajweed</h4>
                            <p class="text-sm text-gray-600" id="viewAvailabilityStatus">Available for Booking</p>
                        </div>
                    </div>
                </div>
                
                <div class="space-y-3">
                    <div class="flex items-start space-x-3">
                        <i class="fas fa-calendar text-purple-600 mt-1"></i>
                        <div class="flex-1">
                            <p class="text-sm text-gray-600">Date</p>
                            <p class="font-semibold text-gray-900" id="viewAvailabilityDate"></p>
                        </div>
                    </div>
                    
                    <div class="flex items-start space-x-3">
                        <i class="fas fa-clock text-purple-600 mt-1"></i>
                        <div class="flex-1">
                            <p class="text-sm text-gray-600">Time</p>
                            <p class="font-semibold text-gray-900" id="viewAvailabilityTime"></p>
                        </div>
                    </div>
                    
                    <div class="flex items-start space-x-3">
                        <i class="fas fa-hourglass-half text-purple-600 mt-1"></i>
                        <div class="flex-1">
                            <p class="text-sm text-gray-600">Duration</p>
                            <p class="font-semibold text-gray-900">15 minutes</p>
                        </div>
                    </div>
                    
                    <div class="flex items-start space-x-3">
                        <i class="fas fa-id-card text-purple-600 mt-1"></i>
                        <div class="flex-1">
                            <p class="text-sm text-gray-600">Schedule ID</p>
                            <p class="font-semibold text-gray-900" id="viewAvailabilityId"></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="p-6 border-t border-gray-200 flex items-center justify-center">
                <button onclick="closeViewAvailabilityModal()" class="px-6 py-2 bg-purple-600 text-white rounded-lg font-semibold hover:bg-purple-700 transition">
                    Close
                </button>
            </div>
        </div>
    </div>
    
    <!-- Delete Availability Modal -->
    <div id="deleteAvailabilityModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center" style="z-index: 9999;">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4" style="position: relative; z-index: 10000;">
            <div class="p-6 border-b border-gray-200">
                <h3 class="text-xl font-bold text-gray-900">Delete Availability?</h3>
            </div>
            
            <div class="p-6 space-y-4">
                <p class="text-gray-700">Are you sure you want to delete this time slot? This action cannot be undone.</p>
                
                <div class="bg-gray-50 rounded-lg p-4">
                    <p class="font-semibold text-gray-900" id="deleteTimeSlot">08:00 - 08:15</p>
                    <p class="text-sm text-gray-600" id="deleteDate">Wednesday, January 14, 2026</p>
                </div>
                
                <input type="hidden" id="deleteScheduleId">
            </div>
            
            <div class="p-6 border-t border-gray-200 flex items-center justify-end space-x-3">
                <button onclick="closeDeleteModal()" class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50 transition">
                    Cancel
                </button>
                <button onclick="confirmDeleteAvailability()" class="px-6 py-2 bg-red-500 text-white rounded-lg font-semibold hover:bg-red-600 transition">
                    Delete
                </button>
            </div>
        </div>
    </div>
    
    <script>
        let selectedDate = null;
        let selectedStartTime = null;
        let selectedEndTime = null;
        let selectedClassData = null;
        let pendingSlots = {};
        let emptySlotRegistry = [];
        let currentViewMode = 'month'; // 'month' or 'week'
        let currentWeekStart = null;
        // When in week mode, confine navigation to this month/year
        let weekModeMonth = null;
        let weekModeYear = null;

        const currentDate = new Date();
        // Server/current real month/year (teachers must be restricted to these)
        const serverMonth = currentDate.getMonth();
        const serverYear = currentDate.getFullYear();
        let currentYear = currentDate.getFullYear();
        let currentMonth = currentDate.getMonth();
        const today = currentDate.getDate();
        
        const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                           'July', 'August', 'September', 'October', 'November', 'December'];
        
        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        
        // Store teacher's availability slots from server
        let availabilitySlots = [];
        
        const hasSlots = '${not empty availabilitySlots}';
        const slotCount = '${fn:length(availabilitySlots)}';
        console.log('=== Loading Availability Slots from Database ===');
        console.log('JSP availabilitySlots attribute exists:', hasSlots);
        console.log('JSP availabilitySlots count:', slotCount);
        
        <c:if test="${not empty availabilitySlots}">
        console.log('Raw availability data from server:');
        <c:forEach items="${availabilitySlots}" var="slot" varStatus="status">
        console.log('  Slot ' + ${status.index} + ': id=' + '${slot.scheduleId}' + ', date=' + '${slot.scheduleDate}' + ', start=' + '${slot.startTime}' + ', end=' + '${slot.endTime}' + ', booked=' + '${slot.bookingStatus}');
        </c:forEach>

        try {
            availabilitySlots = [
                <c:forEach items="${availabilitySlots}" var="slot" varStatus="status">
                {
                    scheduleId: '${slot.scheduleId}',
                    date: '${slot.scheduleDate}',
                    startTime: '${fn:substring(slot.startTime, 0, 5)}',
                    endTime: '${fn:substring(slot.endTime, 0, 5)}',
                    bookingStatus: '${slot.bookingStatus}'
                }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            console.log('Successfully parsed availability slots:', availabilitySlots);
            console.log('Total slots loaded:', availabilitySlots.length);
        } catch(e) {
            console.error('Error parsing availability slots:', e);
            availabilitySlots = [];
        }
        </c:if>
        
        <c:if test="${empty availabilitySlots}">
        console.warn('⚠️ NO availability slots found in database for this teacher!');
        console.warn('This means either:');
        console.warn('1. No availability has been added yet');
        console.warn('2. Servlet is not passing data correctly');
        console.warn('3. Database query returned no results');
        </c:if>
        
        // Load completed, rescheduled, and cancelled classes data for month-by-month filtering
        console.log('=== Loading Completed, Rescheduled and Cancelled Classes ===');
        let completedClassesData = [];
        let rescheduledClassesData = [];
        let cancelledClassesData = [];
        
        <c:if test="${not empty completedClasses}">
        console.log('Loading completed classes:');
        <c:forEach items="${completedClasses}" var="classItem" varStatus="status">
        completedClassesData.push({
            scheduleId: '${classItem.scheduleId}',
            studentName: '${classItem.studentName}',
            className: '${classItem.className}',
            scheduleDate: '${classItem.scheduleDate}',
            startTime: '${fn:substring(classItem.startTime, 0, 5)}',
            endTime: '${fn:substring(classItem.endTime, 0, 5)}',
            needsReschedule: ${classItem.needsReschedule}
        });
        </c:forEach>
        </c:if>

        <c:if test="${not empty rescheduledClasses}">
        console.log('Loading rescheduled classes:');
        <c:forEach items="${rescheduledClasses}" var="classItem" varStatus="status">
        rescheduledClassesData.push({
            scheduleId: '${classItem.scheduleId}',
            studentName: '${classItem.studentName}',
            className: '${classItem.className}',
            scheduleDate: '${classItem.scheduleDate}',
            startTime: '${fn:substring(classItem.startTime, 0, 5)}',
            endTime: '${fn:substring(classItem.endTime, 0, 5)}',
            cancellationReason: '${classItem.cancellationReason}'
        });
        </c:forEach>
        </c:if>
        
        <c:if test="${not empty cancelledClasses}">
        console.log('Loading cancelled classes:');
        <c:forEach items="${cancelledClasses}" var="classItem" varStatus="status">
        cancelledClassesData.push({
            scheduleId: '${classItem.scheduleId}',
            studentName: '${classItem.studentName}',
            className: '${classItem.className}',
            scheduleDate: '${classItem.scheduleDate}',
            startTime: '${fn:substring(classItem.startTime, 0, 5)}',
            endTime: '${fn:substring(classItem.endTime, 0, 5)}',
            cancellationReason: '${classItem.cancellationReason}'
        });
        console.log('  Cancelled: ${classItem.studentName} on ${classItem.scheduleDate}');
        </c:forEach>
        </c:if>
        
        console.log('Total completed:', completedClassesData.length, 'Total rescheduled:', rescheduledClassesData.length, 'Total cancelled:', cancelledClassesData.length);

        function parseScheduleMonthParts(dateStr) {
            if (!dateStr) return null;
            const iso = String(dateStr).substring(0, 10);
            const parts = iso.split('-');
            if (parts.length === 3) {
                const year = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10) - 1;
                if (!isNaN(year) && !isNaN(month)) {
                    return { year: year, month: month };
                }
            }
            const d = new Date(dateStr);
            return isNaN(d.getTime()) ? null : { year: d.getFullYear(), month: d.getMonth() };
        }

        /** Convert HH:mm or HH:mm:ss to 12-hour display (e.g. 02:15 PM). */
        function formatTime12FromString(timeStr) {
            if (!timeStr) return '';
            const match = String(timeStr).trim().match(/^(\d{1,2}):(\d{2})/);
            if (!match) return timeStr;
            let hour = parseInt(match[1], 10);
            const minute = match[2];
            const period = hour >= 12 ? 'PM' : 'AM';
            if (hour === 0) hour = 12;
            else if (hour > 12) hour -= 12;
            const hourStr = hour < 10 ? '0' + hour : String(hour);
            return hourStr + ':' + minute + ' ' + period;
        }

        function formatClassTimeRange(startTime, endTime) {
            return formatTime12FromString(startTime) + ' - ' + formatTime12FromString(endTime);
        }
        
        // Filter classes by the currently displayed month
        function getCompletedClassesForMonth(year, month) {
            return completedClassesData.filter(classItem => {
                const p = parseScheduleMonthParts(classItem.scheduleDate);
                return p && p.year === year && p.month === month;
            });
        }
        
        function getCancelledClassesForMonth(year, month) {
            return cancelledClassesData.filter(classItem => {
                const p = parseScheduleMonthParts(classItem.scheduleDate);
                return p && p.year === year && p.month === month;
            });
        }
        
        function getRescheduledClassesForMonth(year, month) {
            return rescheduledClassesData.filter(classItem => {
                const p = parseScheduleMonthParts(classItem.scheduleDate);
                return p && p.year === year && p.month === month;
            });
        }
        
        // Display completed, rescheduled and cancelled classes for current month
        function updateCompletedCancelledDisplay() {
            const completedThisMonth = getCompletedClassesForMonth(currentYear, currentMonth);
            const rescheduledThisMonth = getRescheduledClassesForMonth(currentYear, currentMonth);
            const cancelledThisMonth = getCancelledClassesForMonth(currentYear, currentMonth);
            
            console.log('Updated month display - Completed:', completedThisMonth.length, 'Rescheduled:', rescheduledThisMonth.length, 'Cancelled:', cancelledThisMonth.length);
            
            updateCompletedClassesDisplay(completedThisMonth);
            updateRescheduledClassesDisplay(rescheduledThisMonth);
            updateCancelledClassesDisplay(cancelledThisMonth);
        }
        
        // Update the DOM display for completed classes
        function updateCompletedClassesDisplay(classes) {
            const container = document.getElementById('completedClassesContainer');
            if (!container) return;
            
            const countSpan = document.getElementById('completedClassesCount');
            if (countSpan) countSpan.textContent = classes.length + ' classes';
            
            if (classes.length === 0) {
                container.innerHTML = '<div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center"><i class="far fa-calendar-check text-gray-400 text-4xl mb-3"></i><p class="text-gray-500">No completed classes this month</p></div>';
                return;
            }
            
            let html = '<div class="space-y-4">';
            classes.forEach(classItem => {
                const dateObj = new Date(classItem.scheduleDate);
                const dateStr = dateObj.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
                const initials = classItem.studentName.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
                const isNotCompleted = classItem.needsReschedule === true || classItem.needsReschedule === 'true';
                const borderClass = isNotCompleted ? 'border-amber-500' : 'border-green-500';
                const badgeClass = isNotCompleted ? 'bg-amber-100 text-amber-800' : 'bg-green-100 text-green-700';
                const badgeLabel = isNotCompleted ? 'Not Completed' : 'Completed';
                html += '<div class="bg-white rounded-xl shadow-sm border-l-4 ' + borderClass + ' border-y border-r border-gray-200 p-6">' +
                    '<div class="flex items-center justify-between">' +
                        '<div class="flex items-center space-x-4">' +
                            '<div class="w-14 h-14 bg-teal-500 rounded-full flex items-center justify-center text-white font-bold text-lg">' + initials + '</div>' +
                            '<div>' +
                                '<h5 class="font-bold text-gray-900 text-lg">' + classItem.studentName + '</h5>' +
                                '<p class="text-gray-600 text-sm">' + classItem.className + '</p>' +
                                '<div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">' +
                                    '<div class="flex items-center space-x-1"><i class="far fa-calendar text-gray-400"></i><span>' + dateStr + '</span></div>' +
                                    '<div class="flex items-center space-x-1"><i class="far fa-clock text-gray-400"></i><span>' + formatClassTimeRange(classItem.startTime, classItem.endTime) + '</span></div>' +
                                    '<span class="px-2 py-1 ' + badgeClass + ' rounded text-xs font-semibold">' + badgeLabel + '</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<button onclick="viewCompletedClassDetails(\'' + classItem.scheduleId + '\')" class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">View Details</button>' +
                    '</div>' +
                '</div>';
            });
            html += '</div>';
            container.innerHTML = html;
        }
        
        // Update the DOM display for rescheduled classes
        function updateRescheduledClassesDisplay(classes) {
            const container = document.getElementById('rescheduledClassesContainer');
            if (!container) return;
            
            const countSpan = document.getElementById('rescheduledClassesCount');
            if (countSpan) countSpan.textContent = classes.length + ' classes';
            
            if (classes.length === 0) {
                container.innerHTML = '<div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center"><i class="far fa-calendar-alt text-gray-400 text-4xl mb-3"></i><p class="text-gray-500">No rescheduled classes this month</p></div>';
                return;
            }
            
            let html = '<div class="space-y-4">';
            classes.forEach(classItem => {
                const dateObj = new Date(classItem.scheduleDate);
                const dateStr = dateObj.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
                const initials = classItem.studentName.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
                const reasonHtml = classItem.cancellationReason ? '<p class="text-teal-700 text-sm mt-2">' + classItem.cancellationReason + '</p>' : '';
                html += '<div class="bg-white rounded-xl shadow-sm border-l-4 border-teal-500 border-y border-r border-gray-200 p-6">' +
                    '<div class="flex items-center justify-between">' +
                        '<div class="flex items-center space-x-4">' +
                            '<div class="w-14 h-14 bg-teal-500 rounded-full flex items-center justify-center text-white font-bold text-lg">' + initials + '</div>' +
                            '<div>' +
                                '<h5 class="font-bold text-gray-900 text-lg">' + classItem.studentName + '</h5>' +
                                '<p class="text-gray-600 text-sm">' + classItem.className + '</p>' +
                                '<div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">' +
                                    '<div class="flex items-center space-x-1"><i class="far fa-calendar text-gray-400"></i><span>' + dateStr + '</span></div>' +
                                    '<div class="flex items-center space-x-1"><i class="far fa-clock text-gray-400"></i><span>' + formatClassTimeRange(classItem.startTime, classItem.endTime) + '</span></div>' +
                                    '<span class="px-2 py-1 bg-teal-100 text-teal-800 rounded text-xs font-semibold">Rescheduled</span>' +
                                '</div>' +
                                reasonHtml +
                            '</div>' +
                        '</div>' +
                        '<button onclick="viewCompletedClassDetails(\'' + classItem.scheduleId + '\')" class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">View Details</button>' +
                    '</div>' +
                '</div>';
            });
            html += '</div>';
            container.innerHTML = html;
        }
        
        // Update the DOM display for cancelled classes
        function updateCancelledClassesDisplay(classes) {
            const container = document.getElementById('cancelledClassesContainer');
            if (!container) return;
            
            const countSpan = document.getElementById('cancelledClassesCount');
            if (countSpan) countSpan.textContent = classes.length + ' classes';
            
            if (classes.length === 0) {
                container.innerHTML = '<div class="bg-gray-50 rounded-xl border border-gray-200 p-8 text-center"><i class="far fa-calendar-times text-gray-400 text-4xl mb-3"></i><p class="text-gray-500">No cancelled classes this month</p></div>';
                return;
            }
            
            let html = '<div class="space-y-4">';
            classes.forEach(classItem => {
                const dateObj = new Date(classItem.scheduleDate);
                const dateStr = dateObj.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
                const initials = classItem.studentName.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
                const reasonHtml = classItem.cancellationReason ? '<p class="text-gray-500 text-sm mt-1">Reason: ' + classItem.cancellationReason + '</p>' : '';
                html += '<div class="bg-white rounded-xl shadow-sm border-l-4 border-red-500 border-y border-r border-gray-200 p-6">' +
                    '<div class="flex items-center justify-between">' +
                        '<div class="flex items-center space-x-4">' +
                            '<div class="w-14 h-14 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 font-bold text-lg">' + initials + '</div>' +
                            '<div>' +
                                '<h5 class="font-bold text-gray-900 text-lg">' + classItem.studentName + '</h5>' +
                                '<p class="text-gray-600 text-sm">' + classItem.className + '</p>' +
                                '<div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">' +
                                    '<div class="flex items-center space-x-1"><i class="far fa-calendar text-gray-400"></i><span>' + dateStr + '</span></div>' +
                                    '<div class="flex items-center space-x-1"><i class="far fa-clock text-gray-400"></i><span>' + formatClassTimeRange(classItem.startTime, classItem.endTime) + '</span></div>' +
                                    '<span class="px-2 py-1 bg-red-100 text-red-700 rounded text-xs font-semibold">Cancelled</span>' +
                                '</div>' +
                                reasonHtml +
                            '</div>' +
                        '</div>' +
                        '<button onclick="viewCancelledClassDetails(\'' + classItem.scheduleId + '\')" class="px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition">View Details</button>' +
                    '</div>' +
                '</div>';
            });
            html += '</div>';
            container.innerHTML = html;
        }
        
        // Build availabilityMap for quick lookup (stores scheduleId and booking status)
        console.log('=== Building Availability Map ===');
        const availabilityMap = {};
        availabilitySlots.forEach((slot, index) => {
            console.log(`Adding slot ${index}: id='${slot.scheduleId}', date='${slot.date}', startTime='${slot.startTime}', booked='${slot.bookingStatus}'`);
            if (!availabilityMap[slot.date]) {
                availabilityMap[slot.date] = {};
                console.log(`  Created new date entry for: ${slot.date}`);
            }
            availabilityMap[slot.date][slot.startTime] = {
                scheduleId: slot.scheduleId,
                bookingStatus: slot.bookingStatus
            };
            console.log(`  Added time slot: ${slot.startTime} to date ${slot.date} with ID ${slot.scheduleId} - Booking: ${slot.bookingStatus}`);
        });
        
        console.log('=== Availability Map Complete ===');
        console.log('Total dates with availability:', Object.keys(availabilityMap).length);
        console.log('Dates:', Object.keys(availabilityMap));
        console.log('Full map structure:', JSON.stringify(availabilityMap, null, 2));
        
        // Helper function to format time as 12-hour with am/pm (e.g. 1:00 pm)
        function formatTime(hour, minute) {
            let period = hour >= 12 ? 'pm' : 'am';
            let h12 = hour % 12;
            if (h12 === 0) h12 = 12;
            const m = minute < 10 ? '0' + minute : '' + minute;
            return h12 + ':' + m + ' ' + period;
        }
        
        // Format time in 24-hour HH:MM format for availability map lookup
        function formatTime24(hour, minute) {
            const h = hour < 10 ? '0' + hour : '' + hour;
            const m = minute < 10 ? '0' + minute : '' + minute;
            return h + ':' + m;
        }

        // Set view mode (month or week)
        function setViewMode(mode) {
            currentViewMode = mode;

            // Update button styles
            const monthBtn = document.getElementById('monthViewBtn');
            const weekBtn = document.getElementById('weekViewBtn');

            if (mode === 'month') {
                monthBtn.className = 'px-3 py-1 text-sm font-medium text-purple-600 bg-purple-100 rounded-lg hover:bg-purple-100 transition';
                weekBtn.className = 'px-3 py-1 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition';
                // Clear any week-mode lock when switching back to month view
                weekModeMonth = null;
                weekModeYear = null;
            } else {
                monthBtn.className = 'px-3 py-1 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition';
                weekBtn.className = 'px-3 py-1 text-sm font-medium text-purple-600 bg-purple-100 rounded-lg hover:bg-purple-100 transition';
                // Reset week start to show current week when switching to week view
                currentWeekStart = null;
                // Lock week navigation to the server/current month/year (teachers restricted to current month)
                weekModeMonth = serverMonth;
                weekModeYear = serverYear;
            }

            initCalendar();
        }

        // Navigate date (previous/next)
        function navigateDate(delta) {
            if (currentViewMode === 'month') {
                // Allow navigating months - teachers should be able to view past and future availability
                currentMonth += delta;
                if (currentMonth > 11) {
                    currentMonth = 0;
                    currentYear++;
                } else if (currentMonth < 0) {
                    currentMonth = 11;
                    currentYear--;
                }
                console.log('Navigating to month:', currentMonth + 1, 'year:', currentYear);
                initCalendar();
            } else { // week view
                // Initialize currentWeekStart if not set
                if (!currentWeekStart) {
                    const todayDate = new Date(currentYear, currentMonth, today);
                    currentWeekStart = new Date(todayDate);
                    currentWeekStart.setDate(todayDate.getDate() - todayDate.getDay()); // Start of week (Sunday)
                }

                // Compute tentative new week start and ensure it stays in the locked month/year
                const tentative = new Date(currentWeekStart);
                tentative.setDate(currentWeekStart.getDate() + (delta * 7));

                if (weekModeMonth !== null && weekModeYear !== null) {
                    if (!weekIntersectsMonth(tentative, weekModeMonth, weekModeYear)) {
                        console.log('Week navigation blocked: would leave locked month', weekModeMonth, weekModeYear);
                        return; // do not navigate outside the locked month
                    }
                }

                // Commit the tentative week start
                currentWeekStart = tentative;

                // Update currentYear and currentMonth to match the week's start date
                currentYear = currentWeekStart.getFullYear();
                currentMonth = currentWeekStart.getMonth();
            }

            initCalendar();
            updateCompletedCancelledDisplay();
        }

        // Enable/disable prev/next buttons depending on view and whether navigation would leave the allowed month
        function updateNavButtons() {
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            if (!prevBtn || !nextBtn) return;

            // Reset styles
            prevBtn.disabled = false;
            nextBtn.disabled = false;
            prevBtn.classList.remove('opacity-50', 'cursor-not-allowed');
            nextBtn.classList.remove('opacity-50', 'cursor-not-allowed');

            // In month view, allow full navigation to see all months
            if (currentViewMode === 'month') {
                // Navigation is now always enabled in month view
                return;
            }

            if (currentViewMode === 'week' && weekModeMonth !== null && weekModeYear !== null) {
                // Determine if navigating -1 week would leave the locked month/year
                let baseStart = currentWeekStart;
                if (!baseStart) {
                    const todayDate = new Date(weekModeYear, weekModeMonth, today);
                    baseStart = new Date(todayDate);
                    baseStart.setDate(todayDate.getDate() - todayDate.getDay());
                }
                const prevCandidate = new Date(baseStart);
                prevCandidate.setDate(baseStart.getDate() - 7);
                if (!weekIntersectsMonth(prevCandidate, weekModeMonth, weekModeYear)) {
                    prevBtn.disabled = true;
                    prevBtn.classList.add('opacity-50', 'cursor-not-allowed');
                }

                const nextCandidate = new Date(baseStart);
                nextCandidate.setDate(baseStart.getDate() + 7);
                if (!weekIntersectsMonth(nextCandidate, weekModeMonth, weekModeYear)) {
                    nextBtn.disabled = true;
                    nextBtn.classList.add('opacity-50', 'cursor-not-allowed');
                }
            }
        }

        // Return true if any day in the week starting at weekStart falls inside given month/year
        function weekIntersectsMonth(weekStart, month, year) {
            for (let d = 0; d < 7; d++) {
                const dt = new Date(weekStart);
                dt.setDate(weekStart.getDate() + d);
                if (dt.getMonth() === month && dt.getFullYear() === year) return true;
            }
            return false;
        }
        
        // Helper function: check if date has any booked slots
        function hasBookedSlots(dateStr) {
            if (!availabilityMap[dateStr]) return false;
            for (let timeSlot in availabilityMap[dateStr]) {
                const slotData = availabilityMap[dateStr][timeSlot];
                const status = slotData && slotData.bookingStatus;
                if (status && status !== 'null' && status !== 'undefined') {
                    return true;
                }
            }
            return false;
        }
        
        // Helper function: extract scheduleId from map entry (handles both old string format and new object format)
        function getScheduleId(mapEntry) {
            if (mapEntry && typeof mapEntry === 'object') {
                return mapEntry.scheduleId;
            }
            return mapEntry;
        }

        function canAddAvailability(date) {
            const todayStart = new Date();
            todayStart.setHours(0, 0, 0, 0);
            const d = new Date(date);
            d.setHours(0, 0, 0, 0);
            return d >= todayStart;
        }

        function getSelectedDateStr() {
            if (!selectedDate) return null;
            const year = selectedDate.getFullYear();
            const month = String(selectedDate.getMonth() + 1).padStart(2, '0');
            const day = String(selectedDate.getDate()).padStart(2, '0');
            return year + '-' + month + '-' + day;
        }

        function to24(timeStr) {
            if (!timeStr) return timeStr;
            let t = String(timeStr).trim().toLowerCase();
            const m = t.match(/^(\d{1,2}):(\d{2})(?:\s*(am|pm))?$/i);
            if (m) {
                let h = parseInt(m[1], 10);
                const mm = m[2];
                const ampm = m[3];
                if (ampm) {
                    if (ampm === 'pm' && h < 12) h += 12;
                    if (ampm === 'am' && h === 12) h = 0;
                }
                return String(h).padStart(2, '0') + ':' + mm;
            }
            const m2 = t.match(/^(\d{2}):(\d{2})(?::\d{2})?$/);
            if (m2) return m2[1] + ':' + m2[2];
            return timeStr;
        }

        function updateSlotSelectionBar() {
            const count = Object.keys(pendingSlots).length;
            const bar = document.getElementById('slotSelectionBar');
            const label = document.getElementById('selectedSlotCount');
            const btn = document.getElementById('addSelectedBtn');
            if (!bar || !label || !btn) return;
            if (count > 0) {
                bar.classList.add('visible');
                label.textContent = count + ' slot' + (count === 1 ? '' : 's') + ' selected';
                btn.disabled = false;
                btn.textContent = 'Add Selected (' + count + ')';
            } else {
                bar.classList.remove('visible');
                btn.disabled = true;
                btn.textContent = 'Add Selected';
            }
        }

        function toggleSlotSelection(startTime24, startTime, endTime, slotEl) {
            if (pendingSlots[startTime24]) {
                delete pendingSlots[startTime24];
                slotEl.classList.remove('selected');
            } else {
                pendingSlots[startTime24] = { startTime: startTime, endTime: endTime, startTime24: startTime24 };
                slotEl.classList.add('selected');
            }
            updateSlotSelectionBar();
        }

        function clearSelectedSlots() {
            pendingSlots = {};
            document.querySelectorAll('.slot-empty.selected').forEach(function(el) {
                el.classList.remove('selected');
            });
            updateSlotSelectionBar();
        }

        function selectAllEmptySlots() {
            emptySlotRegistry.forEach(function(slot) {
                pendingSlots[slot.startTime24] = slot;
                if (slot.element) slot.element.classList.add('selected');
            });
            updateSlotSelectionBar();
        }

        function postAvailabilitySlot(scheduleDate, startTimeFormatted, endTimeFormatted) {
            let start = startTimeFormatted;
            let end = endTimeFormatted;
            if (start.split(':').length === 2) start += ':00';
            if (end.split(':').length === 2) end += ':00';

            return fetch("<%= request.getContextPath() %>/teacher/setAvailability?t=" + new Date().getTime(), {
                method: "POST",
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    className: "Quran Recitation & Tajweed",
                    scheduleDate: scheduleDate,
                    startTime: start,
                    endTime: end
                })
            }).then(function(res) {
                const contentType = res.headers.get("content-type");
                if (!contentType || !contentType.includes("application/json")) {
                    return res.text().then(function(text) {
                        throw new Error("Server returned an unexpected response.");
                    });
                }
                return res.json();
            });
        }

        function submitSelectedAvailability() {
            const keys = Object.keys(pendingSlots);
            if (!keys.length || !selectedDate) return;

            const dateStr = getSelectedDateStr();
            const btn = document.getElementById('addSelectedBtn');
            const confirmBtn = document.getElementById('bulkConfirmBtn');
            if (confirmBtn) {
                confirmBtn.disabled = true;
                confirmBtn.textContent = 'Adding...';
            }
            if (btn) {
                btn.disabled = true;
                btn.textContent = 'Adding...';
            }

            const sorted = keys.sort().map(function(k) { return pendingSlots[k]; });
            let added = 0;
            let failed = 0;
            let lastError = '';

            (function addNext(index) {
                if (index >= sorted.length) {
                    closeBulkConfirmModal();
                    if (btn) {
                        btn.disabled = false;
                        updateSlotSelectionBar();
                    }
                    if (confirmBtn) {
                        confirmBtn.disabled = false;
                        confirmBtn.textContent = 'Confirm & Add';
                    }
                    pendingSlots = {};
                    initCalendar();
                    if (selectedDate) {
                        selectDate(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate());
                    }
                    if (added > 0 && failed === 0) {
                        alert('Successfully added ' + added + ' availability slot' + (added === 1 ? '' : 's') + '.');
                    } else if (added > 0 && failed > 0) {
                        alert('Added ' + added + ' slot(s). ' + failed + ' failed: ' + lastError);
                    } else {
                        alert(lastError || 'Failed to add availability.');
                    }
                    return;
                }

                const slot = sorted[index];
                const start24 = to24(slot.startTime);
                const end24 = to24(slot.endTime);

                postAvailabilitySlot(dateStr, start24, end24)
                    .then(function(data) {
                        if (data.success) {
                            added++;
                            const startShort = start24.substring(0, 5);
                            const endShort = end24.substring(0, 5);
                            availabilitySlots.push({
                                date: dateStr,
                                startTime: startShort,
                                endTime: endShort,
                                bookingStatus: null
                            });
                            if (!availabilityMap[dateStr]) availabilityMap[dateStr] = {};
                            availabilityMap[dateStr][startShort] = {
                                scheduleId: data.scheduleId || 'C000',
                                bookingStatus: null
                            };
                        } else {
                            failed++;
                            lastError = data.message || 'Unknown error';
                        }
                        addNext(index + 1);
                    })
                    .catch(function(err) {
                        failed++;
                        lastError = err.message || 'Request failed';
                        addNext(index + 1);
                    });
            })(0);
        }

        function openSelectedConfirmationModal() {
            const keys = Object.keys(pendingSlots);
            if (!keys.length) {
                alert('Please select at least one time slot.');
                return;
            }
            if (!selectedDate) {
                alert('Please select a date from the calendar first.');
                return;
            }

            const dayName = dayNames[selectedDate.getDay()];
            const dateLabel = dayName + ', ' + monthNames[selectedDate.getMonth()] + ' ' +
                selectedDate.getDate() + ', ' + selectedDate.getFullYear();
            document.getElementById('bulkConfirmDate').textContent = dateLabel;
            document.getElementById('bulkConfirmCount').textContent = keys.length + ' slot' + (keys.length === 1 ? '' : 's');

            const listEl = document.getElementById('bulkConfirmSlotList');
            listEl.innerHTML = '';
            keys.sort().forEach(function(k) {
                const slot = pendingSlots[k];
                const li = document.createElement('li');
                li.className = 'flex items-center justify-between text-sm py-2 px-3 bg-white rounded-lg border border-gray-100';
                li.innerHTML = '<span class="font-semibold text-gray-800">' + slot.startTime + ' - ' + slot.endTime + '</span>' +
                    '<span class="slot-badge">15 min</span>';
                listEl.appendChild(li);
            });

            document.getElementById('bulkConfirmModal').classList.add('active');
        }

        function closeBulkConfirmModal() {
            document.getElementById('bulkConfirmModal').classList.remove('active');
        }

        function confirmSelectedAvailability() {
            submitSelectedAvailability();
        }
        
        function initCalendar() {
            console.log('initCalendar called, mode:', currentViewMode);
            const monthElement = document.getElementById('currentMonth');
            if (!monthElement) {
                console.error('currentMonth element not found!');
                return;
            }

            if (currentViewMode === 'month') {
                monthElement.textContent = monthNames[currentMonth] + ' ' + currentYear;
            } else {
                // For week view, show "Week of [Month] [Year]" based on the week's start date
                monthElement.textContent = 'Week of ' + monthNames[currentMonth] + ' ' + currentYear;
            }

            const calendarGrid = document.getElementById('calendarGrid');
            if (!calendarGrid) {
                console.error('calendarGrid element not found!');
                return;
            }

            // Set the appropriate class for the grid layout
            if (currentViewMode === 'month') {
                calendarGrid.className = 'grid grid-cols-7 gap-2 mb-4';
            } else {
                // Use the same 7-column grid so week cells keep the same sizing as month view
                calendarGrid.className = 'grid grid-cols-7 gap-2 mb-4';
            }

            calendarGrid.innerHTML = '';

            if (currentViewMode === 'month') {
                // Month view - show full month
                const firstDay = new Date(currentYear, currentMonth, 1).getDay();
                const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

                // Empty cells before first day
                for (let i = 0; i < firstDay; i++) {
                    const emptyDiv = document.createElement('div');
                    calendarGrid.appendChild(emptyDiv);
                }

                // Render days
                console.log('=== Rendering Calendar Days (Month View) ===');
                for (let day = 1; day <= daysInMonth; day++) {
                    const dateStr = currentYear + '-' + String(currentMonth + 1).padStart(2, '0') + '-' + String(day).padStart(2, '0');
                    const hasAvailability = availabilityMap[dateStr] && Object.keys(availabilityMap[dateStr]).length > 0;
                    const hasBooked = hasBookedSlots(dateStr);
                    const isToday = day === today && currentMonth === new Date().getMonth() && currentYear === new Date().getFullYear();

                    if (hasAvailability) {
                        console.log('Date with availability:', dateStr, 'booked:', hasBooked, 'slots:', Object.keys(availabilityMap[dateStr]));
                    }

                    const button = document.createElement('button');
                    button.textContent = day;
                    button.className = 'aspect-square rounded-lg text-sm font-medium transition-all';
                    button.setAttribute('data-year', currentYear);
                    button.setAttribute('data-month', currentMonth);
                    button.setAttribute('data-day', day);

                    if (isToday) {
                        button.className += ' border-2 border-gray-900 text-gray-900 font-semibold hover:bg-gray-100';
                    } else if (hasAvailability) {
                        // Dark purple if booked, light purple if available
                        if (hasBooked) {
                            button.className += ' bg-purple-600 text-white font-semibold hover:bg-purple-700';
                        } else {
                            button.className += ' bg-purple-100 text-purple-800 font-semibold hover:bg-purple-300';
                        }
                    } else {
                        button.className += ' border border-gray-200 text-gray-700 hover:bg-gray-50';
                    }

                    button.setAttribute('onclick', 'selectDate(' + currentYear + ',' + currentMonth + ',' + day + ')');
                    calendarGrid.appendChild(button);
                }
            } else {
                // Week view - show only current week
                console.log('=== Rendering Calendar Days (Week View) ===');

                // Initialize currentWeekStart if not set
                if (!currentWeekStart) {
                    // Base the week start on the server current month/year so teachers cannot navigate outside it
                    const baseYear = (weekModeYear !== null) ? weekModeYear : serverYear;
                    const baseMonth = (weekModeMonth !== null) ? weekModeMonth : serverMonth;
                    // Use 'today' day-of-month if it exists in server month, otherwise use 1st
                    const dayInMonth = Math.min(today, new Date(baseYear, baseMonth + 1, 0).getDate());
                    const todayDate = new Date(baseYear, baseMonth, dayInMonth);
                    currentWeekStart = new Date(todayDate);
                    currentWeekStart.setDate(todayDate.getDate() - todayDate.getDay()); // Start of week (Sunday)

                    // Update currentYear and currentMonth to match the week
                    currentYear = currentWeekStart.getFullYear();
                    currentMonth = currentWeekStart.getMonth();
                }

                // Render exactly 7 days (Sun-Sat) for the current week
                for (let i = 0; i < 7; i++) {
                    const weekDate = new Date(currentWeekStart);
                    weekDate.setDate(currentWeekStart.getDate() + i);

                    const day = weekDate.getDate();
                    const dateStr = weekDate.getFullYear() + '-' + String(weekDate.getMonth() + 1).padStart(2, '0') + '-' + String(day).padStart(2, '0');
                    const hasAvailability = availabilityMap[dateStr] && Object.keys(availabilityMap[dateStr]).length > 0;
                    const hasBooked = hasBookedSlots(dateStr);
                    const isToday = day === today && weekDate.getMonth() === new Date().getMonth() && weekDate.getFullYear() === new Date().getFullYear();
                    const isCurrentMonth = weekDate.getMonth() === currentMonth;

                    if (hasAvailability) {
                        console.log('Date with availability:', dateStr, 'booked:', hasBooked, 'slots:', Object.keys(availabilityMap[dateStr]));
                    }

                    const button = document.createElement('button');
                    button.textContent = day;
                    // Use same sizing as month view (square cells)
                    button.className = 'aspect-square rounded-lg text-sm font-medium transition-all';
                    button.setAttribute('data-year', weekDate.getFullYear());
                    button.setAttribute('data-month', weekDate.getMonth());
                    button.setAttribute('data-day', day);

                    if (!isCurrentMonth) {
                        // Date is outside current month - gray it out but still allow clicking
                        button.className += ' text-gray-400';
                    } else if (isToday) {
                        button.className += ' border-2 border-gray-900 text-gray-900 font-semibold hover:bg-gray-100';
                    } else if (hasAvailability) {
                        // Dark purple if booked, light purple if available
                        if (hasBooked) {
                            button.className += ' bg-purple-600 text-white font-semibold hover:bg-purple-700';
                        } else {
                            button.className += ' bg-purple-100 text-purple-800 font-semibold hover:bg-purple-300';
                        }
                    } else {
                        button.className += ' border border-gray-200 text-gray-700 hover:bg-gray-50';
                    }

                    // Allow clicking on all dates in week view
                    button.setAttribute('onclick', 'selectDate(' + weekDate.getFullYear() + ',' + weekDate.getMonth() + ',' + day + ')');
                    calendarGrid.appendChild(button);
                }
            }

            // Update navigation buttons state after rendering
            updateNavButtons();
        }
        
        function selectDate(year, month, day) {
            selectedDate = new Date(year, month, day);
            pendingSlots = {};
            updateSlotSelectionBar();

            const buttons = document.querySelectorAll('#calendarGrid button');
            buttons.forEach(btn => {
                const btnDay = parseInt(btn.textContent);
                const btnYear = parseInt(btn.getAttribute('data-year'));
                const btnMonth = parseInt(btn.getAttribute('data-month'));
                const dateStr = btnYear + '-' + String(btnMonth + 1).padStart(2, '0') + '-' + String(btnDay).padStart(2, '0');
                const hasAvailability = availabilityMap[dateStr] && Object.keys(availabilityMap[dateStr]).length > 0;
                const hasBooked = hasBookedSlots(dateStr);
                const isToday = btnDay === today && btnMonth === new Date().getMonth() && btnYear === new Date().getFullYear();

                // Preserve button sizing based on view mode — use same square sizing for week and month
                const baseClass = 'aspect-square rounded-lg text-sm font-medium transition-all';
                btn.className = baseClass;

                if (btnDay === day && btnMonth === month && btnYear === year) {
                    // Selected date - use dark purple regardless of booking status
                    btn.className += ' bg-purple-600 text-white font-semibold';
                } else if (isToday) {
                    btn.className += ' border-2 border-gray-900 text-gray-900 font-semibold hover:bg-gray-100';
                } else if (hasAvailability) {
                    // Dark purple if booked, light purple if available
                    if (hasBooked) {
                        btn.className += ' bg-purple-600 text-white font-semibold hover:bg-purple-700';
                    } else {
                        btn.className += ' bg-purple-100 text-purple-800 font-semibold hover:bg-purple-300';
                    }
                } else {
                    btn.className += ' border border-gray-200 text-gray-700 hover:bg-gray-50';
                }
            });

            const dayName = dayNames[selectedDate.getDay()];
            const dateStr = dayName + ', ' + monthNames[month] + ' ' + day + ', ' + year;
            document.getElementById('selectedDateDisplay').textContent = dateStr;

            generateTimeSlots();
            updateCompletedCancelledDisplay();
        }
        
        function generateTimeSlots() {
            const container = document.getElementById('timeSlotsContainer');
            if (!container) {
                console.error('timeSlotsContainer not found');
                return;
            }
            
            container.innerHTML = '';
            emptySlotRegistry = [];
            
            const startHour = 8;
            const endHour = 22; // extended to 22 => 10:00 pm
            const interval = 15;
            
            // Format selected date as YYYY-MM-DD for comparison
            const year = selectedDate.getFullYear();
            const month = String(selectedDate.getMonth() + 1).padStart(2, '0');
            const day = String(selectedDate.getDate()).padStart(2, '0');
            const selectedDateStr = year + '-' + month + '-' + day;
            
            console.log('=== Generating Time Slots ===');
            console.log('Selected date:', selectedDateStr);
            console.log('Availability map for this date:', availabilityMap[selectedDateStr]);
            console.log('Total availability slots:', availabilitySlots.length);
            
            for (let hour = startHour; hour < endHour; hour++) {
                for (let minute = 0; minute < 60; minute += interval) {
                    const startTime = formatTime(hour, minute);
                    const endMinute = minute + interval;
                    const nextHour = endMinute >= 60 ? hour + 1 : hour;
                    const nextMin = endMinute >= 60 ? endMinute - 60 : endMinute;
                    const endTime = formatTime(nextHour, nextMin);
                    
                    // Check if this slot is already available using availabilityMap
                    // Use 24-hour format for lookup (HH:MM) to match stored format
                    const startTime24 = formatTime24(hour, minute);
                    const mapEntry = availabilityMap[selectedDateStr] ? availabilityMap[selectedDateStr][startTime24] : null;
                    const scheduleId = getScheduleId(mapEntry);  // Handles both old string and new object format
                    const isAvailable = !!mapEntry;
                    const bookingStatus = (mapEntry && typeof mapEntry === 'object') ? mapEntry.bookingStatus : null;
                    
                    if (isAvailable) {
                        console.log('Found slot:', selectedDateStr, startTime24, '-', endTime);
                        console.log('  scheduleId from map:', scheduleId, 'bookingStatus:', bookingStatus, 'type:', typeof mapEntry);
                    }
                    
                    const slotDiv = document.createElement('div');
                    
                    if (isAvailable) {
                        const isBooked = !!bookingStatus;
                        slotDiv.className = 'slot-filled' + (isBooked ? ' booked' : '');
                        const textColor = isBooked ? 'text-white' : 'text-gray-900';
                        const statusLabel = isBooked ? bookingStatus : 'Available';
                        slotDiv.innerHTML = '<div class="flex items-start justify-between">' +
                            '<div class="flex-1">' +
                                '<div class="flex items-center flex-wrap gap-2 mb-1">' +
                                    '<span class="font-bold ' + textColor + '">' + startTime + ' - ' + endTime + '</span>' +
                                    '<span class="slot-badge">15 min</span>' +
                                    '<span class="slot-status">' + statusLabel + '</span>' +
                                '</div>' +
                                '<p class="text-sm ' + textColor + '">Quran Recitation & Tajweed</p>' +
                            '</div>' +
                            '<div class="flex items-center space-x-2 ml-3">' +
                                '<button type="button" onclick="viewAvailabilityDetails(\'' + scheduleId + '\', \'' + selectedDateStr + '\', \'' + startTime + '\', \'' + endTime + '\')" class="p-1.5 hover:bg-white/20 rounded-lg transition-colors" title="View Details">' +
                                    '<i class="fas fa-eye ' + (isBooked ? 'text-white' : 'text-blue-600') + '"></i>' +
                                '</button>' +
                                '<button type="button" onclick="openDeleteAvailabilityModal(\'' + scheduleId + '\', \'' + selectedDateStr + '\', \'' + startTime + '\', \'' + endTime + '\')" class="p-1.5 hover:bg-white/20 rounded-lg transition-colors" title="Delete">' +
                                    '<i class="fas fa-trash ' + (isBooked ? 'text-white' : 'text-red-600') + '"></i>' +
                                '</button>' +
                            '</div>' +
                        '</div>';
                    } else {
                        const allowAdd = canAddAvailability(selectedDate);
                        if (allowAdd) {
                            const isSelected = !!pendingSlots[startTime24];
                            slotDiv.className = 'slot-empty' + (isSelected ? ' selected' : '');
                            slotDiv.innerHTML = '<div class="flex items-center justify-between">' +
                                '<div class="flex items-center flex-wrap gap-2">' +
                                    '<span class="font-bold text-gray-700">' + startTime + ' - ' + endTime + '</span>' +
                                    '<span class="slot-badge">15 min</span>' +
                                '</div>' +
                                '<span class="text-sm font-medium ' + (isSelected ? 'text-purple-700' : 'text-gray-500') + '">' +
                                    (isSelected ? 'Selected' : 'Click to select') +
                                '</span>' +
                            '</div>';
                            slotDiv.onclick = function() {
                                toggleSlotSelection(startTime24, startTime, endTime, slotDiv);
                            };
                            emptySlotRegistry.push({
                                startTime24: startTime24,
                                startTime: startTime,
                                endTime: endTime,
                                element: slotDiv
                            });
                        } else {
                            slotDiv.className = 'slot-disabled';
                            slotDiv.innerHTML = '<div class="flex items-center justify-between">' +
                                '<div class="flex items-center flex-wrap gap-2">' +
                                    '<span class="font-bold">' + startTime + ' - ' + endTime + '</span>' +
                                    '<span class="slot-badge">15 min</span>' +
                                '</div>' +
                                '<span class="text-sm font-medium">Past slot</span>' +
                            '</div>';
                        }
                    }
                    
                    container.appendChild(slotDiv);
                }
            }
            
            console.log('Time slots generated successfully');
            updateSlotSelectionBar();
        }
        
        function teacherSetAvailability(date, startTime, endTime) {
            console.log('teacherSetAvailability called with:', { date, startTime, endTime });
            
            if (!date) {
                alert('Please select a date from the calendar first.');
                return;
            }
            
            // Ensure date is a proper Date object
            let dateObj = date;
            if (!(date instanceof Date)) {
                console.warn('Date is not a Date object, attempting to convert:', date);
                dateObj = new Date(date);
            }
            
            // Check if date is valid
            if (isNaN(dateObj.getTime())) {
                console.error('Invalid Date object:', dateObj);
                alert('Invalid date. Please select a date from the calendar first.');
                return;
            }
            
            // Store the actual Date object and time values
            selectedDate = dateObj;
            selectedStartTime = startTime;
            selectedEndTime = endTime;
            
            // Format date for display (human-readable)
            const dayName = dayNames[dateObj.getDay()];
            const dateStr = dayName + ', ' + monthNames[dateObj.getMonth()] + ' ' + dateObj.getDate() + ', ' + dateObj.getFullYear();
            
            // Format date for database (YYYY-MM-DD) - Extract components individually
            const year = dateObj.getFullYear();
            const monthNum = dateObj.getMonth() + 1;
            const dayNum = dateObj.getDate();
            
            console.log('Date components:', { year, monthNum, dayNum });
            
            // Validate that we got valid numbers
            if (!year || isNaN(year) || !monthNum || isNaN(monthNum) || !dayNum || isNaN(dayNum)) {
                console.error('Invalid date components:', { year, monthNum, dayNum, dateObj });
                alert('Error: Could not extract valid date components. Please try selecting the date again.');
                return;
            }
            
            // Format with proper padding
            const month = String(monthNum).padStart(2, '0');
            const day = String(dayNum).padStart(2, '0');
            const rawDate = year + '-' + month + '-' + day;
            
            console.log('Formatted date:', { year, month, day, rawDate });
            
            // Final validation of the formatted date
            if (!rawDate || rawDate.includes('undefined') || rawDate.includes('NaN') || rawDate.length !== 10) {
                console.error('Invalid formatted date:', rawDate);
                alert('Error: Date formatting failed. Please try again.');
                return;
            }
            
            // Set display values
            document.getElementById('modalDate').value = dateStr;
            document.getElementById('modalTimeSlot').value = startTime + ' - ' + endTime + ' (15 min)';
            document.getElementById('modalNotes').value = '';
            
            // Store raw values in data attributes
            document.getElementById('modalDate').setAttribute('data-raw-date', rawDate);
            document.getElementById('modalTimeSlot').setAttribute('data-start-time', startTime);
            document.getElementById('modalTimeSlot').setAttribute('data-end-time', endTime);
            
            console.log('Modal data set successfully:', { rawDate, startTime, endTime });
            
            document.getElementById('availabilityModal').classList.add('active');
        }
        
        function closeModal() {
            document.getElementById('availabilityModal').classList.remove('active');
        }
        
        // View Availability Details Function
        function viewAvailabilityDetails(scheduleId, date, startTime, endTime) {
            console.log('=== viewAvailabilityDetails called ===');
            console.log('scheduleId:', scheduleId);
            console.log('date:', date);
            console.log('startTime:', startTime);
            console.log('endTime:', endTime);
            
            // Format date for display
            const dateObj = new Date(date);
            const dayName = dayNames[dateObj.getDay()];
            const monthName = monthNames[dateObj.getMonth()];
            const day = dateObj.getDate();
            const year = dateObj.getFullYear();
            const dateStr = dayName + ', ' + monthName + ' ' + day + ', ' + year;
            
            // Populate modal with availability details
            document.getElementById('viewAvailabilityDate').textContent = dateStr;
            document.getElementById('viewAvailabilityTime').textContent = startTime + ' - ' + endTime;
            document.getElementById('viewAvailabilityId').textContent = scheduleId;
            
            // Show modal
            document.getElementById('viewAvailabilityModal').classList.add('active');
        }
        
        function closeViewAvailabilityModal() {
            document.getElementById('viewAvailabilityModal').classList.remove('active');
        }
        
        // Delete Availability Functions
        function openDeleteAvailabilityModal(scheduleId, date, startTime, endTime) {
            console.log('=== openDeleteAvailabilityModal called ===');
            console.log('scheduleId parameter:', scheduleId, 'type:', typeof scheduleId);
            console.log('date:', date);
            console.log('startTime:', startTime);
            console.log('endTime:', endTime);
            
            // Format date for display
            const dateObj = new Date(date);
            const dayName = dayNames[dateObj.getDay()];
            const monthName = monthNames[dateObj.getMonth()];
            const day = dateObj.getDate();
            const year = dateObj.getFullYear();
            const dateStr = dayName + ', ' + monthName + ' ' + day + ', ' + year;
            
            document.getElementById('deleteTimeSlot').textContent = startTime + ' - ' + endTime;
            document.getElementById('deleteDate').textContent = dateStr;
            document.getElementById('deleteScheduleId').value = scheduleId;
            
            console.log('Set deleteScheduleId input value to:', scheduleId);
            console.log('Verify deleteScheduleId input value:', document.getElementById('deleteScheduleId').value);
            
            document.getElementById('deleteAvailabilityModal').classList.add('active');
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteAvailabilityModal').classList.remove('active');
        }
        
        function confirmDeleteAvailability() {
    const scheduleId = document.getElementById('deleteScheduleId').value;

    console.log('Submitting delete - scheduleId:', scheduleId);

    // Validate scheduleId
    if (!scheduleId || scheduleId.trim() === '') {
        alert('Schedule ID is empty. Please refresh the page and try again.');
        return;
    }

    const url = '<%= request.getContextPath() %>/teacher/classschedule?action=deleteAvailability&scheduleId=' + encodeURIComponent(scheduleId);
    console.log('Sending request to:', url);

    // Perform fetch
    fetch(url, {
        method: 'POST'
    })
    .then(res => {
        console.log('Delete response status:', res.status);
        console.log('Delete response content-type:', res.headers.get('content-type'));
        
        if (!res.ok) {
            throw new Error('HTTP error ' + res.status);
        }
        
        const contentType = res.headers.get('content-type');
        if (!contentType || !contentType.includes('application/json')) {
            return res.text().then(text => {
                console.error('Expected JSON, got HTML:', text.substring(0, 500));
                throw new Error('Server returned HTML instead of JSON. Check server logs.');
            });
        }
        
        return res.json();
    })
    .then(data => {
        console.log('Delete response data:', data);
        if (data.success) {
            alert('Availability deleted successfully!');
            closeDeleteModal();
            location.reload();
        } else {
            alert(data.message || 'Failed to delete availability');
        }
    })
    .catch(err => {
        console.error('Error:', err);
        alert('Failed to delete availability. Please try again.');
    });
}

        function showClassDetails(button) {
            const dataset = button.dataset;
            selectedClassData = {
                studentName: dataset.studentName,
                studentId: dataset.studentId,
                className: dataset.className,
                duration: dataset.duration,
                scheduleDate: dataset.scheduleDate,
                startTime: dataset.startTime,
                endTime: dataset.endTime,
                scheduleId: dataset.scheduleId
            };
            
            const names = selectedClassData.studentName.split(' ');
            const initials = names.map(n => n.charAt(0)).join('').toUpperCase().substring(0, 2);
            
            document.getElementById('modalStudentInitials').textContent = initials;
            document.getElementById('modalStudentName').textContent = selectedClassData.studentName;
            document.getElementById('modalStudentId').textContent = 'Student ID: ' + selectedClassData.studentId;
            document.getElementById('modalClassName').textContent = selectedClassData.className;
            document.getElementById('modalDuration').textContent = selectedClassData.duration + ' min';
            document.getElementById('modalDetailsDate').textContent = selectedClassData.scheduleDate;
            document.getElementById('modalDetailsTime').textContent = selectedClassData.startTime + ' - ' + selectedClassData.endTime;
            
            document.getElementById('classDetailsModal').classList.add('active');
        }
        
        function closeClassDetails() {
            document.getElementById('classDetailsModal').classList.remove('active');
        }
        

        

        
        const CANCEL_MIN_HOURS = 12;
        const CANCEL_TOO_LATE_MSG = 'Classes cannot be cancelled less than 12 hours before the start time.';

        function canCancelByPolicy(isoDate, time24) {
            if (!isoDate || !time24) return false;
            const normalized = time24.length === 5 ? time24 + ':00' : time24;
            const classStart = new Date(isoDate + 'T' + normalized);
            if (isNaN(classStart.getTime())) return false;
            const hoursUntil = (classStart.getTime() - Date.now()) / (1000 * 60 * 60);
            return hoursUntil >= CANCEL_MIN_HOURS;
        }

        function updateTeacherCancelButtons() {
            document.querySelectorAll('.cancel-class-btn').forEach(function(btn) {
                const allowed = canCancelByPolicy(btn.dataset.scheduleIso, btn.dataset.startTime);
                btn.disabled = !allowed;
                if (!allowed) {
                    btn.classList.add('opacity-50', 'cursor-not-allowed');
                    btn.title = CANCEL_TOO_LATE_MSG;
                } else {
                    btn.classList.remove('opacity-50', 'cursor-not-allowed');
                    btn.title = '';
                }
            });
        }

        function showCancelClass(button) {
            const dataset = button.dataset;
            if (!canCancelByPolicy(dataset.scheduleIso, dataset.startTime)) {
                alert(CANCEL_TOO_LATE_MSG);
                return;
            }
            selectedClassData = {
                studentName: dataset.studentName,
                scheduleDate: dataset.scheduleDate,
                scheduleIso: dataset.scheduleIso,
                startTime: dataset.startTime,
                endTime: dataset.endTime,
                scheduleId: dataset.scheduleId,
                bookingId: dataset.bookingId
            };
            
            document.getElementById('cancelStudentName').textContent = selectedClassData.studentName;
            document.getElementById('cancelClassDate').textContent = selectedClassData.scheduleDate;
            document.getElementById('cancelClassTime').textContent = selectedClassData.startTime + ' - ' + selectedClassData.endTime;
            
            document.getElementById('cancelClassModal').classList.add('active');
        }
        
        function closeCancelClass() {
            document.getElementById('cancelClassModal').classList.remove('active');
            document.getElementById('cancellationReason').value = '';
        }
        
        function confirmCancelClass() {
            const reason = document.getElementById('cancellationReason').value.trim();
            if (!reason) {
                alert('Please provide a cancellation reason.');
                return;
            }
            if (selectedClassData && !canCancelByPolicy(selectedClassData.scheduleIso, selectedClassData.startTime)) {
                alert(CANCEL_TOO_LATE_MSG);
                return;
            }
            
            // Send cancellation request to backend with action in URL
            const url = '<%= request.getContextPath() %>/teacher/classschedule?action=cancelClass';
            const formData = new FormData();
            formData.append('scheduleId', selectedClassData.scheduleId);
            formData.append('bookingId', selectedClassData.bookingId);
            formData.append('cancellationReason', reason);
            
            fetch(url, {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Class has been cancelled successfully.\n\nThe student will be notified.');
                    closeCancelClass();
                    // Reload page to refresh the lists
                    window.location.reload();
                } else {
                    alert('Error: ' + (data.message || 'Failed to cancel class'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to cancel class. Please try again.');
            });
        }
        
function submitAvailability() {
    const modalDateInput = document.getElementById('modalDate');
    const modalTimeInput = document.getElementById('modalTimeSlot');

    let dateStr = modalDateInput.getAttribute('data-raw-date');
    let startTimeFormatted = modalTimeInput.getAttribute('data-start-time');
    let endTimeFormatted = modalTimeInput.getAttribute('data-end-time');

    if (!dateStr && selectedDate) {
        dateStr = getSelectedDateStr();
    }

    if (!dateStr || dateStr.includes('--') || dateStr === 'NaN-NaN-NaN') {
        const displayText = modalDateInput.value;
        try {
            const dateObj = new Date(displayText);
            if (!isNaN(dateObj.getTime())) {
                dateStr = dateObj.getFullYear() + '-' +
                    String(dateObj.getMonth() + 1).padStart(2, '0') + '-' +
                    String(dateObj.getDate()).padStart(2, '0');
            } else {
                throw new Error('Invalid date');
            }
        } catch (e) {
            alert("Could not determine date. Please select a date from the calendar again.");
            return;
        }
    }

    if (startTimeFormatted) startTimeFormatted = to24(startTimeFormatted);
    if (endTimeFormatted) endTimeFormatted = to24(endTimeFormatted);
    if (!startTimeFormatted && selectedStartTime) startTimeFormatted = to24(selectedStartTime);
    if (!endTimeFormatted && selectedEndTime) endTimeFormatted = to24(selectedEndTime);

    if (!startTimeFormatted || !endTimeFormatted) {
        const timeDisplay = modalTimeInput.value;
        const timeMatch = timeDisplay.match(/(\d{1,2}:\d{2}\s*(?:am|pm)?)\s*-\s*(\d{1,2}:\d{2}\s*(?:am|pm)?)/i);
        if (timeMatch) {
            startTimeFormatted = to24(timeMatch[1]);
            endTimeFormatted = to24(timeMatch[2]);
        } else {
            alert("Could not determine time slot. Please select a time slot again.");
            return;
        }
    }

    if (!dateStr || !startTimeFormatted || !endTimeFormatted) {
        alert("Please select a date and time slot.");
        return;
    }

    if (!dateStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
        alert("Invalid date format. Please select a valid date from the calendar.");
        return;
    }

    postAvailabilitySlot(dateStr, startTimeFormatted, endTimeFormatted)
    .then(function(data) {
        if (data.success) {
            alert("Availability added successfully!");
            const startTimeShort = to24(startTimeFormatted).substring(0, 5);
            const endTimeShort = to24(endTimeFormatted).substring(0, 5);
            availabilitySlots.push({
                date: dateStr,
                startTime: startTimeShort,
                endTime: endTimeShort,
                bookingStatus: null
            });
            if (!availabilityMap[dateStr]) availabilityMap[dateStr] = {};
            availabilityMap[dateStr][startTimeShort] = {
                scheduleId: data.scheduleId || 'C000',
                bookingStatus: null
            };
            closeModal();
            initCalendar();
            if (selectedDate) {
                selectDate(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate());
            }
        } else {
            alert(data.message || "Failed to add availability");
        }
    })
    .catch(function(err) {
        console.error("Error:", err);
        alert(err.message || "Failed to add availability. Please try again.");
    });
}
</script>

<!-- Completed Class Details Modal -->
<div id="completedClassModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 transform transition-all">
        <div class="p-6">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-gray-900">Class Details</h3>
                <button onclick="closeCompletedModal()" class="text-gray-400 hover:text-gray-600 transition">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>

            <div class="space-y-4">
                <!-- Student Info -->
                <div class="flex items-center space-x-4 mb-6">
                    <div id="completed-avatar" class="w-16 h-16 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center text-white font-bold text-xl">
                        OA
                    </div>
                    <div>
                        <h4 id="completed-student-name" class="font-bold text-gray-900 text-lg">Omar Abdullah</h4>
                        <p id="completed-student-id" class="text-gray-600 text-sm">Student ID: S-105</p>
                    </div>
                </div>

                <!-- Class Type -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Class Type</p>
                    <p id="completed-class-type" class="font-semibold text-gray-800">Quran Recitation & Tajweed</p>
                </div>

                <!-- Duration -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Duration</p>
                    <p id="completed-duration" class="font-semibold text-gray-800">15 min</p>
                </div>

                <!-- Date -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Date</p>
                    <p id="completed-date" class="font-semibold text-gray-800">Monday, December 30, 2024</p>
                </div>

                <!-- Time -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Time</p>
                    <p id="completed-time" class="font-semibold text-gray-800">11:00 - 11:15</p>
                </div>

                <!-- Status -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Status</p>
                    <span class="inline-block px-3 py-1 bg-green-100 text-green-700 text-sm font-semibold rounded-full">Completed</span>
                </div>
            </div>

            <!-- Close Button -->
            <div class="mt-8">
                <button onclick="closeCompletedModal()" class="w-full py-3 bg-gradient-to-r from-purple-500 to-pink-400 text-white rounded-xl font-semibold hover:from-purple-600 hover:to-pink-500 transition">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Cancelled Class Details Modal -->
<div id="cancelledClassModal" class="modal fixed inset-0 bg-black bg-opacity-50 items-center justify-center z-50">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 transform transition-all">
        <div class="p-6">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-gray-900">Class Details</h3>
                <button onclick="closeCancelledModal()" class="text-gray-400 hover:text-gray-600 transition">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>

            <div class="space-y-4">
                <!-- Student Info -->
                <div class="flex items-center space-x-4 mb-6">
                    <div id="cancelled-avatar" class="w-16 h-16 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center text-white font-bold text-xl">
                        OA
                    </div>
                    <div>
                        <h4 id="cancelled-student-name" class="font-bold text-gray-900 text-lg">Omar Abdullah</h4>
                        <p id="cancelled-student-id" class="text-gray-600 text-sm">Student ID: S-105</p>
                    </div>
                </div>

                <!-- Class Type -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Class Type</p>
                    <p id="cancelled-class-type" class="font-semibold text-gray-800">Quran Recitation & Tajweed</p>
                </div>

                <!-- Duration -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Duration</p>
                    <p id="cancelled-duration" class="font-semibold text-gray-800">15 min</p>
                </div>

                <!-- Date -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Date</p>
                    <p id="cancelled-date" class="font-semibold text-gray-800">Monday, December 30, 2024</p>
                </div>

                <!-- Time -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Time</p>
                    <p id="cancelled-time" class="font-semibold text-gray-800">11:00 - 11:15</p>
                </div>

                <!-- Status -->
                <div>
                    <p class="text-sm text-gray-500 mb-1">Status</p>
                    <span class="inline-block px-3 py-1 bg-red-100 text-red-700 text-sm font-semibold rounded-full">Cancelled</span>
                </div>

                <!-- Notes (if any) -->
                <div id="cancelled-notes-section" style="display: none;">
                    <p class="text-sm text-gray-500 mb-1">Notes</p>
                    <p id="cancelled-notes" class="text-gray-800"></p>
                </div>

                <!-- Cancellation Reason -->
                <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                    <p class="text-sm text-gray-700 mb-1 font-semibold">Cancellation Reason</p>
                    <p id="cancelled-reason" class="text-red-700 font-medium">Personal emergency</p>
                </div>
            </div>

            <!-- Close Button -->
            <div class="mt-8">
                <button onclick="closeCancelledModal()" class="w-full py-3 bg-gradient-to-r from-purple-500 to-pink-400 text-white rounded-xl font-semibold hover:from-purple-600 hover:to-pink-500 transition">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    // View Completed Class Details
        function viewCompletedClassDetails(scheduleId) {
            fetch('<%= request.getContextPath() %>/teacher/class-details?scheduleId=' + scheduleId)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.details) {
                        const details = data.details;

                        // Populate modal with data
                        document.getElementById('completed-avatar').textContent = details.studentInitials || '?';
                        document.getElementById('completed-student-name').textContent = details.studentName || 'Unknown Student';
                        document.getElementById('completed-student-id').textContent = 'Student ID: ' + (details.studentId || 'N/A');
                        document.getElementById('completed-class-type').textContent = details.className || 'N/A';
                        document.getElementById('completed-duration').textContent = (details.duration ? details.duration + ' min' : 'N/A');
                        document.getElementById('completed-date').textContent = details.scheduleDate || 'N/A';
                        document.getElementById('completed-time').textContent = (details.startTime && details.endTime) ? details.startTime + ' - ' + details.endTime : 'N/A';

                        // Show modal
                        document.getElementById('completedClassModal').classList.add('active');
                    } else {
                        alert('Failed to load details: ' + (data.error || 'Unknown error'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to load class details. Please try again.');
                });
        }

    // View Cancelled Class Details
    function viewCancelledClassDetails(scheduleId) {
        fetch('<%= request.getContextPath() %>/teacher/class-details?scheduleId=' + scheduleId)
            .then(response => response.json())
            .then(data => {
                if (!data.success || !data.details) {
                    alert('Failed to load details: ' + (data.error || 'Unknown error'));
                    return;
                }

                const details = data.details;

                // Populate modal with data
                document.getElementById('cancelled-avatar').textContent = details.studentInitials || '?';
                document.getElementById('cancelled-student-name').textContent = details.studentName || 'Unknown Student';
                document.getElementById('cancelled-student-id').textContent = 'Student ID: ' + (details.studentId || 'N/A');
                document.getElementById('cancelled-class-type').textContent = details.className || 'N/A';
                document.getElementById('cancelled-duration').textContent = (details.duration ? details.duration + ' min' : 'N/A');

                // Use the already formatted date from servlet
                document.getElementById('cancelled-date').textContent = details.scheduleDate || 'N/A';

                // Format time using startTime and endTime from servlet
                const startTime = details.startTime || 'N/A';
                const endTime = details.endTime || 'N/A';
                document.getElementById('cancelled-time').textContent = startTime + ' - ' + endTime;

                // Hide notes section (not used for cancelled classes)
                document.getElementById('cancelled-notes-section').style.display = 'none';

                // Show cancellation reason
                document.getElementById('cancelled-reason').textContent = details.cancellationReason || 'No reason provided';

                // Show modal
                document.getElementById('cancelledClassModal').classList.add('active');
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to load class details. Please try again.');
            });
    }

    // Close modals
    function closeCompletedModal() {
        document.getElementById('completedClassModal').classList.remove('active');
    }

    function closeCancelledModal() {
        document.getElementById('cancelledClassModal').classList.remove('active');
    }

    // Close modal when clicking outside
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('completedClassModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeCompletedModal();
            }
        });

        document.getElementById('cancelledClassModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeCancelledModal();
            }
        });
    });
</script>

<script>
        document.getElementById('classDetailsModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeClassDetails();
            }
        });
        
        document.getElementById('cancelClassModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeCancelClass();
            }
        });
        
        document.getElementById('availabilityModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });

        document.getElementById('bulkConfirmModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeBulkConfirmModal();
            }
        });
        
        document.getElementById('viewAvailabilityModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeViewAvailabilityModal();
            }
        });
        
        document.getElementById('deleteAvailabilityModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeDeleteModal();
            }
        });
        
        window.onload = function() {
            initCalendar();
            updateCompletedCancelledDisplay();
            updateTeacherCancelButtons();
            selectDate(currentYear, currentMonth, today);
        };
    </script>
</body>
</html>