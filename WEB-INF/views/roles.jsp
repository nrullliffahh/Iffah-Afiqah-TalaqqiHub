<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Choose Your Role - TalaqqiHub</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/colors.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/animations.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/print.css">
</head>
<body>
    <!-- Navbar -->
    <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-16">
                <div class="flex-shrink-0">
                    <a href="<%= request.getContextPath() %>/home" class="text-2xl font-bold text-gradient-primary">
                        TalaqqiHub
                    </a>
                </div>
                
                <div class="hidden md:flex space-x-8">
                    <a href="<%= request.getContextPath() %>/home" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium">
                        Home
                    </a>
                    <a href="<%= request.getContextPath() %>/roles" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium">
                        Roles
                    </a>
                    <a href="<%= request.getContextPath() %>/packages" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium">
                        Packages
                    </a>
                    <a href="<%= request.getContextPath() %>/admin/login" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium">
                        Admin Login
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="min-h-screen py-16" style="background: var(--gradient-bg);">
        <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
            
            <!-- Header -->
            <div class="text-center mb-16">
                <h1 class="text-4xl md:text-5xl font-extrabold text-gradient-primary mb-4">
                    Choose How You Want to Continue
                </h1>
                <p class="text-xl" style="color: var(--color-text-muted);">
                    Select your role to access the right features for you
                </p>
            </div>

            <!-- Role Cards -->
            <div class="grid md:grid-cols-2 gap-8">
                <c:forEach var="role" items="${roles}">
                    <div 
                        class="bg-white rounded-3xl p-8 transition-all duration-300 transform hover:-translate-y-2" 
                        style="box-shadow: var(--shadow-xl);"
                    >
                        <div class="mb-6 rounded-2xl overflow-hidden bg-gradient-to-br from-blue-50 to-purple-50 flex items-center justify-center py-8">
                            <img
                                src="<%= request.getContextPath() %>${role.imagePath}"
                                alt="${role.roleName}"
                                class="w-full h-64 object-contain"
                            />
                        </div>
                        
                        <div class="space-y-4">
                            <div class="flex items-center space-x-3">
                                <div class="w-12 h-12 rounded-xl flex items-center justify-center" style="background: ${role.iconGradient};">
                                    <c:choose>
                                        <c:when test="${role.roleName == 'Student'}">
                                            <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                            </svg>
                                        </c:when>
                                        <c:otherwise>
                                            <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                            </svg>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <h2 class="text-3xl font-bold" style="color: var(--color-text-primary);">${role.roleName}</h2>
                            </div>
                            
                            <p class="text-lg leading-relaxed" style="color: var(--color-text-muted);">
                                ${role.description}
                            </p>
                            
                            <div class="pt-4">
                                <a href="<%= request.getContextPath() %>${role.loginUrl}">
                                    <button 
                                        class="w-full px-6 py-4 text-white rounded-full transform hover:-translate-y-1 transition-all duration-200"
                                        style="background: ${role.iconGradient}; box-shadow: var(--shadow-lg);"
                                    >
                                        Continue as ${role.roleName}
                                    </button>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Back to Home Link -->
            <div class="text-center mt-12">
                <a href="<%= request.getContextPath() %>/home" style="color: var(--color-secondary-500);" class="hover:opacity-80 transition-opacity">
                    ← Back to Home
                </a>
            </div>
        </div>
    </div>
</body>
</html>
