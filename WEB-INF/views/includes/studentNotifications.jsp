<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/views/includes/portalTabContext.jsp">
    <jsp:param name="portalTab" value="student"/>
</jsp:include>
<%
    String notifPrefix = request.getParameter("prefix");
    if (notifPrefix == null || notifPrefix.trim().isEmpty()) {
        notifPrefix = "studentNotif";
    }
%>
<div class="notif-wrap" id="<%= notifPrefix %>Wrap">
    <button id="<%= notifPrefix %>Btn" type="button" class="notif-btn"
            onclick="window['open<%= notifPrefix %>Menu']()">
        <i class="fas fa-bell"></i>
        <span id="<%= notifPrefix %>Badge" class="notif-badge">0</span>
    </button>
    <div id="<%= notifPrefix %>Menu" class="notif-menu">
        <div class="notif-menu-head">
            <h3>Notifications</h3>
            <button type="button" class="notif-mark-read" onclick="window['markAll<%= notifPrefix %>Read']()">Mark all as read</button>
        </div>
        <div id="<%= notifPrefix %>Items" class="notif-items"></div>
        <div class="notif-menu-foot">
            <a href="<%= request.getContextPath() %>/student/announcements">View all notifications</a>
        </div>
    </div>
</div>
<script>
(function() {
    var prefix = '<%= notifPrefix %>';
    var badge = document.getElementById(prefix + 'Badge');
    var itemsEl = document.getElementById(prefix + 'Items');
    var menu = document.getElementById(prefix + 'Menu');
    var ctx = '<%= request.getContextPath() %>';

    var iconMap = {
        announcement: 'fa-bullhorn',
        upcoming: 'fa-book-quran',
        booking: 'fa-calendar',
        cancelled: 'fa-times',
        evaluation: 'fa-star',
        attendance: 'fa-clipboard-check',
        general: 'fa-bell'
    };

    function esc(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function renderNotifications(data) {
        if (!badge || !itemsEl) return;
        var unread = data && data.unreadCount ? data.unreadCount : 0;
        if (unread > 0) {
            badge.style.display = 'inline-flex';
            badge.textContent = unread > 9 ? '9+' : unread;
        } else {
            badge.style.display = 'none';
        }

        itemsEl.innerHTML = '';
        if (data && Array.isArray(data.items) && data.items.length > 0) {
            data.items.forEach(function(it) {
                var type = it.type || 'general';
                var icon = iconMap[type] || iconMap.general;
                var isUnread = it.isRead === '0' || it.isRead === 0 || it.isRead === false;
                var row = document.createElement('div');
                row.className = 'notif-item' + (isUnread ? ' unread' : '');
                row.innerHTML =
                    '<div class="notif-item-icon"><i class="fas ' + icon + '"></i></div>' +
                    '<div class="flex-1">' +
                        '<div class="notif-item-title">' + esc(it.title) + '</div>' +
                        '<div class="notif-item-msg">' + esc(it.message) + '</div>' +
                        '<div class="notif-item-time">' + esc(it.timeAgo || it.time || '') + '</div>' +
                    '</div>';
                itemsEl.appendChild(row);
            });
        } else {
            itemsEl.innerHTML = '<div class="empty-state">No notifications</div>';
        }
    }

    function fetchNotifications() {
        return fetch(ctx + '/api/notifications?role=student', { credentials: 'same-origin' })
            .then(function(res) { return res.json(); })
            .then(function(data) { renderNotifications(data); return data; })
            .catch(function(err) { console.error('Failed to fetch notifications', err); return null; });
    }

    window['open' + prefix + 'Menu'] = function() {
        if (!menu) return;
        menu.classList.toggle('open');
    };

    window['markAll' + prefix + 'Read'] = function() {
        fetch(ctx + '/api/notifications/mark-read?role=student', { method: 'POST', credentials: 'same-origin' })
            .then(function() { return fetchNotifications(); })
            .catch(function() {});
    };

    document.addEventListener('click', function(e) {
        var wrap = document.getElementById(prefix + 'Wrap');
        if (!wrap || !menu || !menu.classList.contains('open')) return;
        if (!wrap.contains(e.target)) menu.classList.remove('open');
    });

    try { fetchNotifications(); } catch(e) {}
    setInterval(fetchNotifications, 20000);
})();
</script>
