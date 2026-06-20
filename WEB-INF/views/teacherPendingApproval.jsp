<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Approval - TalaqqiHub</title>
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
        .pending-icon {
            animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }
        @keyframes pulse {
            0%, 100% {
                opacity: 1;
            }
            50% {
                opacity: 0.5;
            }
        }
        .info-card {
            background: linear-gradient(135deg, #f0f9ff 0%, #fdf2f8 100%);
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
                    <a href="<%= request.getContextPath() %>/teacher/login" class="text-gray-700 hover:text-purple-600 font-medium">Back to Login</a>
                </div>
            </div>
        </div>
    </nav>

    <div class="flex-grow flex items-center justify-center px-4 py-12">
        <div class="max-w-md w-full space-y-6">
            <!-- Header Card -->
            <div class="bg-white rounded-lg shadow-lg p-8 text-center">
                <!-- Pending Icon -->
                <div class="mb-6 flex justify-center">
                    <div class="pending-icon">
                        <svg class="w-20 h-20 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                </div>

                <h1 class="text-3xl font-bold text-gray-800 mb-2">Pending Approval</h1>
                <p class="text-gray-600 text-sm mb-6">Your account is awaiting admin review</p>

                <!-- Status Message -->
                <div class="info-card rounded-lg p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-3">What's Next?</h2>
                    <ul class="text-left space-y-3 text-gray-700 text-sm">
                        <li class="flex items-start">
                            <span class="text-purple-600 font-bold mr-3">✓</span>
                            <span>Your application has been submitted successfully</span>
                        </li>
                        <li class="flex items-start">
                            <span class="text-purple-600 font-bold mr-3">→</span>
                            <span>Our admin team will review your credentials</span>
                        </li>
                        <li class="flex items-start">
                            <span class="text-purple-600 font-bold mr-3">→</span>
                            <span>You will be notified once your account is approved</span>
                        </li>
                        <li class="flex items-start">
                            <span class="text-purple-600 font-bold mr-3">→</span>
                            <span>Please check back later or use the same email to log in</span>
                        </li>
                    </ul>
                </div>

                <!-- Teacher Info -->
                <div class="bg-blue-50 rounded-lg p-4 mb-6">
                    <p class="text-sm text-gray-700">
                        <strong>Teacher Name:</strong><br>
                        <span class="text-purple-600"><%= session.getAttribute("teacherName") %></span>
                    </p>
                    <p class="text-sm text-gray-700 mt-3">
                        <strong>Email:</strong><br>
                        <span class="text-purple-600"><%= session.getAttribute("teacherEmail") %></span>
                    </p>
                </div>

                <!-- Contact Info -->
                <div class="bg-gray-50 rounded-lg p-4 mb-6">
                    <p class="text-xs text-gray-600">
                        <strong>Need Help?</strong><br>
                        Contact our support team at: <span class="text-purple-600">support@talaqqihub.com</span>
                    </p>
                </div>

                <!-- Action Button -->
                <a href="<%= request.getContextPath() %>/teacher/login" 
                   class="w-full bg-gradient-to-r from-purple-700 to-pink-700 text-white font-semibold py-3 rounded-lg hover:from-purple-800 hover:to-pink-800 transition duration-300 inline-block">
                    Back to Login
                </a>
            </div>

            <!-- Info Footer -->
            <div class="text-center text-xs text-gray-600">
                <p>Estimated approval time: 24-48 hours</p>
            </div>
        </div>
    </div>

    <footer class="bg-white border-t border-gray-200 py-6">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-gray-600 text-sm">
            <p>&copy; 2026 TalaqqiHub. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
