<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Verification - Admin - TalaqqiHub</title>
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
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
                    </svg>
                </div>
            </div>

            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-gray-800 mb-2">Security Verification</h2>
                <p class="text-gray-500">Answer your security question to continue</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
                    ${errorMessage}
                </div>
            </c:if>

            <form method="POST" action="<%= request.getContextPath() %>/admin/security-verification">
                <div class="mb-4 p-4 bg-blue-50 rounded-lg">
                    <p class="text-sm text-gray-600 mb-1">Verification for:</p>
                    <p class="text-gray-800 font-semibold">${email}</p>
                </div>

                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Security Question</label>
                    <div class="p-4 bg-gray-50 rounded-lg mb-4">
                        <p class="text-gray-800 font-medium">${securityQuestion}</p>
                    </div>
                    <input type="text" 
                           name="answer" 
                           placeholder="Enter your answer" 
                           required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition">
                </div>

                <button type="submit" 
                        class="w-full py-3 px-4 bg-gradient-to-r from-teal-700 to-purple-700 text-white font-semibold rounded-full hover:from-teal-800 hover:to-purple-800 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 transition duration-200">
                    Verify Answer
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
