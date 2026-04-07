<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - TalaqqiHub</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/colors.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/animations.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css">
</head>
<body class="bg-gray-50">
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <aside class="w-64 fixed h-screen" style="background: linear-gradient(180deg, #2d5f4f 0%, #1a3d30 100%);">
            <div class="p-6">
                <h1 class="text-2xl font-bold text-white">TalaqqiHub</h1>
                <p class="text-sm text-green-200">Student Portal</p>
            </div>
            
            <nav class="mt-6">
                <a href="<%= request.getContextPath() %>/student/dashboard" class="flex items-center px-6 py-3 text-white bg-green-800 bg-opacity-50">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/student/class-booking" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
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
        
        <!-- Main Content -->
        <main class="flex-1 ml-64">
            <!-- Top Bar -->
            <header class="bg-white shadow-sm sticky top-0 z-10">
                <div class="flex items-center justify-between px-8 py-4">
                    <h2 class="text-2xl font-bold text-gray-800">Dashboard</h2>
                    
                    <div class="flex items-center space-x-4">
                        <!-- Notifications -->
                        <div class="relative">
                            <button id="notificationBtnDashboard" class="relative p-2 text-gray-600 hover:bg-gray-100 rounded-lg" onclick="openNotificationMenuDashboard()">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                                </svg>
                                <span id="notificationBadgeDashboard" class="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-purple-600 rounded-full" style="display:none">0</span>
                            </button>
                            <div id="notificationMenuDashboard" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg py-2 z-50">
                                <div id="notificationItemsDashboard" class="max-h-64 overflow-y-auto"></div>
                                <div class="border-t p-2 text-center text-sm"><a href="<%= request.getContextPath() %>/student/announcements" class="text-purple-600">View all</a></div>
                            </div>
                        </div>
                        
                        <!-- Profile Dropdown -->
                        <div class="relative">
                            <button class="flex items-center space-x-2 focus:outline-none" onclick="document.getElementById('profileDropdown').classList.toggle('hidden')">
                                <%
                                    String initials = "";
                                    String _sName = (String) request.getAttribute("studentName");
                                    if (_sName != null && !_sName.trim().isEmpty()) {
                                        String[] _parts = _sName.trim().split("\\s+");
                                        StringBuilder _sb = new StringBuilder();
                                        for (String p : _parts) {
                                            if (p.length() > 0) _sb.append(Character.toUpperCase(p.charAt(0)));
                                            if (_sb.length() >= 2) break;
                                        }
                                        initials = _sb.toString();
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
            
            <!-- Dashboard Content -->
            <div class="p-8">
                <!-- Greeting -->
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">Assalamu'alaikum, ${studentName}</h1>
                    <p class="text-gray-600">Here is an overview of your Quran learning progress.</p>
                    <p class="text-gray-700 mt-2">Package Name: <span class="font-bold text-gray-800">(${packageName})</span></p>
                </div>
                <script>
                    (function(){
                        const badge = document.getElementById('notificationBadgeDashboard');
                        const itemsEl = document.getElementById('notificationItemsDashboard');
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

                        window.openNotificationMenuDashboard = function() {
                            const menu = document.getElementById('notificationMenuDashboard');
                            if (!menu) return;
                            const isHidden = menu.classList.contains('hidden');
                            if (isHidden) {
                                menu.classList.remove('hidden');
                                fetch(ctx + '/api/notifications/mark-read', { method: 'POST', credentials: 'same-origin' }).then(()=>{ fetchNotifications(); }).catch(()=>{});
                            } else {
                                menu.classList.add('hidden');
                            }
                        };

                        try { fetchNotifications(); } catch(e){}
                        setInterval(fetchNotifications, 20000);
                    })();
                </script>
                
                <!-- Summary Cards -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <!-- Upcoming Classes -->
                    <div class="bg-white rounded-2xl p-6 shadow-sm">
                        <div class="w-12 h-12 rounded-xl flex items-center justify-center mb-4" style="background: linear-gradient(135deg, #06b6d4 0%, #3b82f6 100%);">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <h3 class="text-3xl font-bold text-blue-600 mb-1">${upcomingClassCount}</h3>
                        <p class="text-gray-600 text-sm">Upcoming Classes</p>
                    </div>
                    
                    <!-- Attendance Rate -->
                    <div class="bg-white rounded-2xl p-6 shadow-sm">
                        <div class="w-12 h-12 rounded-xl flex items-center justify-center mb-4" style="background: linear-gradient(135deg, #a855f7 0%, #ec4899 100%);">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                        </div>
                        <h3 class="text-3xl font-bold text-purple-600 mb-1">${attendanceRate}%</h3>
                        <p class="text-gray-600 text-sm">Attendance Rate</p>
                    </div>
                    
                    <!-- Completed Sessions -->
                    <div class="bg-white rounded-2xl p-6 shadow-sm">
                        <div class="w-12 h-12 rounded-xl flex items-center justify-center mb-4" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%);">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                            </svg>
                        </div>
                        <h3 class="text-3xl font-bold text-green-600 mb-1">${completedSessions}/${totalSessions}</h3>
                        <p class="text-gray-600 text-sm">Completed Sessions</p>
                    </div>
                    
                    <!-- Latest Evaluation -->
                    <div class="bg-white rounded-2xl p-6 shadow-sm">
                        <div class="w-12 h-12 rounded-xl flex items-center justify-center mb-4" style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                            </svg>
                        </div>
                        <h3 class="text-3xl font-bold text-purple-600 mb-1">${evaluationResult}</h3>
                        <p class="text-gray-600 text-sm">Latest Evaluation</p>
                    </div>
                </div>
                
                <!-- Two Column Layout -->
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Next Talaqqi Session -->
                    <div class="lg:col-span-2">
                        <div class="bg-white rounded-2xl p-6 shadow-sm">
                            <div class="flex items-center justify-between mb-6">
                                <h3 class="text-xl font-bold text-gray-800">Next Talaqqi Session</h3>
                                <span class="px-3 py-1 bg-green-100 text-green-700 text-sm font-medium rounded-full">Upcoming</span>
                            </div>
                            
                            <c:if test="${nextSession != null}">
                                <div class="space-y-4 mb-6">
                                    <div class="flex items-center text-gray-700">
                                        <svg class="w-5 h-5 mr-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                        <div>
                                            <p class="text-sm text-gray-500">Date</p>
                                            <p class="font-semibold">${nextSession.sessionDate}</p>
                                        </div>
                                    </div>
                                    
                                    <div class="flex items-center text-gray-700">
                                        <svg class="w-5 h-5 mr-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                        <div>
                                            <p class="text-sm text-gray-500">Time</p>
                                            <p class="font-semibold">${nextSession.sessionTime}</p>
                                        </div>
                                    </div>
                                    
                                    <div class="flex items-center text-gray-700">
                                        <svg class="w-5 h-5 mr-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                        </svg>
                                        <div>
                                            <p class="text-sm text-gray-500">Teacher</p>
                                            <p class="font-semibold">${nextSession.teacherName}</p>
                                        </div>
                                    </div>
                                    
                                    <div class="flex items-center text-gray-700">
                                        <svg class="w-5 h-5 mr-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                        </svg>
                                        <div>
                                            <p class="text-sm text-gray-500">Session Type</p>
                                            <p class="font-semibold">${nextSession.sessionType}</p>
                                        </div>
                                    </div>
                                </div>
                                
                                <button class="w-full py-3 text-white rounded-full font-medium transition-all" style="background: var(--gradient-feature-green);">
                                    Join Session
                                </button>
                            </c:if>
                            
                            <c:if test="${nextSession == null}">
                                <p class="text-gray-500 text-center py-8">No upcoming sessions scheduled</p>
                            </c:if>
                        </div>
                        
                        <!-- Learning Progress -->
                        <div class="bg-white rounded-2xl p-6 shadow-sm mt-6">
                            <h3 class="text-xl font-bold text-gray-800 mb-4">Learning Progress</h3>
                            <div class="mb-3">
                                <div class="flex items-center justify-between mb-2">
                                    <span class="text-sm font-medium text-gray-700">Session Completion</span>
                                    <span class="text-sm font-bold text-green-600">${completedSessions}/${totalSessions}</span>
                                </div>
                                <div class="w-full bg-gray-200 rounded-full h-3">
                                    <c:set var="progressPercent" value="0" />
                                    <c:if test="${totalSessions > 0}">
                                        <c:set var="progressPercent" value="${(completedSessions * 100) / totalSessions}" />
                                    </c:if>
                                    <div class="h-3 rounded-full" style="width: ${progressPercent}%; background: linear-gradient(90deg, #10b981 0%, #059669 100%);"></div>
                                </div>
                            </div>
                            <c:set var="progressPercent" value="0" />
                            <c:if test="${totalSessions > 0}">
                                <c:set var="progressPercent" value="${(completedSessions * 100) / totalSessions}" />
                            </c:if>
                            <p class="text-sm text-gray-600 mt-3">You've completed ${progressPercent}% of your sessions. Keep up the great work!</p>
                        </div>
                    </div>
                    
                    <!-- Announcements -->
                    <div class="lg:col-span-1">
                        <div class="bg-white rounded-2xl p-6 shadow-sm">
                            <div class="flex items-center justify-between mb-6">
                                <h3 class="text-xl font-bold text-gray-800">Announcements</h3>
                                <span class="w-6 h-6 flex items-center justify-center bg-purple-600 text-white text-xs font-bold rounded-full">${announcementCount > 9 ? '9+' : announcementCount}</span>
                            </div>
                            
                            <div class="space-y-4 mb-4">
                                <c:forEach items="${announcementList}" var="announcement">
                                    <div class="border-l-4 border-purple-500 pl-4 py-2">
                                        <h4 class="font-semibold text-gray-800 mb-1">${announcement.title}</h4>
                                        <p class="text-sm text-gray-500 mb-1">${announcement.date}</p>
                                        <p class="text-sm text-gray-600">${announcement.description}</p>
                                    </div>
                                </c:forEach>
                            </div>
                            
                            <a href="<%= request.getContextPath() %>/student/announcements" class="block w-full py-2 text-center text-purple-600 font-medium border-2 border-purple-600 rounded-full hover:bg-purple-50 transition-colors">
                                View All Announcements
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
