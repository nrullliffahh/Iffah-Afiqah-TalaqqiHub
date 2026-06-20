/**
 * Admin Talaqqi Sessions Management Script
 * Handles filtering, searching, export and interactions
 */

let currentTableData = [];

document.addEventListener('DOMContentLoaded', function() {
    initializeEventListeners();
    initializeTableData();
    applyFilters();
});

function initializeEventListeners() {
    const searchInput = document.getElementById('filterSearch');
    if (searchInput) searchInput.addEventListener('input', applyFilters);

    const teacherSelect = document.getElementById('filterTeacher');
    if (teacherSelect) teacherSelect.addEventListener('change', applyFilters);

    const dateFrom = document.getElementById('filterDateFrom');
    const dateTo = document.getElementById('filterDateTo');
    if (dateFrom) dateFrom.addEventListener('change', applyFilters);
    if (dateTo) dateTo.addEventListener('change', applyFilters);

    const pdfBtn = document.getElementById('exportPdfBtn');
    const csvBtn = document.getElementById('exportCsvBtn');
    const excelBtn = document.getElementById('exportExcelBtn');
    const printBtn = document.getElementById('printBtn');

    if (pdfBtn) pdfBtn.addEventListener('click', function(e) { e.preventDefault(); exportToPDF(); });
    if (csvBtn) csvBtn.addEventListener('click', function(e) { e.preventDefault(); exportToCSV(); });
    if (excelBtn) excelBtn.addEventListener('click', function(e) { e.preventDefault(); exportToExcel(); });
    if (printBtn) printBtn.addEventListener('click', function(e) { e.preventDefault(); printTable(); });

    setupModalCloseHandlers();
}

function initializeTableData() {
    currentTableData = [];
    const tableRows = document.querySelectorAll('#sessionsTable tbody tr[data-student]');

    tableRows.forEach(function(row) {
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
    const searchInput = document.getElementById('filterSearch');
    const teacherSelect = document.getElementById('filterTeacher');
    const dateFromEl = document.getElementById('filterDateFrom');
    const dateToEl = document.getElementById('filterDateTo');

    const search = searchInput ? searchInput.value.toLowerCase().trim() : '';
    const teacherFilter = teacherSelect ? teacherSelect.value : '';
    const dateFromValue = dateFromEl ? dateFromEl.value : '';
    const dateToValue = dateToEl ? dateToEl.value : '';

    let visibleCount = 0;

    currentTableData.forEach(function(data) {
        let show = true;

        if (search) {
            const matchesSearch = data.studentName.toLowerCase().includes(search) ||
                                data.teacherName.toLowerCase().includes(search);
            show = show && matchesSearch;
        }

        if (teacherFilter) {
            show = show && data.teacherName === teacherFilter;
        }

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

        data.element.style.display = show ? '' : 'none';
        if (show) visibleCount++;
    });

    updatePaginationInfo(visibleCount);
}

function parseDate(dateString) {
    const months = {
        'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
        'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
        'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    const parts = dateString.split(' ');
    const month = months[parts[0]];
    const day = parts[1].replace(',', '').padStart(2, '0');
    const year = parts[2];

    return year + '-' + month + '-' + day;
}

function updatePaginationInfo(visibleCount) {
    const countEl = document.getElementById('recordCount');
    const totalRows = currentTableData.length;
    if (!countEl) return;

    if (totalRows === 0) {
        countEl.textContent = 'No sessions available';
    } else if (visibleCount === 0) {
        countEl.textContent = 'No sessions match the applied filters';
    } else {
        countEl.textContent = 'Showing 1-' + visibleCount + ' of ' + totalRows + ' session' + (totalRows !== 1 ? 's' : '');
    }
}

function setupModalCloseHandlers() {
    const modal = document.getElementById('sessionModal');
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) closeModal();
        });
    }
}

function closeModal() {
    const modal = document.getElementById('sessionModal');
    if (modal) {
        modal.classList.remove('show');
        modal.style.display = 'none';
    }
    window.history.replaceState({}, document.title, window.location.pathname);
}

function exportToPDF() {
    const sessions = getFilteredSessionData();

    if (sessions.length === 0) {
        alert('No sessions to export');
        return;
    }

    const printWindow = window.open('', '', 'height=600,width=800');

    let htmlContent = '<html><head><title>Talaqqi Sessions Report</title><style>' +
        'body { font-family: Poppins, Arial, sans-serif; margin: 20px; }' +
        'h1 { text-align: center; color: #1E293B; }' +
        'table { width: 100%; border-collapse: collapse; margin-top: 20px; }' +
        'th { background: linear-gradient(135deg, #7C3AED, #6C3BFF); color: white; padding: 10px; text-align: left; border: 1px solid #ddd; }' +
        'td { padding: 8px; border: 1px solid #ddd; font-size: 13px; }' +
        'tr:nth-child(even) { background-color: #F8FAFC; }' +
        '.summary { margin: 20px 0; padding: 12px; background-color: #F1F5F9; border-radius: 10px; }' +
        '</style></head><body>' +
        '<h1>Talaqqi Sessions Report</h1>' +
        '<div class="summary"><p><strong>Total Sessions:</strong> ' + sessions.length + '</p>' +
        '<p><strong>Report Generated:</strong> ' + new Date().toLocaleString() + '</p></div>' +
        '<table><thead><tr><th>Session ID</th><th>Student</th><th>Teacher</th><th>Date</th><th>Duration</th><th>Status</th></tr></thead><tbody>';

    sessions.forEach(function(session) {
        htmlContent += '<tr><td>' + escapeHtml(session.sessionId) + '</td><td>' + escapeHtml(session.studentName) + '</td><td>' +
            escapeHtml(session.teacherName) + '</td><td>' + escapeHtml(session.sessionDate) + '</td><td>' +
            escapeHtml(session.duration) + '</td><td>' + escapeHtml(session.status) + '</td></tr>';
    });

    htmlContent += '</tbody></table></body></html>';

    printWindow.document.write(htmlContent);
    printWindow.document.close();
    setTimeout(function() { printWindow.print(); }, 250);
}

function exportToCSV() {
    const sessions = getFilteredSessionData();
    if (sessions.length === 0) {
        alert('No sessions to export');
        return;
    }

    let csv = 'Session ID,Student Name,Teacher Name,Class Type,Session Date,Time,Duration,Status,Completed At\n';
    sessions.forEach(function(session) {
        csv += '"' + session.sessionId + '","' + session.studentName + '","' + session.teacherName + '","' +
            session.classType + '","' + session.sessionDate + '","' + session.time + '","' +
            session.duration + '","' + session.status + '","' + session.completedAt + '"\n';
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

    sessions.forEach(function(session) {
        html += '<tr><td>' + session.sessionId + '</td><td>' + session.studentName + '</td><td>' + session.teacherName + '</td><td>' +
            session.classType + '</td><td>' + session.sessionDate + '</td><td>' + session.time + '</td><td>' +
            session.duration + '</td><td>' + session.status + '</td><td>' + session.completedAt + '</td></tr>';
    });

    html += '</table>';
    downloadFile(html, 'talaqqi-sessions.xls', 'application/vnd.ms-excel');
}

function printTable() {
    window.print();
}

function getFilteredSessionData() {
    return currentTableData
        .filter(function(session) { return session.element.style.display !== 'none'; })
        .map(function(session) {
            return {
                sessionId: session.sessionId,
                studentName: session.studentName,
                teacherName: session.teacherName,
                classType: session.classType,
                sessionDate: session.sessionDate,
                time: session.time,
                duration: session.duration,
                status: session.status,
                completedAt: session.completedAt
            };
        });
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
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}
