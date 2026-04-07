<!-- Sidebar include: uses sessionScope.adminName via EL in parent pages if needed -->
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
                <a href="<%= request.getContextPath() %>/admin/packages" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
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
        <a href="<%= request.getContextPath() %>/admin/logout" class="flex items-center hover:bg-white hover:bg-opacity-10 px-3 py-2 rounded transition">
            <span class="text-sm font-medium">Logout</span>
        </a>
    </div>
</aside>
