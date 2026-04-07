<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Admin - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
    <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a href="<%= request.getContextPath() %>/home" class="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">TalaqqiHub</a>
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
                <div class="w-16 h-16 bg-gradient-to-br from-teal-500 to-purple-600 rounded-2xl flex items-center justify-center">
                    <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M18 8a6 6 0 01-7.743 5.743L10 14l-1 1-1 1H6v2H2v-4l4.257-4.257A6 6 0 1118 8zm-6-4a1 1 0 100 2 2 2 0 012 2 1 1 0 102 0 4 4 0 00-4-4z" clip-rule="evenodd"/>
                    </svg>
                </div>
            </div>

            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-gray-800 mb-2">Forgot Password</h2>
                <p class="text-gray-500">We'll help you recover access to your admin account.</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
                    ${errorMessage}
                </div>
            </c:if>

            <form method="POST" action="<%= request.getContextPath() %>/admin/forgot-password">
                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Email Address</label>
                    <input type="email" 
                           name="email" 
                           placeholder="Enter your registered email" 
                           required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition">
                </div>

                <button type="submit" 
                        class="w-full py-3 px-4 bg-gradient-to-r from-teal-500 to-purple-600 text-white font-semibold rounded-full hover:from-teal-600 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 transition duration-200">
                    Continue
                </button>
            </form>

            <div class="mt-6 text-center space-y-2">
                <a href="<%= request.getContextPath() %>/admin/login" class="block text-purple-600 hover:text-purple-700 font-medium text-sm">
                    Back to Login
                </a>
                <a href="<%= request.getContextPath() %>/home" class="block text-gray-600 hover:text-gray-700 text-sm inline-flex items-center justify-center">
                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                    </svg>
                    Back to Home
                </a>
            </div>
        </div>
    </div>
</body>
</html>
