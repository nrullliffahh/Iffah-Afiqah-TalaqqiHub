<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
    :root {
        --admin-gradient: linear-gradient(135deg, #0f766e 0%, #6d28d9 100%);
        --admin-gradient-h: linear-gradient(90deg, #0f766e 0%, #6d28d9 100%);
        --admin-sidebar: linear-gradient(180deg, #134e4a 0%, #312e81 52%, #4c1d95 100%);
        --admin-teal: #0f766e;
        --admin-purple: #6d28d9;
        --admin-accent-light: #e6f2f1;
        --admin-purple-light: #ede9fe;
        --admin-text: #1e293b;
        --admin-text-muted: #64748b;
        --admin-bg: #eef1f5;
        --admin-surface: #ffffff;
        --admin-shadow: 0 2px 12px rgba(15, 23, 42, 0.06);
    }
    * { font-family: 'Poppins', sans-serif; margin: 0; padding: 0; box-sizing: border-box; }
    body { background: var(--admin-bg); overflow-x: hidden; color: var(--admin-text); }
    .sidebar { position: fixed; left: 0; top: 0; width: 280px; height: 100vh; background: var(--admin-sidebar); overflow-y: auto; z-index: 1000; padding: 30px 0; }
    .sidebar-brand { padding: 0 25px 30px; margin-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1); }
    .brand-title { font-size: 24px; font-weight: 700; color: rgba(255,255,255,0.95); }
    .brand-subtitle { font-size: 13px; color: rgba(255,255,255,0.6); }
    .sidebar-menu { list-style: none; padding: 0 15px; }
    .sidebar-menu li { margin-bottom: 10px; }
    .sidebar-menu a { display: flex; align-items: center; padding: 12px 15px; color: rgba(255,255,255,0.65); text-decoration: none; border-radius: 25px; font-size: 14px; font-weight: 500; transition: all .3s; }
    .sidebar-menu a i { width: 20px; margin-right: 15px; text-align: center; }
    .sidebar-menu a:hover, .sidebar-menu a.active { color: white; background: rgba(255,255,255,0.12); font-weight: 600; }
    .sidebar-logout { position: absolute; bottom: 30px; left: 15px; right: 15px; }
    .sidebar-logout a { display: flex; align-items: center; padding: 12px 15px; color: rgba(255,255,255,0.65); text-decoration: none; border-radius: 25px; font-size: 14px; font-weight: 500; transition: all .3s; }
    .sidebar-logout a:hover { color: white; background: rgba(255,255,255,0.12); }
    .sidebar-logout a i { width: 20px; margin-right: 15px; text-align: center; }
    .main-content { margin-left: 280px; min-height: 100vh; }
    .top-navbar { background: var(--admin-surface); border-bottom: 1px solid #e2e8f0; padding: 20px 30px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 100; box-shadow: 0 1px 4px rgba(15,23,42,0.04); }
    .navbar-title { font-size: 24px; font-weight: 700; color: var(--admin-text); }
    .navbar-right { display: flex; align-items: center; gap: 25px; }
    .user-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--admin-gradient); display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 14px; flex-shrink: 0; }
    .user-info { display: flex; align-items: center; gap: 12px; }
    .user-name { font-size: 14px; font-weight: 600; color: var(--admin-text); margin: 0; }
    .user-role { font-size: 12px; color: var(--admin-text-muted); margin: 0; }
    .page-content { padding: 40px 30px; }
    .page-title { font-size: 28px; font-weight: 700; color: var(--admin-text); margin-bottom: 8px; }
    .page-subtitle { font-size: 14px; color: var(--admin-text-muted); margin-bottom: 40px; }
    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px; }
    .stats-grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; margin-bottom: 24px; }
    .section-title { font-size: 20px; font-weight: 700; color: var(--admin-text); margin-bottom: 24px; }
    .filters { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
    .filters-5 { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 16px; }
    .search-wrap { position: relative; }
    .search-wrap i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #94A3B8; }
    .search-wrap .filter-input { padding-left: 36px; }
    .filter-actions { display: flex; gap: 10px; margin-top: 16px; margin-bottom: 24px; }
    .export-btns { display: flex; gap: 10px; flex-wrap: wrap; }
    .records-info, .records-footer { font-size: 13px; color: var(--admin-text-muted); margin-bottom: 12px; }
    .records-footer { margin-bottom: 0; padding-top: 16px; border-top: 1px solid #E2E8F0; }
    .status-pill { display: inline-block; padding: 4px 12px; border-radius: 999px; font-size: 12px; font-weight: 600; }
    .status-pill.upcoming { background: #dbeafe; color: #1e40af; }
    .status-pill.completed { background: #dcfce7; color: #166534; }
    .status-pill.rescheduled { background: #fef3c7; color: #92400e; }
    .status-pill.cancelled { background: #fee2e2; color: #991b1b; }
    .status-pill.default { background: #f1f5f9; color: #475569; }
    .status-badge { display: inline-block; padding: 4px 14px; border-radius: 999px; font-size: 12px; font-weight: 600; }
    .status-active { background: #e6f4ef; color: #065f46; }
    .status-approved { background: #dcfce7; color: #15803D; }
    .status-inactive, .status-rejected { background: #fef2f2; color: #991b1b; }
    .status-pending { background: #ffedd5; color: #9a3412; }
    .status-default { background: #f1f5f9; color: #475569; }
    .btn-action { padding: 8px 16px; border-radius: 10px; border: none; background: var(--admin-gradient); color: white; font-size: 12px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; }
    .btn-action:hover { opacity: 0.9; }
    .btn-approve { background: #059669; }
    .btn-reject { background: #dc2626; }
    .action-btns { display: flex; gap: 8px; flex-wrap: wrap; }
    .modal-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.55); z-index: 200; display: none; align-items: center; justify-content: center; padding: 24px; }
    .modal-overlay.open, .modal-overlay.show { display: flex; }
    .modal-box { background: white; border-radius: 20px; width: 100%; max-width: 640px; max-height: 90vh; overflow-y: auto; box-shadow: 0 16px 48px rgba(0,0,0,0.15); padding: 28px; }
    .modal-box.wide { max-width: 768px; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .modal-title { font-size: 22px; font-weight: 700; color: var(--admin-text); }
    .modal-close { background: none; border: none; color: #94A3B8; font-size: 22px; cursor: pointer; }
    .modal-close:hover { color: #64748B; }
    .detail-section { margin-bottom: 24px; padding-bottom: 24px; border-bottom: 1px solid #E2E8F0; }
    .detail-section:last-of-type { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
    .detail-section-title { font-size: 16px; font-weight: 700; color: var(--admin-text); margin-bottom: 16px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .detail-label { font-size: 12px; font-weight: 600; color: #94A3B8; margin-bottom: 4px; }
    .detail-value { font-size: 14px; font-weight: 600; color: var(--admin-text); }
    .alert-box { background: #FEF2F2; border: 1px solid #FECACA; border-radius: 12px; padding: 16px; margin-top: 20px; }
    .alert-box-title { font-size: 13px; font-weight: 700; color: #B91C1C; margin-bottom: 4px; }
    .alert-box-text { font-size: 13px; color: #B91C1C; }
    .empty-state { font-size: 13px; color: #94A3B8; text-align: center; padding: 24px 0; }
    .stat-card { background: var(--admin-surface); border-radius: 20px; padding: 24px; box-shadow: var(--admin-shadow); border: 1px solid #e8edf2; display: flex; gap: 18px; align-items: center; }
    .stat-icon { width: 64px; height: 64px; border-radius: 16px; background: var(--admin-gradient); color: white; display: flex; align-items: center; justify-content: center; font-size: 26px; flex-shrink: 0; opacity: 0.92; }
    .stat-icon.blue { background: linear-gradient(135deg, #3b82f6, #2563eb); }
    .stat-icon.green { background: linear-gradient(135deg, #059669, #047857); }
    .stat-icon.purple { background: var(--admin-gradient); }
    .stat-icon.teal { background: linear-gradient(135deg, #0d9488, #0f766e); }
    .stat-icon.red { background: linear-gradient(135deg, #dc2626, #b91c1c); }
    .stat-icon.amber { background: linear-gradient(135deg, #d97706, #b45309); }
    .stat-value { font-size: 30px; font-weight: 700; color: var(--admin-text); line-height: 1; }
    .stat-label { font-size: 13px; color: var(--admin-text-muted); font-weight: 600; margin-top: 6px; }
    .stat-hint { font-size: 12px; color: #94A3B8; margin-top: 2px; }
    .panel { background: var(--admin-surface); border-radius: 20px; padding: 28px; box-shadow: var(--admin-shadow); border: 1px solid #e8edf2; margin-bottom: 24px; }
    .panel-title { font-size: 16px; font-weight: 700; color: var(--admin-text); margin-bottom: 4px; }
    .panel-subtitle { font-size: 12px; color: #94A3B8; margin-bottom: 0; }
    .panel-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
    .trends-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 40px; }
    .trend-row { display: flex; align-items: center; gap: 12px; margin-bottom: 14px; }
    .trend-row:last-child { margin-bottom: 0; }
    .trend-label { width: 118px; font-size: 13px; color: var(--admin-text-muted); font-weight: 600; flex-shrink: 0; }
    .trend-bar-wrap { flex: 1; height: 28px; background: #e8edf2; border-radius: 14px; overflow: hidden; }
    .trend-bar { height: 100%; border-radius: 14px; background: var(--admin-gradient-h); display: flex; align-items: center; justify-content: flex-end; padding-right: 10px; color: white; font-size: 12px; font-weight: 700; min-width: 48px; }
    .records-panel { background: var(--admin-surface); border-radius: 20px; padding: 28px; box-shadow: var(--admin-shadow); border: 1px solid #e8edf2; }
    .records-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .records-title { font-size: 20px; font-weight: 700; color: var(--admin-text); }
    .btn-primary { padding: 10px 22px; border-radius: 999px; font-size: 13px; font-weight: 600; border: none; background: var(--admin-gradient); color: white; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 2px 8px rgba(15,118,110,0.2); transition: opacity .2s; }
    .btn-primary:hover { opacity: 0.9; }
    .btn-secondary { padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1px solid #e2e8f0; background: white; color: var(--admin-text-muted); cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
    .filter-input, .filter-select { width: 100%; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 10px; font-size: 13px; background: white; }
    .filter-input:focus, .filter-select:focus { outline: none; border-color: var(--admin-purple); box-shadow: 0 0 0 3px rgba(109,40,217,0.1); }
    .filter-label { font-size: 12px; font-weight: 600; color: var(--admin-text-muted); margin-bottom: 6px; display: block; }
    .records-table { width: 100%; border-collapse: collapse; }
    .records-table th { padding: 14px 16px; text-align: left; font-size: 12px; font-weight: 700; color: var(--admin-text-muted); text-transform: uppercase; background: #f4f6f9; border-bottom: 1px solid #e2e8f0; }
    .records-table td { padding: 16px; border-bottom: 1px solid #e2e8f0; font-size: 13px; color: var(--admin-text); }
    .records-table tbody tr:hover { background: #f4f6f9; }
    .flash-success { background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; padding: 12px 16px; border-radius: 10px; margin-bottom: 16px; font-size: 14px; }
    .flash-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 12px 16px; border-radius: 10px; margin-bottom: 16px; font-size: 14px; }
    @media (max-width: 1200px) {
        .stats-grid, .stats-grid-4, .trends-grid, .filters, .filters-5, .detail-grid { grid-template-columns: 1fr; }
        .main-content { margin-left: 0; }
        .sidebar { position: relative; width: 100%; height: auto; }
    }
    @media print {
        .sidebar, .top-navbar, .btn-primary, .btn-secondary, .no-print { display: none !important; }
        .main-content { margin-left: 0; }
    }
</style>
