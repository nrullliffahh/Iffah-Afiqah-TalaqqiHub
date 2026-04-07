<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            background: linear-gradient(135deg, #e0f2fe 0%, #fce7f3 100%);
            min-height: 100vh;
        }
        .gradient-button {
            background: linear-gradient(135deg, #a855f7 0%, #ec4899 100%);
        }
        .gradient-button:hover {
            background: linear-gradient(135deg, #9333ea 0%, #db2777 100%);
        }
    </style>
</head>
<body class="flex flex-col min-h-screen">
    <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a href="<%= request.getContextPath() %>/home" class="text-2xl font-bold text-purple-600">TalaqqiHub</a>
                </div>
                <div class="flex items-center space-x-8">
                    <a href="<%= request.getContextPath() %>/home" class="text-gray-700 hover:text-purple-600 font-medium">Home</a>
                    <a href="<%= request.getContextPath() %>/roles" class="text-gray-700 hover:text-purple-600 font-medium">Roles</a>
                    <a href="<%= request.getContextPath() %>/packages" class="text-gray-700 hover:text-purple-600 font-medium">Packages</a>
                    <a href="<%= request.getContextPath() %>/admin/login" class="text-gray-700 hover:text-purple-600 font-medium">Admin Login</a>
                </div>
            </div>
        </div>
    </nav>

    <div class="flex-grow flex items-center justify-center px-4 py-12">
        <div class="max-w-md w-full">
            <div class="text-center mb-8">
                <h1 class="text-4xl font-bold text-purple-600 mb-2">TalaqqiHub</h1>
            </div>

            <div class="bg-white rounded-3xl shadow-2xl p-8">
                <div class="flex justify-center mb-6">
                    <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                </div>

                <div class="text-center mb-8">
                    <h2 class="text-3xl font-bold text-gray-800 mb-2">Reset Password</h2>
                    <p class="text-sm text-gray-600">Create a new secure password for your teacher account.</p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                        <p class="text-sm text-red-600 font-medium">${errorMessage}</p>
                    </div>
                </c:if>

                <div class="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl flex items-center">
                    <svg class="w-5 h-5 text-green-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                    </svg>
                    <p class="text-sm text-green-600 font-medium">Identity verified successfully!</p>
                </div>

                <form method="POST" action="<%= request.getContextPath() %>/teacher/reset-password">
                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">New Password</label>
                        <input type="password" name="newPassword" placeholder="Enter new password" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        <p class="text-xs text-gray-600 mt-2">Must be at least 6 characters long</p>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Confirm New Password</label>
                        <input type="password" name="confirmPassword" placeholder="Re-enter new password" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                    </div>

                    <button type="submit" class="w-full py-3 gradient-button text-white font-bold rounded-xl shadow-lg transition-all duration-300 transform hover:scale-105 mb-6">
                        Reset Password
                    </button>

                    <div class="text-center">
                        <a href="<%= request.getContextPath() %>/teacher/login" class="text-purple-600 hover:text-purple-700 text-sm font-semibold">
                            ← Back to Login
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
