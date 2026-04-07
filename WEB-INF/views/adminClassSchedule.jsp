<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Schedule - TalaqqiHub</title>
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
                <a href="<%= request.getContextPath() %>/admin/dashboard" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/></svg>
                    <span class="text-sm font-medium">Dashboard</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/class-schedule" class="flex items-center px-6 py-3 bg-white bg-opacity-10 border-l-4 border-white">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"/></svg>
                    <span class="text-sm font-medium">Class Schedule</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/packages" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20"><path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z"/></svg>
                    <span class="text-sm font-medium">Attendance Analytics</span>
                </a>
                <a href="#" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
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
                    <h2 class="text-2xl font-bold text-gray-800">Class Schedule</h2>
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
                                    <p class="text-sm font-semibold text-gray-800">Admin Manager</p>
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
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">Class Schedule Management</h1>
                    <p class="text-gray-600">Monitor all class activities across the TalaqqiHub platform</p>
                </div>

                <section class="mb-8">
                    <div class="grid grid-cols-4 gap-6">
                        <div class="bg-white rounded-xl shadow-sm p-6">
                                <div class="flex items-center justify-between mb-4">
                                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                    <svg class="w-6 h-6 text-purple-600" fill="currentColor" viewBox="0 0 20 20"><path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"/></svg>
                                </div>
                                <p class="text-4xl font-bold text-gray-800"><%= request.getAttribute("totalClasses") != null ? request.getAttribute("totalClasses") : "0" %></p>
                            </div>
                            <p class="font-semibold text-gray-800 mb-1">Total Classes Created</p>
                            <p class="text-sm text-gray-500">All time class slots</p>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-center justify-between mb-4">
                                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                                    <svg class="w-6 h-6 text-green-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>
                                </div>
                                <p class="text-4xl font-bold text-green-600"><%= request.getAttribute("totalBooked") != null ? request.getAttribute("totalBooked") : "0" %></p>
                            </div>
                            <p class="font-semibold text-gray-800 mb-1">Total Booked Classes</p>
                            <p class="text-sm text-gray-500">Reserved by students</p>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-center justify-between mb-4">
                                <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                                    <svg class="w-6 h-6 text-red-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/></svg>
                                </div>
                                <p class="text-4xl font-bold text-red-600"><%= request.getAttribute("cancelledCount") != null ? request.getAttribute("cancelledCount") : "0" %></p>
                            </div>
                            <p class="font-semibold text-gray-800 mb-1">Cancelled Classes</p>
                            <p class="text-sm text-gray-500">Cancelled sessions</p>
                        </div>

                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <div class="flex items-center justify-between mb-4">
                                <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                                    <svg class="w-6 h-6 text-orange-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/></svg>
                                </div>
                                <p class="text-4xl font-bold text-orange-500"><%= request.getAttribute("rescheduledCount") != null ? request.getAttribute("rescheduledCount") : "0" %></p>
                            </div>
                            <p class="font-semibold text-gray-800 mb-1">Rescheduled Classes</p>
                            <p class="text-sm text-gray-500">Modified schedules</p>
                        </div>
                    </div>
                </section>

                <section>
                    <div class="bg-white rounded-xl shadow-sm">
                        <div class="p-6 border-b border-gray-200">
                            <div class="flex items-center justify-between mb-6">
                                <h3 class="text-xl font-bold text-gray-800">Class Records</h3>
                                <div class="flex items-center space-x-3">
                                    <button class="px-4 py-2 bg-gradient-to-r from-purple-500 to-purple-400 text-white rounded-lg text-sm font-medium hover:from-purple-600 hover:to-purple-500 transition flex items-center space-x-2">
                                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M6 2a2 2 0 00-2 2v12a2 2 0 002 2h8a2 2 0 002-2V7.414A2 2 0 0015.414 6L12 2.586A2 2 0 0010.586 2H6zm5 6a1 1 0 10-2 0v3.586l-1.293-1.293a1 1 0 10-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L11 11.586V8z" clip-rule="evenodd"/></svg>
                                        <span>Export PDF</span>
                                    </button>
                                    <button class="px-4 py-2 bg-white border border-gray-300 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-50 transition">
                                        CSV
                                    </button>
                                    <button class="px-4 py-2 bg-white border border-gray-300 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-50 transition">
                                        Excel
                                    </button>
                                    <button class="px-4 py-2 bg-white border border-gray-300 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-50 transition flex items-center space-x-2">
                                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5 4v3H4a2 2 0 00-2 2v3a2 2 0 002 2h1v2a2 2 0 002 2h6a2 2 0 002-2v-2h1a2 2 0 002-2V9a2 2 0 00-2-2h-1V4a2 2 0 00-2-2H7a2 2 0 00-2 2zm8 0H7v3h6V4zm0 8H7v4h6v-4z" clip-rule="evenodd"/></svg>
                                        <span>Print</span>
                                    </button>
                                </div>
                            </div>

                            <div class="grid grid-cols-5 gap-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
                                    <div class="relative">
                                        <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"/></svg>
                                        <input type="text" placeholder="Search teacher or student..." class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
                                    <select name="filterStatus" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                                        <option>All Status</option>
                                        <option>Upcoming</option>
                                        <option>Completed</option>
                                        <option>Rescheduled</option>
                                        <option>Cancelled</option>
                                    </select>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Teacher</label>
                                    <select class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                                        <option>All Teachers</option>
                                        <option>Ustadh Ibrahim Khan</option>
                                        <option>Ustadha Maryam Yusuf</option>
                                    </select>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Date From</label>
                                    <input type="date" placeholder="dd/mm/yyyy" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Date To</label>
                                    <input type="date" placeholder="dd/mm/yyyy" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                                </div>
                            </div>
                        </div>

                        <div class="p-6">
                            <p class="text-sm text-gray-600 mb-4">Showing database class records</p>

                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead>
                                        <tr class="border-b border-gray-200">
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Teacher Name</th>
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Student Name</th>
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Class Type</th>
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Date</th>
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Time</th>
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Status</th>
                                            
                                            <th class="text-left py-3 px-4 text-sm font-semibold text-gray-700">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-100">
                                        <% java.util.List<java.util.Map<String, Object>> records = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("classRecords");
                                           if (records != null && !records.isEmpty()) {
                                               for (java.util.Map<String, Object> r : records) {
                                                   String teacherName = r.get("teacherName") != null ? (String) r.get("teacherName") : "-";
                                                   String studentName = r.get("studentName") != null ? (String) r.get("studentName") : "-";
                                                   String className = r.get("className") != null ? (String) r.get("className") : "-";
                                                   java.util.Date schedDate = (java.util.Date) r.get("scheduleDate");
                                                   java.sql.Time start = (java.sql.Time) r.get("startTime");
                                                   java.sql.Time end = (java.sql.Time) r.get("endTime");
                                                   String status = r.get("status") != null ? (String) r.get("status") : "-";
                                                   String displayStatus = "-";
                                                   if (status != null) {
                                                       String s = status.trim().toLowerCase();
                                                       if (s.equals("booked") || s.equals("scheduled") || s.equals("available") || s.equals("confirmed") || s.equals("approved") || s.equals("upcoming")) {
                                                           displayStatus = "Upcoming";
                                                       } else if (s.equals("completed")) {
                                                           displayStatus = "Completed";
                                                       } else if (s.equals("rescheduled") || s.equals("reschedule")) {
                                                           displayStatus = "Rescheduled";
                                                       } else if (s.equals("cancelled") || s.equals("canceled")) {
                                                           displayStatus = "Cancelled";
                                                       } else {
                                                           // fallback: show status as-is but capitalized
                                                           displayStatus = status.substring(0,1).toUpperCase() + (status.length()>1?status.substring(1):"");
                                                       }
                                                   }
                                        %>
                                        <tr class="hover:bg-gray-50">
                                            <td class="py-4 px-4 text-sm text-gray-800 font-medium"><%= teacherName %></td>
                                            <td class="py-4 px-4 text-sm text-gray-600"><%= studentName %></td>
                                            <td class="py-4 px-4 text-sm text-gray-600"><%= className %></td>
                                            <td class="py-4 px-4 text-sm text-gray-600"><%= schedDate != null ? new java.text.SimpleDateFormat("MMM d, yyyy").format(schedDate) : "-" %></td>
                                            <td class="py-4 px-4 text-sm text-gray-600"><%= (start != null ? new java.text.SimpleDateFormat("h:mm a").format(start) : "-") + (end != null ? " - " + new java.text.SimpleDateFormat("h:mm a").format(end) : "") %></td>
                                            <td class="py-4 px-4">
                                                <% if ("Upcoming".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="px-3 py-1 bg-blue-100 text-blue-700 text-xs font-medium rounded-full"><%= displayStatus %></span>
                                                <% } else if ("Completed".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="px-3 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-full"><%= displayStatus %></span>
                                                <% } else if ("Rescheduled".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="px-3 py-1 bg-amber-100 text-amber-700 text-xs font-medium rounded-full"><%= displayStatus %></span>
                                                <% } else if ("Cancelled".equalsIgnoreCase(displayStatus)) { %>
                                                    <span class="px-3 py-1 bg-red-100 text-red-700 text-xs font-medium rounded-full"><%= displayStatus %></span>
                                                <% } else { %>
                                                    <span class="px-3 py-1 bg-gray-100 text-gray-700 text-xs font-medium rounded-full"><%= displayStatus %></span>
                                                <% } %>
                                            </td>
                                            
                                            <td class="py-4 px-4">
                                                <button onclick="viewAdminClassDetails('<%= r.get("scheduleId") %>')" class="px-4 py-2 bg-gradient-to-r from-purple-500 to-purple-400 text-white rounded-lg text-xs font-medium hover:from-purple-600 hover:to-purple-500 transition">View</button>
                                            </td>
                                        </tr>
                                        <%   }
                                           } else { %>
                                        <tr>
                                            <td colspan="7" class="py-6 text-center text-sm text-gray-500">No class records found</td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </main>
    </div>
</body>
</html>

<!-- Admin Class Details Modal & JS -->
<div id="adminClassDetailsModal" class="fixed inset-0 bg-black bg-opacity-40 hidden items-center justify-center z-50">
    <div class="bg-white rounded-lg shadow-xl w-3/4 max-w-2xl p-6 overflow-auto" role="dialog" aria-modal="true">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold">Class Details</h3>
            <button onclick="closeAdminClassDetails()" class="text-gray-500 hover:text-gray-700">✕</button>
        </div>

        <div class="grid grid-cols-2 gap-6">
            <div>
                <p class="text-sm text-gray-500">Teacher Name</p>
                <p id="admin-teacher-name" class="font-semibold text-gray-800">-</p>
            </div>
            <div>
                <p class="text-sm text-gray-500">Student Name</p>
                <p id="admin-student-name" class="font-semibold text-gray-800">-</p>
            </div>
            <div>
                <p class="text-sm text-gray-500">Class Type</p>
                <p id="admin-class-type" class="font-semibold text-gray-800">-</p>
            </div>
            <div>
                <p class="text-sm text-gray-500">Status</p>
                <p id="admin-status" class="inline-block px-3 py-1 rounded-full text-sm font-medium">-</p>
            </div>
            <div>
                <p class="text-sm text-gray-500">Date</p>
                <p id="admin-date" class="font-semibold text-gray-800">-</p>
            </div>
            <div>
                <p class="text-sm text-gray-500">Time</p>
                <p id="admin-time" class="font-semibold text-gray-800">-</p>
            </div>
        </div>

        <div id="admin-cancellation-reason" class="mt-6 bg-red-50 border border-red-200 rounded-lg p-4 hidden">
            <p class="text-sm font-semibold text-red-700">Cancellation Reason</p>
            <p id="admin-cancellation-text" class="text-red-700"></p>
        </div>

        <!-- History removed per request -->

        <div class="mt-6">
            <button onclick="closeAdminClassDetails()" class="w-full py-3 bg-gray-100 rounded-lg font-medium">Close</button>
        </div>
    </div>
</div>

<script>
    function viewAdminClassDetails(scheduleId) {
        fetch('<%= request.getContextPath() %>/teacher/class-details?scheduleId=' + encodeURIComponent(scheduleId))
            .then(res => {
                if (!res.ok) {
                    return res.text().then(text => { console.error('Details fetch failed', res.status, text); alert('Failed to load details (status ' + res.status + ')'); throw new Error('HTTP ' + res.status); });
                }
                const ct = res.headers.get('content-type') || '';
                if (ct.indexOf('application/json') === -1) {
                    return res.text().then(text => { console.error('Unexpected content-type for details:', ct, text); alert('Failed to load details (invalid response)'); throw new Error('Invalid content'); });
                }
                return res.json();
            })
            .then(data => {
                if (!data.success || !data.details) {
                    alert('Failed to load details');
                    return;
                }
                const d = data.details;
                document.getElementById('admin-teacher-name').textContent = d.teacherName || '-';
                document.getElementById('admin-student-name').textContent = d.studentName || '-';
                document.getElementById('admin-class-type').textContent = d.className || '-';

                // Status pill styling based on normalized status
                const statusEl = document.getElementById('admin-status');
                const status = d.status || '-';
                statusEl.textContent = status;
                statusEl.className = 'inline-block px-3 py-1 rounded-full text-sm font-medium';
                if (status === 'Upcoming') {
                    statusEl.classList.add('bg-blue-100','text-blue-700');
                } else if (status === 'Completed') {
                    statusEl.classList.add('bg-green-100','text-green-700');
                } else if (status === 'Rescheduled') {
                    statusEl.classList.add('bg-amber-100','text-amber-700');
                } else if (status === 'Cancelled') {
                    statusEl.classList.add('bg-red-100','text-red-700');
                } else {
                    statusEl.classList.add('bg-gray-100','text-gray-700');
                }

                document.getElementById('admin-date').textContent = d.scheduleDate || '-';
                document.getElementById('admin-time').textContent = (d.startTime && d.endTime) ? d.startTime + ' - ' + d.endTime : (d.startTime || '-');

                if (status === 'Cancelled' && d.cancellationReason) {
                    document.getElementById('admin-cancellation-text').textContent = d.cancellationReason;
                    document.getElementById('admin-cancellation-reason').classList.remove('hidden');
                } else {
                    document.getElementById('admin-cancellation-reason').classList.add('hidden');
                }

                // history removed

                const modal = document.getElementById('adminClassDetailsModal');
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            })
            .catch(err => { console.error(err); alert('Failed to load class details'); });
    }

    function closeAdminClassDetails() {
        const modal = document.getElementById('adminClassDetailsModal');
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }

    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('adminClassDetailsModal').addEventListener('click', function(e) {
            if (e.target === this) closeAdminClassDetails();
        });
    });
</script>
