<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Login - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/tailwind.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/colors.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/animations.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css">
    <style>
        body {
            background: linear-gradient(135deg, #e0f2fe 0%, #fce7f3 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .gradient-button {
            background: linear-gradient(135deg, #a855f7 0%, #ec4899 100%);
        }
        .gradient-button:hover {
            background: linear-gradient(135deg, #9333ea 0%, #db2777 100%);
        }
    </style>
</head>
<body>
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
                            <path d="M9 4.804A7.968 7.968 0 005.5 4c-1.255 0-2.443.29-3.5.804v10A7.969 7.969 0 015.5 14c1.669 0 3.218.51 4.5 1.385A7.962 7.962 0 0114.5 14c1.255 0 2.443.29 3.5.804v-10A7.968 7.968 0 0014.5 4c-1.255 0-2.443.29-3.5.804V12a1 1 0 11-2 0V4.804z"/>
                        </svg>
                    </div>
                </div>

                <div class="text-center mb-8">
                    <h2 class="text-3xl font-bold text-gray-800 mb-2">Teacher Login</h2>
                    <p class="text-sm text-gray-600">Welcome back. Please sign in to manage your talaqqi sessions.</p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                        <p class="text-sm text-red-600 font-medium">${errorMessage}</p>
                    </div>
                </c:if>

                <form method="POST" action="<%= request.getContextPath() %>/teacher/login">
                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                        <input type="email" name="email" placeholder="teacher@example.com" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Password</label>
                        <input type="password" name="password" placeholder="Enter your password" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                    </div>

                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center">
                            <input type="checkbox" name="remember" id="remember" class="w-4 h-4 text-purple-600 border-gray-300 rounded focus:ring-purple-500">
                            <label for="remember" class="ml-2 text-sm text-gray-700">Remember me</label>
                        </div>
                        <a href="<%= request.getContextPath() %>/teacher/forgot-password" class="text-sm text-purple-600 hover:text-purple-700 font-medium">Forgot Password?</a>
                    </div>

                    <button type="submit" class="w-full py-3 gradient-button text-white font-bold rounded-xl shadow-lg transition-all duration-300 transform hover:scale-105 mb-6">
                        Login
                    </button>

                    <div class="text-center">
                        <p class="text-sm text-gray-600">
                            Don't have an account? 
                            <a href="<%= request.getContextPath() %>/teacher/register" class="text-purple-600 hover:text-purple-700 font-semibold">Register here</a>
                        </p>
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
