<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/student-attendance-responsive.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .glass-effect { backdrop-filter: blur(10px); }
        .card-hover { transition: all 0.3s ease; }
        .card-hover:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .stat-card { background: linear-gradient(135deg, var(--tw-gradient-from) 0%, var(--tw-gradient-to) 100%); }
        .fade-in { animation: fadeIn 0.6s ease-in; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .pulse-dot { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="attendance"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Attendance"/>
            <jsp:param name="notifPrefix" value="attendanceNotif"/>
        </jsp:include>

        <div class="page-content student-attendance">
            <p class="page-subtitle attendance-subtitle" style="margin-top:-24px;margin-bottom:32px;"><span class="w-2 h-2 bg-green-500 rounded-full mr-2 inline-block"></span>Track your session history</p>

                    <!-- TOP ACTIONS -->
                    <div class="attendance-toolbar">
                        <div></div>
                        <div class="attendance-toolbar-actions">
                            <button id="exportBtn" class="bg-gradient-to-r from-teal-500 to-green-600 hover:from-teal-600 hover:to-green-700 text-white px-6 py-2.5 rounded-lg flex items-center transition shadow-lg hover:shadow-xl transform hover:scale-105">
                                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                                </svg>
                                Export
                            </button>
                            <button id="printBtn" class="border-2 border-gray-400 hover:border-gray-600 text-gray-700 px-6 py-2.5 rounded-lg flex items-center transition hover:bg-gray-100 shadow-md">
                                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4H7a2 2 0 01-2-2v-4a2 2 0 012-2h10a2 2 0 012 2v4a2 2 0 01-2 2zm-6-4a2 2 0 100-4 2 2 0 000 4z"></path>
                                </svg>
                                Print
                            </button>
                        </div>
                    </div>
                    
                    <!-- SEARCH BAR -->
                    <div class="mb-8">
                        <div class="relative">
                            <svg class="absolute left-4 top-3.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                            </svg>
                            <input type="text" placeholder="Search by date, session, or teacher..." 
                                   class="attendance-search-input w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent shadow-sm hover:border-gray-300 transition">
                        </div>
                    </div>
                    
                    <!-- STATS CARDS -->
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                        <!-- Total Sessions Card -->
                        <div class="fade-in card-hover bg-white rounded-2xl p-6 shadow-sm hover:shadow-md">
                            <div class="flex items-start justify-between">
                                <div>
                                    <p class="text-gray-500 text-sm font-medium">Total Sessions</p>
                                    <p class="attendance-stat-value text-4xl font-bold text-gray-900 mt-2">${total}</p>
                                </div>
                                <div class="w-14 h-14 bg-teal-100 rounded-2xl flex items-center justify-center flex-shrink-0">
                                    <svg class="w-7 h-7 text-teal-600" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm3.5-9c.83 0 1.5-.67 1.5-1.5S16.33 8 15.5 8 14 8.67 14 9.5s.67 1.5 1.5 1.5zm-7 0c.83 0 1.5-.67 1.5-1.5S9.33 8 8.5 8 7 8.67 7 9.5 7.67 11 8.5 11zm3.5 6.5c2.33 0 4.31-1.46 5.11-3.5H6.89c.8 2.04 2.78 3.5 5.11 3.5z"></path>
                                    </svg>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Present Card -->
                        <div class="fade-in card-hover bg-white rounded-2xl p-6 shadow-sm hover:shadow-md">
                            <div class="flex items-start justify-between">
                                <div>
                                    <p class="text-gray-500 text-sm font-medium">Present</p>
                                    <p class="attendance-stat-value text-4xl font-bold text-green-600 mt-2">${present}</p>
                                </div>
                                <div class="w-14 h-14 bg-green-100 rounded-2xl flex items-center justify-center flex-shrink-0">
                                    <svg class="w-7 h-7 text-green-600" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"></path>
                                    </svg>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Absent Card -->
                        <div class="fade-in card-hover bg-white rounded-2xl p-6 shadow-sm hover:shadow-md">
                            <div class="flex items-start justify-between">
                                <div>
                                    <p class="text-gray-500 text-sm font-medium">Absent</p>
                                    <p class="attendance-stat-value text-4xl font-bold text-red-600 mt-2">${absent}</p>
                                </div>
                                <div class="w-14 h-14 bg-red-100 rounded-2xl flex items-center justify-center flex-shrink-0">
                                    <svg class="w-7 h-7 text-red-600" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z"></path>
                                    </svg>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Attendance Rate Card -->
                        <div class="fade-in card-hover bg-white rounded-2xl p-6 shadow-sm hover:shadow-md">
                            <div class="flex items-start justify-between">
                                <div>
                                    <p class="text-gray-500 text-sm font-medium">Attendance Rate <span class="text-gray-400">ⓘ</span></p>
                                    <p class="attendance-stat-value text-4xl font-bold text-teal-700 mt-2">${rate}%</p>
                                </div>
                                <div class="w-14 h-14 bg-emerald-100 rounded-2xl flex items-center justify-center flex-shrink-0">
                                    <svg class="w-7 h-7 text-emerald-600" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zM9 17H7v-7h2V17zm4 0h-2V7h2V17zm4 0h-2v-4h2V17z"></path>
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- CHARTS SECTION -->
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                        <!-- Attendance Distribution Chart -->
                        <div class="fade-in card-hover bg-white rounded-2xl shadow-lg p-8 hover:shadow-xl attendance-chart-panel">
                            <h3 class="text-xl font-bold text-gray-800 mb-8">Attendance Distribution</h3>
                            <div class="flex justify-center items-center min-h-60 max-w-sm mx-auto">
                                <canvas id="distributionChart"></canvas>
                            </div>
                        </div>
                        
                        <!-- Attendance Trend Chart -->
                        <div class="fade-in card-hover bg-white rounded-2xl shadow-lg p-8 hover:shadow-xl attendance-chart-panel">
                            <h3 class="text-xl font-bold text-gray-800 mb-8">Attendance Trend</h3>
                            <div class="flex justify-center items-center min-h-80">
                                <div class="w-full" style="height: 300px;">
                                    <canvas id="trendChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- ATTENDANCE RECORDS TABLE -->
                    <div class="fade-in card-hover bg-white rounded-2xl shadow-lg overflow-hidden attendance-records-panel">
                        <div class="px-8 py-6 border-b border-gray-200 attendance-records-header">
                            <div class="flex justify-between items-center">
                                <h3 class="text-2xl font-bold text-gray-800">Attendance Records</h3>
                            </div>
                        </div>
                        <div class="overflow-x-auto attendance-table-wrap">
                            <table class="w-full attendance-table">
                                <thead class="border-b-2 border-gray-200 bg-white">
                                    <tr>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Date</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Session</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Teacher</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Time</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Status</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Join Time</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Leave Time</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <c:choose>
                                        <c:when test="${empty records}">
                                            <tr>
                                                <td colspan="7" class="px-6 py-12 text-center">
                                                    <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                                    </svg>
                                                    <p class="text-lg text-gray-500 font-medium">No attendance records found</p>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="record" items="${records}" varStatus="status">
                                                <tr class="hover:bg-gray-50 transition-colors duration-200 bg-white">
                                                    <td class="px-6 py-4 text-sm text-gray-700">
                                                        ${record.sessionDate}
                                                    </td>
                                                    <td class="px-6 py-4 text-sm font-semibold text-gray-800">${record.sessionName}</td>
                                                    <td class="px-6 py-4 text-sm text-gray-500">${record.teacherName}</td>
                                                    <td class="px-6 py-4 text-sm text-gray-700">${record.timeRange}</td>
                                                    <td class="px-6 py-4 text-sm">
                                                        <c:choose>
                                                            <c:when test="${record.status == 'Present'}">
                                                                <span class="bg-green-500 text-white px-3 py-1 rounded-full text-xs font-semibold">Present</span>
                                                            </c:when>
                                                            <c:when test="${record.status == 'Absent'}">
                                                                <span class="bg-red-500 text-white px-3 py-1 rounded-full text-xs font-semibold">Absent</span>
                                                            </c:when>
                                                            <c:when test="${record.status == 'Late'}">
                                                                <span class="bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-semibold">Late</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td class="px-6 py-4 text-sm text-gray-700">
                                                        <c:choose>
                                                            <c:when test="${record.status == 'Absent' or empty record.joinTime}">-</c:when>
                                                            <c:otherwise>${record.joinTime}</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="px-6 py-4 text-sm text-gray-700">
                                                        <c:choose>
                                                            <c:when test="${record.status == 'Absent' or empty record.leaveTime}">-</c:when>
                                                            <c:otherwise>${record.leaveTime}</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
        </div>
    </div>
    
    <script>
        // Chart.js Global Settings
        Chart.defaults.font.family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
        
        // Attendance Distribution Chart (Donut)
        const distributionCtx = document.getElementById('distributionChart').getContext('2d');
        const totalAttendance = ${total};
        const presentCount = ${present};
        const absentCount = ${absent};
        const lateCount = ${late};
        
        const distributionChart = new Chart(distributionCtx, {
            type: 'doughnut',
            data: {
                labels: ['Present', 'Absent', 'Late'],
                datasets: [{
                    data: [presentCount, absentCount, lateCount],
                    backgroundColor: ['#10b981', '#ef4444', '#f59e0b'],
                    borderColor: ['#ffffff', '#ffffff', '#ffffff'],
                    borderWidth: 3,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                layout: {
                    padding: 20
                },
                plugins: {
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.85)',
                        padding: 14,
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        borderColor: '#ffffff',
                        borderWidth: 1,
                        displayColors: true,
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed;
                                const percentage = totalAttendance > 0 ? ((value / totalAttendance) * 100).toFixed(1) : 0;
                                return label + ': ' + value + ' (' + percentage + '%)';
                            }
                        }
                    },
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 25,
                            font: { size: 13, weight: 'bold' },
                            usePointStyle: true,
                            pointStyle: 'circle',
                            color: '#1f2937'
                        }
                    }
                }
            }
        });
        
        // Attendance Trend Chart (Bar)
        const trendCtx = document.getElementById('trendChart').getContext('2d');

        const presentData = ${presentTrendJson};
        const absentData = ${absentTrendJson};
        const lateData = ${lateTrendJson};
        const trendMax = Math.max(4, ...presentData, ...absentData, ...lateData);
        
        const trendChart = new Chart(trendCtx, {
            type: 'bar',
            data: {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [
                    {
                        label: 'Present',
                        data: presentData,
                        backgroundColor: '#10b981',
                        borderRadius: 6,
                        borderSkipped: false,
                        hoverBackgroundColor: '#059669',
                        barPercentage: 0.7,
                        categoryPercentage: 0.8
                    },
                    {
                        label: 'Absent',
                        data: absentData,
                        backgroundColor: '#ef4444',
                        borderRadius: 6,
                        borderSkipped: false,
                        hoverBackgroundColor: '#dc2626',
                        barPercentage: 0.7,
                        categoryPercentage: 0.8
                    },
                    {
                        label: 'Late',
                        data: lateData,
                        backgroundColor: '#f59e0b',
                        borderRadius: 6,
                        borderSkipped: false,
                        hoverBackgroundColor: '#d97706',
                        barPercentage: 0.7,
                        categoryPercentage: 0.8
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.85)',
                        padding: 14,
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        borderColor: '#ffffff',
                        borderWidth: 1,
                        displayColors: true
                    },
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 25,
                            font: { size: 13, weight: 'bold' },
                            usePointStyle: true,
                            pointStyle: 'rect',
                            color: '#1f2937'
                        }
                    }
                },
                scales: {
                    x: {
                        stacked: false,
                        grid: {
                            display: false,
                            drawBorder: false
                        },
                        ticks: {
                            font: { size: 13, weight: 'bold' },
                            color: '#6b7280',
                            padding: 10
                        }
                    },
                    y: {
                        beginAtZero: true,
                        stacked: false,
                        max: trendMax,
                        ticks: {
                            stepSize: Math.max(1, Math.ceil(trendMax / 4)),
                            font: { size: 12, weight: '500' },
                            color: '#9ca3af',
                            padding: 8
                        },
                        grid: {
                            color: '#e5e7eb',
                            drawBorder: false,
                            drawTicks: true
                        }
                    }
                }
            }
        });
        
        // Export to CSV function
        document.getElementById('exportBtn').addEventListener('click', function() {
            const table = document.querySelector('table');
            let csv = [];
            
            // Get headers
            const headers = [];
            table.querySelectorAll('thead th').forEach(th => {
                headers.push(th.textContent.trim());
            });
            csv.push(headers.join(','));
            
            // Get rows
            table.querySelectorAll('tbody tr').forEach(tr => {
                const row = [];
                tr.querySelectorAll('td').forEach(td => {
                    let text = td.textContent.trim();
                    // Handle status badges - extract text content
                    const span = td.querySelector('span');
                    if (span) {
                        text = span.textContent.trim();
                    }
                    // Escape quotes and wrap in quotes
                    text = '"' + text.replace(/"/g, '""') + '"';
                    row.push(text);
                });
                if (row.length > 0) {
                    csv.push(row.join(','));
                }
            });
            
            // Create CSV blob and download
            const csvContent = csv.join('\n');
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            const url = URL.createObjectURL(blob);
            
            link.setAttribute('href', url);
            link.setAttribute('download', 'attendance_records_' + new Date().toISOString().slice(0, 10) + '.csv');
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
        
        // Print function
        document.getElementById('printBtn').addEventListener('click', function() {
            const printWindow = window.open('', '', 'height=600,width=900');
            const table = document.querySelector('table').outerHTML;
            const title = 'Attendance Records - ' + new Date().toLocaleDateString();
            const printDate = 'Printed on ' + new Date().toLocaleString();
            
            const htmlContent = '<!DOCTYPE html>' +
                '<html>' +
                '<head>' +
                '<title>' + title + '</title>' +
                '<style>' +
                'body { font-family: Arial, sans-serif; margin: 20px; background: white; }' +
                'h1 { text-align: center; color: #1f2937; margin-bottom: 10px; font-size: 24px; }' +
                '.print-date { text-align: center; color: #6b7280; margin-bottom: 20px; font-size: 14px; }' +
                'table { width: 100%; border-collapse: collapse; margin-top: 20px; }' +
                'thead { background-color: #f3f4f6; }' +
                'th { padding: 12px; text-align: left; font-weight: 600; border-bottom: 2px solid #d1d5db; color: #1f2937; }' +
                'td { padding: 10px 12px; border-bottom: 1px solid #e5e7eb; }' +
                'tbody tr:nth-child(even) { background-color: #f9fafb; }' +
                'tbody tr:hover { background-color: #f0f9ff; }' +
                '@media print { body { margin: 10px; } table { page-break-inside: avoid; } }' +
                '</style>' +
                '</head>' +
                '<body>' +
                '<h1>Attendance Records</h1>' +
                '<div class="print-date">' + printDate + '</div>' +
                table +
                '</body>' +
                '</html>';
            
            printWindow.document.write(htmlContent);
            printWindow.document.close();
            setTimeout(() => {
                printWindow.print();
            }, 250);
        });
    </script>
</body>
</html>
