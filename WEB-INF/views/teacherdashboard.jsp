<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.text.SimpleDateFormat, java.sql.Time, java.sql.Date" %>
<%
    // Authentication check
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }
    
    String teacherName = (String) request.getAttribute("teacherName");
    String teacherCode = (String) request.getAttribute("teacherCode");
    String specialization = (String) request.getAttribute("specialization");
    String joinedDate = (String) request.getAttribute("joinedDate");
    String nextClassCountdown = (String) request.getAttribute("nextClassCountdown");
    
    int classesThisWeek = (Integer) request.getAttribute("classesThisWeek");
    int totalStudents = (Integer) request.getAttribute("totalStudents");
    int pendingEvaluations = (Integer) request.getAttribute("pendingEvaluations");
    String averageRating = (String) request.getAttribute("averageRating");
    
    List<Map<String, Object>> upcomingClasses = (List<Map<String, Object>>) request.getAttribute("upcomingClasses");
    List<Map<String, Object>> recentFeedback = (List<Map<String, Object>>) request.getAttribute("recentFeedback");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - TalaqqiHub Teacher Portal</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }
        
        .sidebar-gradient {
            background: linear-gradient(180deg, #7c3aed 0%, #5b21b6 100%);
        }
        
        .card-hover {
            transition: all 0.3s ease;
        }
        
        .card-hover:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
        }
        
        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-upcoming {
            background-color: #dbeafe;
            color: #1e40af;
        }
        
        .status-scheduled {
            background-color: #d1fae5;
            color: #065f46;
        }
        
        .status-completed {
            background-color: #e0e7ff;
            color: #4338ca;
        }
    </style>
</head>
<body class="bg-gray-50">
    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <aside class="sidebar-gradient w-64 flex-shrink-0 overflow-y-auto">
            <div class="p-6">
                <div class="text-white mb-8">
                    <h1 class="text-2xl font-bold">TalaqqiHub</h1>
                    <p class="text-purple-200 text-sm mt-1">Teacher Portal</p>
                </div>
                
                <nav class="space-y-2">
                    <a href="<%= request.getContextPath() %>/teacher/teacherdashboard" 
                       class="flex items-center space-x-3 px-4 py-3 text-white bg-white bg-opacity-20 rounded-lg">
                        <i class="fas fa-home w-5"></i>
                        <span>Dashboard</span>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/classschedule" 
                       class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                        <i class="far fa-calendar w-5"></i>
                        <span>Class Schedule</span>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/attendance" 
                       class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                        <i class="far fa-clipboard w-5"></i>
                        <span>Attendance</span>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/evaluation" 
                       class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                        <i class="far fa-file-alt w-5"></i>
                        <span>Evaluation</span>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/sessions" 
                       class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                        <i class="fas fa-book-quran w-5"></i>
                        <span>Talaqqi Sessions</span>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/announcements" 
                       class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                        <i class="far fa-bell w-5"></i>
                        <span>Announcements</span>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/ai-assistance" 
                       class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                        <i class="fas fa-bolt w-5"></i>
                        <span>AI Assistance</span>
                    </a>
                </nav>
            </div>
            
            <div class="absolute bottom-0 w-64 p-6">
                <a href="<%= request.getContextPath() %>/teacher/logout" 
                   class="flex items-center space-x-3 px-4 py-3 text-purple-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                    <i class="fas fa-sign-out-alt w-5"></i>
                    <span>Logout</span>
                </a>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 overflow-y-auto">
            <!-- Top Navigation Bar -->
            <header class="bg-white shadow-sm border-b border-gray-200">
                <div class="px-8 py-4 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900">Dashboard</h2>
                    
                    <div class="flex items-center space-x-4">
                        <button class="relative p-2 text-gray-400 hover:text-gray-600">
                            <i class="far fa-bell text-xl"></i>
                            <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
                        </button>
                        
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center text-white font-semibold">
                                UI
                            </div>
                            <div>
                                <p class="text-sm font-semibold text-gray-900"><%= teacherName %></p>
                                <p class="text-xs text-gray-500">Teacher ID: <%= teacherCode %></p>
                            </div>
                        </div>
                    </div>
                </div>
            </header>
            
            <!-- Dashboard Content -->
            <div class="p-8">
                <!-- Greeting Section -->
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">
                        Assalamu'alaikum, <%= teacherName %>
                    </h1>
                    <p class="text-gray-600">Here is an overview of your teaching activities and student progress.</p>
                </div>
                
                <!-- Teacher Info Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                    <div class="bg-white rounded-lg p-4 shadow-sm border border-gray-200">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                                <i class="far fa-calendar text-purple-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Joined</p>
                                <p class="text-sm font-semibold text-gray-900"><%= joinedDate %></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-white rounded-lg p-4 shadow-sm border border-gray-200">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                                <i class="fas fa-book-quran text-blue-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Specialization</p>
                                <p class="text-sm font-semibold text-gray-900"><%= specialization %></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-white rounded-lg p-4 shadow-sm border border-gray-200">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                                <i class="far fa-clock text-green-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Next class in</p>
                                <p class="text-sm font-semibold text-gray-900"><%= nextClassCountdown %></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Statistics Cards -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <!-- Classes This Week -->
                    <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover">
                        <div class="flex items-start justify-between mb-4">
                            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                <i class="far fa-calendar text-purple-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900 mb-1"><%= classesThisWeek %></h3>
                        <p class="text-sm text-gray-600 mb-2">Classes This Week</p>
                        <p class="text-xs text-gray-500">Your scheduled sessions</p>
                    </div>
                    
                    <!-- Total Students -->
                    <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover">
                        <div class="flex items-start justify-between mb-4">
                            <div class="w-12 h-12 bg-teal-100 rounded-lg flex items-center justify-center">
                                <i class="fas fa-users text-teal-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900 mb-1"><%= totalStudents %></h3>
                        <p class="text-sm text-gray-600 mb-2">Total Students</p>
                        <p class="text-xs text-gray-500">Students you teach</p>
                    </div>
                    
                    <!-- Pending Evaluations -->
                    <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover">
                        <div class="flex items-start justify-between mb-4">
                            <div class="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                                <i class="far fa-file-alt text-yellow-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900 mb-1"><%= pendingEvaluations %></h3>
                        <p class="text-sm text-gray-600 mb-2">Pending Evaluations</p>
                        <a href="#" class="text-xs text-yellow-600 hover:text-yellow-700 font-medium">Complete evaluations →</a>
                    </div>
                    
                    <!-- Average Rating -->
                    <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover">
                        <div class="flex items-start justify-between mb-4">
                            <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                                <i class="fas fa-star text-orange-600 text-xl"></i>
                            </div>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900 mb-1"><%= averageRating %> <span class="text-lg text-gray-500">/5.0</span></h3>
                        <p class="text-sm text-gray-600 mb-2">Average Rating</p>
                        <div class="flex items-center space-x-1">
                            <% 
                            double avgRating = Double.parseDouble(averageRating);
                            for (int i = 1; i <= 5; i++) {
                                if (i <= avgRating) {
                            %>
                                <i class="fas fa-star text-orange-400 text-xs"></i>
                            <% } else { %>
                                <i class="far fa-star text-gray-300 text-xs"></i>
                            <% 
                                }
                            }
                            %>
                        </div>
                    </div>
                </div>
                
                <!-- Action Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <a href="<%= request.getContextPath() %>/teacher/availability" 
                       class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover cursor-pointer">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-4">
                                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-plus text-purple-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-semibold text-gray-900">Set Availability</h3>
                                    <p class="text-sm text-gray-600">Create time slots</p>
                                </div>
                            </div>
                            <i class="fas fa-chevron-right text-gray-400"></i>
                        </div>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/schedule" 
                       class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover cursor-pointer">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-4">
                                <div class="w-12 h-12 bg-teal-100 rounded-lg flex items-center justify-center">
                                    <i class="far fa-calendar text-teal-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-semibold text-gray-900">View Class Schedule</h3>
                                    <p class="text-sm text-gray-600">Manage your sessions</p>
                                </div>
                            </div>
                            <i class="fas fa-chevron-right text-gray-400"></i>
                        </div>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/teacher/evaluation" 
                       class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 card-hover cursor-pointer">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-4">
                                <div class="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                                    <i class="far fa-file-alt text-yellow-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-semibold text-gray-900">Evaluate Student</h3>
                                    <p class="text-sm text-gray-600"><%= pendingEvaluations %> pending</p>
                                </div>
                            </div>
                            <i class="fas fa-chevron-right text-gray-400"></i>
                        </div>
                    </a>
                </div>
                
                <!-- Two Column Layout -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <!-- Upcoming Classes -->
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200">
                        <div class="p-6 border-b border-gray-200">
                            <div class="flex items-center justify-between">
                                <h3 class="text-lg font-bold text-gray-900">Your Upcoming Classes</h3>
                                <a href="<%= request.getContextPath() %>/teacher/schedule" 
                                   class="text-sm text-purple-600 hover:text-purple-700 font-medium flex items-center space-x-1">
                                    <span>View All</span>
                                    <i class="fas fa-chevron-right text-xs"></i>
                                </a>
                            </div>
                            <p class="text-sm text-gray-600 mt-1">Classes assigned to you</p>
                        </div>
                        
                        <div class="p-6">
                            <% if (upcomingClasses != null && !upcomingClasses.isEmpty()) { %>
                                <div class="space-y-4">
                                    <% for (Map<String, Object> classInfo : upcomingClasses) { 
                                        String className = (String) classInfo.get("className");
                                        String studentName = (String) classInfo.get("studentName");
                                        Date scheduleDate = (Date) classInfo.get("scheduleDate");
                                        Time startTime = (Time) classInfo.get("startTime");
                                        Time endTime = (Time) classInfo.get("endTime");
                                        String status = (String) classInfo.get("status");

                                        // Skip unbooked / available slots: no student assigned or booked flag is false
                                        Object bookedObj = classInfo.get("booked");
                                        boolean booked = false;
                                        if (bookedObj instanceof Boolean) booked = (Boolean) bookedObj;
                                        if (studentName == null || studentName.trim().length() == 0 || !booked) {
                                            continue;
                                        }
                                        
                                        String studentInitials = "S";
                                        if (studentName != null && studentName.length() > 0) {
                                            String[] names = studentName.split(" ");
                                            studentInitials = names.length > 1 ? 
                                                names[0].substring(0, 1) + names[1].substring(0, 1) : 
                                                names[0].substring(0, 1);
                                        }
                                    %>
                                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                                        <div class="flex items-center space-x-4">
                                            <div class="w-10 h-10 bg-teal-500 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                                                <%= studentInitials %>
                                            </div>
                                            <div>
                                                <h4 class="font-semibold text-gray-900"><%= className != null ? className : "Class Session" %></h4>
                                                <p class="text-sm text-gray-600"><%= studentName != null ? studentName : "No student assigned" %></p>
                                                <div class="flex items-center space-x-4 mt-1 text-xs text-gray-500">
                                                    <span><i class="far fa-calendar mr-1"></i><%= scheduleDate != null ? dateFormat.format(scheduleDate) : "N/A" %></span>
                                                    <span><i class="far fa-clock mr-1"></i><%= startTime != null ? timeFormat.format(startTime) : "N/A" %> - <%= endTime != null ? timeFormat.format(endTime) : "N/A" %></span>
                                                    <span><i class="far fa-hourglass mr-1"></i><%= classInfo.get("duration") %> hour</span>
                                                </div>
                                            </div>
                                        </div>
                                        <span class="status-badge <%= status != null && status.equalsIgnoreCase("Scheduled") ? "status-scheduled" : "status-upcoming" %>">
                                            <%= status != null ? status : "Upcoming" %>
                                        </span>
                                    </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="text-center py-8">
                                    <i class="far fa-calendar-times text-gray-300 text-4xl mb-3"></i>
                                    <p class="text-gray-500">No upcoming classes scheduled</p>
                                    <a href="<%= request.getContextPath() %>/teacher/availability" 
                                       class="text-purple-600 hover:text-purple-700 text-sm font-medium mt-2 inline-block">
                                        Set your availability
                                    </a>
                                </div>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- Recent Student Feedback -->
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200">
                        <div class="p-6 border-b border-gray-200">
                            <div class="flex items-center justify-between">
                                <h3 class="text-lg font-bold text-gray-900">Recent Student Feedback</h3>
                                <a href="<%= request.getContextPath() %>/teacher/evaluations" 
                                   class="text-sm text-purple-600 hover:text-purple-700 font-medium flex items-center space-x-1">
                                    <span>View All</span>
                                    <i class="fas fa-chevron-right text-xs"></i>
                                </a>
                            </div>
                            <p class="text-sm text-gray-600 mt-1">Evaluations you received</p>
                        </div>
                        
                        <div class="p-6">
                            <% if (recentFeedback != null && !recentFeedback.isEmpty()) { %>
                                <div class="space-y-4">
                                    <% for (Map<String, Object> feedback : recentFeedback) { 
                                        String studentName = (String) feedback.get("studentName");
                                        int rating = (Integer) feedback.get("rating");
                                        String comment = (String) feedback.get("comment");
                                        java.sql.Timestamp feedbackDate = (java.sql.Timestamp) feedback.get("date");
                                        
                                        String studentInitials = "S";
                                        if (studentName != null && studentName.length() > 0) {
                                            String[] names = studentName.split(" ");
                                            studentInitials = names.length > 1 ? 
                                                names[0].substring(0, 1) + names[1].substring(0, 1) : 
                                                names[0].substring(0, 1);
                                        }
                                        
                                        // Calculate time ago
                                        long diffInMillis = new java.util.Date().getTime() - feedbackDate.getTime();
                                        long hours = diffInMillis / (1000 * 60 * 60);
                                        long days = hours / 24;
                                        String timeAgo = days > 0 ? days + " days ago" : hours + " hours ago";
                                    %>
                                    <div class="p-4 bg-gray-50 rounded-lg">
                                        <div class="flex items-start space-x-3">
                                            <div class="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center text-white font-semibold text-sm flex-shrink-0">
                                                <%= studentInitials %>
                                            </div>
                                            <div class="flex-1">
                                                <div class="flex items-center justify-between mb-1">
                                                    <h4 class="font-semibold text-gray-900"><%= studentName %></h4>
                                                    <span class="text-xs text-gray-500"><%= timeAgo %></span>
                                                </div>
                                                <div class="flex items-center space-x-1 mb-2">
                                                    <% for (int i = 1; i <= 5; i++) { %>
                                                        <i class="<%= i <= rating ? "fas" : "far" %> fa-star text-orange-400 text-sm"></i>
                                                    <% } %>
                                                </div>
                                                <p class="text-sm text-gray-700 italic">"<%= comment != null ? comment : "No comment provided" %>"</p>
                                            </div>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="text-center py-8">
                                    <i class="far fa-comments text-gray-300 text-4xl mb-3"></i>
                                    <p class="text-gray-500">No feedback received yet</p>
                                    <p class="text-sm text-gray-400 mt-1">Student evaluations will appear here</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
