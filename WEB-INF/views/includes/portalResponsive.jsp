<style>
    .sidebar-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.45);
        z-index: 999;
        opacity: 0;
        transition: opacity 0.25s ease;
    }
    .sidebar-overlay.active {
        display: block;
        opacity: 1;
    }
    .sidebar-toggle {
        display: none;
        background: none;
        border: none;
        font-size: 20px;
        color: inherit;
        cursor: pointer;
        padding: 8px 10px;
        border-radius: 10px;
        flex-shrink: 0;
        line-height: 1;
        transition: background 0.2s;
    }
    .sidebar-toggle:hover { background: #f1f5f9; }
    .sidebar-close {
        display: none;
        position: absolute;
        top: 22px;
        right: 18px;
        background: rgba(255, 255, 255, 0.12);
        border: none;
        color: rgba(255, 255, 255, 0.85);
        font-size: 18px;
        cursor: pointer;
        width: 36px;
        height: 36px;
        border-radius: 10px;
        align-items: center;
        justify-content: center;
        transition: background 0.2s;
    }
    .sidebar-close:hover { background: rgba(255, 255, 255, 0.2); }
    .navbar-left {
        display: flex;
        align-items: center;
        gap: 4px;
        min-width: 0;
        flex: 1;
    }
    .navbar-title {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .user-text { text-align: left; min-width: 0; }
    .table-responsive {
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
        width: 100%;
    }
    .table-responsive .records-table { min-width: 640px; }
    .info-grid,
    .quick-actions-grid,
    .attendance-mini-stats,
    .filter-grid { display: grid; gap: 16px; }

    @media (max-width: 1400px) {
        .stats-grid-4 { grid-template-columns: repeat(2, 1fr); }
        .filters-5 { grid-template-columns: repeat(3, 1fr); }
    }

    @media (max-width: 1024px) {
        .sidebar-toggle { display: inline-flex; align-items: center; justify-content: center; }
        .sidebar-close { display: inline-flex; }
        .sidebar {
            position: fixed !important;
            left: 0;
            top: 0;
            width: 280px !important;
            height: 100vh !important;
            transform: translateX(-100%);
            transition: transform 0.28s ease;
            z-index: 1001;
        }
        .sidebar.open { transform: translateX(0); }
        .main-content { margin-left: 0 !important; }
        .sidebar-logout {
            position: relative !important;
            bottom: auto !important;
            left: auto !important;
            right: auto !important;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        .stats-grid { grid-template-columns: repeat(2, 1fr); }
        .trends-grid,
        .content-grid-2-1 { grid-template-columns: 1fr; }
        .filters { grid-template-columns: repeat(2, 1fr); }
        .filters-5 { grid-template-columns: repeat(2, 1fr); }
        .detail-grid { grid-template-columns: 1fr 1fr; }
        .quick-actions-grid { grid-template-columns: repeat(2, 1fr); }
        .info-grid { grid-template-columns: repeat(2, 1fr); }
        body.sidebar-open { overflow: hidden; }
    }

    @media (max-width: 768px) {
        .top-navbar {
            padding: 14px 16px !important;
            gap: 10px;
        }
        .navbar-title { font-size: 18px !important; }
        .navbar-right { gap: 10px !important; flex-shrink: 0; }
        .user-text { display: none; }
        .profile-chevron { display: none; }
        .page-content { padding: 20px 16px !important; }
        .page-title { font-size: 22px !important; }
        .page-subtitle { margin-bottom: 24px !important; font-size: 13px !important; }
        .stats-grid,
        .stats-grid-4,
        .trends-grid,
        .content-grid-2-1,
        .filters,
        .filters-5,
        .detail-grid,
        .info-grid,
        .quick-actions-grid,
        .attendance-mini-stats,
        .filter-grid { grid-template-columns: 1fr !important; }
        .stat-card { padding: 16px; gap: 14px; }
        .stat-icon { width: 52px; height: 52px; font-size: 22px; }
        .stat-value { font-size: 24px; }
        .panel,
        .records-panel { padding: 20px 16px; border-radius: 16px; }
        .panel-head { flex-direction: column; align-items: flex-start; }
        .section-title { font-size: 18px; margin-bottom: 16px; }
        .notif-menu,
        .profile-dropdown {
            width: calc(100vw - 32px) !important;
            max-width: 360px;
            right: -8px;
        }
        .filter-actions { flex-direction: column; }
        .filter-actions .btn-primary,
        .filter-actions .btn-secondary,
        .export-btns .btn-secondary,
        .export-btns .btn-primary { width: 100%; justify-content: center; }
        .records-header { flex-direction: column; align-items: flex-start; }
        .trend-label { width: 72px; font-size: 11px; }
        .modal-overlay { padding: 12px; }
        .modal-box { padding: 20px 16px; border-radius: 16px; max-height: 92vh; }
        .modal-title { font-size: 18px; }
        .action-btns { flex-direction: column; }
        .action-btns .btn-action { width: 100%; text-align: center; }
    }

    @media (max-width: 480px) {
        .navbar-title { font-size: 16px !important; max-width: 140px; }
        .page-title { font-size: 20px !important; }
        .stat-value { font-size: 20px; }
        .btn-primary,
        .btn-secondary { font-size: 12px; padding: 9px 16px; }
    }
</style>
<script>
document.addEventListener('DOMContentLoaded', function () {
    var sidebar = document.querySelector('.sidebar');
    var toggle = document.getElementById('portalSidebarToggle');
    var overlay = document.getElementById('portalSidebarOverlay');
    var closeBtn = document.getElementById('portalSidebarClose');

    if (!sidebar) return;

    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'portalSidebarOverlay';
        overlay.className = 'sidebar-overlay';
        sidebar.parentNode.insertBefore(overlay, sidebar);
    }

    function setOpen(open) {
        sidebar.classList.toggle('open', open);
        overlay.classList.toggle('active', open);
        document.body.classList.toggle('sidebar-open', open);
        if (toggle) toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    }

    function closeSidebar() { setOpen(false); }

    if (toggle) {
        toggle.addEventListener('click', function () {
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
</script>
