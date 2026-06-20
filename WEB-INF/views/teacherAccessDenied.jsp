<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - TalaqqiHub</title>
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
            background: linear-gradient(135deg, #fee2e2 0%, #fce7f3 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
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
                    <a href="<%= request.getContextPath() %>/teacher/login" class="text-gray-700 hover:text-purple-600 font-medium">Teacher Login</a>
                </div>
            </div>
        </div>
    </nav>

    <div class="flex-grow flex items-center justify-center px-4 py-12">
        <div class="max-w-md w-full space-y-6">
            <!-- Error Card -->
            <div class="bg-white rounded-lg shadow-lg p-8 text-center">
                <!-- Error Icon -->
                <div class="mb-6 flex justify-center">
                    <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center">
                        <svg class="w-12 h-12 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4v2m0 0v2m0-6V9m0 0l1.414-1.414m2.828 0L14 9m2 2h4m0 0h2m-2 0v4m0 0v2m0-2h-2m2 0h4"></path>
                        </svg>
                    </div>
                </div>

                <h1 class="text-3xl font-bold text-red-600 mb-2">Access Denied</h1>
                <p class="text-gray-600 text-sm mb-6">Your teacher application has been rejected</p>

                <!-- Rejection Message -->
                <div class="bg-red-50 rounded-lg p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-3">Application Status</h2>
                    <p class="text-gray-700 text-sm leading-relaxed mb-4">
                        Unfortunately, your application to join TalaqqiHub as a teacher has been rejected. 
                        Your profile did not meet the required criteria at this time.
                    </p>
                    <div class="bg-white rounded p-3 border border-red-200">
                        <p class="text-sm text-gray-600">
                            <strong>Status:</strong> <span class="text-red-600">Rejected</span>
                        </p>
                    </div>
                </div>

                <!-- Next Steps -->
                <div class="bg-blue-50 rounded-lg p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-3">What Can You Do?</h2>
                    <ul class="text-left space-y-2 text-gray-700 text-sm">
                        <li class="flex items-start">
                            <span class="text-blue-600 font-bold mr-3">→</span>
                            <span>Contact our support team for detailed feedback</span>
                        </li>
                        <li class="flex items-start">
                            <span class="text-blue-600 font-bold mr-3">→</span>
                            <span>Improve your qualifications and reapply later</span>
                        </li>
                        <li class="flex items-start">
                            <span class="text-blue-600 font-bold mr-3">→</span>
                            <span>Register as a student to access our courses</span>
                        </li>
                    </ul>
                </div>

                <!-- Contact Support -->
                <div class="bg-gray-50 rounded-lg p-4 mb-6">
                    <p class="text-sm text-gray-600 mb-2">
                        <strong>Need Assistance?</strong>
                    </p>
                    <p class="text-xs text-gray-600">
                        Email: <span class="text-purple-600 font-semibold">support@talaqqihub.com</span>
                    </p>
                    <p class="text-xs text-gray-600 mt-2">
                        We're here to help and can provide more information about the decision.
                    </p>
                </div>

                <!-- Action Buttons -->
                <div class="space-y-3">
                    <a href="<%= request.getContextPath() %>/home" 
                       class="w-full bg-gradient-to-r from-purple-700 to-pink-700 text-white font-semibold py-3 rounded-lg hover:from-purple-800 hover:to-pink-800 transition duration-300 inline-block">
                        Go to Home
                    </a>
                    <a href="<%= request.getContextPath() %>/student/register" 
                       class="w-full bg-gray-200 text-gray-800 font-semibold py-3 rounded-lg hover:bg-gray-300 transition duration-300 inline-block">
                        Register as Student
                    </a>
                </div>
            </div>

            <!-- Footer Note -->
            <div class="text-center text-xs text-gray-600">
                <p>If you believe this is a mistake, please contact support immediately.</p>
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
