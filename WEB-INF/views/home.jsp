<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TalaqqiHub - Learn the Quran with Guidance and Care</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- CSS (USE CONTEXT PATH) -->
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
    <nav class="bg-white shadow-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-16">
                <!-- Logo -->
                <div class="flex-shrink-0">
                    <a href="<%= request.getContextPath() %>/home" class="text-2xl font-bold text-gradient-primary">
                        TalaqqiHub
                    </a>
                </div>
                
                <!-- Navigation Links -->
                <div class="hidden md:flex space-x-8">
                    <a href="<%= request.getContextPath() %>/home" class="text-gray-700 px-3 py-2 text-sm font-medium transition-colors nav-link">
                        Home
                    </a>
                    <a href="<%= request.getContextPath() %>/roles" class="text-gray-700 px-3 py-2 text-sm font-medium transition-colors nav-link">
                        Roles
                    </a>
                    <a href="<%= request.getContextPath() %>/packages" class="text-gray-700 px-3 py-2 text-sm font-medium transition-colors nav-link">
                        Packages
                    </a>
                    <a href="<%= request.getContextPath() %>/admin/login" class="text-gray-700 px-3 py-2 text-sm font-medium transition-colors nav-link">
                        Admin Login
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="min-h-screen py-16" style="background: var(--gradient-bg);">
        
        <!-- Hero Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 md:py-24">
        <div class="grid md:grid-cols-2 gap-12 items-center">
            
            <!-- Left - Image -->
            <div class="order-2 md:order-1">
                <div class="rounded-3xl overflow-hidden shadow-2xl">
                    <img
                        src="<%= request.getContextPath() %>/images/landing%202.JPG"
                        alt="Quran learning"
                        class="w-full h-[400px] object-cover"
                        onerror="this.src='<%= request.getContextPath() %>/images/placeholder.jpg'; this.onerror=null; this.style.background='linear-gradient(135deg, #667eea 0%, #764ba2 100%)'"
                    />
                </div>
            </div>

            <!-- Right - Content -->
            <div class="order-1 md:order-2 space-y-6">
                <h1 class="text-5xl md:text-6xl font-extrabold text-gradient-primary">
                    Welcome to TalaqqiHub
                </h1>
                
                <h2 class="text-2xl md:text-3xl text-gray-800 font-semibold">
                    Learn the Quran with Guidance and Care
                </h2>
                
                <p class="text-lg leading-relaxed text-gray-600">
                    TalaqqiHub is an online Quran learning platform that helps students learn in a guided and structured way. 
                    Join talaqqi sessions, track your progress, and grow your understanding of the Quran at your own pace.
                </p>
                
                <div class="pt-4">
                    <a 
                        href="<%= request.getContextPath() %>/roles"
                        class="inline-block px-8 py-4 text-white font-semibold rounded-full transform hover:-translate-y-1 transition-all duration-200 shadow-lg bg-gradient-button"
                    >
                        Get Started
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div class="grid md:grid-cols-3 gap-8">
            
            <!-- Feature 1 -->
            <div class="feature-card rounded-2xl p-8 transition-shadow hover:shadow-xl shadow-md">
                <div class="feature-badge bg-gradient-feature-green mb-4">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                </div>
                <h3 class="text-xl font-semibold mb-2 text-gray-800">Guided Learning</h3>
                <p class="text-gray-600">Structured talaqqi sessions with experienced teachers</p>
            </div>

            <!-- Feature 2 -->
            <div class="feature-card rounded-2xl p-8 transition-shadow hover:shadow-xl shadow-md">
                <div class="feature-badge bg-gradient-feature-purple mb-4">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                </div>
                <h3 class="text-xl font-semibold mb-2 text-gray-800">Track Progress</h3>
                <p class="text-gray-600">Monitor your learning journey with detailed feedback</p>
            </div>

            <!-- Feature 3 -->
            <div class="feature-card rounded-2xl p-8 transition-shadow hover:shadow-xl shadow-md">
                <div class="feature-badge bg-gradient-feature-teal mb-4">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <h3 class="text-xl font-semibold mb-2 text-gray-800">Flexible Schedule</h3>
                <p class="text-gray-600">Learn at your own pace with flexible session timing</p>
            </div>

        </div>
    </section>
</div>
</body>
</html>
