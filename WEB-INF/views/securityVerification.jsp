<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Verification - TalaqqiHub</title>
    
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

            <!-- Security Verification Card -->
            <div class="bg-white rounded-3xl p-8 sm:p-10" style="box-shadow: var(--shadow-xl);">
                <div class="text-center mb-8">
                    <div class="w-16 h-16 mx-auto rounded-2xl flex items-center justify-center mb-4" style="background: var(--gradient-feature-purple);">
                        <svg class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <h2 class="text-3xl font-bold mb-2" style="color: var(--color-text-primary);">
                        Security Verification
                    </h2>
                    <p style="color: var(--color-text-muted);">
                        Please answer your security question to reset your password.
                    </p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-4 p-4 rounded-xl" style="background-color: #fee; color: #c00;">
                        ${errorMessage}
                    </div>
                </c:if>

                <form action="<%= request.getContextPath() %>/student/security-question" method="post" class="space-y-6">
                    <!-- Email Address (Read-only) -->
                    <div>
                        <label class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Email Address
                        </label>
                        <div class="w-full px-4 py-3 rounded-xl border-2" style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light); color: var(--color-text-primary);">
                            ${sessionScope.resetEmail}
                        </div>
                    </div>

                    <!-- Security Question (Read-only) -->
                    <div>
                        <label class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Security Question
                        </label>
                        <div class="w-full px-4 py-3 rounded-xl border-2" style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light); color: var(--color-text-primary);">
                            ${sessionScope.securityQuestion}
                        </div>
                    </div>

                    <!-- Answer Input -->
                    <div>
                        <label for="answer" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Answer
                        </label>
                        <input
                            id="answer"
                            name="answer"
                            type="text"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            placeholder="Enter your answer"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                        />
                    </div>

                    <!-- Verify Button -->
                    <button
                        type="submit"
                        class="w-full px-6 py-4 text-white rounded-full transform hover:-translate-y-1 transition-all duration-200"
                        style="background: var(--gradient-feature-purple); box-shadow: var(--shadow-lg);"
                    >
                        Verify
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
