/**
 * Admin Talaqqi Sessions Management Script
 * Handles filtering, searching, export and interactions
 */

let currentTableData = [];

document.addEventListener('DOMContentLoaded', function() {
    initializeEventListeners();
    initializeTableData();
});

function initializeEventListeners() {
    // Search input
    const searchInput = document.querySelector('input[placeholder="Search student or teacher..."]');
    if (searchInput) {
        searchInput.addEventListener('input', applyFilters);
    }

    // Teacher dropdown
    const teacherSelect = document.querySelector('select');
    if (teacherSelect) {
        teacherSelect.addEventListener('change', applyFilters);
    }

    // Date inputs
    const dateInputs = document.querySelectorAll('input[type="date"]');
    if (dateInputs.length >= 2) {
        dateInputs[0].addEventListener('change', applyFilters);
        dateInputs[1].addEventListener('change', applyFilters);
    }

    // Export buttons - find them by their text and button containers
    const allButtons = document.querySelectorAll('button, input[type="button"]');
    allButtons.forEach(btn => {
        const text = btn.textContent || btn.value;
        if (text.includes('Export PDF') || text.includes('PDF')) {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                exportToPDF();
            });
        }
    });

    // Find export buttons in second row
    const exportSection = document.querySelector('.flex.justify-end');
    if (exportSection) {
        const exportButtons = exportSection.querySelectorAll('button');
        if (exportButtons[0]) {
            exportButtons[0].addEventListener('click', (e) => {
                e.preventDefault();
                exportToCSV();
            });
        }
        if (exportButtons[1]) {
            exportButtons[1].addEventListener('click', (e) => {
                e.preventDefault();
                exportToExcel();
            });
        }
        if (exportButtons[2]) {
            exportButtons[2].addEventListener('click', (e) => {
                e.preventDefault();
                printTable();
            });
        }
    }

    // Modal close buttons
    setupModalCloseHandlers();
}

function initializeTableData() {
    // Capture current table data into an array for filtering
    const tableRows = document.querySelectorAll('tbody tr');
    currentTableData = [];
    
    tableRows.forEach(row => {
        if (row.textContent.includes('No sessions found')) return;
        
        const cells = row.querySelectorAll('td');
        if (cells.length > 0) {
            currentTableData.push({
                sessionId: cells[0].textContent.trim(),
                studentName: cells[1].textContent.trim(),
                teacherName: cells[2].textContent.trim(),
                classType: cells[3].textContent.trim(),
                sessionDate: cells[4].textContent.trim(),
                time: cells[5].textContent.trim(),
                duration: cells[6].textContent.trim(),
                status: cells[7].textContent.trim(),
                completedAt: cells[8].textContent.trim(),
                element: row
            });
        }
    });
}

function applyFilters() {
    const searchInput = document.querySelector('input[placeholder="Search student or teacher..."]').value.toLowerCase();
    const teacherFilter = document.querySelector('select').value;
    const dateFromValue = document.querySelectorAll('input[type="date"]')[0].value;
    const dateToValue = document.querySelectorAll('input[type="date"]')[1].value;

    currentTableData.forEach(data => {
        let show = true;

        // Search filter
        if (searchInput) {
            const matchesSearch = data.studentName.toLowerCase().includes(searchInput) ||
                                data.teacherName.toLowerCase().includes(searchInput);
            show = show && matchesSearch;
        }

        // Teacher filter
        if (teacherFilter && teacherFilter !== 'All Teachers') {
            show = show && data.teacherName === teacherFilter;
        }

        // Date range filter
        if (dateFromValue) {
            const sessionDate = new Date(parseDate(data.sessionDate));
            const dateFrom = new Date(dateFromValue);
            show = show && sessionDate >= dateFrom;
        }

        if (dateToValue) {
            const sessionDate = new Date(parseDate(data.sessionDate));
            const dateTo = new Date(dateToValue);
            dateTo.setHours(23, 59, 59, 999);
            show = show && sessionDate <= dateTo;
        }

        // Show or hide the row
        data.element.style.display = show ? '' : 'none';
    });

    updatePaginationInfo();
}

function parseDate(dateString) {
    // Parse "MMM dd, yyyy" format to "yyyy-MM-dd"
    const months = {
        'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
        'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
        'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };
    
    const parts = dateString.split(' ');
    const month = months[parts[0]];
    const day = parts[1].replace(',', '').padStart(2, '0');
    const year = parts[2];
    
    return `${year}-${month}-${day}`;
}

function updatePaginationInfo() {
    const visibleRows = document.querySelectorAll('tbody tr:not([style="display: none;"])');
    const totalRows = currentTableData.length;
    const visibleCount = visibleRows.length;

    const paginationText = document.querySelector('.px-6.py-4.border-t');
    if (paginationText) {
        if (visibleCount === 0 && totalRows > 0) {
            paginationText.textContent = 'No sessions match the applied filters';
        } else if (visibleCount > 0) {
            paginationText.textContent = `Showing 1-${visibleCount} of ${totalRows} sessions`;
        }
    }
}

function setupModalCloseHandlers() {
    // Close modal by clicking outside the modal box
    const modal = document.querySelector('.fixed.inset-0');
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });
    }
}

function closeModal() {
    const modal = document.querySelector('.fixed.inset-0');
    if (modal) {
        modal.style.display = 'none';
    }
    // Also clear the viewId parameter from URL
    window.history.replaceState({}, document.title, window.location.pathname);
}

function exportToPDF() {
    const sessions = getFilteredSessionData();
    
    if (sessions.length === 0) {
        alert('No sessions to export');
        return;
    }

    // Create a new window for printing
    const printWindow = window.open('', '', 'height=600,width=800');
    
    let htmlContent = `
        <html>
        <head>
            <title>Talaqqi Sessions Report</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                h1 { text-align: center; color: #333; }
                table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                th { background-color: #7C3AED; color: white; padding: 10px; text-align: left; border: 1px solid #ddd; }
                td { padding: 8px; border: 1px solid #ddd; }
                tr:nth-child(even) { background-color: #f9f9f9; }
                .summary { margin: 20px 0; padding: 10px; background-color: #f0f0f0; }
                .footer { margin-top: 30px; font-size: 12px; color: #666; }
            </style>
        </head>
        <body>
            <h1>Talaqqi Sessions Report</h1>
            <div class="summary">
                <p><strong>Total Sessions:</strong> ${sessions.length}</p>
                <p><strong>Report Generated:</strong> ${new Date().toLocaleString()}</p>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Session ID</th>
                        <th>Student</th>
                        <th>Teacher</th>
                        <th>Date</th>
                        <th>Duration</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
    `;

    sessions.forEach(session => {
        htmlContent += `
            <tr>
                <td>${escapeHtml(session.sessionId)}</td>
                <td>${escapeHtml(session.studentName)}</td>
                <td>${escapeHtml(session.teacherName)}</td>
                <td>${escapeHtml(session.sessionDate)}</td>
                <td>${escapeHtml(session.duration)}</td>
                <td>${escapeHtml(session.status)}</td>
            </tr>
        `;
    });

    htmlContent += `
                </tbody>
            </table>
            <div class="footer">
                <p>This is an auto-generated report from TalaqqiHub Admin Portal</p>
            </div>
        </body>
        </html>
    `;

    printWindow.document.write(htmlContent);
    printWindow.document.close();
    
    // Trigger print dialog
    setTimeout(() => {
        printWindow.print();
    }, 250);
}

function exportToCSV() {
    const sessions = getFilteredSessionData();
    
    if (sessions.length === 0) {
        alert('No sessions to export');
        return;
    }

    let csv = 'Session ID,Student Name,Teacher Name,Class Type,Session Date,Time,Duration,Status,Completed At\n';
    
    sessions.forEach(session => {
        csv += `"${session.sessionId}","${session.studentName}","${session.teacherName}","${session.classType}","${session.sessionDate}","${session.time}","${session.duration}","${session.status}","${session.completedAt}"\n`;
    });

    downloadFile(csv, 'talaqqi-sessions.csv', 'text/csv');
}

function exportToExcel() {
    const sessions = getFilteredSessionData();
    
    if (sessions.length === 0) {
        alert('No sessions to export');
        return;
    }

    let html = '<table><tr><th>Session ID</th><th>Student Name</th><th>Teacher Name</th><th>Class Type</th><th>Session Date</th><th>Time</th><th>Duration</th><th>Status</th><th>Completed At</th></tr>';
    
    sessions.forEach(session => {
        html += `<tr><td>${session.sessionId}</td><td>${session.studentName}</td><td>${session.teacherName}</td><td>${session.classType}</td><td>${session.sessionDate}</td><td>${session.time}</td><td>${session.duration}</td><td>${session.status}</td><td>${session.completedAt}</td></tr>`;
    });
    
    html += '</table>';

    const data = new Blob([html], { type: 'application/vnd.ms-excel' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(data);
    link.download = 'talaqqi-sessions.xls';
    link.click();
}

function printTable() {
    const sessions = getFilteredSessionData();
    
    if (sessions.length === 0) {
        alert('No sessions to print');
        return;
    }

    const printWindow = window.open('', '', 'height=600,width=800');
    
    let htmlContent = `
        <html>
        <head>
            <title>Talaqqi Sessions</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 10px; }
                h1 { text-align: center; color: #333; font-size: 24px; }
                table { width: 100%; border-collapse: collapse; margin-top: 15px; }
                th { background-color: #7C3AED; color: white; padding: 10px; text-align: left; border: 1px solid #ddd; }
                td { padding: 8px; border: 1px solid #ddd; font-size: 13px; }
                tr:nth-child(even) { background-color: #f9f9f9; }
                @media print {
                    body { margin: 0; }
                }
            </style>
        </head>
        <body>
            <h1>Talaqqi Sessions Report</h1>
            <p style="text-align: center; color: #666;">Generated on ${new Date().toLocaleString()}</p>
            <table>
                <thead>
                    <tr>
                        <th>Session ID</th>
                        <th>Student</th>
                        <th>Teacher</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Duration</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
    `;

    sessions.forEach(session => {
        htmlContent += `
            <tr>
                <td>${escapeHtml(session.sessionId)}</td>
                <td>${escapeHtml(session.studentName)}</td>
                <td>${escapeHtml(session.teacherName)}</td>
                <td>${escapeHtml(session.sessionDate)}</td>
                <td>${escapeHtml(session.time)}</td>
                <td>${escapeHtml(session.duration)}</td>
                <td>${escapeHtml(session.status)}</td>
            </tr>
        `;
    });

    htmlContent += `
                </tbody>
            </table>
        </body>
        </html>
    `;

    printWindow.document.write(htmlContent);
    printWindow.document.close();
    
    setTimeout(() => {
        printWindow.print();
    }, 250);
}

function getFilteredSessionData() {
    return currentTableData
        .filter(session => session.element.style.display !== 'none')
        .map(session => ({
            sessionId: session.sessionId,
            studentName: session.studentName,
            teacherName: session.teacherName,
            classType: session.classType,
            sessionDate: session.sessionDate,
            time: session.time,
            duration: session.duration,
            status: session.status,
            completedAt: session.completedAt
        }));
}

function downloadFile(content, filename, type) {
    const data = new Blob([content], { type: type });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(data);
    link.download = filename;
    link.click();
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}
