<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Announcement" %>
<%
    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";
    
    int totalActiveStudents = request.getAttribute("totalActiveStudents") != null ? (int) request.getAttribute("totalActiveStudents") : 0;
    int totalActiveTeachers = request.getAttribute("totalActiveTeachers") != null ? (int) request.getAttribute("totalActiveTeachers") : 0;
    int totalSessions = request.getAttribute("totalSessions") != null ? (int) request.getAttribute("totalSessions") : 0;
    int upcomingSessions = request.getAttribute("upcomingSessions") != null ? (int) request.getAttribute("upcomingSessions") : 0;
    int completedSessions = request.getAttribute("completedSessions") != null ? (int) request.getAttribute("completedSessions") : 0;
    int cancelledSessions = request.getAttribute("cancelledSessions") != null ? (int) request.getAttribute("cancelledSessions") : 0;
    
    int presentCount = request.getAttribute("presentCount") != null ? (int) request.getAttribute("presentCount") : 0;
    int absentCount = request.getAttribute("absentCount") != null ? (int) request.getAttribute("absentCount") : 0;
    double attendanceRate = request.getAttribute("attendanceRate") != null ? (double) request.getAttribute("attendanceRate") : 0.0;
    
    double avgTeacherRating = request.getAttribute("avgTeacherRating") != null ? (double) request.getAttribute("avgTeacherRating") : 0.0;
    double avgStudentPerformance = request.getAttribute("avgStudentPerformance") != null ? (double) request.getAttribute("avgStudentPerformance") : 0.0;
    
    List<Map<String, Object>> recentActivities = (List<Map<String, Object>>) request.getAttribute("recentActivities");
    List<Announcement> recentAnnouncements = (List<Announcement>) request.getAttribute("recentAnnouncements");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .scrollbar-hide::-webkit-scrollbar {
            display: none;
        }
        .scrollbar-hide {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
</head>
<body class="bg-gray-50 font-sans">
    <div class="flex min-h-screen">
        <aside class="w-56 bg-gradient-to-b from-purple-600 via-purple-500 to-purple-700 text-white flex flex-col fixed h-full shadow-xl">
            <div class="p-6 border-b border-white border-opacity-20">
                <h1 class="text-2xl font-bold">TalaqqiHub</h1>
                <p class="text-sm text-purple-100 opacity-90">Admin Portal</p>
            </div>
            
            <nav class="flex-1 py-4 overflow-y-auto scrollbar-hide">
                <a href="#" class="flex items-center px-6 py-3 bg-white bg-opacity-10 border-l-4 border-white">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/></svg>
                    <span class="text-sm font-medium">Dashboard</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/class-schedule" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"/></svg>
                    <span class="text-sm font-medium">Class Schedule</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/packages" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z"/></svg>
                    <span class="text-sm font-medium">Attendance Analytics</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/talaqqi-sessions" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z"/></svg>
                    <span class="text-sm font-medium">Talaqqi Session</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/></svg>
                    <span class="text-sm font-medium">Evaluation Analytics</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M18 3a1 1 0 00-1.196-.98l-10 2A1 1 0 006 5v9.114A4.369 4.369 0 005 14c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V7.82l8-1.6v5.894A4.37 4.37 0 0015 12c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V3z"/></svg>
                    <span class="text-sm font-medium">Announcements</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M11 3a1 1 0 10-2 0v1a1 1 0 102 0V3zM15.657 5.757a1 1 0 00-1.414-1.414l-.707.707a1 1 0 001.414 1.414l.707-.707zM18 10a1 1 0 01-1 1h-1a1 1 0 110-2h1a1 1 0 011 1zM5.05 6.464A1 1 0 106.464 5.05l-.707-.707a1 1 0 00-1.414 1.414l.707.707zM5 10a1 1 0 01-1 1H3a1 1 0 110-2h1a1 1 0 011 1zM8 16v-1h4v1a2 2 0 11-4 0zM12 14c.015-.34.208-.646.477-.859a4 4 0 10-4.954 0c.27.213.462.519.476.859h4.002z"/></svg>
                    <span class="text-sm font-medium">AI Assistance</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-students" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/></svg>
                    <span class="text-sm font-medium">Manage Students</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-teachers" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z"/></svg>
                    <span class="text-sm font-medium">Manage Teachers</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/packages" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M3 1a1 1 0 000 2h1.22l.305 1.222a.997.997 0 00.01.042l1.358 5.43-.893.892C3.74 11.846 4.632 14 6.414 14H15a1 1 0 000-2H6.414l1-1H14a1 1 0 00.894-.553l3-6A1 1 0 0017 3H6.28l-.31-1.243A1 1 0 005 1H3zM16 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM6.5 18a1.5 1.5 0 100-3 1.5 1.5 0 000 3z"/></svg>
                    <span class="text-sm font-medium">Packages</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z"/></svg>
                    <span class="text-sm font-medium">Notifications</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/></svg>
                    <span class="text-sm font-medium">Profile</span>
                </a>
            </nav>
            
            <div class="p-6 border-t border-white border-opacity-20">
                <a href="#" class="flex items-center hover:bg-white hover:bg-opacity-10 px-3 py-2 rounded transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z" clip-rule="evenodd"/></svg>
                    <span class="text-sm font-medium">Logout</span>
                </a>
            </div>
        </aside>

        <main class="flex-1 ml-56 overflow-y-auto scrollbar-hide">
            <header class="bg-white shadow-sm sticky top-0 z-10">
                <div class="flex items-center justify-between px-8 py-4">
                    <h2 class="text-2xl font-bold text-gray-800">Admin Dashboard</h2>
                    <div class="flex items-center space-x-5">
                        <div class="relative cursor-pointer">
                            <svg class="w-6 h-6 text-gray-600" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z"/></svg>
                            <span class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-semibold">3</span>
                        </div>
                        <div class="flex items-center space-x-3 cursor-pointer">
                            <div class="w-10 h-10 bg-purple-400 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                                AM
                            </div>
                            <div class="flex items-center space-x-2">
                                <div>
                                    <p class="text-sm font-semibold text-gray-800"><%= adminName %></p>
                                    <p class="text-xs text-gray-500">Administrator</p>
                                </div>
                                <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"/></svg>
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <div class="p-8">
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">Welcome back, <%= adminName %>!</h1>
                    <p class="text-gray-600">Here's an overview of TalaqqiHub platform activity</p>
                </div>

                <section class="mb-8">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Platform Overview</h3>
                    <div class="grid grid-cols-3 gap-6 mb-6">
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-start justify-between">
                                <div class="w-12 h-12 bg-purple-200 rounded-xl flex items-center justify-center text-2xl">
                                    👥
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-bold text-gray-800"><%= totalActiveStudents %></p>
                                </div>
                            </div>
                            <div class="mt-4">
                                <p class="font-semibold text-gray-800">Total Active Students</p>
                                <p class="text-sm text-gray-500">Currently enrolled</p>
                            </div>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-start justify-between">
                                <div class="w-12 h-12 bg-purple-200 rounded-xl flex items-center justify-center text-2xl">
                                    👤
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-bold text-gray-800"><%= totalActiveTeachers %></p>
                                </div>
                            </div>
                            <div class="mt-4">
                                <p class="font-semibold text-gray-800">Total Active Teachers</p>
                                <p class="text-sm text-gray-500">Currently teaching</p>
                            </div>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-start justify-between">
                                <div class="w-12 h-12 bg-purple-200 rounded-xl flex items-center justify-center text-2xl">
                                    🎥
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-bold text-gray-800"><%= totalSessions %></p>
                                </div>
                            </div>
                            <div class="mt-4">
                                <p class="font-semibold text-gray-800">Total Talaqqi Sessions</p>
                                <p class="text-sm text-gray-500">All-time sessions</p>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-3 gap-6">
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-start justify-between">
                                <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center text-2xl">
                                    ⏰
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-bold text-blue-600"><%= upcomingSessions %></p>
                                </div>
                            </div>
                            <div class="mt-4">
                                <p class="font-semibold text-gray-800">Upcoming Sessions</p>
                                <p class="text-sm text-gray-500">Scheduled sessions</p>
                            </div>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-start justify-between">
                                <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center text-2xl">
                                    ✅
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-bold text-green-600"><%= completedSessions %></p>
                                </div>
                            </div>
                            <div class="mt-4">
                                <p class="font-semibold text-gray-800">Completed Sessions</p>
                                <p class="text-sm text-gray-500">Successfully finished</p>
                            </div>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-start justify-between">
                                <div class="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center text-2xl">
                                    ❌
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-bold text-red-600"><%= cancelledSessions %></p>
                                </div>
                            </div>
                            <div class="mt-4">
                                <p class="font-semibold text-gray-800">Cancelled Sessions</p>
                                <p class="text-sm text-gray-500">Cancelled by users</p>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="mb-8">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Analytics Overview</h3>
                    <div class="grid grid-cols-2 gap-6">
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-center mb-6">
                                <div class="w-10 h-10 bg-purple-200 rounded-lg flex items-center justify-center text-xl mr-3">
                                    📊
                                </div>
                                <h4 class="text-lg font-semibold text-gray-800">Attendance Rate Overview</h4>
                            </div>

                            <div class="flex items-center justify-center mb-6">
                                <div class="relative w-48 h-48">
                                    <svg class="w-48 h-48 transform -rotate-90">
                                        <circle cx="96" cy="96" r="80" stroke="#e5e7eb" stroke-width="24" fill="none"/>
                                        <circle cx="96" cy="96" r="80" stroke="url(#gradient)" stroke-width="24" fill="none" stroke-dasharray="502.4" stroke-dashoffset="62.8" stroke-linecap="round"/>
                                        <defs>
                                            <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                                                <stop offset="0%" style="stop-color:#8b5cf6;stop-opacity:1" />
                                                <stop offset="100%" style="stop-color:#a855f7;stop-opacity:1" />
                                            </linearGradient>
                                        </defs>
                                    </svg>
                                    <div class="absolute inset-0 flex flex-col items-center justify-center">
                                        <p class="text-4xl font-bold text-gray-800"><%= String.format("%.1f", attendanceRate) %>%</p>
                                        <p class="text-sm text-gray-600">Attendance Rate</p>
                                    </div>
                                </div>
                            </div>

                            <div class="grid grid-cols-2 gap-4 mb-6">
                                <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                                    <p class="text-sm text-green-600 font-medium mb-1">Present</p>
                                    <p class="text-3xl font-bold text-green-600"><%= presentCount %></p>
                                </div>
                                <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                                    <p class="text-sm text-red-600 font-medium mb-1">Absent</p>
                                    <p class="text-3xl font-bold text-red-600"><%= absentCount %></p>
                                </div>
                            </div>

                            <p class="text-center text-sm text-gray-600 mb-4">Overall student attendance performance</p>
                            
                            <button class="w-full bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold py-3 rounded-lg hover:from-purple-600 hover:to-pink-600 transition">
                                View Full Attendance Analytics
                            </button>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-center mb-6">
                                <div class="w-10 h-10 bg-purple-200 rounded-lg flex items-center justify-center text-xl mr-3">
                                    ⭐
                                </div>
                                <h4 class="text-lg font-semibold text-gray-800">Evaluation Analytics</h4>
                            </div>

                            <div class="mb-8">
                                <div class="flex items-center justify-between mb-2">
                                    <p class="text-sm font-medium text-gray-700">Average Teacher Rating</p>
                                    <p class="text-2xl font-bold text-gray-800"><%= String.format("%.1f", avgTeacherRating) %> <span class="text-sm text-gray-500">/5.0</span></p>
                                </div>
                                <div class="flex items-center mb-3">
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-gray-300 text-xl">★</span>
                                </div>
                                <div class="w-full bg-gray-200 rounded-full h-2">
                                    <div class="bg-gradient-to-r from-purple-400 to-pink-500 h-2 rounded-full" style="width: 92%"></div>
                                </div>
                            </div>

                            <div class="mb-8">
                                <div class="flex items-center justify-between mb-2">
                                    <p class="text-sm font-medium text-gray-700">Average Student Performance</p>
                                    <p class="text-2xl font-bold text-gray-800"><%= String.format("%.1f", avgStudentPerformance) %> <span class="text-sm text-gray-500">/5.0</span></p>
                                </div>
                                <div class="flex items-center mb-3">
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-yellow-400 text-xl">★</span>
                                    <span class="text-gray-300 text-xl">★</span>
                                </div>
                                <div class="w-full bg-gray-200 rounded-full h-2">
                                    <div class="bg-gradient-to-r from-purple-400 to-pink-500 h-2 rounded-full" style="width: 84%"></div>
                                </div>
                            </div>

                            <p class="text-center text-sm text-gray-600 mb-4">Platform-wide evaluation metrics</p>
                            
                            <button class="w-full bg-gradient-to-r from-purple-400 to-purple-300 text-white font-semibold py-3 rounded-lg hover:from-purple-500 hover:to-purple-400 transition">
                                View Full Evaluation Analytics
                            </button>
                        </div>
                    </div>
                </section>

                <section class="mb-8">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Recent Activities</h3>
                    <div class="bg-white rounded-xl shadow-sm p-6">
                        <div class="space-y-4">
                            <%
                            if (recentActivities != null && !recentActivities.isEmpty()) {
                                for (int i = 0; i < recentActivities.size(); i++) {
                                    Map<String, Object> activity = recentActivities.get(i);
                                    String status = (String) activity.get("classStatus");
                                    String teacherName = (String) activity.get("teacherName");
                                    String studentName = (String) activity.get("studentName");
                                    String className = (String) activity.get("className");
                                    
                                    String iconBg = "bg-gray-100";
                                    String iconColor = "text-gray-600";
                                    String icon = "●";
                                    String message = className;
                                    
                                    if ("Cancelled".equals(status)) {
                                        iconBg = "bg-red-100";
                                        iconColor = "text-red-600";
                                        icon = "⊗";
                                        message = teacherName + " cancelled class for " + studentName;
                                    } else if ("Completed".equals(status)) {
                                        iconBg = "bg-green-100";
                                        iconColor = "text-green-600";
                                        icon = "✓";
                                        message = "Class completed: " + className;
                                    } else {
                                        iconBg = "bg-blue-100";
                                        iconColor = "text-blue-600";
                                        icon = "📅";
                                        message = "Upcoming: " + className;
                                    }
                                    
                                    String borderClass = (i < recentActivities.size() - 1) ? "pb-4 border-b border-gray-100" : "";
                            %>
                            <div class="flex items-start space-x-3 <%= borderClass %>">
                                <div class="w-10 h-10 <%= iconBg %> rounded-full flex items-center justify-center flex-shrink-0">
                                    <span class="<%= iconColor %>"><%= icon %></span>
                                </div>
                                <div class="flex-1">
                                    <p class="text-sm text-gray-800"><%= message %></p>
                                    <p class="text-xs text-gray-500 mt-1"><%= activity.get("scheduleDate") %></p>
                                </div>
                            </div>
                            <%
                                }
                            } else {
                            %>
                            <p class="text-gray-500 text-sm">No recent activities</p>
                            <%
                            }
                            %>
                        </div>
                    </div>
                </section>

                <section class="mb-8">
                    <div class="flex items-center justify-between mb-6">
                        <h3 class="text-xl font-bold text-gray-800">Recent Announcements</h3>
                        <button class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                            Manage Announcements
                        </button>
                    </div>
                    <div class="space-y-4">
                        <%
                        if (recentAnnouncements != null && !recentAnnouncements.isEmpty()) {
                            for (Announcement announcement : recentAnnouncements) {
                        %>
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <h4 class="font-semibold text-gray-800 mb-3"><%= announcement.getTitle() != null ? announcement.getTitle() : "Announcement" %></h4>
                            <div class="flex items-center space-x-4 text-sm text-gray-600">
                                <span class="flex items-center">
                                    <span class="mr-1">👤</span> <%= announcement.getAuthor() != null ? announcement.getAuthor() : "Admin" %>
                                </span>
                                <span class="flex items-center">
                                    <span class="mr-1">👥</span> <%= announcement.getTargetAudience() != null ? announcement.getTargetAudience() : "All Users" %>
                                </span>
                                <span>• <%= announcement.getDate() != null ? announcement.getDate() : "" %></span>
                            </div>
                        </div>
                        <%
                            }
                        } else {
                        %>
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <p class="text-gray-500 text-sm">No recent announcements</p>
                        </div>
                        <%
                        }
                        %>
                    </div>
                </section>

                <section class="mb-8">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">Quick Actions</h3>
                    <div class="grid grid-cols-4 gap-4">
                        <div class="bg-gradient-to-br from-pink-400 to-pink-300 rounded-xl shadow-sm p-6 text-white cursor-pointer hover:shadow-lg transition">
                            <div class="w-12 h-12 bg-white bg-opacity-30 rounded-lg flex items-center justify-center text-2xl mb-4">
                                🎁
                            </div>
                            <h4 class="font-semibold text-lg mb-2">Create Announcement</h4>
                            <p class="text-sm text-white text-opacity-90">Send platform-wide message</p>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6 cursor-pointer hover:shadow-lg transition border border-gray-100">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center text-2xl mb-4">
                                📅
                            </div>
                            <h4 class="font-semibold text-lg mb-2 text-gray-800">View Class Schedule</h4>
                            <p class="text-sm text-gray-600">Manage platform schedule</p>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6 cursor-pointer hover:shadow-lg transition border border-gray-100">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center text-2xl mb-4">
                                📊
                            </div>
                            <h4 class="font-semibold text-lg mb-2 text-gray-800">Attendance Analytics</h4>
                            <p class="text-sm text-gray-600">View detailed reports</p>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6 cursor-pointer hover:shadow-lg transition border border-gray-100">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center text-2xl mb-4">
                                ⭐
                            </div>
                            <h4 class="font-semibold text-lg mb-2 text-gray-800">Evaluation Analytics</h4>
                            <p class="text-sm text-gray-600">Track performance</p>
                        </div>
                    </div>
                </section>
            </div>
        </main>
    </div>
</body>
</html>
