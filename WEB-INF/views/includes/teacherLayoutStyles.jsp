<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
    :root {
        --teacher-gradient: linear-gradient(135deg, #7c3aed 0%, #be185d 100%);
        --teacher-gradient-h: linear-gradient(90deg, #7c3aed 0%, #be185d 100%);
        --teacher-sidebar: linear-gradient(180deg, #4c1d95 0%, #6b21a8 50%, #86198f 100%);
        --teacher-purple: #7c3aed;
        --teacher-pink: #be185d;
        --teacher-purple-light: #f3efff;
        --teacher-text: #1e293b;
        --teacher-text-muted: #64748b;
        --teacher-bg: #eef1f5;
        --teacher-surface: #ffffff;
        --teacher-shadow: 0 2px 12px rgba(15, 23, 42, 0.06);
    }
    * { font-family: 'Poppins', sans-serif; margin: 0; padding: 0; box-sizing: border-box; }
    body { background: var(--teacher-bg); overflow-x: hidden; color: var(--teacher-text); }
    .sidebar { position: fixed; left: 0; top: 0; width: 280px; height: 100vh; background: var(--teacher-sidebar); overflow-y: auto; z-index: 1000; padding: 30px 0; }
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
    .top-navbar { background: var(--teacher-surface); border-bottom: 1px solid #e2e8f0; padding: 20px 30px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 100; box-shadow: 0 1px 4px rgba(15,23,42,0.04); }
    .navbar-title { font-size: 24px; font-weight: 700; color: var(--teacher-text); }
    .navbar-right { display: flex; align-items: center; gap: 20px; }
    .user-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--teacher-gradient); display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 14px; flex-shrink: 0; }
    .user-info { display: flex; align-items: center; gap: 12px; }
    .user-name { font-size: 14px; font-weight: 600; color: var(--teacher-text); margin: 0; }
    .user-role { font-size: 12px; color: var(--teacher-text-muted); margin: 0; }
    .page-content { padding: 40px 30px; }
    .page-title { font-size: 28px; font-weight: 700; color: var(--teacher-text); margin-bottom: 8px; }
    .page-subtitle { font-size: 14px; color: var(--teacher-text-muted); margin-bottom: 40px; }
    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px; }
    .stats-grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; margin-bottom: 24px; }
    .section-title { font-size: 20px; font-weight: 700; color: var(--teacher-text); margin-bottom: 24px; }
    .stat-card { background: var(--teacher-surface); border-radius: 20px; padding: 24px; box-shadow: var(--teacher-shadow); border: 1px solid #e8edf2; display: flex; gap: 18px; align-items: center; }
    .stat-icon { width: 64px; height: 64px; border-radius: 16px; background: var(--teacher-gradient); color: white; display: flex; align-items: center; justify-content: center; font-size: 26px; flex-shrink: 0; opacity: 0.92; }
    .stat-icon.blue { background: linear-gradient(135deg, #3b82f6, #2563eb); }
    .stat-icon.green { background: linear-gradient(135deg, #059669, #047857); }
    .stat-icon.purple { background: var(--teacher-gradient); }
    .stat-icon.pink { background: linear-gradient(135deg, #9333ea, #be185d); }
    .stat-icon.red { background: linear-gradient(135deg, #dc2626, #b91c1c); }
    .stat-icon.amber { background: linear-gradient(135deg, #d97706, #b45309); }
    .stat-value { font-size: 30px; font-weight: 700; color: var(--teacher-text); line-height: 1; }
    .stat-label { font-size: 13px; color: var(--teacher-text-muted); font-weight: 600; margin-top: 6px; }
    .stat-hint { font-size: 12px; color: #94A3B8; margin-top: 2px; }
    .panel { background: var(--teacher-surface); border-radius: 20px; padding: 28px; box-shadow: var(--teacher-shadow); border: 1px solid #e8edf2; margin-bottom: 24px; }
    .panel-title { font-size: 16px; font-weight: 700; color: var(--teacher-text); margin-bottom: 4px; }
    .panel-subtitle { font-size: 12px; color: #94A3B8; margin-bottom: 0; }
    .panel-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
    .trends-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 40px; }
    .btn-primary { padding: 10px 22px; border-radius: 999px; font-size: 13px; font-weight: 600; border: none; background: var(--teacher-gradient); color: white; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 2px 8px rgba(124,58,237,0.2); transition: opacity .2s; }
    .btn-primary:hover { opacity: 0.9; }
    .btn-secondary { padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1px solid #e2e8f0; background: white; color: var(--teacher-text-muted); cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
    .btn-block { display: block; width: 100%; text-align: center; justify-content: center; }
    .empty-state { font-size: 13px; color: #94A3B8; text-align: center; padding: 24px 0; }
    .status-pill { display: inline-block; padding: 4px 12px; border-radius: 999px; font-size: 12px; font-weight: 600; }
    .status-pill.upcoming { background: #ede9fe; color: #6d28d9; }
    .status-pill.scheduled { background: #fce7f3; color: #be185d; }
    .status-pill.completed { background: #f3efff; color: #7c3aed; }
    .notif-wrap { position: relative; }
    .notif-btn { position: relative; background: none; border: none; color: #94A3B8; font-size: 20px; cursor: pointer; padding: 8px; border-radius: 10px; transition: all .2s; }
    .notif-btn:hover { color: var(--teacher-purple); background: var(--teacher-purple-light); }
    .notif-badge { position: absolute; top: 2px; right: 2px; background: var(--teacher-gradient); color: white; border-radius: 999px; min-width: 18px; height: 18px; font-size: 10px; font-weight: 700; display: none; align-items: center; justify-content: center; padding: 0 5px; }
    .notif-menu { display: none; position: absolute; right: 0; top: calc(100% + 8px); width: 360px; background: white; border-radius: 16px; box-shadow: 0 8px 28px rgba(15,23,42,0.1); border: 1px solid #e2e8f0; z-index: 200; overflow: hidden; }
    .notif-menu.open { display: block; }
    .notif-menu-head { display: flex; justify-content: space-between; align-items: center; padding: 16px 18px; border-bottom: 1px solid #f1f5f9; }
    .notif-menu-head h3 { font-size: 15px; font-weight: 700; color: var(--teacher-text); }
    .notif-mark-read { background: none; border: none; font-size: 12px; font-weight: 600; color: var(--teacher-purple); cursor: pointer; }
    .notif-items { max-height: 320px; overflow-y: auto; }
    .notif-item { display: flex; gap: 12px; padding: 14px 18px; border-bottom: 1px solid #f8fafc; }
    .notif-item.unread { background: #faf8ff; }
    .notif-item-icon { width: 40px; height: 40px; border-radius: 12px; background: var(--teacher-purple-light); color: var(--teacher-purple); display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 14px; }
    .notif-item-title { font-size: 13px; font-weight: 700; color: var(--teacher-text); }
    .notif-item-msg { font-size: 12px; color: var(--teacher-text-muted); margin-top: 2px; line-height: 1.4; }
    .notif-item-time { font-size: 11px; color: #94A3B8; margin-top: 4px; }
    .notif-menu-foot { padding: 12px; text-align: center; border-top: 1px solid #f1f5f9; }
    .notif-menu-foot a { font-size: 13px; font-weight: 600; color: var(--teacher-purple); text-decoration: none; }
    @media (max-width: 1200px) {
        .stats-grid, .stats-grid-4, .trends-grid { grid-template-columns: 1fr; }
        .main-content { margin-left: 0; }
        .sidebar { position: relative; width: 100%; height: auto; }
    }
</style>
