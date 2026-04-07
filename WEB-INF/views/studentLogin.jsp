<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login - TalaqqiHub</title>
    
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
    <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8" style="background: var(--gradient-bg);">
        <div class="max-w-md w-full">
            <!-- Logo/Brand -->
            <div class="text-center mb-8">
                <a href="<%= request.getContextPath() %>/home" class="inline-block">
                    <h1 class="text-3xl font-bold text-gradient-primary">TalaqqiHub</h1>
                </a>
            </div>

            <!-- Login Card -->
            <div class="bg-white rounded-3xl p-8 sm:p-10" style="box-shadow: var(--shadow-xl);">
                <div class="text-center mb-8">
                    <div class="w-16 h-16 mx-auto rounded-2xl flex items-center justify-center mb-4" style="background: var(--gradient-feature-green);">
                        <svg class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                    </div>
                    <h2 class="text-3xl font-bold mb-2" style="color: var(--color-text-primary);">
                        Student Login
                    </h2>
                    <p style="color: var(--color-text-muted);">
                        Welcome back. Please sign in to continue your learning journey.
                    </p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-4 p-4 rounded-xl" style="background-color: #fee; color: #c00;">
                        ${errorMessage}
                    </div>
                </c:if>

                <form action="<%= request.getContextPath() %>/student/login" method="post" class="space-y-6">
                    <!-- Email Address -->
                    <div>
                        <label for="email" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Email Address
                        </label>
                        <input
                            id="email"
                            name="email"
                            type="email"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-border-light); background-color: #fafafa;"
                            placeholder="student@example.com"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-border-light)'"
                        />
                    </div>

                    <!-- Password -->
                    <div>
                        <label for="password" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Password
                        </label>
                        <input
                            id="password"
                            name="password"
                            type="password"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-border-light); background-color: #fafafa;"
                            placeholder="Enter your password"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-border-light)'"
                        />
                    </div>

                    <!-- Remember Me & Forgot Password -->
                    <div class="flex items-center justify-between">
                        <label class="flex items-center cursor-pointer">
                            <input
                                type="checkbox"
                                name="rememberMe"
                                value="true"
                                class="w-4 h-4 rounded cursor-pointer"
                                style="accent-color: var(--color-primary-500);"
                            />
                            <span class="ml-2" style="color: var(--color-text-muted);">
                                Remember me
                            </span>
                        </label>
                        <a 
                            href="<%= request.getContextPath() %>/student/forgot-password" 
                            style="color: var(--color-secondary-500);"
                            class="hover:opacity-80 transition-opacity"
                        >
                            Forgot Password?
                        </a>
                    </div>

                    <!-- Login Button -->
                    <button
                        type="submit"
                        class="w-full px-6 py-4 text-white rounded-full transform hover:-translate-y-1 transition-all duration-200"
                        style="background: var(--gradient-feature-green); box-shadow: var(--shadow-lg);"
                    >
                        Login
                    </button>

                    <!-- Register Link -->
                    <p class="text-center" style="color: var(--color-text-muted);">
                        Don't have an account? 
                        <a 
                            href="<%= request.getContextPath() %>/student/register" 
                            style="color: var(--color-primary-500);"
                            class="font-medium hover:opacity-80 transition-opacity"
                        >
                            Register here
                        </a>
                    </p>
                </form>
            </div>

            <!-- Back to Home -->
            <div class="text-center mt-6">
                <a href="<%= request.getContextPath() %>/home" style="color: var(--color-text-muted);" class="hover:opacity-80 transition-opacity">
                    ← Back to Home
                </a>
            </div>
        </div>
    </div>
</body>
</html>
