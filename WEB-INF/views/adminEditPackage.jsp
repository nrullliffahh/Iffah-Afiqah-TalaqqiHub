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
    <title>Edit Package - Admin</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="packages"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Edit Package"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Edit Package</h1>
            <p class="page-subtitle">Update package details and pricing</p>
            <c:if test="${empty pkg}">
                <div class="flash-error">Package not found.</div>
            </c:if>
            <c:if test="${not empty pkg}">
                <form method="post" action="<%= request.getContextPath() %>/admin/packages/edit" class="panel max-w-2xl">
                    <% model.Package _pkg = (model.Package) request.getAttribute("pkg");
                       String hiddenId = "P000";
                       if (_pkg != null) hiddenId = String.format("P%03d", _pkg.getPackageId());
                    %>
                    <input type="hidden" name="packageId" value="<%= hiddenId %>">

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Package Name</label>
                        <input name="packageName" value="${pkg.packageName}" class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-700">Total Sessions</label>
                            <input name="sessions" value="${pkg.sessions}" type="number" min="1" class="mt-1 block w-full rounded border border-gray-200 p-2" />
                        </div>
                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-700">Minutes per Session</label>
                            <input type="text" disabled value="15 minutes (Fixed)" class="mt-1 block w-full rounded border border-gray-200 p-2 bg-gray-50" />
                            <input type="hidden" name="durationPerSession" value="15" />
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Price</label>
                        <input name="price" value="${pkg.price}" class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Age Range</label>
                        <input name="ageRange" value="${pkg.ageRange}" placeholder="e.g., 6-12" class="mt-1 block w-full rounded border border-gray-200 p-2" />
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Description</label>
                        <textarea name="description" rows="4" class="mt-1 block w-full rounded border border-gray-200 p-2">${pkg.description}</textarea>
                    </div>

                    <div class="mb-4">
                        <label class="flex items-center space-x-3">
                            <input type="checkbox" name="popular" value="1" class="form-checkbox h-5 w-5 text-purple-600" <c:if test="${pkg.popular}">checked</c:if> />
                            <span class="text-sm font-medium text-gray-700">Mark as "Most Popular"</span>
                        </label>
                        <p class="text-xs text-gray-500 mt-1">Display a badge on this package</p>
                    </div>

                    <div class="flex space-x-3">
                        <button type="submit" class="btn-primary">Save</button>
                        <a href="<%= request.getContextPath() %>/admin/packages" class="btn-secondary">Cancel</a>
                    </div>
                </form>
            </c:if>
        </div>
    </div>
</body>
</html>
