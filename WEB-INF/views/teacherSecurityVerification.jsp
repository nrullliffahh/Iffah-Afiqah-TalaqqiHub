<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Verification - TalaqqiHub</title>
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
                            <path fill-rule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                </div>

                <div class="text-center mb-8">
                    <h2 class="text-3xl font-bold text-gray-800 mb-2">Security Verification</h2>
                    <p class="text-sm text-gray-600">Please answer your security question to reset your password.</p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                        <p class="text-sm text-red-600 font-medium">${errorMessage}</p>
                    </div>
                </c:if>

                <form method="POST" action="<%= request.getContextPath() %>/teacher/security-verification">
                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                        <div class="w-full px-4 py-3 bg-gray-100 border-2 border-gray-200 rounded-xl text-gray-700 font-medium">
                            ${email}
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Security Question</label>
                        <div class="w-full px-4 py-3 bg-gray-50 border-2 border-gray-200 rounded-xl text-gray-700">
                            ${securityQuestion}
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Answer</label>
                        <input type="text" name="answer" placeholder="Enter your answer" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                    </div>

                    <button type="submit" class="w-full py-3 gradient-button text-white font-bold rounded-xl shadow-lg transition-all duration-300 transform hover:scale-105 mb-6">
                        Verify
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
