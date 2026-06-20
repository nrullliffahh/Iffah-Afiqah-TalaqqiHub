<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Change Password - TalaqqiHub</title>
  <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css" />
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css" />
  <style>
    .content-max { max-width: 1100px; }
  </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Change Password"/>
            <jsp:param name="notifPrefix" value="changePwdNotif"/>
        </jsp:include>

        <div class="page-content">
      <div class="content-max mx-auto">
        <h2 class="text-2xl font-bold text-gray-800">Change Password</h2>
        <p class="text-gray-600 mb-6">Keep your account secure with a strong password</p>

        <div class="bg-white rounded-xl shadow-sm p-8 max-w-2xl mx-auto">
          <c:if test="${not empty success}">
            <div class="mb-4 p-3 rounded bg-green-50 border border-green-100 text-green-700">${success}</div>
          </c:if>
          <c:if test="${not empty error}">
            <div class="mb-4 p-3 rounded bg-red-50 border border-red-100 text-red-700">${error}</div>
          </c:if>

          <form action="<%= request.getContextPath() %>/student/change-password" method="post" class="space-y-6">
            <div>
              <label class="text-xs text-gray-500">Current Password *</label>
              <div class="mt-1 relative">
                <input id="currentPassword" name="currentPassword" type="password" required class="block w-full rounded border border-gray-200 p-3 pr-10 focus:outline-none" placeholder="Enter your current password" />
                <button type="button" onclick="toggle('currentPassword', this)" class="absolute right-2 top-2 text-gray-500">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                </button>
              </div>
            </div>

            <div>
              <label class="text-xs text-gray-500">New Password *</label>
              <div class="mt-1 relative">
                <input id="newPassword" name="newPassword" type="password" required class="block w-full rounded border border-gray-200 p-3 pr-10 focus:outline-none" placeholder="Enter your new password" />
                <button type="button" onclick="toggle('newPassword', this)" class="absolute right-2 top-2 text-gray-500">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                </button>
              </div>
            </div>

            <div>
              <label class="text-xs text-gray-500">Confirm New Password *</label>
              <div class="mt-1 relative">
                <input id="confirmPassword" name="confirmPassword" type="password" required class="block w-full rounded border border-gray-200 p-3 pr-10 focus:outline-none" placeholder="Confirm your new password" />
                <button type="button" onclick="toggle('confirmPassword', this)" class="absolute right-2 top-2 text-gray-500">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                </button>
              </div>
            </div>

            <div class="flex items-center space-x-4">
              <button type="submit" class="flex items-center px-6 py-3 bg-gradient-to-r from-teal-400 to-green-400 text-white rounded-full">Update Password</button>
              <a href="<%= request.getContextPath() %>/student/profile" class="px-6 py-3 border border-gray-300 rounded-full">Cancel</a>
            </div>
          </form>

          <div class="mt-8 bg-gray-50 rounded-xl p-4 shadow-sm">
            <h4 class="font-semibold text-gray-800">Password Requirements</h4>
            <ul class="text-sm text-gray-600 mt-2 list-disc list-inside">
              <li>At least 8 characters long</li>
              <li>Contains uppercase and lowercase letters</li>
              <li>Contains at least one number</li>
              <li>Special characters recommended for extra security</li>
            </ul>
          </div>
        </div>
      </div>
        </div>
    </div>

  <script>
    function toggle(id, btn) {
      var el = document.getElementById(id);
      if (!el) return;
      if (el.type === 'password') el.type = 'text'; else el.type = 'password';
    }
  </script>
</body>
</html>
