<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Student" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Student Profile - TalaqqiHub Admin</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        .profile-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 32px; }
        .profile-section-title { font-size: 14px; font-weight: 700; color: #334155; margin-bottom: 16px; }
        .profile-field-label { font-size: 12px; color: #94A3B8; margin-bottom: 4px; }
        .profile-field-value { font-size: 14px; font-weight: 600; color: #1E293B; }
        .profile-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 16px 24px; }
        .session-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; text-align: center; margin-top: 8px; }
        .session-stat-value { font-size: 30px; font-weight: 800; color: #1E293B; }
        .session-stat-value.blue { color: #3B82F6; }
        .session-stat-value.green { color: #10B981; }
        .profile-progress-track { width: 100%; height: 12px; background: #F1F5F9; border-radius: 999px; overflow: hidden; margin-top: 24px; }
        .profile-progress-bar { height: 100%; border-radius: 999px; background: var(--admin-gradient-h); }
        .status-badge { display: inline-block; padding: 6px 16px; border-radius: 999px; font-size: 13px; font-weight: 600; }
        .status-badge.active { background: linear-gradient(90deg,#e6f9ef,#dff7e9); color:#06703a; }
        .status-badge.inactive { background:#fff1f0; color:#8b1e1e; }
        @media (max-width: 900px) { .profile-grid, .profile-fields, .session-stats { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="manage-students"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Student Profile"/>
        </jsp:include>

        <div class="page-content">
            <div class="panel" style="max-width: 960px; margin: 0 auto;">
                <div class="panel-head">
                    <div>
                        <h1 class="page-title" style="margin-bottom: 4px;">Student Profile</h1>
                        <p class="page-subtitle" style="margin-bottom: 0;">View-only access</p>
                    </div>
                    <a href="<%= request.getContextPath() %>/admin/manage-students" class="btn-secondary">Back to Students</a>
                </div>

                <div class="profile-grid">
                    <div>
                        <h4 class="profile-section-title">Personal Information</h4>
                        <div class="profile-fields">
                            <div>
                                <p class="profile-field-label">Full Name</p>
                                <p class="profile-field-value"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getStudentName() : "-" %></p>
                            </div>
                            <div>
                                <p class="profile-field-label">Email</p>
                                <p class="profile-field-value"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getStudentEmail() : "-" %></p>
                            </div>
                            <div>
                                <p class="profile-field-label">Phone Number</p>
                                <p class="profile-field-value"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getPhoneNumber() : "-" %></p>
                            </div>
                            <div>
                                <p class="profile-field-label">Date of Birth</p>
                                <p class="profile-field-value"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getDateOfBirth() : "-" %></p>
                            </div>
                        </div>
                    </div>

                    <div>
                        <h4 class="profile-section-title">Account Information</h4>
                        <div class="profile-fields">
                            <div>
                                <p class="profile-field-label">Registration Date</p>
                                <p class="profile-field-value"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getRegistrationDate() : "-" %></p>
                            </div>
                            <div>
                                <p class="profile-field-label">Account Status</p>
                                <%
                                    Student __st = (Student) request.getAttribute("student");
                                    boolean __isActive = __st != null && "Active".equalsIgnoreCase(__st.getStudentStatus());
                                    String __statusText = __st != null ? __st.getStudentStatus() : "-";
                                %>
                                <span class="status-badge <%= __isActive ? "active" : "inactive" %>"><%= __statusText %></span>
                            </div>
                            <div>
                                <p class="profile-field-label">Package Subscribed</p>
                                <%
                                    String _pkgName = "-";
                                    Object attrPkg = request.getAttribute("packageName");
                                    if (attrPkg != null) {
                                        _pkgName = String.valueOf(attrPkg);
                                    } else {
                                        try {
                                            __st = (model.Student) request.getAttribute("student");
                                            if (__st != null) {
                                                String _pkgId = null;
                                                try { _pkgId = __st.getPackageId(); } catch (Throwable ignore) {}
                                                if (_pkgId != null) {
                                                    dao.PackageDAO _pdao = new dao.PackageDAO();
                                                    for (model.Package _p : _pdao.getAllPackages()) {
                                                        String digits = String.valueOf(_p.getPackageId());
                                                        if (digits.equals(_pkgId) || _pkgId.replaceAll("\\D+", "").equals(digits)) {
                                                            _pkgName = _p.getPackageName();
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                        } catch (Throwable ignore) {}
                                    }
                                %>
                                <p class="profile-field-value"><%= _pkgName %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 32px;">
                    <h4 class="profile-section-title">Session Information</h4>
                    <div class="session-stats">
                        <div>
                            <p class="session-stat-value"><%= request.getAttribute("totalSessions") != null ? request.getAttribute("totalSessions") : 0 %></p>
                            <p class="profile-field-label" style="margin-top: 6px;">Total Sessions</p>
                        </div>
                        <div>
                            <p class="session-stat-value blue"><%= request.getAttribute("usedSessions") != null ? request.getAttribute("usedSessions") : 0 %></p>
                            <p class="profile-field-label" style="margin-top: 6px;">Sessions Used</p>
                        </div>
                        <div>
                            <p class="session-stat-value green"><%= request.getAttribute("remainingSessions") != null ? request.getAttribute("remainingSessions") : 0 %></p>
                            <p class="profile-field-label" style="margin-top: 6px;">Sessions Remaining</p>
                        </div>
                    </div>

                    <div class="profile-progress-track">
                        <div class="profile-progress-bar" style="width:<%= request.getAttribute("progressPercentage") != null ? request.getAttribute("progressPercentage") : 0 %>%"></div>
                    </div>
                    <p class="profile-field-label" style="margin-top: 12px;">Progress — <%= request.getAttribute("progressPercentage") != null ? request.getAttribute("progressPercentage") : 0 %>%</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
