document.addEventListener('DOMContentLoaded', function () {
    var sidebar = document.querySelector('.sidebar');
    var toggle = document.getElementById('portalSidebarToggle');
    if (!sidebar) return;

    var overlay = document.getElementById('portalSidebarOverlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'portalSidebarOverlay';
        overlay.className = 'sidebar-overlay';
        sidebar.parentNode.insertBefore(overlay, sidebar);
    }

    var closeBtn = document.getElementById('portalSidebarClose');

    function setOpen(open) {
        sidebar.classList.toggle('open', open);
        overlay.classList.toggle('active', open);
        document.body.classList.toggle('sidebar-open', open);
        if (toggle) toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    }

    function closeSidebar() { setOpen(false); }

    if (toggle) {
        toggle.addEventListener('click', function (e) {
            e.stopPropagation();
            setOpen(!sidebar.classList.contains('open'));
        });
    }
    if (closeBtn) closeBtn.addEventListener('click', closeSidebar);
    overlay.addEventListener('click', closeSidebar);

    sidebar.querySelectorAll('.sidebar-menu a, .sidebar-logout a').forEach(function (link) {
        link.addEventListener('click', function () {
            if (window.innerWidth <= 1024) closeSidebar();
        });
    });

    window.addEventListener('resize', function () {
        if (window.innerWidth > 1024) closeSidebar();
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeSidebar();
    });
});
