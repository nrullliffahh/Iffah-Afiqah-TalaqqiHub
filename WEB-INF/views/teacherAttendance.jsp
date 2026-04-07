<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Attendance - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }
        .sidebar-gradient {
            background: linear-gradient(180deg, #7c3aed 0%, #5b21b6 100%);
        }
    </style>
</head>
<body class="bg-gray-50">
    <div class="flex h-screen overflow-hidden">
        <!-- SIDEBAR -->
        <aside class="sidebar-gradient w-64 flex-shrink-0 overflow-y-auto">
            <div class="p-6">
                <div class="text-white mb-8">
                    <h1 class="text-2xl font-bold">TalaqqiHub</h1>
                    <p class="text-purple-200 text-sm mt-1">Teacher Portal</p>
                </div>
                
                <nav class="space-y-2">
                    <a href="<%= request.getContextPath() %>/teacher/teacherdashboard" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/teacher/classschedule" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-calendar"></i>
                        <span>Class Schedule</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/teacher/attendance" class="flex items-center space-x-3 px-4 py-3 text-white bg-purple-600 rounded-lg">
                        <i class="fas fa-clipboard-check"></i>
                        <span>Attendance</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/teacher/evaluation" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-chart-bar"></i>
                        <span>Evaluation</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/teacher/talaqqisessions" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-tv"></i>
                        <span>Talaqqi Sessions</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/teacher/announcements" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-bullhorn"></i>
                        <span>Announcements</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/teacher/ai" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-magic"></i>
                        <span>AI Assistance</span>
                    </a>
                </nav>
                
                <div class="mt-auto pt-6 border-t border-purple-500">
                    <a href="<%= request.getContextPath() %>/logout" class="flex items-center space-x-3 px-4 py-3 text-purple-100 rounded-lg hover:bg-purple-600 transition">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </div>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="flex-1 overflow-y-auto">
            <!-- HEADER -->
            <header class="bg-white border-b border-gray-200 sticky top-0 z-40">
                <div class="px-8 py-4 flex items-center justify-between">
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900">Attendance</h1>
                        <p class="text-gray-500 text-sm mt-1">Monitor and track attendance records for the current month</p>
                    </div>
                    <div class="flex items-center space-x-4">
                        <button class="relative text-gray-600 hover:text-gray-900">
                            <i class="fas fa-bell text-xl"></i>
                            <span class="absolute top-0 right-0 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">2</span>
                        </button>
                        <div class="w-10 h-10 bg-gradient-to-br from-purple-400 to-purple-600 rounded-full flex items-center justify-center text-white font-bold">UI</div>
                        <div class="text-sm">
                            <p class="font-semibold text-gray-900">${teacherName}</p>
                        </div>
                    </div>
                </div>
            </header>

            <div class="p-8">
                <!-- TOP CARDS -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <!-- Total Students -->
                    <div class="bg-white rounded-xl shadow-sm p-6 border-l-4 border-pink-500">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-gray-600 text-sm font-medium">Total Students</p>
                                <p class="text-3xl font-bold text-gray-900 mt-2">${totalStudents}</p>
                            </div>
                            <div class="w-14 h-14 bg-pink-100 rounded-full flex items-center justify-center">
                                <i class="fas fa-users text-pink-500 text-2xl"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Total Sessions -->
                    <div class="bg-white rounded-xl shadow-sm p-6 border-l-4 border-teal-500">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-gray-600 text-sm font-medium">Total Sessions</p>
                                <p class="text-3xl font-bold text-gray-900 mt-2">${totalSessions}</p>
                            </div>
                            <div class="w-14 h-14 bg-teal-100 rounded-full flex items-center justify-center">
                                <i class="fas fa-calendar-alt text-teal-500 text-2xl"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Attendance Rate -->
                    <div class="bg-white rounded-xl shadow-sm p-6 border-l-4 border-blue-500">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-gray-600 text-sm font-medium">Attendance Rate</p>
                                <p class="text-3xl font-bold text-gray-900 mt-2">${rate}%</p>
                            </div>
                            <div class="w-14 h-14 bg-blue-100 rounded-full flex items-center justify-center">
                                <i class="fas fa-chart-pie text-blue-500 text-2xl"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SECOND ROW CARDS -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <!-- Present -->
                    <div class="bg-white rounded-xl shadow-sm p-6">
                        <div class="flex items-center space-x-4">
                            <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                                <i class="fas fa-check-circle text-green-500 text-xl"></i>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm">Present</p>
                                <p class="text-2xl font-bold text-green-600">${present}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Absent -->
                    <div class="bg-white rounded-xl shadow-sm p-6">
                        <div class="flex items-center space-x-4">
                            <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                                <i class="fas fa-times-circle text-red-500 text-xl"></i>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm">Absent</p>
                                <p class="text-2xl font-bold text-red-600">${absent}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Late -->
                    <div class="bg-white rounded-xl shadow-sm p-6">
                        <div class="flex items-center space-x-4">
                            <div class="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center">
                                <i class="fas fa-hourglass-end text-yellow-500 text-xl"></i>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm">Late</p>
                                <p class="text-2xl font-bold text-yellow-600">${late}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ACTIONS & SEARCH -->
                <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
                    <div class="flex-1 w-full">
                        <input type="text" id="searchInput" placeholder="Search by date, student name, or class..." 
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
                    </div>
                    <div class="flex items-center space-x-2">
                        <select id="monthFilter" class="px-4 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-purple-500">
                            <option value="">Month: Current</option>
                            <option value="all">All Records</option>
                        </select>
                        <select id="classFilter" class="px-4 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-purple-500">
                            <option value="">Class: All</option>
                        </select>
                        <select id="statusFilter" class="px-4 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-purple-500">
                            <option value="">Status: All</option>
                            <option value="Present">Present</option>
                            <option value="Absent">Absent</option>
                            <option value="Late">Late</option>
                        </select>
                    </div>
                    <button id="exportBtn" class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 font-medium">
                        <i class="fas fa-download mr-2"></i>Export
                    </button>
                    <button id="printBtn" class="px-4 py-2 bg-gradient-to-r from-purple-500 to-purple-600 text-white rounded-lg hover:shadow-lg transition font-medium">
                        <i class="fas fa-print mr-2"></i>Print
                    </button>
                </div>

                <!-- ATTENDANCE TABLE -->
                <div class="bg-white rounded-xl shadow-sm overflow-hidden mb-8">
                    <c:choose>
                        <c:when test="${empty records}">
                            <div class="p-8 text-center">
                                <i class="far fa-file-csv text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 text-lg">No attendance records found</p>
                                <p class="text-gray-400 text-sm mt-1">Attendance records will appear here once students mark attendance</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Date</th>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Student Name</th>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Class / Session</th>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Time</th>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Status</th>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Join Time</th>
                                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Leave Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${records}" begin="0" end="9">
                            <tr class="border-b border-gray-200 hover:bg-gray-50 transition">
                                <td class="px-6 py-4 text-sm text-gray-900">
                                    <fmt:formatDate value="${r.sessionDate}" pattern="MMM d, yyyy" />
                                </td>
                                <td class="px-6 py-4 text-sm">
                                    <div class="font-semibold text-gray-900">${r.studentName}</div>
                                    <div class="text-gray-500 text-xs">${r.studentCode}</div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-900">${r.className}</td>
                                <td class="px-6 py-4 text-sm text-gray-900">${r.timeRange}</td>
                                <td class="px-6 py-4 text-sm">
                                    <c:choose>
                                        <c:when test="${r.status == 'Present' || r.status == 'present'}">
                                            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold">Present</span>
                                        </c:when>
                                        <c:when test="${r.status == 'Absent' || r.status == 'absent'}">
                                            <span class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-xs font-semibold">Absent</span>
                                        </c:when>
                                        <c:when test="${r.status == 'Late' || r.status == 'late'}">
                                            <span class="px-3 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-semibold">Late</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-semibold">${r.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-900"><c:out value="${empty r.joinTime ? '-' : r.joinTime}" /></td>
                                <td class="px-6 py-4 text-sm text-gray-900"><c:out value="${empty r.leaveTime ? '-' : r.leaveTime}" /></td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- PAGINATION -->
                <div class="flex items-center justify-between mb-8">
                    <p class="text-sm text-gray-600">Showing 1-10 of ${fn:length(records)} records</p>
                    <div class="flex items-center space-x-2">
                        <button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-500 cursor-not-allowed">Previous</button>
                        <button class="px-4 py-2 bg-purple-600 text-white rounded-lg font-semibold">2</button>
                    </div>
                </div>

                <!-- CHARTS -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <!-- Attendance Distribution -->
                    <div class="bg-white rounded-xl shadow-sm p-6">
                        <h3 class="text-lg font-bold text-gray-900 mb-6">Attendance Distribution</h3>
                        <div style="position: relative; height: 300px;">
                            <canvas id="distributionChart"></canvas>
                        </div>
                        <div class="flex justify-center gap-6 mt-6">
                            <div class="flex items-center space-x-2">
                                <div class="w-4 h-4 bg-green-500 rounded"></div>
                                <span class="text-sm text-gray-600">Present</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-4 h-4 bg-red-500 rounded"></div>
                                <span class="text-sm text-gray-600">Absent</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-4 h-4 bg-yellow-500 rounded"></div>
                                <span class="text-sm text-gray-600">Late</span>
                            </div>
                        </div>
                    </div>

                    <!-- Attendance Trend -->
                    <div class="bg-white rounded-xl shadow-sm p-6">
                        <h3 class="text-lg font-bold text-gray-900 mb-6">Attendance Trend</h3>
                        <div style="position: relative; height: 300px;">
                            <canvas id="trendChart"></canvas>
                        </div>
                        <div class="flex justify-center gap-6 mt-6">
                            <div class="flex items-center space-x-2">
                                <div class="w-4 h-4 bg-green-500 rounded"></div>
                                <span class="text-sm text-gray-600">Present</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-4 h-4 bg-red-500 rounded"></div>
                                <span class="text-sm text-gray-600">Absent</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-4 h-4 bg-yellow-500 rounded"></div>
                                <span class="text-sm text-gray-600">Late</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Attendance Distribution Chart (Donut)
        const distributionCtx = document.getElementById('distributionChart').getContext('2d');
        const distributionChart = new Chart(distributionCtx, {
            type: 'doughnut',
            data: {
                labels: ['Present', 'Absent', 'Late'],
                datasets: [{
                    data: [${present}, ${absent}, ${late}],
                    backgroundColor: ['#10b981', '#ef4444', '#f59e0b'],
                    borderColor: ['#10b981', '#ef4444', '#f59e0b'],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });

        // Attendance Trend Chart (Bar)
        const trendCtx = document.getElementById('trendChart').getContext('2d');
        const trendChart = new Chart(trendCtx, {
            type: 'bar',
            data: {
                labels: ${weekLabelsJson},
                datasets: [
                    {
                        label: 'Present',
                        data: ${presentDataJson},
                        backgroundColor: '#10b981'
                    },
                    {
                        label: 'Absent',
                        data: ${absentDataJson},
                        backgroundColor: '#ef4444'
                    },
                    {
                        label: 'Late',
                        data: ${lateDataJson},
                        backgroundColor: '#f59e0b'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 12
                    }
                }
            }
        });

        // ===== SEARCH & FILTER FUNCTIONALITY =====
        const searchInput = document.getElementById('searchInput');
        const monthFilter = document.getElementById('monthFilter');
        const classFilter = document.getElementById('classFilter');
        const statusFilter = document.getElementById('statusFilter');
        const exportBtn = document.getElementById('exportBtn');
        const printBtn = document.getElementById('printBtn');
        const tableRows = document.querySelectorAll('tbody tr');
        
        // Build month filter dropdown from table data
        const uniqueMonths = new Set();
        
        tableRows.forEach(row => {
            const dateCell = row.querySelector('td:nth-child(1)')?.textContent.trim();
            if (dateCell && dateCell !== '') {
                // Parse the date (format: "MMM d, yyyy") and extract "MMM yyyy"
                const parts = dateCell.split(' ');
                if (parts.length >= 2) {
                    // Get month and year (e.g., "Apr 2026")
                    const monthYear = parts[0] + ' ' + parts[parts.length - 1];
                    uniqueMonths.add(monthYear);
                }
            }
        });
        
        // Sort months in descending order (newest first)
        const monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const sortedMonths = Array.from(uniqueMonths).sort((a, b) => {
            const [monthA, yearA] = a.split(' ');
            const [monthB, yearB] = b.split(' ');
            
            const yearDiff = parseInt(yearB) - parseInt(yearA);
            if (yearDiff !== 0) return yearDiff;
            
            return monthOrder.indexOf(monthB) - monthOrder.indexOf(monthA);
        });
        
        sortedMonths.forEach(monthYear => {
            const option = document.createElement('option');
            option.value = monthYear;
            option.textContent = 'Month: ' + monthYear;
            monthFilter.appendChild(option);
        });
        
        // Build class filter dropdown from table data
        const uniqueClasses = new Set();
        tableRows.forEach(row => {
            const classCell = row.querySelector('td:nth-child(3)')?.textContent.trim();
            if (classCell && classCell !== '') {
                uniqueClasses.add(classCell);
            }
        });
        
        uniqueClasses.forEach(className => {
            const option = document.createElement('option');
            option.value = className;
            option.textContent = className;
            classFilter.appendChild(option);
        });
        
        // Search and Filter Function
        function filterTable() {
            const searchTerm = searchInput.value.toLowerCase();
            const selectedMonth = monthFilter.value;
            const selectedClass = classFilter.value;
            const selectedStatus = statusFilter.value;
            let visibleCount = 0;
            
            tableRows.forEach(row => {
                const dateCell = row.querySelector('td:nth-child(1)')?.textContent.trim() || '';
                
                // Extract month and year from date (format: "MMM d, yyyy")
                const parts = dateCell.split(' ');
                let rowMonthYear = '';
                if (parts.length >= 2) {
                    rowMonthYear = parts[0] + ' ' + parts[parts.length - 1];
                }
                
                const date = row.querySelector('td:nth-child(1)')?.textContent.toLowerCase() || '';
                const studentName = row.querySelector('td:nth-child(2)')?.textContent.toLowerCase() || '';
                const className = row.querySelector('td:nth-child(3)')?.textContent.trim() || '';
                const status = row.querySelector('td:nth-child(5)')?.textContent.trim() || '';
                
                // Check search term
                const matchesSearch = !searchTerm || 
                    date.includes(searchTerm) || 
                    studentName.includes(searchTerm) || 
                    className.toLowerCase().includes(searchTerm);
                
                // Check month filter
                const matchesMonth = !selectedMonth || rowMonthYear === selectedMonth;
                
                // Check class filter
                const matchesClass = !selectedClass || className === selectedClass;
                
                // Check status filter
                const matchesStatus = !selectedStatus || status === selectedStatus;
                
                const shouldShow = matchesSearch && matchesMonth && matchesClass && matchesStatus;
                row.style.display = shouldShow ? '' : 'none';
                
                if (shouldShow) visibleCount++;
            });
            
            // Show/hide empty state message
            const emptyState = document.querySelector('.bg-gray-50.rounded-xl');
            if (emptyState && tableRows.length === 0) {
                emptyState.style.display = visibleCount === 0 ? 'block' : 'none';
            }
        }
        
        // Export to CSV Function
        function exportToCSV() {
            const table = document.querySelector('table');
            if (!table) return;
            
            let csv = [];
            const rows = table.querySelectorAll('tr');
            
            rows.forEach(row => {
                const cols = row.querySelectorAll('td, th');
                let csvRow = [];
                cols.forEach(col => {
                    csvRow.push('"' + col.textContent.trim().replace(/"/g, '""') + '"');
                });
                csv.push(csvRow.join(','));
            });
            
            const csvContent = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv.join('\n'));
            const link = document.createElement('a');
            link.setAttribute('href', csvContent);
            link.setAttribute('download', 'attendance_' + new Date().toISOString().split('T')[0] + '.csv');
            link.click();
        }
        
        // Print Function
        function printTable() {
            const table = document.querySelector('table');
            if (!table) return;
            
            const printWindow = window.open('', '', 'height=600,width=800');
            printWindow.document.write('<html><head><title>Attendance Report</title>');
            printWindow.document.write('<style>');
            printWindow.document.write('body { font-family: Arial, sans-serif; margin: 20px; }');
            printWindow.document.write('h1 { color: #333; text-align: center; }');
            printWindow.document.write('table { width: 100%; border-collapse: collapse; margin-top: 20px; }');
            printWindow.document.write('th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }');
            printWindow.document.write('th { background-color: #f0f0f0; font-weight: bold; }');
            printWindow.document.write('tr:nth-child(even) { background-color: #f9f9f9; }');
            printWindow.document.write('tr:hover { background-color: #f0f0f0; }');
            printWindow.document.write('.present { background-color: #d1fae5; color: #065f46; }');
            printWindow.document.write('.absent { background-color: #fee2e2; color: #991b1b; }');
            printWindow.document.write('.late { background-color: #fef3c7; color: #92400e; }');
            printWindow.document.write('@media print { .no-print { display: none; } }');
            printWindow.document.write('</style></head><body>');
            printWindow.document.write('<h1>Attendance Report</h1>');
            printWindow.document.write('<p><strong>Generated:</strong> ' + new Date().toLocaleString() + '</p>');
            printWindow.document.write(table.outerHTML);
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            
            setTimeout(() => {
                printWindow.print();
            }, 250);
        }
        
        // Event Listeners
        if (searchInput) searchInput.addEventListener('keyup', filterTable);
        if (monthFilter) monthFilter.addEventListener('change', filterTable);
        if (classFilter) classFilter.addEventListener('change', filterTable);
        if (statusFilter) statusFilter.addEventListener('change', filterTable);
        if (exportBtn) exportBtn.addEventListener('click', exportToCSV);
        if (printBtn) printBtn.addEventListener('click', printTable);
        
        // Auto-select current month on page load
        const today = new Date();
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const currentMonth = monthNames[today.getMonth()];
        const currentYear = today.getFullYear();
        const currentMonthYear = currentMonth + ' ' + currentYear;
        
        // Find and select the current month option
        for (let option of monthFilter.options) {
            if (option.value === currentMonthYear) {
                monthFilter.value = currentMonthYear;
                break;
            }
        }
        
        // Apply current month filter on page load
        filterTable();
    </script>
</body>
</html>
