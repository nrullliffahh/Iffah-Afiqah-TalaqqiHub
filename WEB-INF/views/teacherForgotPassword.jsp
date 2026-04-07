<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - TalaqqiHub</title>
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
                            <path fill-rule="evenodd" d="M18 8a6 6 0 01-7.743 5.743L10 14l-1 1-1 1H6v2H2v-4l4.257-4.257A6 6 0 1118 8zm-6-4a1 1 0 100 2 2 2 0 012 2 1 1 0 102 0 4 4 0 00-4-4z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                </div>

                <div class="text-center mb-8">
                    <h2 class="text-3xl font-bold text-gray-800 mb-2">Forgot Password</h2>
                    <p class="text-sm text-gray-600">We'll help you recover access to your teacher account.</p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                        <p class="text-sm text-red-600 font-medium">${errorMessage}</p>
                    </div>
                </c:if>

                <form method="POST" action="<%= request.getContextPath() %>/teacher/forgot-password">
                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                        <input type="email" name="email" placeholder="Enter your registered email" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                    </div>

                    <p class="text-sm text-gray-600 mb-6">We'll verify your identity using your security question.</p>

                    <button type="submit" class="w-full py-3 gradient-button text-white font-bold rounded-xl shadow-lg transition-all duration-300 transform hover:scale-105 mb-6">
                        Continue
                    </button>

                    <div class="text-center">
                        <a href="<%= request.getContextPath() %>/teacher/login" class="text-purple-600 hover:text-purple-700 text-sm font-semibold">
                            ← Back to Login
                        </a>
                    </div>
                </form>
            </div>

            <div class="text-center mt-8">
                <a href="<%= request.getContextPath() %>/home" class="text-gray-600 hover:text-gray-800 text-sm font-medium">
                    ← Back to Home
                </a>
            </div>
        </div>
    </div>
</body>
</html>
