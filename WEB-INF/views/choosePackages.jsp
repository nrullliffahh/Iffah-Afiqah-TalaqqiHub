<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Packages - TalaqqiHub</title>
    
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
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            
            <!-- Header -->
            <header class="text-center mb-16">
                <h1 class="text-4xl md:text-5xl font-extrabold text-gradient-primary">
                    Choose a Package That Fits Your Goals
                </h1>
            </header>

            <!-- Kids Packages -->
            <div class="mb-20">
                <h2 class="text-3xl font-bold mb-8 text-center md:text-left" style="color: var(--color-text-primary);">
                    Kids Packages
                </h2>
                <div class="grid md:grid-cols-2 gap-8">
                    <c:forEach var="pkg" items="${packages}">
                        <c:if test="${pkg.category == 'Kids'}">
                            <div class="relative">
                                <c:if test="${pkg.popular}">
                                    <div class="absolute -top-4 left-1/2 transform -translate-x-1/2 z-10">
                                        <span class="text-white px-4 py-1 rounded-full text-sm" style="background: var(--gradient-button); box-shadow: var(--shadow-lg);">
                                            Most Popular
                                        </span>
                                    </div>
                                </c:if>
                                <div 
                                    class="bg-white rounded-3xl p-8 transition-all duration-300 transform hover:-translate-y-2 ${pkg.popular ? 'border-2' : ''}"
                                    style="box-shadow: var(--shadow-xl); ${pkg.popular ? 'border-color: var(--color-accent-pink);' : ''}"
                                >
                                    <%-- header extracted; icon colors will use white like packages.jsp --%>
                                    <div class="text-center mb-6">
                                        <h3 class="text-2xl font-bold mb-2" style="color: var(--color-text-primary);">
                                            ${pkg.packageName}
                                        </h3>
                                        <div class="flex items-baseline justify-center">
                                            <span class="package-price">RM<fmt:formatNumber value="${pkg.price}" type="number" maxFractionDigits="0"/></span>
                                            <span class="ml-2" style="color: var(--color-text-muted);">/ month</span>
                                        </div>
                                    </div>

                                    <div class="space-y-4 mb-6">
                                        <div class="flex items-center space-x-3">
                                            <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${pkg.gradient}; color: #fff;">
                                                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                    <path d="M20 6L9 17l-5-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                                </svg>
                                            </div>
                                            <span style="color: var(--color-text-secondary);">${pkg.sessions} sessions</span>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${pkg.gradient}; color: #fff;">
                                                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                    <circle cx="12" cy="12" r="9" stroke="rgba(255,255,255,0.12)" stroke-width="1.2" fill="none"/>
                                                    <path d="M12 7v5l3 2" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                                </svg>
                                            </div>
                                            <span style="color: var(--color-text-secondary);">${pkg.durationPerSession} minutes per session</span>
                                        </div>
                                            
                                    </div>

                                    <p class="leading-relaxed mb-6" style="color: var(--color-text-muted);">${pkg.description}</p>
                                    <form method="post" action="<%= request.getContextPath() %>/student/choose-package">
                                        <%
                                            Object _pkgObj = pageContext.getAttribute("pkg");
                                            String _pkgDbId = null;
                                            if (_pkgObj != null) {
                                                try {
                                                    java.lang.reflect.Method m = _pkgObj.getClass().getMethod("getDbPackageId");
                                                    Object v = m.invoke(_pkgObj);
                                                    if (v != null) _pkgDbId = v.toString();
                                                } catch (Exception e) {
                                                    try {
                                                        java.lang.reflect.Method m2 = _pkgObj.getClass().getMethod("getPackageId");
                                                        Object v2 = m2.invoke(_pkgObj);
                                                        if (v2 != null) _pkgDbId = v2.toString();
                                                    } catch (Exception ignore) { }
                                                }
                                            }
                                        %>
                                        <input type="hidden" name="packageId" value="<%= _pkgDbId %>" />
                                        <div class="text-center">
                                            <button type="submit" class="pkg-cta inline-flex items-center px-4 py-2 rounded-full text-white" style="background: var(--gradient-button);">Choose ${pkg.packageName}</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>

            <!-- Adults Packages -->
            <div>
                <h2 class="text-3xl font-bold mb-8 text-center md:text-left" style="color: var(--color-text-primary);">
                    Adults Packages
                </h2>
                <div class="grid md:grid-cols-2 gap-8">
                    <c:forEach var="pkg" items="${packages}">
                        <c:if test="${pkg.category == 'Adults'}">
                            <div class="relative">
                                <c:if test="${pkg.popular}">
                                    <div class="absolute -top-4 left-1/2 transform -translate-x-1/2 z-10">
                                        <span class="text-white px-4 py-1 rounded-full text-sm" style="background: var(--gradient-button); box-shadow: var(--shadow-lg);">
                                            Most Popular
                                        </span>
                                    </div>
                                </c:if>
                                <div 
                                    class="bg-white rounded-3xl p-8 transition-all duration-300 transform hover:-translate-y-2 ${pkg.popular ? 'border-2' : ''}"
                                    style="box-shadow: var(--shadow-xl); ${pkg.popular ? 'border-color: var(--color-accent-pink);' : ''}"
                                >
                                    <div class="text-center mb-6">
                                        <h3 class="text-2xl font-bold mb-2" style="color: var(--color-text-primary);">
                                            ${pkg.packageName}
                                        </h3>
                                        <div class="flex items-baseline justify-center">
                                            <span class="package-price">RM<fmt:formatNumber value="${pkg.price}" type="number" maxFractionDigits="0"/></span>
                                            <span class="ml-2" style="color: var(--color-text-muted);">/ month</span>
                                        </div>
                                    </div>

                                    <div class="space-y-4 mb-6">
                                        <div class="flex items-center space-x-3">
                                            <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${pkg.gradient}; color: #fff;">
                                                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                    <path d="M20 6L9 17l-5-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                                </svg>
                                            </div>
                                            <span style="color: var(--color-text-secondary);">${pkg.sessions} sessions</span>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${pkg.gradient}; color: #fff;">
                                                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                    <circle cx="12" cy="12" r="9" stroke="rgba(255,255,255,0.12)" stroke-width="1.2" fill="none"/>
                                                    <path d="M12 7v5l3 2" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                                </svg>
                                            </div>
                                            <span style="color: var(--color-text-secondary);">${pkg.durationPerSession} minutes per session</span>
                                        </div>
                                    </div>

                                    <p class="leading-relaxed mb-6" style="color: var(--color-text-muted);">
                                        ${pkg.description}
                                    </p>
                                    <form method="post" action="<%= request.getContextPath() %>/student/choose-package">
                                        <%
                                            Object _pkgObj = pageContext.getAttribute("pkg");
                                            String _pkgDbId = null;
                                            if (_pkgObj != null) {
                                                try {
                                                    java.lang.reflect.Method m = _pkgObj.getClass().getMethod("getDbPackageId");
                                                    Object v = m.invoke(_pkgObj);
                                                    if (v != null) _pkgDbId = v.toString();
                                                } catch (Exception e) {
                                                    try {
                                                        java.lang.reflect.Method m2 = _pkgObj.getClass().getMethod("getPackageId");
                                                        Object v2 = m2.invoke(_pkgObj);
                                                        if (v2 != null) _pkgDbId = v2.toString();
                                                    } catch (Exception ignore) { }
                                                }
                                            }
                                        %>
                                        <input type="hidden" name="packageId" value="<%= _pkgDbId %>" />
                                        <div class="text-center">
                                            <button type="submit" class="pkg-cta inline-flex items-center px-4 py-2 rounded-full text-white" style="background: var(--gradient-button);">Choose ${pkg.packageName}</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
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
