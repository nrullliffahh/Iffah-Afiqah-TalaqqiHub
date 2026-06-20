<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/colors.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-packages.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="packages"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Manage Packages"/>
        </jsp:include>

        <div class="page-content">
            <div class="panel-head no-print" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title" style="margin-bottom: 4px;">Manage Packages</h1>
                    <p class="page-subtitle" style="margin-bottom: 0;">Create, edit, and manage all TalaqqiHub learning packages</p>
                </div>
                <div style="display:flex; gap:10px; flex-wrap:wrap;">
                    <button id="openAddModal" type="button" class="btn-primary">+ Add Package</button>
                </div>
            </div>
                <%
                    String deletedParam = request.getParameter("deleted");
                    String deletedReason = request.getParameter("reason");
                    if (deletedParam != null) {
                        if ("1".equals(deletedParam)) {
                %>
                <div class="mb-4 p-4 bg-green-50 border border-green-200 text-green-800 rounded flash-success">
                    Package deleted successfully.
                </div>
                <%
                        } else {
                %>
                <div class="mb-4 p-4 bg-red-50 border border-red-200 text-red-800 rounded flash-error">
                    Failed to delete package. 
                    <% if ("referenced".equals(deletedReason)) { %>
                        There are students assigned to this package; reassign or remove them before deleting.
                    <% } else { %>
                        Please try again or check the server logs for details.
                    <% } %>
                </div>
                <%
                        }
                    }
                %>

                <!-- Dynamic top packages summary cards -->
                <c:if test="${not empty topPackages}">
                    <div class="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
                        <c:forEach var="pkg" items="${topPackages}" varStatus="loop">
                            <div class="bg-white rounded-xl shadow-sm p-6 flex items-center justify-between">
                                <div class="flex items-start">
                                    <c:choose>
                                        <c:when test="${loop.index == 0}">
                                            <div class="pkg-summary-icon pkg-summary-icon--purple mr-4">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-8"/><path d="M7 7h10v5H7z"/><path d="M12 3v4"/></svg>
                                            </div>
                                        </c:when>
                                        <c:when test="${loop.index == 1}">
                                            <div class="pkg-summary-icon pkg-summary-icon--green mr-4">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M16 3v4"/><path d="M8 3v4"/></svg>
                                            </div>
                                        </c:when>
                                        <c:when test="${loop.index == 2}">
                                            <div class="pkg-summary-icon pkg-summary-icon--red mr-4">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7h18"/><path d="M12 21V7"/><path d="M8 11h8"/></svg>
                                            </div>
                                        </c:when>
                                        <c:when test="${loop.index == 3}">
                                            <div class="pkg-summary-icon pkg-summary-icon--yellow mr-4">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l3 7h7l-5.5 4 2 7L12 16l-6.5 4 2-7L2 9h7z"/></svg>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="pkg-summary-icon pkg-summary-icon--yellow mr-4">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l3 7h7l-5.5 4 2 7L12 16l-6.5 4 2-7L2 9h7z"/></svg>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <p class="text-sm font-medium text-gray-700">${pkg.name}</p>
                                        <p class="text-xs text-gray-500">Students enrolled</p>
                                    </div>
                                </div>
                                <c:choose>
                                    <c:when test="${loop.index == 0}">
                                        <div class="text-3xl font-bold" style="color: var(--color-chart-2);">${pkg.count}</div>
                                    </c:when>
                                    <c:when test="${loop.index == 1}">
                                        <div class="text-3xl font-bold" style="color: var(--color-chart-4);">${pkg.count}</div>
                                    </c:when>
                                    <c:when test="${loop.index == 2}">
                                        <div class="text-3xl font-bold" style="color: var(--color-destructive);">${pkg.count}</div>
                                    </c:when>
                                    <c:when test="${loop.index == 3}">
                                        <div class="text-3xl font-bold" style="color: var(--color-chart-3);">${pkg.count}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-3xl font-bold" style="color: var(--color-chart-5);">${pkg.count}</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <!-- Kids Packages -->
                <div class="mb-12">
                    <h3 class="text-2xl font-bold mb-6">Kids Packages</h3>
                    <div class="grid md:grid-cols-2 gap-8">
                        <c:forEach var="pkg" items="${packages}">
                            <c:if test="${pkg.category == 'Kids'}">
                                <div class="bg-white rounded-3xl p-8 shadow-lg" <c:if test="${pkg.popular}">style="border-radius:18px; border:2px solid transparent; background-image: linear-gradient(#fff,#fff), ${not empty pkg.gradient ? fn:escapeXml(pkg.gradient) : 'linear-gradient(135deg,#3fb79f,#4fd1c5)'}; background-origin: padding-box, border-box; background-clip: padding-box, border-box;"</c:if>>
                                            <div class="text-center mb-4">
                                                <h4 class="text-xl font-bold">${pkg.packageName}</h4>
                                                <div class="text-3xl font-extrabold text-purple-600 mt-2">${pkg.price} <span class="text-sm text-gray-500">/ month</span></div>
                                            </div>
                                            <c:if test="${pkg.popular}">
                                                <div class="text-center mb-4">
                                                    <span class="text-white px-4 py-1 rounded-full text-sm" style="background: var(--gradient-button); box-shadow: var(--shadow-lg);">Most Popular</span>
                                                </div>
                                            </c:if>
                                        <div class="mb-4 text-gray-600 space-y-2">
                                            <div class="pkg-row">
                                                <span class="pkg-icon pkg-icon--check" aria-hidden="true">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>
                                                </span>
                                                <div class="text-sm">${pkg.sessions} sessions</div>
                                            </div>
                                            <div class="pkg-row">
                                                <span class="pkg-icon pkg-icon--clock" aria-hidden="true">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                                                </span>
                                                <div class="text-sm">15 minutes per session</div>
                                            </div>
                                            <div class="pkg-row">
                                                <span class="pkg-icon pkg-icon--age" aria-hidden="true">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><circle cx="12" cy="7" r="4"/></svg>
                                                </span>
                                                <div class="text-sm">Range Age : ${empty pkg.ageRange ? '-' : pkg.ageRange}</div>
                                            </div>
                                        </div>
                                    <p class="text-gray-500 mb-6">${pkg.description}</p>
                                    <div class="flex space-x-4 justify-center">
                                        <button type="button" class="btn-edit" onclick="openEditModal('${pkg.packageId}')">Edit</button>
                                        <button type="button" class="btn-delete" data-package-id="${pkg.packageId}" data-package-name="${pkg.packageName}" onclick="openDeleteModal(this)">Delete</button>
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
                                <div class="bg-white rounded-3xl p-8 shadow-lg" <c:if test="${pkg.popular}">style="border-radius:18px; border:2px solid transparent; background-image: linear-gradient(#fff,#fff), ${not empty pkg.gradient ? fn:escapeXml(pkg.gradient) : 'linear-gradient(135deg,#b993d6,#8ca6db)'}; background-origin: padding-box, border-box; background-clip: padding-box, border-box;"</c:if>>
                                    <div class="text-center mb-4">
                                        <h4 class="text-xl font-bold">${pkg.packageName}</h4>
                                        <div class="text-3xl font-extrabold text-purple-600 mt-2">${pkg.price} <span class="text-sm text-gray-500">/ month</span></div>
                                    </div>
                                    <c:if test="${pkg.popular}">
                                        <div class="text-center mb-4">
                                            <span class="text-white px-4 py-1 rounded-full text-sm" style="background: var(--gradient-button); box-shadow: var(--shadow-lg);">Most Popular</span>
                                        </div>
                                    </c:if>
                                    <div class="mb-4 text-gray-600 space-y-2">
                                        <div class="flex items-center space-x-3">
                                            <div class="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center text-green-600">✓</div>
                                            <div class="text-sm">${pkg.sessions} sessions</div>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-600">⏱️</div>
                                            <div class="text-sm">15 minutes per session</div>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-600">👤</div>
                                            <div class="text-sm">Range Age : ${empty pkg.ageRange ? '-' : pkg.ageRange}</div>
                                        </div>
                                    </div>
                                    <p class="text-gray-500 mb-6">${pkg.description}</p>
                                    <div class="flex space-x-4 justify-center">
                                        <button type="button" class="bg-yellow-400 px-6 py-2 rounded-full text-white" onclick="openEditModal('${pkg.packageId}')">Edit</button>
                                        <button type="button" class="btn-delete" data-package-id="${pkg.packageId}" data-package-name="${pkg.packageName}" onclick="openDeleteModal(this)">Delete</button>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>
        </div>
    </div>

    <!-- Add Package Modal (hidden by default) -->
    <div id="addPackageModal" class="fixed inset-0 z-50 hidden">
        <div class="absolute inset-0 bg-black opacity-40"></div>
        <div class="relative max-w-2xl mx-auto mt-12 bg-white rounded shadow-lg overflow-auto max-h-[80vh] border border-gray-200">
            <div class="flex items-center justify-between p-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold">Add New Package</h3>
                <button id="closeAddModal" class="text-gray-500 hover:text-gray-800">✕</button>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/admin/packages/add" class="p-6">
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Package Name *</label>
                    <input name="packageName" placeholder="e.g., TalaqqiSpark" required class="mt-1 block w-full rounded border border-gray-200 p-2" />
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Category *</label>
                    <select name="category" class="mt-1 block w-full rounded border border-gray-200 p-2">
                        <option>Kids</option>
                        <option>Adults</option>
                    </select>
                </div>

                    <div class="grid grid-cols-2 gap-4 mb-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Price (RM) *</label>
                        <input name="price" value="0" required class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Sessions per Month *</label>
                        <input name="sessions" type="number" min="1" value="8" required class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Session Duration (minutes)</label>
                    <input type="text" disabled value="15 minutes (Fixed)" class="mt-1 block w-full rounded border border-gray-200 p-2 bg-gray-50" />
                    <input type="hidden" name="durationPerSession" value="15" />
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Age Range</label>
                    <input name="ageRange" placeholder="e.g., 6-12" class="mt-1 block w-full rounded border border-gray-200 p-2" />
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Description *</label>
                    <textarea name="description" rows="4" required class="mt-1 block w-full rounded border border-gray-200 p-2" placeholder="Enter package description..."></textarea>
                </div>

                <div class="flex justify-end space-x-3">
                    <button type="button" id="cancelAdd" class="bg-gray-200 px-4 py-2 rounded">Cancel</button>
                    <button type="submit" class="bg-purple-600 text-white px-4 py-2 rounded">Create Package</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        (function(){
            var open = document.getElementById('openAddModal');
            var modal = document.getElementById('addPackageModal');
            var close = document.getElementById('closeAddModal');
            var cancel = document.getElementById('cancelAdd');
            function show(){ modal.classList.remove('hidden'); }
            function hide(){ modal.classList.add('hidden'); }
            if(open) open.addEventListener('click', function(e){ e.preventDefault(); show(); });
            if(close) close.addEventListener('click', function(e){ e.preventDefault(); hide(); });
            if(cancel) cancel.addEventListener('click', function(e){ e.preventDefault(); hide(); });
            document.addEventListener('keydown', function(e){ if(e.key === 'Escape') hide(); });
        })();
    </script>

    <!-- Edit Package Modal -->
    <div id="editPackageModal" class="fixed inset-0 z-50 hidden">
        <div class="absolute inset-0 bg-black opacity-40"></div>
        <div class="relative max-w-2xl mx-auto mt-12 bg-white rounded shadow-lg overflow-auto max-h-[80vh] border border-gray-200">
            <div class="flex items-center justify-between p-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold">Edit Package</h3>
                <button id="closeEditModal" class="text-gray-500 hover:text-gray-800">✕</button>
            </div>
            <form method="post" id="editPackageForm" action="<%= request.getContextPath() %>/admin/packages/edit" class="p-6">
                <input type="hidden" name="packageId" id="editPackageId" value="" />
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Package Name *</label>
                    <input id="editPackageName" name="packageName" required class="mt-1 block w-full rounded border border-gray-200 p-2" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Category (Cannot be changed)</label>
                    <input id="editCategory" type="text" disabled class="mt-1 block w-full rounded border border-gray-200 p-2 bg-gray-50" />
                </div>
                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Price (RM) *</label>
                        <input id="editPrice" name="price" required class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Sessions per Month *</label>
                        <input id="editSessions" name="sessions" type="number" min="1" required class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Session Duration (minutes)</label>
                    <input type="text" disabled value="15 minutes (Fixed)" class="mt-1 block w-full rounded border border-gray-200 p-2 bg-gray-50" />
                    <input type="hidden" name="durationPerSession" id="editDuration" value="15" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Age Range</label>
                    <input id="editAge" name="ageRange" placeholder="e.g., 6-12" class="mt-1 block w-full rounded border border-gray-200 p-2" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Description *</label>
                    <textarea id="editDescription" name="description" rows="4" required class="mt-1 block w-full rounded border border-gray-200 p-2"></textarea>
                </div>
                <div class="mb-4">
                    <label class="flex items-center justify-between">
                        <div>
                            <div class="text-sm font-medium text-gray-700">Mark as "Most Popular"</div>
                            <div class="text-xs text-gray-500">Display a badge on this package</div>
                        </div>
                        <label class="toggle">
                            <input type="checkbox" id="editPopular" name="popular" value="1" />
                            <span class="track"><span class="thumb"></span></span>
                        </label>
                    </label>
                </div>
                <div class="flex justify-end space-x-3">
                    <button type="button" id="cancelEdit" class="bg-gray-200 px-4 py-2 rounded">Cancel</button>
                    <button type="submit" class="bg-purple-600 text-white px-4 py-2 rounded">Save</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        const ctxPath = '<%= request.getContextPath() %>';
        function openEditModal(id){
            var overlay = document.getElementById('editPackageModal');
            var form = document.getElementById('editPackageForm');
            // fetch package details
            fetch(ctxPath + '/admin/packages/get?packageId=' + encodeURIComponent(id)).then(function(res){
                if(!res.ok) throw new Error('failed');
                return res.json();
            }).then(function(data){
                document.getElementById('editPackageId').value = data.packageId || id;
                document.getElementById('editPackageName').value = data.packageName || '';
                document.getElementById('editCategory').value = data.category || (data.packageName? '':'');
                document.getElementById('editPrice').value = data.price || '';
                document.getElementById('editSessions').value = data.sessions || 8;
                document.getElementById('editDuration').value = data.durationPerSession || 15;
                document.getElementById('editDescription').value = data.description || '';
                document.getElementById('editAge').value = data.ageRange || '';
                var pop = data.popular === true || data.popular === 'true' || data.popular === '1';
                document.getElementById('editPopular').checked = pop;
                overlay.classList.remove('hidden');
            }).catch(function(){
                // fallback: just open blank modal (rare)
                document.getElementById('editPackageId').value = id;
                overlay.classList.remove('hidden');
            });
        }
        function closeEditModal(){ document.getElementById('editPackageModal').classList.add('hidden'); }
        document.getElementById('closeEditModal').addEventListener('click', closeEditModal);
        document.getElementById('cancelEdit').addEventListener('click', closeEditModal);
        document.addEventListener('keydown', function(e){ if(e.key === 'Escape') closeEditModal(); });
        document.getElementById('editPackageModal').addEventListener('click', function(e){ if(e.target === this) closeEditModal(); });
    </script>

    <!-- Delete confirmation modal -->
    <div id="deleteConfirmOverlay" class="confirm-overlay" role="dialog" aria-modal="true">
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
            var form = document.getElementById('deleteConfirmForm');
            var input = document.getElementById('deletePackageId');
            var title = document.getElementById('deleteConfirmTitle');
            var text = document.getElementById('deleteConfirmText');
            var pkgId = btn.getAttribute('data-package-id');
            var pkgName = btn.getAttribute('data-package-name') || '';
            input.value = pkgId;
            title.textContent = 'Delete Package';
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
        // close modal with Escape key
        document.addEventListener('keydown', function(e){ if(e.key === 'Escape'){ closeDeleteModal(); } });
        // close when clicking outside modal
        document.getElementById('deleteConfirmOverlay').addEventListener('click', function(e){ if(e.target === this) closeDeleteModal(); });
    </script>
</body>
</html>
