<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Admin - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100">
    <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a href="<%= request.getContextPath() %>/home" class="text-2xl font-bold bg-gradient-to-r from-teal-700 to-purple-700 bg-clip-text text-transparent">TalaqqiHub</a>
                </div>
                <div class="flex items-center space-x-8">
                    <a href="<%= request.getContextPath() %>/home" class="text-gray-600 hover:text-purple-600 font-medium transition">Home</a>
                    <a href="<%= request.getContextPath() %>/roles" class="text-gray-600 hover:text-purple-600 font-medium transition">Roles</a>
                    <a href="<%= request.getContextPath() %>/packages" class="text-gray-600 hover:text-purple-600 font-medium transition">Packages</a>
                    <a href="<%= request.getContextPath() %>/admin/login" class="text-gray-600 hover:text-purple-600 font-medium transition">Admin Login</a>
                </div>
            </div>
        </div>
    </nav>

    <div class="flex items-center justify-center px-4 py-16">
        <div class="max-w-md w-full bg-white rounded-xl shadow-xl p-8">
            <div class="flex justify-center mb-6">
                <div class="w-16 h-16 bg-gradient-to-br from-teal-700 to-purple-700 rounded-2xl flex items-center justify-center">
                    <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"/>
                    </svg>
                </div>
            </div>

            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-gray-800 mb-2">Reset Password</h2>
                <p class="text-gray-500">Enter your new password</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
                    ${errorMessage}
                </div>
            </c:if>

            <form method="POST" action="<%= request.getContextPath() %>/admin/reset-password">
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-medium mb-2">New Password</label>
                    <input type="password" 
                           name="newPassword" 
                           placeholder="Enter new password (min 6 characters)" 
                           required
                           minlength="6"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition">
                </div>

                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Confirm Password</label>
                    <input type="password" 
                           name="confirmPassword" 
                           placeholder="Confirm your new password" 
                           required
                           minlength="6"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition">
                </div>

                <button type="submit" 
                        class="w-full py-3 px-4 bg-gradient-to-r from-teal-700 to-purple-700 text-white font-semibold rounded-full hover:from-teal-800 hover:to-purple-800 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 transition duration-200">
                    Reset Password
                </button>
            </form>

            <div class="mt-6 text-center">
                <a href="<%= request.getContextPath() %>/admin/login" class="text-gray-600 hover:text-gray-700 text-sm">
                    Cancel and return to login
                </a>
            </div>
        </div>
    </div>
</body>
</html>
