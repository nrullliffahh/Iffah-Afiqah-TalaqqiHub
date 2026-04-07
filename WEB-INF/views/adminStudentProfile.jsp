<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Student" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Student Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-transparent">
<div class="min-h-screen flex items-center justify-center p-6 bg-gray-50">
    <div class="w-full max-w-4xl">
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
            <div class="px-8 py-6">
                <div class="flex items-start justify-between">
                    <div>
                        <h3 class="text-2xl font-semibold text-gray-900">Student Profile</h3>
                        <p class="text-sm text-gray-500 mt-1">View-only access</p>
                    </div>
                    <div class="text-sm">
                        <a href="<%= request.getContextPath() %>/admin/manage-students" class="text-gray-400 hover:text-gray-600">Close</a>
                    </div>
                </div>

                <div class="mt-6 grid grid-cols-2 gap-8">
                    <div>
                        <h4 class="text-sm font-semibold text-gray-700 mb-4">Personal Information</h4>
                        <div class="grid grid-cols-2 gap-y-4 text-sm text-gray-600">
                            <div>
                                <p class="text-xs text-gray-500">Full Name</p>
                                <p class="font-medium text-gray-800"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getStudentName() : "-" %></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Email</p>
                                <p class="font-medium text-gray-800"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getStudentEmail() : "-" %></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Phone Number</p>
                                <p class="font-medium text-gray-800"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getPhoneNumber() : "-" %></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Date of Birth</p>
                                <p class="font-medium text-gray-800"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getDateOfBirth() : "-" %></p>
                            </div>
                        </div>
                    </div>

                    <div>
                        <h4 class="text-sm font-semibold text-gray-700 mb-4">Account Information</h4>
                        <div class="grid grid-cols-2 gap-y-4 text-sm text-gray-600">
                            <div>
                                <p class="text-xs text-gray-500">Registration Date</p>
                                <p class="font-medium text-gray-800"><%= ((Student)request.getAttribute("student") != null) ? ((Student)request.getAttribute("student")).getRegistrationDate() : "-" %></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500">Account Status</p>
                                <%
                                    Student __st = (Student) request.getAttribute("student");
                                    boolean __isActive = __st != null && "Active".equalsIgnoreCase(__st.getStudentStatus());
                                    String __statusText = __st != null ? __st.getStudentStatus() : "-";
                                %>
                                <p class="font-medium">
                                    <% if (__isActive) { %>
                                        <span class="inline-block px-4 py-1.5 rounded-full text-sm font-semibold shadow-sm align-middle" style="background: linear-gradient(90deg,#e6f9ef,#dff7e9); color:#06703a;">
                                            <%= __statusText %>
                                        </span>
                                    <% } else { %>
                                        <span class="inline-block px-4 py-1.5 rounded-full text-sm font-semibold shadow-sm align-middle" style="background:#fff1f0; color:#8b1e1e;">
                                            <%= __statusText %>
                                        </span>
                                    <% } %>
                                </p>
                            </div>

                            <!-- Assigned Teacher removed for admin profile -->
                            <div>
                                <p class="text-xs text-gray-500">Package Subscribed</p>
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
                                <p class="font-medium text-gray-800"><%= _pkgName %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-8">
                    <h4 class="text-sm font-semibold text-gray-700 mb-4">Session Information</h4>
                    <div class="mt-2 grid grid-cols-3 gap-6 text-center">
                        <div>
                            <p class="text-3xl font-extrabold text-gray-800"><%= request.getAttribute("totalSessions") != null ? request.getAttribute("totalSessions") : 0 %></p>
                            <p class="text-sm text-gray-500 mt-1">Total Sessions</p>
                        </div>
                        <div>
                            <p class="text-3xl font-extrabold text-blue-600"><%= request.getAttribute("usedSessions") != null ? request.getAttribute("usedSessions") : 0 %></p>
                            <p class="text-sm text-gray-500 mt-1">Sessions Used</p>
                        </div>
                        <div>
                            <p class="text-3xl font-extrabold text-green-600"><%= request.getAttribute("remainingSessions") != null ? request.getAttribute("remainingSessions") : 0 %></p>
                            <p class="text-sm text-gray-500 mt-1">Sessions Remaining</p>
                        </div>
                    </div>

                    <div class="mt-6">
                        <div class="w-full bg-gray-100 rounded-full h-3">
                            <div class="h-3 rounded-full bg-gradient-to-r from-purple-500 to-pink-400" style="width:<%= request.getAttribute("progressPercentage") != null ? request.getAttribute("progressPercentage") : 0 %>%"></div>
                        </div>
                        <p class="text-xs text-gray-500 mt-3">Progress — <%= request.getAttribute("progressPercentage") != null ? request.getAttribute("progressPercentage") : 0 %>%</p>
                    </div>
                </div>

                <div class="mt-6 text-right">
                    <a href="<%= request.getContextPath() %>/admin/manage-students" class="inline-block px-4 py-2 bg-white border rounded text-sm">Close</a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>