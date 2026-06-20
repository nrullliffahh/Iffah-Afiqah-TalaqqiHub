<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100">
    <!-- Top Navbar -->
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
                    <a href="<%= request.getContextPath() %>/admin/login" class="text-purple-600 font-semibold">Admin Login</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Login Card -->
    <div class="flex items-center justify-center px-4 py-16">
        <div class="max-w-md w-full bg-white rounded-xl shadow-xl p-8">
            <!-- Lock Icon -->
            <div class="flex justify-center mb-6">
                <div class="w-16 h-16 bg-gradient-to-br from-teal-700 to-purple-700 rounded-2xl flex items-center justify-center">
                    <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                    </svg>
                </div>
            </div>

            <!-- Title -->
            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-gray-800 mb-2">Admin Login</h2>
                <p class="text-gray-500">Access the TalaqqiHub admin panel</p>
            </div>

            <!-- Error Message -->
            <c:if test="${not empty errorMessage}">
                <div class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
                    ${errorMessage}
                </div>
            </c:if>

            <!-- Login Form -->
            <form action="<%= request.getContextPath() %>/admin/login" method="post">
                <!-- Email Field -->
                <div class="mb-4">
                    <label for="email" class="block text-gray-700 text-sm font-medium mb-2">Email Address</label>
                    <input type="email" 
                           id="email" 
                           name="email" 
                           placeholder="admin@talaqqihub.com"
                           required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition">
                </div>

                <!-- Password Field -->
                <div class="mb-4">
                    <label for="password" class="block text-gray-700 text-sm font-medium mb-2">Password</label>
                    <input type="password" 
                           id="password" 
                           name="password" 
                           placeholder="••••••••"
                           required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition">
                </div>

                <!-- Remember Me & Forgot Password -->
                <div class="flex items-center justify-between mb-6">
                    <label class="flex items-center">
                        <input type="checkbox" name="remember" class="w-4 h-4 text-purple-600 border-gray-300 rounded focus:ring-purple-500">
                        <span class="ml-2 text-sm text-gray-600">Remember me</span>
                    </label>
                    <a href="<%= request.getContextPath() %>/admin/forgot-password" class="text-sm text-purple-600 hover:text-purple-700 font-medium">Forgot password?</a>
                </div>

                <!-- Sign In Button -->
                <button type="submit" 
                        class="w-full py-3 px-4 bg-gradient-to-r from-teal-700 to-purple-700 text-white font-semibold rounded-full hover:from-teal-800 hover:to-purple-800 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 transition duration-200">
                    Sign In
                </button>
            </form>

            <!-- Back to Home Link -->
            <div class="mt-6 text-center">
                <a href="<%= request.getContextPath() %>/home" class="text-purple-600 hover:text-purple-700 font-medium text-sm inline-flex items-center">
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
