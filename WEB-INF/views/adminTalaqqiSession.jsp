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
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }
    </style>
    <script src="<%= request.getContextPath() %>/js/admin-talaqqi-sessions.js"></script>
</head>
<body class="bg-gray-50">
    <div class="flex h-screen overflow-hidden">
        
        <!-- SIDEBAR -->
        <aside class="w-64 bg-gradient-to-b from-purple-600 via-purple-500 to-purple-700 text-white flex flex-col fixed h-full shadow-xl">
            <!-- Brand -->
            <div class="p-6 border-b border-white border-opacity-20">
                <h1 class="text-2xl font-bold">TalaqqiHub</h1>
                <p class="text-sm text-purple-100 opacity-90">Admin Portal</p>
            </div>

            <!-- Navigation -->
            <nav class="flex-1 py-4 overflow-y-auto">
                <a href="<%= request.getContextPath() %>/admin/dashboard" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-home w-5 mr-3"></i>
                    <span class="text-sm font-medium">Dashboard</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/class-schedule" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-calendar w-5 mr-3"></i>
                    <span class="text-sm font-medium">Class Schedule</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/packages" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-chart-bar w-5 mr-3"></i>
                    <span class="text-sm font-medium">Attendance Analytics</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/talaqqi-sessions" class="flex items-center px-6 py-3 bg-white bg-opacity-20 border-l-4 border-white">
                    <i class="fas fa-book-quran w-5 mr-3"></i>
                    <span class="text-sm font-medium">Talaqqi Session</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-star w-5 mr-3"></i>
                    <span class="text-sm font-medium">Evaluation Analytics</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-bell w-5 mr-3"></i>
                    <span class="text-sm font-medium">Announcements</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-bolt w-5 mr-3"></i>
                    <span class="text-sm font-medium">AI Assistance</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-students" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-users w-5 mr-3"></i>
                    <span class="text-sm font-medium">Manage Students</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-teachers" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <i class="fas fa-chalkboard-user w-5 mr-3"></i>
                    <span class="text-sm font-medium">Manage Teachers</span>
                </a>
            </nav>

            <!-- Logout -->
            <div class="p-6 border-t border-white border-opacity-20">
                <a href="<%= request.getContextPath() %>/admin/logout" class="flex items-center px-3 py-2 hover:bg-white hover:bg-opacity-10 rounded transition">
                    <i class="fas fa-sign-out-alt w-5 mr-3"></i>
                    <span class="text-sm font-medium">Logout</span>
                </a>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="flex-1 ml-64 overflow-y-auto">
            
            <!-- HEADER -->
            <header class="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10">
                <div class="flex items-center justify-between px-8 py-4">
                    <h1 class="text-2xl font-bold text-gray-800">Talaqqi Sessions</h1>
                    <div class="flex items-center space-x-6">
                        <!-- Notification Bell -->
                        <div class="relative">
                            <button class="text-gray-400 hover:text-gray-600">
                                <i class="fas fa-bell text-xl"></i>
                                <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">5</span>
                            </button>
                        </div>

                        <!-- Profile -->
                        <div class="flex items-center space-x-3 cursor-pointer">
                            <div class="w-10 h-10 bg-purple-400 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                                AM
                            </div>
                            <div>
                                <p class="text-sm font-semibold text-gray-800">Admin Manager</p>
                                <p class="text-xs text-gray-500">Administrator</p>
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- CONTENT -->
            <div class="p-8">
                
                <!-- TITLE SECTION -->
                <div class="mb-8">
                    <h2 class="text-3xl font-bold text-gray-900 mb-2">Talaqqi Session Management</h2>
                    <p class="text-gray-600">Monitor completed Talaqqi sessions across the TalaqqiHub platform</p>
                </div>

                <!-- STATS CARDS -->
                <div class="grid grid-cols-3 gap-6 mb-8">
                    <!-- Card 1: Total Completed Sessions -->
                    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                <i class="fas fa-check-circle text-purple-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900">${completedSessionsCount}</h3>
                        <p class="text-sm font-semibold text-gray-600 mt-1">Total Completed Sessions</p>
                        <p class="text-xs text-gray-500">All time completions</p>
                    </div>

                    <!-- Card 2: Total Active Teachers -->
                    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                <i class="fas fa-users text-purple-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900">${activeTeachersCount}</h3>
                        <p class="text-sm font-semibold text-gray-600 mt-1">Total Active Teachers</p>
                        <p class="text-xs text-gray-500">Currently teaching</p>
                    </div>

                    <!-- Card 3: Total Active Students -->
                    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                <i class="fas fa-book-reader text-purple-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900">${activeStudentsCount}</h3>
                        <p class="text-sm font-semibold text-gray-600 mt-1">Total Active Students</p>
                        <p class="text-xs text-gray-500">Currently enrolled</p>
                    </div>
                </div>

                <!-- SESSIONS TABLE SECTION -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-100">
                    
                    <!-- Section Header with Filters -->
                    <div class="p-6 border-b border-gray-200">
                        <h3 class="text-xl font-bold text-gray-900 mb-6">Completed Talaqqi Sessions</h3>

                        <!-- Filter Section -->
                        <div class="grid grid-cols-5 gap-4 mb-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
                                <input type="text" placeholder="Search student or teacher..."
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Teacher</label>
                                <select class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500">
                                    <option>All Teachers</option>
                                    <c:forEach var="teacher" items="${teachers}">
                                        <option><c:out value="${teacher}" /></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Date From</label>
                                <input type="date" 
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Date To</label>
                                <input type="date" 
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500">
                            </div>
                            <div class="flex flex-col">
                                <label class="block text-sm font-medium text-gray-700 mb-2">&nbsp;</label>
                                <button class="bg-gradient-to-r from-purple-500 to-purple-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:opacity-90 transition flex items-center justify-center gap-2">
                                    <i class="fas fa-file-pdf"></i>
                                    Export PDF
                                </button>
                            </div>
                        </div>

                        <!-- Additional Buttons -->
                        <div class="flex justify-end gap-3">
                            <button class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                                CSV
                            </button>
                            <button class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                                Excel
                            </button>
                            <button class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition flex items-center gap-2">
                                <i class="fas fa-print"></i>
                                Print
                            </button>
                        </div>
                    </div>

                    <!-- Table -->
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b border-gray-200 bg-gray-50">
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Session ID</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Student Name</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Teacher Name</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Class Type</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Session Date</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Time</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Duration</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Status</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Completed At</th>
                                    <th class="text-left py-4 px-6 font-semibold text-gray-700">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty sessions}">
                                        <c:forEach var="s" items="${sessions}">
                                            <tr class="border-b border-gray-100 hover:bg-gray-50 transition">
                                                <td class="py-4 px-6 text-gray-900 font-medium"><c:out value="${s['sessionId']}" /></td>
                                                <td class="py-4 px-6 text-gray-700"><c:out value="${s['studentName']}" /></td>
                                                <td class="py-4 px-6 text-gray-700"><c:out value="${s['teacherName']}" /></td>
                                                <td class="py-4 px-6 text-gray-700"><c:out value="${s['classType']}" /></td>
                                                <td class="py-4 px-6 text-gray-700">
                                                    <fmt:formatDate value="${s['sessionDate']}" pattern="MMM dd, yyyy" />
                                                </td>
                                                <td class="py-4 px-6 text-gray-700">
                                                    <c:out value="${s['timeStart']}" /> - <c:out value="${s['timeEnd']}" />
                                                </td>
                                                <td class="py-4 px-6 text-gray-700">
                                                    <c:out value="${s['duration']}" /> minutes
                                                </td>
                                                <td class="py-4 px-6">
                                                    <span class="inline-block bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold">
                                                        <c:out value="${s['status']}" />
                                                    </span>
                                                </td>
                                                <td class="py-4 px-6 text-gray-700">
                                                    <fmt:formatDate value="${s['completedAt']}" pattern="MMM dd, yyyy hh:mm a" />
                                                </td>
                                                <td class="py-4 px-6">
                                                    <a href="?viewId=${s['sessionId']}" class="bg-purple-500 text-white px-4 py-1 rounded-full text-xs font-semibold hover:bg-purple-600 transition inline-block">
                                                        View
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="10" class="py-8 text-center text-gray-500">
                                                No sessions found
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Info -->
                    <div class="px-6 py-4 border-t border-gray-200 text-sm text-gray-600">
                        <c:choose>
                            <c:when test="${not empty sessions}">
                                Showing 1-<c:out value="${fn:length(sessions)}" /> of <c:out value="${fn:length(sessions)}" /> sessions
                            </c:when>
                            <c:otherwise>
                                No sessions available
                            </c:otherwise>
                        </c:choose>
                    </div>

                </div>

            </div>

        </main>

    </div>

    <!-- MODAL: Talaqqi Session Details -->
    <c:if test="${not empty selectedSession}">
        <div class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
            <div class="bg-white rounded-2xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto p-6 mx-4">
                
                <!-- Modal Header -->
                <div class="flex items-center justify-between mb-6">
                    <h2 class="text-2xl font-bold text-gray-900">Talaqqi Session Details</h2>
                    <button onclick="closeModal()" class="text-gray-400 hover:text-gray-600 transition" type="button">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                    </button>
                </div>

                <!-- Session Information -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <div class="flex items-start justify-between">
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-1">Session ID</p>
                            <p class="text-lg font-semibold text-gray-900"><c:out value="${selectedSession['sessionId']}" /></p>
                        </div>
                        <span class="inline-block bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold">
                            <c:out value="${selectedSession['status']}" />
                        </span>
                    </div>
                </div>

                <!-- Participants -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">Participants</h3>
                    <div class="grid grid-cols-2 gap-6">
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-1">Student Name</p>
                            <p class="text-gray-800"><c:out value="${selectedSession['studentName']}" /></p>
                        </div>
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-1">Teacher Name</p>
                            <p class="text-gray-800"><c:out value="${selectedSession['teacherName']}" /></p>
                        </div>
                    </div>
                </div>

                <!-- Schedule Details -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">Schedule Details</h3>
                    <div class="grid grid-cols-2 gap-6">
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-2">Session Date</p>
                            <p class="text-gray-800 mb-4"><fmt:formatDate value="${selectedSession['sessionDate']}" pattern="MMM dd, yyyy" /></p>
                            <p class="text-xs font-semibold text-gray-500 mb-2">Duration</p>
                            <p class="text-gray-800"><c:out value="${selectedSession['duration']}" /> minutes</p>
                        </div>
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-2">Time</p>
                            <p class="text-gray-800 mb-4"><c:out value="${selectedSession['timeStart']}" /> - <c:out value="${selectedSession['timeEnd']}" /></p>
                            <p class="text-xs font-semibold text-gray-500 mb-2">Attendance Status</p>
                            <p class="inline-block bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold">
                                <c:out value="${selectedSession['attendanceStatus']}" />
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Quran Coverage -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">Quran Coverage</h3>
                    <div class="grid grid-cols-2 gap-6">
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-1">Surah</p>
                            <p class="text-gray-800">
                                <c:choose>
                                    <c:when test="${selectedSession['surahNumber'] > 0}">
                                        <c:out value="${selectedSession['surahName']}" />
                                    </c:when>
                                    <c:otherwise>
                                        Not Set
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div>
                            <p class="text-xs font-semibold text-gray-500 mb-1">Ayah</p>
                            <p class="text-gray-800">
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
                                    <c:otherwise>
                                        Not Set
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Completion Details -->
                <div class="mb-8 pb-6 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">Completion Details</h3>
                    <p class="text-xs font-semibold text-gray-500 mb-1">Session Completed At</p>
                    <p class="text-gray-800"><fmt:formatDate value="${selectedSession['completedAt']}" pattern="MMM dd, yyyy hh:mm a" /></p>
                </div>

                <!-- Modal Footer -->
                <div class="text-center">
                    <button onclick="closeModal()" class="inline-block px-6 py-2 border border-gray-300 rounded-full text-sm font-semibold text-gray-700 hover:bg-gray-100 transition" type="button">
                        Close
                    </button>
                </div>

            </div>
        </div>
    </c:if>

</body>
</html>
