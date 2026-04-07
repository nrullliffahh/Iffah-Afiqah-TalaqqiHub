<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Booking - TalaqqiHub</title>
    
                            <script src="https://cdn.tailwindcss.com"></script>
    
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/colors.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/animations.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css">
</head>
<body class="bg-gray-50">
    <!-- Debug banner (temporary) - shown only when ?debug=1 is present -->
    <c:if test="${param.debug == '1'}">
        <div id="debugBanner" style="position:fixed;top:8px;right:8px;z-index:60;padding:8px;border-radius:6px;background:#fee2e2;color:#991b1b;font-size:12px;box-shadow:0 2px 6px rgba(0,0,0,0.08)">Debug: session.studentId=${sessionScope.studentId} selectedDate=${selectedDate}</div>
    </c:if>
    <div class="flex min-h-screen">
        <aside class="w-64 fixed h-screen" style="background: linear-gradient(180deg, #2d5f4f 0%, #1a3d30 100%);">
            <div class="p-6">
                <h1 class="text-2xl font-bold text-white">TalaqqiHub</h1>
                <p class="text-sm text-green-200">Student Portal</p>
            </div>
            
            <nav class="mt-6">
                <a href="<%= request.getContextPath() %>/student/dashboard" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/student/class-booking" class="flex items-center px-6 py-3 text-white bg-green-800 bg-opacity-50">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    Class Booking
                </a>
                <a href="<%= request.getContextPath() %>/student/attendance" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    Attendance
                </a>
                <a href="<%= request.getContextPath() %>/student/sessions" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    Talaqqi Sessions
                </a>
                <a href="<%= request.getContextPath() %>/student/evaluation" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                    Evaluation
                </a>
                <a href="<%= request.getContextPath() %>/student/announcements" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z" />
                    </svg>
                    Announcements
                </a>
                <a href="<%= request.getContextPath() %>/student/ai-assistance" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                    </svg>
                    AI Assistance
                </a>
            </nav>
            
            <div class="absolute bottom-0 w-64 p-6">
                <a href="<%= request.getContextPath() %>/student/logout" class="flex items-center px-4 py-2 text-green-200 hover:bg-red-600 hover:text-white rounded-lg transition-colors">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                    </svg>
                    Logout
                </a>
            </div>
        </aside>
        
        <main class="flex-1 ml-64">
            <header class="bg-white shadow-sm sticky top-0 z-10">
                <div class="flex items-center justify-between px-8 py-4">
                    <h2 class="text-2xl font-bold text-gray-800">Class Booking</h2>
                    
                    <div class="flex items-center space-x-4">
                        <!-- Notifications -->
                        <div class="relative">
                            <button id="notificationBtn" class="relative p-2 text-gray-600 hover:bg-gray-100 rounded-lg" onclick="openNotificationMenu()">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                            </svg>
                                <span id="notificationBadge" class="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-purple-600 rounded-full" style="display:none">0</span>
                            </button>

                            <div id="notificationMenu" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg py-2 z-50">
                                <div id="notificationItems" class="max-h-64 overflow-y-auto"></div>
                                <div class="border-t p-2 text-center text-sm"><a href="<%= request.getContextPath() %>/student/announcements" class="text-purple-600">View all</a></div>
                            </div>
                        </div>
                        
                        <!-- Profile Dropdown -->
                        <!-- Export / Print -->
                        <div class="relative">
                            <button id="exportBtn" onclick="document.getElementById('exportMenu').classList.toggle('hidden')" class="px-4 py-2 bg-teal-400 text-white rounded-lg flex items-center space-x-2 hover:opacity-95">
                                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v12m0 0l-4-4m4 4l4-4M21 21H3" />
                                </svg>
                                <span>Export</span>
                            </button>
                            <div id="exportMenu" class="hidden absolute right-0 mt-2 w-44 bg-white rounded-lg shadow-lg py-2 z-40">
                                <button onclick="exportAsPDF()" class="w-full text-left px-4 py-2 hover:bg-gray-50">Export as PDF</button>
                                <button onclick="exportAsCSV()" class="w-full text-left px-4 py-2 hover:bg-gray-50">Export as CSV</button>
                                <button onclick="exportAsExcel()" class="w-full text-left px-4 py-2 hover:bg-gray-50">Export as Excel</button>
                            </div>
                        </div>

                        <button id="printBtn" onclick="printPage()" class="px-4 py-2 border-2 border-gray-200 bg-white text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-50">
                            Print
                        </button>
                        <div class="relative">
                            <button class="flex items-center space-x-2 focus:outline-none" onclick="document.getElementById('profileDropdown').classList.toggle('hidden')">
                                <%
                                    String initials = "";
                                    String name = null;
                                    Object rn = request.getAttribute("studentName");
                                    if (rn != null) name = rn.toString();
                                    if ((name == null || name.trim().isEmpty()) && session.getAttribute("studentName") != null) {
                                        name = (String) session.getAttribute("studentName");
                                    }
                                    if ((name == null || name.trim().isEmpty()) && session.getAttribute("student") != null) {
                                        model.Student s = (model.Student) session.getAttribute("student");
                                        if (s != null) {
                                            if (s.getFullName() != null && !s.getFullName().trim().isEmpty()) name = s.getFullName();
                                            else if (s.getStudentName() != null && !s.getStudentName().trim().isEmpty()) name = s.getStudentName();
                                        }
                                    }
                                    if (name != null && !name.trim().isEmpty()) {
                                        String[] parts = name.trim().split("\\s+");
                                        StringBuilder sb = new StringBuilder();
                                        for (String p : parts) {
                                            if (p.length() > 0) sb.append(Character.toUpperCase(p.charAt(0)));
                                            if (sb.length() >= 2) break;
                                        }
                                        initials = sb.toString();
                                    }
                                    if (initials.length() == 0) initials = "U";
                                %>
                                <div class="w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold" style="background: var(--gradient-feature-green);">
                                    <%= initials %>
                                </div>
                                <span class="font-medium text-gray-700">${studentName}</span>
                                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>
                            
                            <div id="profileDropdown" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-20">
                                <a href="<%= request.getContextPath() %>/student/profile" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100">
                                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                    View Profile
                                </a>
                                <a href="<%= request.getContextPath() %>/student/edit-profile" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100">
                                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                    </svg>
                                    Edit Profile
                                </a>
                                <a href="<%= request.getContextPath() %>/student/change-password" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100">
                                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
                                    </svg>
                                    Change Password
                                </a>
                                <hr class="my-2">
                                <a href="<%= request.getContextPath() %>/student/logout" class="flex items-center px-4 py-2 text-red-600 hover:bg-red-50">
                                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                                    </svg>
                                    Logout
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </header>
            
            <div class="p-8">
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                        ${sessionScope.successMessage}
                    </div>
                    <c:remove var="successMessage" scope="session" />
                </c:if>
                
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                        ${sessionScope.errorMessage}
                    </div>
                    <c:remove var="errorMessage" scope="session" />
                </c:if>
                
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">Class Booking</h1>
                    <p class="text-gray-600">Book your one-to-one Quran Recitation & Tajweed sessions</p>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl p-6 shadow-sm border border-gray-200">
                        <div class="w-14 h-14 rounded-full bg-gray-200 flex items-center justify-center mb-4">
                            <svg class="w-7 h-7 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <p class="text-sm text-gray-600 mb-1">Total Sessions</p>
                        <h3 class="text-4xl font-bold text-gray-800 mb-1">${summary.totalSessions}</h3>
                        <p class="text-xs text-gray-500">Per month</p>
                    </div>
                    
                    <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl p-6 shadow-sm border border-blue-200">
                        <div class="w-14 h-14 rounded-full bg-blue-200 flex items-center justify-center mb-4">
                            <svg class="w-7 h-7 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <p class="text-sm text-blue-700 mb-1">Used Sessions</p>
                        <h3 class="text-4xl font-bold text-blue-600 mb-1">${summary.usedSessions}</h3>
                        <p class="text-xs text-blue-500">Completed this month</p>
                    </div>
                    
                    <div class="bg-gradient-to-br from-orange-50 to-orange-100 rounded-2xl p-6 shadow-sm border border-orange-200">
                        <div class="w-14 h-14 rounded-full bg-orange-200 flex items-center justify-center mb-4">
                            <svg class="w-7 h-7 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <p class="text-sm text-orange-700 mb-1">Remaining Sessions</p>
                        <h3 class="text-4xl font-bold text-orange-600 mb-1">${summary.remainingSessions}</h3>
                        <p class="text-xs text-orange-500">Available to book</p>
                    </div>
                </div>
                
                <div class="bg-white rounded-2xl p-6 shadow-sm mb-8 border border-gray-200">
                    <div class="flex items-center justify-between mb-3">
                        <span class="text-sm font-semibold text-gray-700">Monthly Progress</span>
                        <span class="text-sm font-bold text-teal-600">${summary.usedSessions} / ${summary.totalSessions} (${summary.progressPercentage}%)</span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
                        <div class="h-4 rounded-full bg-gradient-to-r from-teal-400 to-teal-600 transition-all duration-300" style="width: ${summary.progressPercentage}%;"></div>
                    </div>
                    <p class="text-xs text-gray-500 mt-2">${summary.remainingSessions} sessions remaining • Resets on 1st of next month</p>
                </div>
                
                <div class="bg-white rounded-2xl p-6 shadow-sm mb-8 border border-gray-200">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Book Your Session</h3>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- LEFT: Calendar -->
                        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                            <h4 class="text-lg font-semibold text-gray-900 mb-4">Select Date</h4>

                            <!-- View Filters -->
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center space-x-2">
                                    <button id="monthViewBtn" class="px-3 py-1 text-sm font-medium text-green-600 bg-green-100 rounded-lg hover:bg-green-200 transition">
                                        Month View
                                    </button>
                                    <button id="weekViewBtn" class="px-3 py-1 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition">
                                        Week View
                                    </button>
                                </div>
                                <div class="text-sm text-gray-500">15 min slots</div>
                            </div>

                            <!-- Month/Week Display with Navigation -->
                            <div class="flex items-center justify-between mb-4">
                                <button id="prevBtn" class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition">&lt;</button>
                                <span id="currentMonth" class="text-base font-semibold text-gray-900"></span>
                                <button id="nextBtn" class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition">&gt;</button>
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
                                    <div class="w-4 h-4 bg-green-200 rounded"></div>
                                    <span class="text-gray-600">Available to Book</span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <div class="w-4 h-4 bg-green-600 rounded"></div>
                                    <span class="text-gray-600">Booked</span>
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
                            <p id="selectedDateDisplay" class="text-sm text-gray-500 mb-4">Please select a date</p>

                            <!-- Time Slots Container -->
                            <div id="timeSlotsContainer" class="space-y-3 max-h-[500px] overflow-y-auto pr-2">
                                <div class="text-center text-gray-400 py-12">
                                    <i class="far fa-calendar-alt text-5xl mb-3"></i>
                                    <p class="text-sm">Select a date to view available time slots</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script>
                        // Enhanced calendar renderer for student booking
                        (function(){
                            let selectedDate = null;
                            let selectedStartTime = null;
                            let selectedEndTime = null;
                            let selectedClassData = null;
                            let currentViewMode = 'month'; // 'month' or 'week'
                            let currentWeekStart = null;
                            // When in week mode, confine navigation to this month/year
                            let weekModeMonth = null;
                            let weekModeYear = null;
                            let weekStartDate = null; // Sunday start for week view

                            const currentDate = new Date();
                            // Server/current real month/year (students can book in current and future months)
                            const serverMonth = currentDate.getMonth();
                            const serverYear = currentDate.getFullYear();
                            let currentYear = currentDate.getFullYear();
                            let currentMonth = currentDate.getMonth();
                            const today = currentDate.getDate();

                            const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                                               'July', 'August', 'September', 'October', 'November', 'December'];

                            const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

                            // Store available schedules from server
                            let availableSchedules = [];

                            const calendarGrid = document.getElementById('calendarGrid');
                            const currentMonthElement = document.getElementById('currentMonth');
                            const prevBtn = document.getElementById('prevBtn');
                            const nextBtn = document.getElementById('nextBtn');
                            const monthViewBtn = document.getElementById('monthViewBtn');
                            const weekViewBtn = document.getElementById('weekViewBtn');
                            const selectedDateDisplay = document.getElementById('selectedDateDisplay');
                            const timeSlotsContainer = document.getElementById('timeSlotsContainer');

                            // Initialize view variables
                            let viewYear = currentYear;
                            let viewMonth = currentMonth;

                            // If server provided selectedDate, use it to set view.
                            // Also fall back to a persisted selection in localStorage so
                            // refreshes restore the highlighted date and time slots.
                            const serverDate = '${selectedDate}';
                            if (serverDate && serverDate !== '') {
                                const parts = serverDate.split('-');
                                if (parts.length === 3) {
                                    viewYear = parseInt(parts[0], 10) || viewYear;
                                    viewMonth = (parseInt(parts[1], 10) - 1) || viewMonth;
                                }
                            }

                            // initial persisted selection (server or localStorage)
                            const initialDateValue = (serverDate && serverDate !== '') ? serverDate : (localStorage.getItem('selectedDate') || '');

                            // If there is an initial selected date, set it now so selection
                            // persists across renders and async availability updates.
                            if (initialDateValue && initialDateValue !== '') {
                                try {
                                    const partsInit = initialDateValue.split('-');
                                    if (partsInit.length === 3) {
                                        const yy = parseInt(partsInit[0], 10);
                                        const mm = parseInt(partsInit[1], 10) - 1;
                                        const dd = parseInt(partsInit[2], 10);
                                        selectedDate = new Date(yy, mm, dd);
                                    }
                                } catch (e) { /* ignore parse errors */ }
                            }

                            // Update navigation (prev/next) button enabled state
                            function updateNavButtons() {
                                // Month view does not use prev/next
                                if (currentViewMode === 'month') {
                                    prevBtn.disabled = true;
                                    nextBtn.disabled = true;
                                    return;
                                }
                                // Week view: only allow prev/next if the target week still intersects the current view month
                                if (currentViewMode === 'week') {
                                    if (!weekStartDate) {
                                        prevBtn.disabled = true;
                                        nextBtn.disabled = true;
                                        return;
                                    }
                                    const candidatePrev = new Date(weekStartDate);
                                    candidatePrev.setDate(candidatePrev.getDate() - 7);
                                    const candidatePrevEnd = new Date(candidatePrev);
                                    candidatePrevEnd.setDate(candidatePrevEnd.getDate() + 6);
                                    prevBtn.disabled = !(candidatePrev.getMonth() === viewMonth || candidatePrevEnd.getMonth() === viewMonth);

                                    const candidateNext = new Date(weekStartDate);
                                    candidateNext.setDate(candidateNext.getDate() + 7);
                                    const candidateNextEnd = new Date(candidateNext);
                                    candidateNextEnd.setDate(candidateNextEnd.getDate() + 6);
                                    nextBtn.disabled = !(candidateNext.getMonth() === viewMonth || candidateNextEnd.getMonth() === viewMonth);
                                    return;
                                }
                                // Fallback: disable when no weekStartDate is available
                                if (!weekStartDate) {
                                    prevBtn.disabled = true;
                                    nextBtn.disabled = true;
                                    return;
                                }
                            }


                            // Select a date: highlight button, set display, fetch slots
                            function selectDate(year, month, day) {
                                selectedDate = new Date(year, month, day);

                                // Debugging aid: log selection
                                try { console.log('[calendar] selectDate', year, month, day); } catch(e){}

                                const buttons = calendarGrid.querySelectorAll('button');
                                buttons.forEach(btn => {
                                    const btnDay = parseInt(btn.textContent, 10);
                                    const btnYear = parseInt(btn.getAttribute('data-year'), 10);
                                    const btnMonth = parseInt(btn.getAttribute('data-month'), 10);
                                    // remember markers
                                    const hadAvail = btn.classList.contains('avail-date');
                                    const hadBooked = btn.classList.contains('booked-date');

                                    // remove only selection-specific classes so availability/booked markers stay
                                    btn.classList.remove('selected-date','bg-green-600','text-white','border-2','border-green-600','ring-2','ring-green-600','font-semibold');

                                    // ensure base classes exist (don't remove avail/booked)
                                    const baseClasses = ['aspect-square','rounded-lg','text-sm','font-medium','transition-all','cal-day','border','border-gray-200','hover:border-teal-400'];
                                    baseClasses.forEach(c => { if (!btn.classList.contains(c)) btn.classList.add(c); });

                                    const isToday = (btnDay === currentDate.getDate() && btnMonth === currentDate.getMonth() && btnYear === currentDate.getFullYear());

                                    if (btnDay === day && btnMonth === month && btnYear === year) {
                                        // Selected cell: try to preserve booked/avail look and add a visible selection ring/border
                                        if (hadBooked) {
                                            btn.classList.add('booked-date','selected-date','ring-2','ring-green-600');
                                        } else if (hadAvail) {
                                            btn.classList.add('avail-date','selected-date','ring-2','ring-green-600','border-2','border-green-600');
                                        } else {
                                            // no prior marker: apply solid selected style
                                            btn.classList.add('bg-green-600','text-white','font-semibold','border-2','border-green-600','selected-date');
                                        }
                                    } else if (isToday) {
                                        // Today's cell: ensure today's styling remains
                                        btn.classList.add('border-2','border-gray-900','text-gray-700','font-semibold');
                                    } else {
                                        // Non-selected, non-today: reapply markers if they existed
                                        if (hadBooked) {
                                            btn.classList.add('bg-green-600','text-white','font-semibold','booked-date');
                                        } else if (hadAvail) {
                                            btn.classList.add('bg-green-200','text-green-800','font-semibold','avail-date');
                                        }
                                    }
                                });

                                const dayName = dayNames[selectedDate.getDay()];
                                const dateStr = dayName + ', ' + monthNames[month] + ' ' + day + ', ' + year;
                                selectedDateDisplay.textContent = dateStr;

                                const iso = year + '-' + String(month + 1).padStart(2, '0') + '-' + String(day).padStart(2, '0');
                                try { console.log('[calendar] fetching slots for', iso); fetchAvailableSlots(iso); } catch(e) { console.error('fetchAvailableSlots error', e); }
                                try { localStorage.setItem('selectedDate', iso); } catch(e) {/*ignore*/}
                            }

                            // Next week navigation (restricted to the current view month)
                            nextBtn.addEventListener('click', function(){
                                if (currentViewMode === 'month') return;
                                if (!weekStartDate) return;
                                const candidate = new Date(weekStartDate);
                                candidate.setDate(candidate.getDate() + 7);
                                const candidateEnd = new Date(candidate);
                                candidateEnd.setDate(candidateEnd.getDate() + 6);
                                // Only allow if the candidate week still intersects the viewMonth
                                if (candidate.getMonth() === viewMonth || candidateEnd.getMonth() === viewMonth) {
                                    weekStartDate = candidate;
                                    render();
                                    updateNavButtons();
                                    // re-apply availability markers for the view
                                    try { fetchMonthlyAvailability(viewYear, viewMonth); } catch(e){/*ignore*/}
                                }
                            });

                            // Previous week navigation (restricted to the current view month)
                            prevBtn.addEventListener('click', function(){
                                if (currentViewMode === 'month') return;
                                if (!weekStartDate) return;
                                const candidate = new Date(weekStartDate);
                                candidate.setDate(candidate.getDate() - 7);
                                const candidateEnd = new Date(candidate);
                                candidateEnd.setDate(candidateEnd.getDate() + 6);
                                if (candidate.getMonth() === viewMonth || candidateEnd.getMonth() === viewMonth) {
                                    weekStartDate = candidate;
                                    render();
                                    updateNavButtons();
                                    try { fetchMonthlyAvailability(viewYear, viewMonth); } catch(e){/*ignore*/}
                                }
                            });

                            // Set up view mode buttons
                            monthViewBtn.addEventListener('click', function(){
                                currentViewMode = 'month';
                                monthViewBtn.className = 'px-3 py-1 text-sm font-medium text-green-600 bg-green-100 rounded-lg hover:bg-green-200 transition';
                                weekViewBtn.className = 'px-3 py-1 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition';
                                // lock month view to the current month
                                viewYear = currentYear;
                                viewMonth = currentMonth;
                                weekStartDate = null;
                                render();
                                updateNavButtons();
                                // re-apply availability markings for the month view
                                try { fetchMonthlyAvailability(viewYear, viewMonth); } catch(e){/*ignore*/}
                            });

                            weekViewBtn.addEventListener('click', function(){
                                currentViewMode = 'week';
                                weekViewBtn.className = 'px-3 py-1 text-sm font-medium text-green-600 bg-green-100 rounded-lg hover:bg-green-200 transition';
                                monthViewBtn.className = 'px-3 py-1 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition';
                                // initialize weekStartDate to the Sunday of the week that contains the 1st of the month
                                const firstOfMonth = new Date(viewYear, viewMonth, 1);
                                const sunday = new Date(firstOfMonth);
                                sunday.setDate(firstOfMonth.getDate() - firstOfMonth.getDay());
                                weekStartDate = sunday;
                                render();
                                updateNavButtons();
                                // ensure availability markers are applied for the week rendering
                                try { fetchMonthlyAvailability(viewYear, viewMonth); } catch(e){/*ignore*/}
                            });

                            // global JS error handler (show in debug banner)
                            window.addEventListener('error', function(e){
                                try{
                                    const dbg = document.getElementById('debugBanner');
                                    if (dbg) dbg.textContent = 'JS Error: ' + (e && (e.message || e.error) || 'unknown');
                                }catch(ignore){}
                                console.error('Captured error', e);
                            });

                            // initial render (guarded)
                            try{
                                render();
                                // fetch availability markers for the displayed month
                                fetchMonthlyAvailability(viewYear, viewMonth);
                            }catch(err){
                                const dbg = document.getElementById('debugBanner');
                                if (dbg) dbg.textContent = 'Init error: ' + (err && err.message ? err.message : String(err));
                                console.error('Error during calendar init', err);
                            }

                            // Expose a small API for other page elements to open calendar for rescheduling
                            window.talaqqi = window.talaqqi || {};
                            window.talaqqi.openReschedule = function(bookingId, dateStr) {
                                try { localStorage.setItem('rescheduleBookingId', bookingId || ''); } catch(e){}
                                try { window.talaqqi.pendingReschedule = bookingId || ''; } catch(e){}
                                try { if (calendarGrid) calendarGrid.dataset.pendingReschedule = bookingId || ''; } catch(e){}
                                // Do NOT auto-select a specific day here — user should pick the new date first.
                                // If a dateStr is provided, we can jump the calendar to that month for convenience,
                                // but we will not set `selectedDate` so the student must pick a date.
                                if (dateStr) {
                                    try {
                                        const parts = dateStr.split('-');
                                        if (parts.length === 3) {
                                            viewYear = parseInt(parts[0],10) || viewYear;
                                            viewMonth = (parseInt(parts[1],10) - 1) || viewMonth;
                                        }
                                    } catch(e) { /* ignore parse errors */ }
                                }
                                currentViewMode = 'month';
                                render();
                                try { fetchMonthlyAvailability(viewYear, viewMonth); } catch(e){}
                                // scroll to calendar
                                try { document.getElementById('calendarGrid').scrollIntoView({behavior:'smooth', block:'center'}); } catch(e){}
                            };
                            function render() {
                                calendarGrid.innerHTML = '';
                                const first = new Date(viewYear, viewMonth, 1);
                                currentMonthElement.textContent = first.toLocaleString(undefined, { month: 'long', year: 'numeric' });
                                if (currentViewMode === 'week') {
                                    // render a single week (Sunday - Saturday) starting from weekStartDate
                                    renderWeek();
                                    return;
                                }

                                const last = new Date(viewYear, viewMonth + 1, 0);
                                // start blanks for month view
                                const startDay = first.getDay();
                                for (let i=0;i<startDay;i++) {
                                    const d = document.createElement('div');
                                    d.className = '';
                                    calendarGrid.appendChild(d);
                                }

                                for (let d=1; d<= last.getDate(); d++) {
                                    const cell = document.createElement('button');
                                    cell.type = 'button';
                                    cell.className = 'aspect-square rounded-lg text-sm font-medium transition-all cal-day border border-gray-200 hover:border-teal-400';
                                    cell.textContent = d;
                                    const y = viewYear;
                                    const m = viewMonth; // zero-based month stored here
                                    const day = ('0' + d).slice(-2);
                                    const iso = y + '-' + ('0' + (m+1)).slice(-2) + '-' + day;

                                    // expose year/month on the button for availability marking
                                    cell.setAttribute('data-year', String(y));
                                    cell.setAttribute('data-month', String(m));

                                    // highlight today by default (grey border) even without clicking
                                    const cellDate = new Date(viewYear, viewMonth, d);
                                    if (cellDate.getFullYear() === currentDate.getFullYear() && cellDate.getMonth() === currentDate.getMonth() && cellDate.getDate() === currentDate.getDate()) {
                                        // Today's cell: stronger black border
                                        cell.classList.remove('border-gray-200');
                                        cell.classList.add('border-2','border-gray-900','text-gray-700','font-semibold');
                                    }
                                    // If this date matches the currently selected date, apply selected styling immediately
                                    if (selectedDate instanceof Date && selectedDate.getFullYear() === cellDate.getFullYear() && selectedDate.getMonth() === cellDate.getMonth() && selectedDate.getDate() === cellDate.getDate()) {
                                        cell.classList.remove('border-gray-200');
                                        cell.classList.add('bg-green-600','text-white','font-semibold','border-2','border-green-600','selected-date');
                                    }

                                    cell.addEventListener('click', function(){
                                        // select date and fetch slots via AJAX
                                        // pass zero-based month (m is already zero-based)
                                        selectDate(y, m, d);
                                    });
                                    calendarGrid.appendChild(cell);
                                }
                                // restore selection if current selectedDate is within this month view
                                if (selectedDate) {
                                    if (selectedDate.getFullYear() === viewYear && selectedDate.getMonth() === viewMonth) {
                                        selectDate(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate());
                                    }
                                }
                                updateNavButtons();
                            }

                            // Confirm modal helpers
                            window.openConfirmModal = function(data){
                                try {
                                    document.getElementById('confirmTeacher').textContent = data.teacherName || '';
                                    document.getElementById('confirmDate').textContent = data.dateDisplay || data.bookingDate || '';
                                    document.getElementById('confirmTime').textContent = data.bookingTime || '';
                                    document.getElementById('confirm_scheduleId').value = data.scheduleId || '';
                                    document.getElementById('confirm_bookingDate').value = data.bookingDate || '';
                                    document.getElementById('confirm_bookingTime').value = data.bookingTime || '';
                                    document.getElementById('confirm_teacherId').value = data.teacherId || '';
                                    // prefer explicit value passed in `data`, then pendingReschedule, then dataset, then localStorage
                                    var rs = (data && data.rescheduleBookingId) || (window.talaqqi && window.talaqqi.pendingReschedule) || (calendarGrid && calendarGrid.dataset && calendarGrid.dataset.pendingReschedule) || localStorage.getItem('rescheduleBookingId');
                                    document.getElementById('confirm_rescheduleBookingId').value = rs && rs !== 'null' ? rs : '';
                                    document.getElementById('confirmModal').classList.remove('hidden');
                                    // ensure the calendar dataset is not cleared until submit
                                    try { if (calendarGrid && (!calendarGrid.dataset.pendingReschedule || calendarGrid.dataset.pendingReschedule === '')) { /* nothing */ } } catch(e){}
                                } catch(e){ console.error('openConfirmModal error', e); }
                            }
                            window.closeConfirmModal = function(){
                                try{ document.getElementById('confirmModal').classList.add('hidden'); }catch(e){}
                            }

                            // Delegate book button clicks to open confirm modal
                            document.addEventListener('click', function(e){
                                const btn = e.target.closest && e.target.closest('.book-now');
                                if (!btn) return;
                                e.preventDefault();
                                const scheduleId = btn.getAttribute('data-scheduleid');
                                const bookingDate = btn.getAttribute('data-bookingdate');
                                const bookingTime = btn.getAttribute('data-bookingtime');
                                const teacherId = btn.getAttribute('data-teacherid');
                                const teacherName = btn.getAttribute('data-teachername');
                                const d = new Date();
                                try { d.setTime(Date.parse(bookingDate + 'T00:00:00')); } catch(e){}
                                const dateDisplay = (isNaN(d.getTime()) ? bookingDate : d.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }));

                                // Ensure any pending reschedule id is propagated into storage and dataset
                                var rs = (window.talaqqi && window.talaqqi.pendingReschedule) || (calendarGrid && calendarGrid.dataset && calendarGrid.dataset.pendingReschedule) || localStorage.getItem('rescheduleBookingId') || '';
                                try { if (rs && rs !== 'null') { localStorage.setItem('rescheduleBookingId', rs); if (window.talaqqi) window.talaqqi.pendingReschedule = rs; if (calendarGrid) calendarGrid.dataset.pendingReschedule = rs; } } catch(e){}

                                // Pass the reschedule id explicitly to the modal so it's always set
                                openConfirmModal({ scheduleId: scheduleId, bookingDate: bookingDate, bookingTime: bookingTime, teacherId: teacherId, teacherName: teacherName, dateDisplay: dateDisplay, rescheduleBookingId: rs });
                            });

                            // When confirm form submits, clear pending/localStorage reschedule after a short delay (allow normal form submit)
                            (function(){
                                const frm = document.getElementById('confirmBookingForm');
                                if (frm && typeof frm.addEventListener === 'function') {
                                    frm.addEventListener('submit', function(){
                                        try {
                                            var rsEl = document.getElementById('confirm_rescheduleBookingId');
                                            var rsVal = rsEl ? rsEl.value : '';
                                            console.log('[reschedule] submitting rescheduleBookingId=', rsVal);
                                            // clear after logging so the server receives the value
                                            localStorage.removeItem('rescheduleBookingId');
                                            if (window.talaqqi) window.talaqqi.pendingReschedule = null;
                                            if (calendarGrid) delete calendarGrid.dataset.pendingReschedule;
                                        } catch(e){}
                                    });
                                } else {
                                    // Fallback: delegate submit event on document for when the form is added later
                                    document.addEventListener('submit', function(ev){
                                        try {
                                            const t = ev.target || ev.srcElement;
                                            if (t && t.id === 'confirmBookingForm') {
                                                try { localStorage.removeItem('rescheduleBookingId'); if (window.talaqqi) window.talaqqi.pendingReschedule = null; } catch(e){}
                                            }
                                        } catch(e){}
                                    }, true);
                                }
                            })();

                            function renderWeek() {
                                if (!weekStartDate) {
                                    // find first Sunday within the current month
                                    const s = new Date(viewYear, viewMonth, 1);
                                    while (s.getMonth() === viewMonth && s.getDay() !== 0) {
                                        s.setDate(s.getDate() + 1);
                                    }
                                    if (s.getMonth() !== viewMonth) {
                                        // fallback to the 1st of month
                                        weekStartDate = new Date(viewYear, viewMonth, 1);
                                    } else {
                                        weekStartDate = new Date(s.getFullYear(), s.getMonth(), s.getDate());
                                    }
                                }

                                calendarGrid.innerHTML = '';
                                for (let i = 0; i < 7; i++) {
                                    const d = new Date(weekStartDate);
                                    d.setDate(weekStartDate.getDate() + i);
                                    const cell = document.createElement('button');
                                    cell.type = 'button';
                                    cell.className = 'aspect-square rounded-lg text-sm font-medium transition-all cal-day border border-gray-200 hover:border-teal-400';
                                    cell.textContent = d.getDate();
                                    const y = d.getFullYear();
                                    const m = d.getMonth();
                                    const day = ('0' + d.getDate()).slice(-2);
                                    const iso = y + '-' + ('0' + (m+1)).slice(-2) + '-' + day;

                                    cell.setAttribute('data-year', String(y));
                                    cell.setAttribute('data-month', String(m));

                                    // highlight today
                                    if (d.getFullYear() === currentDate.getFullYear() && d.getMonth() === currentDate.getMonth() && d.getDate() === currentDate.getDate()) {
                                        cell.classList.remove('border-gray-200');
                                        cell.classList.add('border-2','border-gray-900','text-gray-700','font-semibold');
                                    }
                                    // If this week cell matches the currently selected date, apply selected styling immediately
                                    if (selectedDate instanceof Date && selectedDate.getFullYear() === d.getFullYear() && selectedDate.getMonth() === d.getMonth() && selectedDate.getDate() === d.getDate()) {
                                        cell.classList.remove('border-gray-200');
                                        cell.classList.add('bg-green-600','text-white','font-semibold','border-2','border-green-600','selected-date');
                                    }

                                    // dim days outside the current view month
                                    if (m !== viewMonth) {
                                        cell.classList.add('opacity-50');
                                    }

                                    cell.addEventListener('click', function(){
                                        selectDate(y, m, d.getDate());
                                    });
                                    calendarGrid.appendChild(cell);
                                }
                                // restore selection if selectedDate falls within this week
                                if (selectedDate && weekStartDate) {
                                    const weekStart = new Date(weekStartDate);
                                    const weekEnd = new Date(weekStartDate);
                                    weekEnd.setDate(weekEnd.getDate() + 6);
                                    if (selectedDate >= weekStart && selectedDate <= weekEnd) {
                                        selectDate(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate());
                                    } else {
                                        // clear slots if selected date is outside current week
                                        const container = document.getElementById('timeSlotsContainer');
                                        if (container) container.innerHTML = '<div class="text-center text-gray-400 py-12"><p class="text-sm">Select a date to view available time slots</p></div>';
                                        selectedDateDisplay.textContent = 'Please select a date';
                                    }
                                }
                                updateNavButtons();
                            }
                            function generateDefaultSlots(isoDate) {
                                const slots = [];
                                const startHour = 8;
                                const endHour = 22;
                                for (let h = startHour; h < endHour; h++) {
                                    for (let m = 0; m < 60; m += 15) {
                                        const hh = String(h).padStart(2, '0');
                                        const mm = String(m).padStart(2, '0');
                                        const startTime = hh + ':' + mm;
                                        const scheduleId = 'MANUAL-' + isoDate + '-' + hh + mm;
                                        slots.push({ scheduleId: scheduleId, startTime: startTime, duration: 15, teacherName: 'Click to add' });
                                    }
                                }
                                return slots;
                            }

                            function computeEndTime(start, duration) {
                                if (!start) return '';
                                const parts = start.split(':');
                                let hh = parseInt(parts[0], 10) || 0;
                                let mm = parseInt(parts[1], 10) || 0;
                                let dur = parseInt(duration, 10) || 15;
                                let total = hh * 60 + mm + dur;
                                let eh = Math.floor(total / 60) % 24;
                                let em = total % 60;
                                return String(eh).padStart(2, '0') + ':' + String(em).padStart(2, '0');
                            }

                            // Convert a time string like "15:00:00" or "15:00" to 12-hour format e.g. "3:00 pm"
                            function formatTo12Hour(timeStr) {
                                if (!timeStr) return '';
                                const parts = timeStr.split(':');
                                if (parts.length === 0) return timeStr;
                                let hh = parseInt(parts[0], 10) || 0;
                                let mm = parseInt(parts[1], 10) || 0;
                                let period = hh >= 12 ? 'pm' : 'am';
                                let h12 = hh % 12;
                                if (h12 === 0) h12 = 12;
                                const m = mm < 10 ? '0' + mm : '' + mm;
                                return h12 + ':' + m + ' ' + period;
                            }

                            // Embed student's bookings into JS for client-side slot marking
                            const myBookings = [
                                <c:forEach var="b" items="${myBookings}">
                                    { bookingId: '${b.bookingId}', bookingDate: '${b.bookingDate}', bookingTime: '${b.bookingTime}', bookingStatus: '${b.bookingStatus}', teacherName: '${b.teacherName}' },
                                </c:forEach>
                            ];

                            // current student id available from session
                            const currentStudentId = '${sessionScope.studentId}';

                            function renderSlots(list, isoDate) {
                                try { console.log('[calendar] renderSlots', isoDate, Array.isArray(list) ? list.length : typeof list); } catch(e){}
                                const ctx = '<%= request.getContextPath() %>';
                                const container = document.getElementById('timeSlotsContainer');
                                if (!container) return;
                                if (!Array.isArray(list) || list.length === 0) {
                                    container.innerHTML = '<div class="text-center py-8 text-gray-400"><p class="text-sm">No available time slots for this date</p></div>';
                                    return;
                                }

                                const html = list.map(function(s){
                                    // Ensure scheduleId exists
                                    const sched = s.scheduleId || ('MANUAL-' + isoDate + '-' + s.startTime.replace(':',''));
                                    const endTime = s.endTime && s.endTime !== '' ? s.endTime : computeEndTime(s.startTime, s.duration);
                                    const displayStart = formatTo12Hour(s.startTime);
                                    const displayEnd = formatTo12Hour(endTime);

                                    // If server indicates this slot is booked, render accordingly
                                    if (s.booked) {
                                        // If booked by current student, show View Details
                                        if (s.bookingStudentId && s.bookingStudentId === currentStudentId) {
                                            // Current student's booked slot: show neutral grey tile without action button
                                                    return '<div class="flex items-center justify-between p-4 rounded-lg bg-gray-100 text-gray-700">'
                                                + '<div>'
                                                            + '<p class="font-semibold">' + displayStart + ' - ' + displayEnd + ' <span class="text-sm opacity-80">(' + s.duration + ' min)</span></p>'
                                                    + '<p class="text-xs opacity-80">' + (s.teacherName || '') + '</p>'
                                                + '</div>'
                                                + '<div>'
                                                    + '<span class="px-4 py-2 bg-gray-400 text-white rounded-lg text-sm font-medium">Booked</span>'
                                                + '</div>'
                                            + '</div>';
                                        }

                                        // Booked by someone else: render as a visible, but fully non-interactive tile
                                        return '<div class="flex items-center justify-between p-4 rounded-lg bg-gray-100 text-gray-600 opacity-90" title="This slot is already booked" style="pointer-events:none;cursor:not-allowed;">'
                                            + '<div>'
                                                + '<p class="font-semibold opacity-80">' + displayStart + ' - ' + displayEnd + ' <span class="text-sm opacity-80">(' + s.duration + ' min)</span></p>'
                                                + '<p class="text-xs opacity-80">' + (s.teacherName || '') + '</p>'
                                            + '</div>'
                                            + '<div>'
                                                + '<span class="px-4 py-2 bg-gray-400 text-white rounded-lg text-sm font-medium">Booked</span>'
                                            + '</div>'
                                        + '</div>';
                                    }

                                    // Not booked: show booking action button which opens a confirmation modal
                                    return '<div class="flex items-center justify-between p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-teal-400 transition">'
                                        + '<div>'
                                            + '<p class="font-semibold text-gray-800">' + displayStart + ' - ' + displayEnd + ' <span class="text-sm text-gray-500">(' + s.duration + ' min)</span></p>'
                                            + '<p class="text-xs text-gray-500">' + (s.teacherName || '') + '</p>'
                                        + '</div>'
                                        + '<div class="inline">'
                                            + '<button type="button" class="px-4 py-2 bg-teal-500 text-white rounded-lg text-sm font-medium hover:bg-teal-600 book-now" '
                                                + 'data-scheduleid="' + sched + '" '
                                                + 'data-bookingdate="' + isoDate + '" '
                                                + 'data-bookingtime="' + s.startTime + '" '
                                                + 'data-teacherid="' + (s.teacherId || '') + '" '
                                                + 'data-teachername="' + (s.teacherName || '') + '">Book</button>'
                                        + '</div>'
                                    + '</div>';
                                }).join('');

                                container.innerHTML = html;
                            }

                            // Fetch available slots for a specific date from server
                            function fetchAvailableSlots(isoDate) {
                                const ctx = '<%= request.getContextPath() %>';
                                const url = ctx + '/student/api/available-schedules?selectedDate=' + encodeURIComponent(isoDate);
                                fetch(url, { credentials: 'same-origin' })
                                    .then(res => res.json())
                                    .then(list => {
                                        // Expecting an array of schedule objects; render them directly
                                        if (!Array.isArray(list)) {
                                            console.error('Invalid schedules response', list);
                                            renderSlots([], isoDate);
                                            return;
                                        }
                                        // Map server fields (including booking info)
                                        const mapped = list.map(s => ({
                                            scheduleId: s.scheduleId,
                                            startTime: s.startTime,
                                            endTime: s.endTime,
                                            duration: s.duration || 15,
                                            teacherName: s.teacherName || '',
                                            booked: s.booked === true || s.booked === 'true' || s.booked === '1',
                                            bookingId: s.bookingId || null,
                                            bookingStudentId: s.bookingStudentId || null,
                                            bookingStatus: s.bookingStatus || null
                                        }));
                                        renderSlots(mapped, isoDate);
                                    })
                                    .catch(err => {
                                        console.error('Error fetching available slots', err);
                                        renderSlots([], isoDate);
                                    });
                            }

                            function fetchMonthlyAvailability(year, monthIndex) {
                                const ctx = '<%= request.getContextPath() %>';
                                const month = (monthIndex + 1);

                                // 1) Fetch teacher availability dates (to indicate where teachers added slots)
                                const urlAvail = ctx + '/student/api/available-schedules?year=' + encodeURIComponent(year) + '&month=' + encodeURIComponent(month);
                                fetch(urlAvail, { credentials: 'same-origin' })
                                    .then(res => res.json())
                                    .then(list => {
                                        if (!Array.isArray(list) || list.length === 0) return;
                                        // mark buttons that match available dates
                                        list.forEach(dateStr => {
                                            const btns = document.querySelectorAll('#calendarGrid button');
                                            btns.forEach(b => {
                                                const y = b.getAttribute('data-year');
                                                const m = (parseInt(b.getAttribute('data-month'),10) + 1).toString().padStart(2,'0');
                                                const d = b.textContent.toString().padStart(2,'0');
                                                const iso = y + '-' + m + '-' + d;
                                                if (iso === dateStr) {
                                                    if (!b.classList.contains('booked-date')) {
                                                        b.classList.add('bg-green-200','text-green-800','font-semibold','avail-date');
                                                    }
                                                }
                                            });
                                        });
                                        // After applying availability markers, reapply the selected date highlight
                                        try { reapplySelectionFromInitial(); } catch(e) { /* ignore */ }
                                    })
                                    .catch(err => console.error('Error fetching monthly availability', err));

                                // 2) Fetch booked dates (students who already booked) and mark them more prominently
                                const urlBooked = ctx + '/student/api/available-schedules?year=' + encodeURIComponent(year) + '&month=' + encodeURIComponent(month) + '&mode=booked';
                                fetch(urlBooked, { credentials: 'same-origin' })
                                    .then(res => res.json())
                                    .then(list => {
                                        if (!Array.isArray(list) || list.length === 0) return;
                                        list.forEach(dateStr => {
                                            const btns = document.querySelectorAll('#calendarGrid button');
                                            btns.forEach(b => {
                                                const y = b.getAttribute('data-year');
                                                const m = (parseInt(b.getAttribute('data-month'),10) + 1).toString().padStart(2,'0');
                                                const d = b.textContent.toString().padStart(2,'0');
                                                const iso = y + '-' + m + '-' + d;
                                                if (iso === dateStr) {
                                                    b.classList.remove('bg-green-200','text-green-800','avail-date');
                                                    b.classList.add('bg-green-600','text-white','font-semibold','booked-date');
                                                }
                                            });
                                        });
                                        // After marking booked dates, ensure selection reflects availability/booked state
                                        try { reapplySelectionFromInitial(); } catch(e) { /* ignore */ }
                                    })
                                    .catch(err => console.error('Error fetching booked dates', err));
                            }

                            // Reapply the initial selection (server date or persisted date) after markers are applied
                            function reapplySelectionFromInitial() {
                                // Prefer the actively selected date (if user clicked) so highlight persists
                                if (selectedDate instanceof Date) {
                                    const y = selectedDate.getFullYear();
                                    const m = selectedDate.getMonth();
                                    const d = selectedDate.getDate();
                                    if (y === viewYear && m === viewMonth) {
                                        selectDate(y, m, d);
                                        return;
                                    }
                                }
                                if (!initialDateValue || initialDateValue === '') return;
                                const parts = initialDateValue.split('-');
                                if (parts.length !== 3) return;
                                const y = parseInt(parts[0],10);
                                const m = parseInt(parts[1],10) - 1;
                                const d = parseInt(parts[2],10);
                                if (y === viewYear && m === viewMonth) {
                                    selectDate(y, m, d);
                                }
                            }
                        })();
                    </script>
                </div>
                
                <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">My Booked Classes</h3>
                    
                    <c:if test="${empty myBookings}">
                        <div class="text-center py-12 text-gray-400">
                            <svg class="w-20 h-20 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                            <p>No bookings found</p>
                        </div>
                    </c:if>
                    
                            <div class="space-y-4">
                        <!-- Upcoming bookings -->
                        <c:forEach var="booking" items="${upcomingBookings}">
                            <c:set var="borderClass" value="border-blue-200 bg-blue-50" />
                            <div class="border-2 rounded-xl p-5 ${borderClass} booking-entry" data-booking-id="${booking.bookingId}" data-booking-date="${booking.bookingDate}" data-booking-time="${booking.bookingTime}" data-teacher-name="${booking.teacherName}" data-class-type="${booking.className}" data-booking-status="${booking.bookingStatus}">
                                <div class="flex items-start justify-between">
                                    <div class="flex-1">
                                        <div class="flex items-center gap-3 mb-3">
                                            <h4 class="font-bold text-gray-800 text-lg">${booking.className}</h4>
                                            <span class="px-3 py-1 bg-blue-100 text-blue-700 text-sm font-semibold rounded-full">Upcoming</span>
                                        </div>
                                        <div class="grid grid-cols-3 gap-4">
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Teacher</p>
                                                    <p class="text-sm font-semibold text-gray-700">${booking.teacherName}</p>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Date</p>
                                                    <p class="text-sm font-semibold text-gray-700 booking-date" data-booking-date="${booking.bookingDate}">${booking.bookingDate}</p>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Time</p>
                                                    <p class="text-sm font-semibold text-gray-700 booking-time" data-booking-time="${booking.bookingTime}">${booking.bookingTime}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="flex gap-2 ml-4">
                                        <button type="button" onclick="openDetailsModal('${booking.bookingId}')" class="px-4 py-2 border-2 border-gray-300 bg-white text-gray-700 rounded-lg text-sm font-semibold hover:bg-gray-100 transition-colors">
                                            View Details
                                        </button>
                                        <button type="button" onclick="openCancelModal('${booking.bookingId}')" class="px-4 py-2 bg-red-500 text-white rounded-lg text-sm font-semibold hover:bg-red-600 transition-colors">
                                            Cancel Booking
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>

                        <!-- Completed bookings -->
                        <c:forEach var="booking" items="${completedBookings}">
                            <c:set var="borderClass" value="border-green-200 bg-green-50" />
                            <div class="border-2 rounded-xl p-5 ${borderClass} booking-entry" data-booking-id="${booking.bookingId}" data-booking-date="${booking.bookingDate}" data-booking-time="${booking.bookingTime}" data-teacher-name="${booking.teacherName}" data-class-type="${booking.className}" data-booking-status="${booking.bookingStatus}">
                                <div class="flex items-start justify-between">
                                    <div class="flex-1">
                                        <div class="flex items-center gap-3 mb-3">
                                            <h4 class="font-bold text-gray-800 text-lg">${booking.className}</h4>
                                            <span class="px-3 py-1 bg-green-100 text-green-700 text-sm font-semibold rounded-full">Completed</span>
                                        </div>
                                        <div class="grid grid-cols-3 gap-4">
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Teacher</p>
                                                    <p class="text-sm font-semibold text-gray-700">${booking.teacherName}</p>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Date</p>
                                                    <p class="text-sm font-semibold text-gray-700 booking-date" data-booking-date="${booking.bookingDate}">${booking.bookingDate}</p>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Time</p>
                                                    <p class="text-sm font-semibold text-gray-700 booking-time" data-booking-time="${booking.bookingTime}">${booking.bookingTime}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="flex gap-2 ml-4">
                                        <button type="button" onclick="openDetailsModal('${booking.bookingId}')" class="px-4 py-2 border-2 border-gray-300 text-gray-700 rounded-lg text-sm font-semibold hover:bg-gray-100 transition-colors">
                                            View Details
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>

                        <!-- Cancelled bookings (bottom) -->
                        <c:forEach var="booking" items="${cancelledBookings}">
                            <c:set var="borderClass" value="border-red-200 bg-red-50" />
                            <div class="border-2 rounded-xl p-5 ${borderClass} booking-entry" data-booking-id="${booking.bookingId}" data-booking-date="${booking.bookingDate}" data-booking-time="${booking.bookingTime}" data-teacher-name="${booking.teacherName}" data-teacher-id="${booking.teacherId}" data-schedule-id="${booking.scheduleId}" data-class-type="${booking.className}" data-booking-status="${booking.bookingStatus}">
                                <div class="flex items-start justify-between">
                                    <div class="flex-1">
                                        <div class="flex items-center gap-3 mb-3">
                                            <h4 class="font-bold text-gray-800 text-lg">${booking.className}</h4>
                                            <span class="px-3 py-1 bg-red-100 text-red-700 text-sm font-semibold rounded-full">Cancelled</span>
                                        </div>
                                        <div class="grid grid-cols-3 gap-4">
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Teacher</p>
                                                    <p class="text-sm font-semibold text-gray-700">${booking.teacherName}</p>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Date</p>
                                                    <p class="text-sm font-semibold text-gray-700 booking-date" data-booking-date="${booking.bookingDate}">${booking.bookingDate}</p>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2">
                                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                                <div>
                                                    <p class="text-xs text-gray-500">Time</p>
                                                    <p class="text-sm font-semibold text-gray-700 booking-time" data-booking-time="${booking.bookingTime}">${booking.bookingTime}</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="mt-3 text-sm text-red-700">Cancellation reason: ${booking.cancellationReason}</div>
                                    </div>
                                        <div class="flex gap-2 ml-4">
                                                <button type="button" onclick="openDetailsModal('${booking.bookingId}')" class="px-4 py-2 border-2 border-gray-300 bg-white text-gray-700 rounded-lg text-sm font-semibold hover:bg-gray-100 transition-colors">
                                                    View Details
                                                </button>
                                        </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <div id="cancelModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-2xl p-8 max-w-md w-full mx-4 shadow-2xl">
            <h3 class="text-2xl font-bold text-gray-800 mb-2">Cancel Booking</h3>
            <p id="cancelSummary" class="text-sm text-gray-600 mb-4">Are you sure you want to cancel this class?</p>
            <form method="POST" action="<%= request.getContextPath() %>/student/cancel-booking">
                <input type="hidden" name="bookingId" id="cancelBookingId">
                <div id="cancelBookingInfo" class="text-sm text-gray-700 mb-4"></div>
                <div class="mb-6">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Reason for Cancellation <span class="text-red-500">*</span></label>
                    <textarea name="reason" rows="4" placeholder="Please provide a reason for cancelling this booking..." 
                              class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-red-500 transition-colors resize-none" required></textarea>
                </div>
                <div class="flex gap-3">
                    <button type="button" onclick="closeCancelModal()" class="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 rounded-xl font-semibold hover:bg-gray-50 transition-colors">
                        Keep Booking
                    </button>
                    <button type="submit" class="flex-1 px-4 py-3 bg-red-200 text-red-700 rounded-xl font-semibold hover:bg-red-300 transition-colors">
                        Cancel Booking
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Details Modal -->
    <div id="detailsModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-2xl p-8 max-w-lg w-full mx-4 shadow-2xl">
            <div class="flex items-start justify-between mb-4">
                <h3 class="text-2xl font-bold text-gray-800">Class Details</h3>
                <button onclick="closeDetailsModal()" class="text-gray-500 hover:text-gray-700">✕</button>
            </div>
            <!-- More page scripts: export/print helpers and global booking data -->
            <script>
                // Expose booking data for export utilities (server-side rendered)
                window.bookingExportList = [
                    <c:forEach var="b" items="${myBookings}">
                        { bookingId: '${b.bookingId}', bookingDate: '${b.bookingDate}', bookingTime: '${b.bookingTime}', bookingStatus: '${b.bookingStatus}', teacherName: '${b.teacherName}', className: '${b.className}' },
                    </c:forEach>
                ];

                function sanitizeCell(v) {
                    if (v === null || v === undefined) return '';
                    return String(v).replace(/\"/g, '""');
                }

                function exportAsCSV() {
                    const rows = [['Booking ID','Date','Time','Status','Teacher','Class']];
                    (window.bookingExportList || []).forEach(b => rows.push([b.bookingId, b.bookingDate, b.bookingTime, b.bookingStatus, b.teacherName, b.className]));
                    const csv = rows.map(r => r.map(c => '"' + sanitizeCell(c) + '"').join(',')).join('\r\n');
                    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a'); a.href = url; a.download = 'bookings.csv'; document.body.appendChild(a); a.click(); setTimeout(()=>{ URL.revokeObjectURL(url); a.remove(); }, 150);
                }

                function exportAsExcel() {
                    // Simple Excel export using CSV format but .xls extension for compatibility
                    const rows = [['Booking ID','Date','Time','Status','Teacher','Class']];
                    (window.bookingExportList || []).forEach(b => rows.push([b.bookingId, b.bookingDate, b.bookingTime, b.bookingStatus, b.teacherName, b.className]));
                    const csv = rows.map(r => r.map(c => '"' + sanitizeCell(c) + '"').join(',')).join('\r\n');
                    const blob = new Blob([csv], { type: 'application/vnd.ms-excel' });
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a'); a.href = url; a.download = 'bookings.xls'; document.body.appendChild(a); a.click(); setTimeout(()=>{ URL.revokeObjectURL(url); a.remove(); }, 150);
                }

                function exportAsPDF() {
                    // Open a printable window containing a simple table of bookings and trigger print
                    const list = window.bookingExportList || [];
                    const win = window.open('', '_blank');
                    const css = '<style>body{font-family:Arial,Helvetica,sans-serif;padding:20px}table{width:100%;border-collapse:collapse}th,td{border:1px solid #ddd;padding:8px;text-align:left}th{background:#f4f4f4}</style>';
                    let html = '<html><head><title>Bookings Export</title>' + css + '</head><body>';
                    html += '<h2>My Bookings</h2>';
                    html += '<table><thead><tr><th>Booking ID</th><th>Date</th><th>Time</th><th>Status</th><th>Teacher</th><th>Class</th></tr></thead><tbody>';
                    list.forEach(b => {
                        html += '<tr>' +
                            '<td>' + (b.bookingId||'') + '</td>' +
                            '<td>' + (b.bookingDate||'') + '</td>' +
                            '<td>' + (b.bookingTime||'') + '</td>' +
                            '<td>' + (b.bookingStatus||'') + '</td>' +
                            '<td>' + (b.teacherName||'') + '</td>' +
                            '<td>' + (b.className||'') + '</td>' +
                            '</tr>';
                    });
                    html += '</tbody></table>';
                    html += '<script>setTimeout(function(){ window.print(); }, 250);</' + 'script>';
                    html += '</body></html>';
                    win.document.open(); win.document.write(html); win.document.close();
                }

                function printPage() {
                    window.print();
                }
                // Notifications polling: fetch recent cancellation events for current user
                (function(){
                    const badge = document.getElementById('notificationBadge');
                    const itemsEl = document.getElementById('notificationItems');
                    const ctx = '<%= request.getContextPath() %>';

                    function renderNotifications(data) {
                        if (!badge || !itemsEl) return;
                        const count = data && data.count ? data.count : 0;
                        if (count > 0) {
                            badge.style.display = 'inline-flex';
                            badge.textContent = count > 9 ? '9+' : count;
                        } else {
                            badge.style.display = 'none';
                        }

                        itemsEl.innerHTML = '';
                        if (data && Array.isArray(data.items) && data.items.length > 0) {
                            data.items.forEach(it => {
                                const d = document.createElement('div');
                                d.className = 'px-4 py-3 hover:bg-gray-50 border-b text-sm';
                                const who = it.by === 'teacher' ? 'Teacher cancelled' : (it.by === 'student' ? 'Student cancelled' : 'Cancelled');
                                let title = who + ' • ' + (it.bookingDate || '') + ' ' + (it.bookingTime || '');
                                d.innerHTML = '<div class="font-semibold text-gray-800">' + title + '</div>' +
                                              '<div class="text-gray-600 text-xs mt-1">' + (it.reason || '') + '</div>' +
                                              '<div class="text-gray-400 text-xs mt-1">' + (it.time || '') + '</div>';
                                itemsEl.appendChild(d);
                            });
                        } else {
                            itemsEl.innerHTML = '<div class="p-4 text-sm text-gray-500">No notifications</div>';
                        }
                    }

                    function fetchNotifications() {
                        return fetch(ctx + '/api/notifications', { credentials: 'same-origin' })
                            .then(res => res.json())
                            .then(data => { renderNotifications(data); return data; })
                            .catch(err => { console.error('Failed to fetch notifications', err); return null; });
                    }

                    // Open menu and mark notifications read
                    window.openNotificationMenu = function() {
                        const menu = document.getElementById('notificationMenu');
                        if (!menu) return;
                        const isHidden = menu.classList.contains('hidden');
                        if (isHidden) {
                            // show menu and mark notifications read
                            menu.classList.remove('hidden');
                            // mark all read then refresh
                            fetch(ctx + '/api/notifications/mark-read', { method: 'POST', credentials: 'same-origin' }).then(()=>{ fetchNotifications(); }).catch(()=>{});
                        } else {
                            menu.classList.add('hidden');
                        }
                    };

                    // Initial fetch and interval
                    try { fetchNotifications(); } catch(e){}
                    setInterval(fetchNotifications, 20000);
                })();
            </script>
            <div class="space-y-3 text-sm text-gray-700 mb-6">
                <div>
                    <p class="text-xs text-gray-500">Class Type:</p>
                    <p id="detailsClassType" class="font-semibold text-gray-800">Quran Recitation &amp; Tajweed</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Teacher:</p>
                    <p id="detailsTeacher" class="font-semibold text-gray-800">Ustadh Ibrahim Khan</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Date:</p>
                    <p id="detailsDate" class="font-semibold text-gray-800">Thursday, January 2, 2025</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Time:</p>
                    <p id="detailsTime" class="font-semibold text-gray-800">10:00 AM - 10:15 AM</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Status:</p>
                    <p id="detailsStatus" class="inline-block px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">Upcoming</p>
                </div>
            </div>
            <div class="text-center">
                <button onclick="closeDetailsModal()" class="px-6 py-3 bg-gradient-to-r from-teal-400 to-teal-600 text-white rounded-xl font-semibold">Close</button>
            </div>
        </div>
    </div>
    
    <!-- Confirm Booking Modal -->
    <div id="confirmModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-2xl p-8 max-w-md w-full mx-4 shadow-2xl">
            <h3 class="text-2xl font-bold text-gray-800 mb-2">Confirm Booking</h3>
            <div class="space-y-3 text-sm text-gray-700 mb-6">
                <div>
                    <p class="text-xs text-gray-500">Class Type:</p>
                    <p id="confirmClassType" class="font-semibold text-gray-800">Quran Recitation &amp; Tajweed</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Teacher:</p>
                    <p id="confirmTeacher" class="font-semibold text-gray-800"></p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Date:</p>
                    <p id="confirmDate" class="font-semibold text-gray-800"></p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Time:</p>
                    <p id="confirmTime" class="font-semibold text-gray-800"></p>
                </div>
            </div>
            <form id="confirmBookingForm" method="POST" action="<%= request.getContextPath() %>/student/book-session">
                <input type="hidden" name="scheduleId" id="confirm_scheduleId">
                <input type="hidden" name="bookingDate" id="confirm_bookingDate">
                <input type="hidden" name="bookingTime" id="confirm_bookingTime">
                <input type="hidden" name="teacherId" id="confirm_teacherId">
                <input type="hidden" name="rescheduleBookingId" id="confirm_rescheduleBookingId">
                <div class="flex gap-3">
                    <button type="button" onclick="closeConfirmModal()" class="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 rounded-xl font-semibold hover:bg-gray-50 transition-colors">Cancel</button>
                    <button type="submit" class="flex-1 px-4 py-3 bg-gradient-to-r from-teal-400 to-teal-600 text-white rounded-xl font-semibold">Confirm Booking</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // Attach reschedule handlers to cancelled bookings (outside the calendar IIFE)
        (function(){
            function bindRescheduleButtons(){
                const buttons = document.querySelectorAll('.reschedule-btn');
                buttons.forEach(btn => {
                    btn.removeEventListener('click', btn._rescheduleHandler);
                    const handler = function(){
                        const bookingId = btn.getAttribute('data-booking-id');
                        const bookingDate = btn.getAttribute('data-booking-date');
                        try { window.talaqqi.openReschedule(bookingId, bookingDate); } catch(e){
                            try { localStorage.setItem('rescheduleBookingId', bookingId || ''); } catch(err){}
                            try { window.talaqqi.pendingReschedule = bookingId || ''; } catch(err){}
                        }
                        try { if (calendarGrid) calendarGrid.dataset.pendingReschedule = bookingId || ''; } catch(e){}
                    };
                    btn._rescheduleHandler = handler;
                    btn.addEventListener('click', handler);
                });
            }
            // Bind now and on DOM changes
            document.addEventListener('DOMContentLoaded', bindRescheduleButtons);
            bindRescheduleButtons();
        })();
        function openCancelModal(bookingId) {
            const el = document.querySelector('.booking-entry[data-booking-id="' + bookingId + '"]');
            if (el) {
                const classType = el.dataset.classType || 'Quran Recitation & Tajweed';
                const teacher = el.dataset.teacherName || '';
                const rawDate = el.dataset.bookingDate || '';
                const rawTime = el.dataset.bookingTime || '';
                // format using helper if available
                let prettyDate = rawDate;
                let prettyTime = rawTime;
                if (window.talaqqi && typeof window.talaqqi.formatDateISO === 'function') {
                    prettyDate = window.talaqqi.formatDateISO(rawDate);
                    const t = window.talaqqi.parseTime(rawTime);
                    if (t) {
                        const base = rawDate ? new Date(rawDate + 'T00:00:00') : new Date();
                        const start = new Date(base.getFullYear(), base.getMonth(), base.getDate(), t.h, t.m, 0);
                        const end = new Date(start.getTime() + (15 * 60 * 1000));
                        prettyTime = window.talaqqi.fmtTime(start) + ' - ' + window.talaqqi.fmtTime(end);
                    }
                }
                const info = document.getElementById('cancelBookingInfo');
                if (info) info.innerHTML = '<div class="font-medium">' + classType + '</div><div class="text-sm text-gray-600">' + (prettyDate || '') + ' at ' + (prettyTime || '') + '</div><div class="text-sm text-gray-600 mt-1">Teacher: ' + (teacher || '') + '</div>';
            }
            document.getElementById('cancelBookingId').value = bookingId;
            document.getElementById('cancelModal').classList.remove('hidden');
        }

        function closeCancelModal() {
            document.getElementById('cancelModal').classList.add('hidden');
        }

        function openDetailsModal(bookingId) {
            const el = document.querySelector('.booking-entry[data-booking-id="' + bookingId + '"]');
            if (!el) return;
            const classType = el.dataset.classType || 'Quran Recitation & Tajweed';
            const teacher = el.dataset.teacherName || '';
            const rawDate = el.dataset.bookingDate || '';
            const rawTime = el.dataset.bookingTime || '';
            let prettyDate = rawDate;
            let prettyTime = rawTime;
            if (window.talaqqi && typeof window.talaqqi.formatDateISO === 'function') {
                prettyDate = window.talaqqi.formatDateISO(rawDate);
                const t = window.talaqqi.parseTime(rawTime);
                if (t) {
                    const base = rawDate ? new Date(rawDate + 'T00:00:00') : new Date();
                    const start = new Date(base.getFullYear(), base.getMonth(), base.getDate(), t.h, t.m, 0);
                    const end = new Date(start.getTime() + (15 * 60 * 1000));
                    prettyTime = window.talaqqi.fmtTime(start) + ' - ' + window.talaqqi.fmtTime(end);
                }
            }
            const elClass = document.getElementById('detailsClassType'); if (elClass) elClass.textContent = classType;
            const elTeacher = document.getElementById('detailsTeacher'); if (elTeacher) elTeacher.textContent = teacher;
            const elDate = document.getElementById('detailsDate'); if (elDate) elDate.textContent = prettyDate;
            const elTime = document.getElementById('detailsTime'); if (elTime) elTime.textContent = prettyTime;
            const statusEl = document.getElementById('detailsStatus'); if (statusEl) {
                const sts = (el.dataset.bookingStatus || 'Upcoming');
                statusEl.textContent = sts;
                // set color: Upcoming = blue, Completed = green, Cancelled = red
                statusEl.className = 'inline-block px-3 py-1 rounded-full text-xs font-semibold';
                if (sts === 'Upcoming' || sts === 'Confirmed') {
                    statusEl.classList.add('bg-blue-100','text-blue-700');
                } else if (sts === 'Completed') {
                    statusEl.classList.add('bg-green-100','text-green-700');
                } else if (sts === 'Cancelled') {
                    statusEl.classList.add('bg-red-100','text-red-700');
                } else {
                    statusEl.classList.add('bg-gray-100','text-gray-700');
                }
            }
            document.getElementById('detailsModal').classList.remove('hidden');
        }

        function closeDetailsModal() {
            document.getElementById('detailsModal').classList.add('hidden');
        }
    </script>
    <script>
        (function(){
            function two(n){ return String(n).padStart(2,'0'); }
            function formatDateISO(iso){
                if(!iso) return iso || '';
                const parts = iso.toString().split('-');
                if(parts.length===3){
                    const y = parseInt(parts[0],10), m = parseInt(parts[1],10)-1, d = parseInt(parts[2],10);
                    const dt = new Date(y,m,d);
                    try{ return dt.toLocaleDateString(undefined, { weekday:'long', year:'numeric', month:'long', day:'numeric' }); }catch(e){ return iso; }
                }
                return iso;
            }
            function parseTime(t){
                if(!t) return null;
                const s = t.trim();
                const m12 = s.match(/^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$/);
                const m24 = s.match(/^(\d{1,2}):(\d{2})$/);
                if(m12){
                    let hh = parseInt(m12[1],10), mm = parseInt(m12[2],10); const am = m12[3].toUpperCase();
                    if(am==='PM' && hh<12) hh+=12; if(am==='AM' && hh===12) hh=0; return {h:hh,m:mm};
                } else if(m24){ return {h:parseInt(m24[1],10), m:parseInt(m24[2],10)}; }
                const dt = new Date('1970-01-01T' + s);
                if(!isNaN(dt)) return {h:dt.getHours(), m:dt.getMinutes()};
                return null;
            }
            function fmtTime(d){ let h = d.getHours(); const m = d.getMinutes(); const am = h>=12? 'PM':'AM'; if(h===0) h=12; else if(h>12) h-=12; return two(h)+':' + two(m) + ' ' + am; }

            // expose helpers to other scripts
            window.talaqqi = window.talaqqi || {};
            window.talaqqi.formatDateISO = formatDateISO;
            window.talaqqi.parseTime = parseTime;
            window.talaqqi.fmtTime = fmtTime;

            const entries = document.querySelectorAll('.booking-entry');
            entries.forEach(function(entry){
                const dateEl = entry.querySelector('.booking-date');
                const timeEl = entry.querySelector('.booking-time');
                const rawDate = dateEl ? dateEl.dataset.bookingDate : null;
                if(dateEl && rawDate){ dateEl.textContent = formatDateISO(rawDate); }
                if(timeEl && timeEl.dataset.bookingTime){
                    const rawTime = timeEl.dataset.bookingTime;
                    const t = parseTime(rawTime);
                    if(t){
                        let base = new Date();
                        if(rawDate){ const p = rawDate.split('-'); if(p.length===3) base = new Date(parseInt(p[0],10), parseInt(p[1],10)-1, parseInt(p[2],10)); }
                        const start = new Date(base.getFullYear(), base.getMonth(), base.getDate(), t.h, t.m, 0);
                        const end = new Date(start.getTime() + (15 * 60 * 1000));
                        timeEl.textContent = fmtTime(start) + ' - ' + fmtTime(end);
                    }
                }
            });
        })();
    </script>
</body>
</html>