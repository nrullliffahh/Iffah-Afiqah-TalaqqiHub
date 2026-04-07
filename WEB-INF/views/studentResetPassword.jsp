<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - TalaqqiHub</title>
    
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

            <!-- Reset Password Card -->
            <div class="bg-white rounded-3xl p-8 sm:p-10" style="box-shadow: var(--shadow-xl);">
                <div class="text-center mb-8">
                    <div class="w-16 h-16 mx-auto rounded-2xl flex items-center justify-center mb-4" style="background: var(--gradient-feature-green);">
                        <svg class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                        </svg>
                    </div>
                    <h2 class="text-3xl font-bold mb-2" style="color: var(--color-text-primary);">
                        Reset Password
                    </h2>
                    <p style="color: var(--color-text-muted);">
                        Create a new secure password for your account.
                    </p>
                </div>

                <!-- Success Message -->
                <div class="mb-6 p-4 rounded-xl flex items-center" style="background-color: #d1fae5; border: 1px solid #6ee7b7;">
                    <svg class="w-5 h-5 mr-2" style="color: #059669;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span style="color: #059669; font-weight: 500;">Identity verified successfully!</span>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-4 p-4 rounded-xl" style="background-color: #fee; color: #c00;">
                        ${errorMessage}
                    </div>
                </c:if>

                <form action="<%= request.getContextPath() %>/student/reset-password" method="post" class="space-y-6">
                    <!-- New Password -->
                    <div>
                        <label for="newPassword" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            New Password
                        </label>
                        <input
                            id="newPassword"
                            name="newPassword"
                            type="password"
                            required
                            minlength="8"
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            placeholder="Enter new password"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                        />
                        <p class="mt-2 text-sm" style="color: var(--color-text-muted);">
                            Must be at least 8 characters long
                        </p>
                    </div>

                    <!-- Confirm New Password -->
                    <div>
                        <label for="confirmPassword" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Confirm New Password
                        </label>
                        <input
                            id="confirmPassword"
                            name="confirmPassword"
                            type="password"
                            required
                            minlength="8"
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            placeholder="Re-enter new password"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                        />
                    </div>

                    <!-- Reset Password Button -->
                    <button
                        type="submit"
                        class="w-full px-6 py-4 text-white rounded-full transform hover:-translate-y-1 transition-all duration-200"
                        style="background: var(--gradient-feature-green); box-shadow: var(--shadow-lg);"
                    >
                        Reset Password
                    </button>

                    <!-- Back to Login -->
                    <p class="text-center">
                        <a 
                            href="<%= request.getContextPath() %>/student/login"
                            style="color: var(--color-secondary-500);"
                            class="hover:opacity-80 transition-opacity"
                        >
                            ← Back to Login
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
