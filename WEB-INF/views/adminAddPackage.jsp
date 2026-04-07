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
    <title>Add Package - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body class="bg-gray-50 font-sans">
    <div class="flex min-h-screen">
        <%@ include file="includes/adminSidebar.jsp" %>
        <main class="flex-1 ml-56 p-8">
            <h1 class="text-2xl font-bold mb-4">Add New Package</h1>
            <form method="post" action="<%= request.getContextPath() %>/admin/packages/add" class="bg-white p-6 rounded shadow-md max-w-2xl">
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

                <div class="mb-4">
                    <label class="flex items-center space-x-3">
                        <label class="toggle">
                            <input type="checkbox" name="popular" value="1" />
                            <span class="track"><span class="thumb"></span></span>
                        </label>
                        <div>
                            <div class="text-sm font-medium text-gray-700">Mark as "Most Popular"</div>
                            <div class="text-xs text-gray-500">Display a badge on this package</div>
                        </div>
                    </label>
                </div>

                <div class="mb-4">
                    <label class="flex items-center space-x-3">
                        <input type="checkbox" name="popular" value="1" class="form-checkbox h-5 w-5 text-purple-600" />
                        <span class="text-sm font-medium text-gray-700">Mark as "Most Popular"</span>
                    </label>
                    <p class="text-xs text-gray-500 mt-1">Display a badge on this package</p>
                </div>

                <div class="flex space-x-3">
                    <button type="submit" class="bg-purple-600 text-white px-4 py-2 rounded">Create Package</button>
                    <a href="<%= request.getContextPath() %>/admin/packages" class="bg-gray-200 px-4 py-2 rounded">Cancel</a>
                </div>
            </form>
        </main>
    </div>
</body>
</html>
