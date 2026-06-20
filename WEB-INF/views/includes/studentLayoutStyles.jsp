<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
    :root {
        --student-gradient: linear-gradient(135deg, #3d7265 0%, #047857 100%);
        --student-gradient-h: linear-gradient(90deg, #3d7265 0%, #047857 100%);
        --student-sidebar: #1a4035;
        --student-green: #047857;
        --student-green-dark: #1a4035;
        --student-teal: #0d9488;
        --student-green-light: #ecfdf5;
        --student-text: #1e293b;
        --student-text-muted: #64748b;
        --student-bg: #eef1f5;
        --student-surface: #ffffff;
        --student-shadow: 0 2px 12px rgba(15, 23, 42, 0.06);
    }
    * { font-family: 'Poppins', sans-serif; margin: 0; padding: 0; box-sizing: border-box; }
    body { background: var(--student-bg); overflow-x: hidden; color: var(--student-text); }
    .sidebar { position: fixed; left: 0; top: 0; width: 280px; height: 100vh; background: var(--student-sidebar); overflow-y: auto; z-index: 1000; padding: 30px 0; }
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
    .top-navbar { background: var(--student-surface); border-bottom: 1px solid #e2e8f0; padding: 20px 30px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 100; box-shadow: 0 1px 4px rgba(15,23,42,0.04); }
    .navbar-title { font-size: 24px; font-weight: 700; color: var(--student-text); }
    .navbar-right { display: flex; align-items: center; gap: 20px; }
    .user-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--student-green-dark); display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 14px; flex-shrink: 0; }
    .user-info { display: flex; align-items: center; gap: 12px; position: relative; }
    .user-name { font-size: 14px; font-weight: 600; color: var(--student-text); margin: 0; }
    .user-role { font-size: 12px; color: var(--student-text-muted); margin: 0; }
    .profile-trigger { display: flex; align-items: center; gap: 10px; background: none; border: none; cursor: pointer; padding: 4px; border-radius: 12px; transition: background .2s; }
    .profile-trigger:hover { background: #f8fafc; }
    .profile-chevron { color: #94a3b8; font-size: 12px; }
    .profile-dropdown { display: none; position: absolute; right: 0; top: calc(100% + 8px); width: 200px; background: white; border-radius: 12px; box-shadow: 0 8px 28px rgba(15,23,42,0.1); border: 1px solid #e2e8f0; z-index: 200; overflow: hidden; }
    .profile-dropdown.open { display: block; }
    .profile-dropdown a { display: flex; align-items: center; gap: 10px; padding: 12px 16px; font-size: 13px; font-weight: 500; color: var(--student-text); text-decoration: none; transition: background .2s; }
    .profile-dropdown a:hover { background: var(--student-green-light); color: var(--student-green); }
    .profile-dropdown a i { width: 16px; text-align: center; color: #94a3b8; }
    .profile-dropdown a:hover i { color: var(--student-green); }
    .profile-dropdown hr { border: none; border-top: 1px solid #f1f5f9; margin: 4px 0; }
    .profile-dropdown a.logout { color: #dc2626; }
    .profile-dropdown a.logout:hover { background: #fef2f2; color: #dc2626; }
    .page-content { padding: 40px 30px; }
    .page-title { font-size: 28px; font-weight: 700; color: var(--student-text); margin-bottom: 8px; }
    .page-subtitle { font-size: 14px; color: var(--student-text-muted); margin-bottom: 40px; }
    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px; }
    .stats-grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; margin-bottom: 24px; }
    .section-title { font-size: 20px; font-weight: 700; color: var(--student-text); margin-bottom: 24px; }
    .stat-card { background: var(--student-surface); border-radius: 20px; padding: 24px; box-shadow: var(--student-shadow); border: 1px solid #e8edf2; display: flex; gap: 18px; align-items: center; }
    .stat-icon { width: 64px; height: 64px; border-radius: 16px; background: var(--student-gradient); color: white; display: flex; align-items: center; justify-content: center; font-size: 26px; flex-shrink: 0; opacity: 0.92; }
    .stat-icon.blue { background: linear-gradient(135deg, #3b82f6, #2563eb); }
    .stat-icon.green { background: linear-gradient(135deg, #059669, #047857); }
    .stat-icon.teal { background: linear-gradient(135deg, #0d9488, #047857); }
    .stat-icon.amber { background: linear-gradient(135deg, #d97706, #b45309); }
    .stat-value { font-size: 30px; font-weight: 700; color: var(--student-text); line-height: 1; }
    .stat-label { font-size: 13px; color: var(--student-text-muted); font-weight: 600; margin-top: 6px; }
    .stat-hint { font-size: 12px; color: #94A3B8; margin-top: 2px; }
    .panel { background: var(--student-surface); border-radius: 20px; padding: 28px; box-shadow: var(--student-shadow); border: 1px solid #e8edf2; margin-bottom: 24px; }
    .panel-title { font-size: 16px; font-weight: 700; color: var(--student-text); margin-bottom: 4px; }
    .panel-subtitle { font-size: 12px; color: #94A3B8; margin-bottom: 0; }
    .panel-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
    .trends-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 40px; }
    .content-grid-2-1 { display: grid; grid-template-columns: 1fr 380px; gap: 24px; align-items: stretch; }
    .dashboard-left { display: flex; flex-direction: column; gap: 24px; }
    .panel-announcements { display: flex; flex-direction: column; margin-bottom: 0; min-height: 100%; }
    .announcements-list { flex: 1; }
    .panel-empty { min-height: 120px; display: flex; align-items: center; justify-content: center; }
    .btn-outline { padding: 12px 18px; border-radius: 12px; font-size: 14px; font-weight: 600; border: 1px solid #e2e8f0; background: white; color: var(--student-text-muted); cursor: pointer; text-decoration: none; display: block; width: 100%; text-align: center; transition: background .2s, border-color .2s; }
    .btn-outline:hover { background: #f8fafc; border-color: #cbd5e1; color: var(--student-text); }
    .stat-value-sm { font-size: 26px; }
    .btn-primary { padding: 10px 22px; border-radius: 999px; font-size: 13px; font-weight: 600; border: none; background: var(--student-gradient); color: white; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 2px 8px rgba(4,120,87,0.2); transition: opacity .2s; }
    .btn-primary:hover { opacity: 0.9; }
    .btn-secondary { padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1px solid #e2e8f0; background: white; color: var(--student-text-muted); cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
    .btn-block { display: block; width: 100%; text-align: center; justify-content: center; }
    .empty-state { font-size: 13px; color: #94A3B8; text-align: center; padding: 24px 0; }
    .status-pill { display: inline-block; padding: 4px 12px; border-radius: 999px; font-size: 12px; font-weight: 600; }
    .status-pill.upcoming { background: var(--student-green-light); color: var(--student-green); }
    .status-pill.completed { background: #f0fdf4; color: #15803d; }
    .notif-wrap { position: relative; }
    .notif-btn { position: relative; background: none; border: none; color: #94A3B8; font-size: 20px; cursor: pointer; padding: 8px; border-radius: 10px; transition: all .2s; }
    .notif-btn:hover { color: var(--student-green); background: var(--student-green-light); }
    .notif-badge { position: absolute; top: 2px; right: 2px; background: var(--student-gradient); color: white; border-radius: 999px; min-width: 18px; height: 18px; font-size: 10px; font-weight: 700; display: none; align-items: center; justify-content: center; padding: 0 5px; }
    .notif-menu { display: none; position: absolute; right: 0; top: calc(100% + 8px); width: 360px; background: white; border-radius: 16px; box-shadow: 0 8px 28px rgba(15,23,42,0.1); border: 1px solid #e2e8f0; z-index: 200; overflow: hidden; }
    .notif-menu.open { display: block; }
    .notif-menu-head { display: flex; justify-content: space-between; align-items: center; padding: 16px 18px; border-bottom: 1px solid #f1f5f9; }
    .notif-menu-head h3 { font-size: 15px; font-weight: 700; color: var(--student-text); }
    .notif-mark-read { background: none; border: none; font-size: 12px; font-weight: 600; color: var(--student-green); cursor: pointer; }
    .notif-items { max-height: 320px; overflow-y: auto; }
    .notif-item { display: flex; gap: 12px; padding: 14px 18px; border-bottom: 1px solid #f8fafc; }
    .notif-item.unread { background: #f0fdf4; }
    .notif-item-icon { width: 40px; height: 40px; border-radius: 12px; background: var(--student-green-light); color: var(--student-green); display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 14px; }
    .notif-item-title { font-size: 13px; font-weight: 700; color: var(--student-text); }
    .notif-item-msg { font-size: 12px; color: var(--student-text-muted); margin-top: 2px; line-height: 1.4; }
    .notif-item-time { font-size: 11px; color: #94A3B8; margin-top: 4px; }
    .notif-menu-foot { padding: 12px; text-align: center; border-top: 1px solid #f1f5f9; }
    .notif-menu-foot a { font-size: 13px; font-weight: 600; color: var(--student-green); text-decoration: none; }
    .progress-track { height: 8px; background: #f1f5f9; border-radius: 4px; overflow: hidden; margin-top: 8px; }
    .progress-fill { height: 100%; background: var(--student-gradient-h); border-radius: 4px; }
    .session-detail { display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #f1f5f9; }
    .session-detail:last-child { border-bottom: none; }
    .session-detail i { width: 20px; color: #94a3b8; text-align: center; }
    .session-detail-label { font-size: 12px; color: #94a3b8; }
    .session-detail-value { font-size: 14px; font-weight: 600; color: var(--student-text); }
    .announcement-item { border-left: 3px solid var(--student-green); padding: 12px 16px; margin-bottom: 12px; background: #f8fafc; border-radius: 0 12px 12px 0; }
    .announcement-item h4 { font-size: 14px; font-weight: 700; color: var(--student-text); margin-bottom: 4px; }
    .announcement-item .date { font-size: 12px; color: #94a3b8; margin-bottom: 4px; }
    .announcement-item p { font-size: 13px; color: var(--student-text-muted); line-height: 1.5; }
    .badge-count { min-width: 24px; height: 24px; border-radius: 999px; background: var(--student-gradient); color: white; font-size: 11px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; padding: 0 6px; }
    @media (max-width: 1200px) {
        .stats-grid, .stats-grid-4, .trends-grid, .content-grid-2-1 { grid-template-columns: 1fr; }
        .main-content { margin-left: 0; }
        .sidebar { position: relative; width: 100%; height: auto; }
    }
</style>
