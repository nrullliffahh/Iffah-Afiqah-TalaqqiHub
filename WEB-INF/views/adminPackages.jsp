<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Packages - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/colors.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-packages.css">
</head>
<body class="bg-gray-50 font-sans">
    <div class="flex min-h-screen">
        <!-- Sidebar (copied from adminDashboard) -->
        <aside class="w-56 bg-gradient-to-b from-purple-600 via-purple-500 to-purple-700 text-white flex flex-col fixed h-full shadow-xl">
            <div class="p-6 border-b border-white border-opacity-20">
                <h1 class="text-2xl font-bold">TalaqqiHub</h1>
                <p class="text-sm text-purple-100 opacity-90">Admin Portal</p>
            </div>
            <nav class="flex-1 py-4 overflow-y-auto">
                <a href="<%= request.getContextPath() %>/admin/dashboard" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-10 transition">
                    <span class="text-sm font-medium">Dashboard</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/class-schedule" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <span class="text-sm font-medium">Class Schedule</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-students" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <span class="text-sm font-medium">Manage Students</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-teachers" class="flex items-center px-6 py-3 hover:bg-white hover:bg-opacity-5 transition">
                    <span class="text-sm font-medium">Manage Teachers</span>
                </a>
                <a href="<%= request.getContextPath() %>/admin/packages" class="flex items-center px-6 py-3 bg-white bg-opacity-10 border-l-4 border-white">
                    <span class="text-sm font-medium">Packages</span>
                </a>
            </nav>
            <div class="p-6 border-t border-white border-opacity-20">
                <a href="<%= request.getContextPath() %>/admin/logout" class="flex items-center hover:bg-white hover:bg-opacity-10 px-3 py-2 rounded transition">
                    <span class="text-sm font-medium">Logout</span>
                </a>
            </div>
        </aside>

        <main class="flex-1 ml-56 overflow-y-auto">
            <header class="bg-white shadow-sm sticky top-0 z-10">
                <div class="flex items-center justify-between px-8 py-4">
                    <h2 class="text-2xl font-bold text-gray-800">Manage Packages</h2>
                    <div class="flex items-center space-x-4">
                        <a href="#" class="bg-white px-4 py-2 rounded-full shadow text-sm">Export PDF</a>
                        <a href="#" class="bg-white px-4 py-2 rounded-full shadow text-sm">CSV</a>
                        <a href="#" class="bg-white px-4 py-2 rounded-full shadow text-sm">Print</a>
                        <a href="<%= request.getContextPath() %>/admin/packages/add" class="bg-gradient-to-r from-purple-400 to-pink-400 text-white px-4 py-2 rounded-full shadow text-sm">+ Add Package</a>
                    </div>
                </div>
            </header>

            <div class="p-8">
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">Manage Packages</h1>
                    <p class="text-gray-600">Create, edit, and manage all TalaqqiHub learning packages</p>
                </div>

                <!-- Kids Packages -->
                <div class="mb-12">
                    <h3 class="text-2xl font-bold mb-6">Kids Packages</h3>
                    <div class="grid md:grid-cols-2 gap-8">
                        <c:forEach var="pkg" items="${packages}">
                            <c:if test="${pkg.category == 'Kids'}">
                                <div class="bg-white rounded-3xl p-8 shadow-lg">
                                    <div class="text-center mb-4">
                                        <h4 class="text-xl font-bold">${pkg.packageName}</h4>
                                        <div class="text-3xl font-extrabold text-purple-600 mt-2">${pkg.price} <span class="text-sm text-gray-500">/ month</span></div>
                                    </div>
                                    <div class="mb-4 text-gray-600">
                                        <div>${pkg.sessions} sessions</div>
                                        <div>${pkg.durationPerSession} minutes per session</div>
                                    </div>
                                    <p class="text-gray-500 mb-6">${pkg.description}</p>
                                    <div class="flex space-x-4 justify-center">
                                        <a href="<%= request.getContextPath() %>/admin/packages/edit?packageId=${pkg.packageId}" class="bg-yellow-400 px-6 py-2 rounded-full text-white">Edit</a>
                                        <button type="button" class="bg-red-500 px-6 py-2 rounded-full text-white" data-package-id="${pkg.packageId}" data-package-name="${pkg.packageName}" onclick="openDeleteModal(this)">Delete</button>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

                <!-- Adults Packages -->
                <div>
                    <h3 class="text-2xl font-bold mb-6">Adults Packages</h3>
                    <div class="grid md:grid-cols-2 gap-8">
                        <c:forEach var="pkg" items="${packages}">
                            <c:if test="${pkg.category == 'Adults'}">
                                <div class="bg-white rounded-3xl p-8 shadow-lg">
                                    <div class="text-center mb-4">
                                        <h4 class="text-xl font-bold">${pkg.packageName}</h4>
                                        <div class="text-3xl font-extrabold text-purple-600 mt-2">${pkg.price} <span class="text-sm text-gray-500">/ month</span></div>
                                    </div>
                                    <div class="mb-4 text-gray-600">
                                        <div>${pkg.sessions} sessions</div>
                                        <div>${pkg.durationPerSession} minutes per session</div>
                                    </div>
                                    <p class="text-gray-500 mb-6">${pkg.description}</p>
                                    <div class="flex space-x-4 justify-center">
                                        <a href="<%= request.getContextPath() %>/admin/packages/edit?packageId=${pkg.packageId}" class="bg-yellow-400 px-6 py-2 rounded-full text-white">Edit</a>
                                        <button type="button" class="bg-red-500 px-6 py-2 rounded-full text-white" data-package-id="${pkg.packageId}" data-package-name="${pkg.packageName}" onclick="openDeleteModal(this)">Delete</button>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
            <!-- Delete confirmation modal -->
            <div id="deleteConfirmOverlay" class="confirm-overlay" role="dialog" aria-modal="true" style="display:none;">
                <div class="confirm-modal">
                    <div class="modal-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18" /><path d="M8 6v12a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V6" /><path d="M10 11v6" /><path d="M14 11v6" /><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" /></svg>
                    </div>
                    <h3 id="deleteConfirmTitle">Delete Package</h3>
                    <p id="deleteConfirmText">Are you sure you want to delete this package? This action cannot be undone.</p>
                    <div class="confirm-actions">
                        <button type="button" class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
                        <form id="deleteConfirmForm" method="get" action="<%= request.getContextPath() %>/admin/packages/delete" style="display:inline">
                            <input type="hidden" name="packageId" id="deletePackageId" value="" />
                            <button type="submit" class="btn-confirm">Delete</button>
                        </form>
                    </div>
                </div>
            </div>

            <script>
                function openDeleteModal(btn){
                    var overlay = document.getElementById('deleteConfirmOverlay');
                    var input = document.getElementById('deletePackageId');
                    var text = document.getElementById('deleteConfirmText');
                    var pkgId = btn.getAttribute('data-package-id');
                    var pkgName = btn.getAttribute('data-package-name') || '';
                    input.value = pkgId;
                    text.innerHTML = 'Are you sure you want to delete <strong>' + escapeHtml(pkgName) + '</strong>? This action cannot be undone.';
                    overlay.style.display = 'flex';
                }
                function closeDeleteModal(){
                    var overlay = document.getElementById('deleteConfirmOverlay');
                    overlay.style.display = 'none';
                }
                function escapeHtml(str){
                    if(!str) return '';
                    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
                }
                document.addEventListener('keydown', function(e){ if(e.key === 'Escape'){ closeDeleteModal(); } });
                document.getElementById('deleteConfirmOverlay').addEventListener('click', function(e){ if(e.target === this) closeDeleteModal(); });
            </script>
</body>
</html>
