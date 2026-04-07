<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-packages.css">
</head>
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
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-packages.css">
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

  <main class="min-h-screen py-16" style="background: var(--gradient-bg);">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
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
                <%-- derive two hex colors from pkg.gradient so we can use them in SVG linearGradient --%>
                <% model.Package __pkg = (model.Package) pageContext.getAttribute("pkg"); String __grad = (__pkg.getGradient()!=null)?__pkg.getGradient():""; String __c1 = "#4facfe"; String __c2 = "#a66bff"; java.util.regex.Matcher __m = java.util.regex.Pattern.compile("#[0-9A-Fa-f]{3,6}").matcher(__grad); if(__m.find()){ __c1 = __m.group(); } if(__m.find()){ __c2 = __m.group(); } String __gid = "g" + __pkg.getPackageId(); %>
                <c:if test="${pkg.popular}">
                  <div class="absolute -top-4 left-1/2 transform -translate-x-1/2 z-10">
                    <span class="text-white px-4 py-1 rounded-full text-sm" style="background: var(--gradient-button); box-shadow: var(--shadow-lg);">
                      Most Popular
                    </span>
                  </div>
                </c:if>
                <div class="pkg-card-container transition-all duration-300 transform hover:-translate-y-2"
                     <c:if test="${pkg.popular}">
                       style="border-radius:18px; border:2px solid transparent; background-image: linear-gradient(#fff,#fff), ${not empty pkg.gradient ? fn:escapeXml(pkg.gradient) : 'linear-gradient(135deg,#4facfe,#a66bff)'}; background-origin: padding-box, border-box; background-clip: padding-box, border-box;"
                     </c:if>
                >
                  <div class="pkg-card">
                    <div class="text-center mb-6">
                      <h3 class="text-xl font-semibold mb-1" style="color: var(--color-text-primary);">${pkg.packageName}</h3>
                      <div class="mb-1">
                        <span class="package-price">RM<fmt:formatNumber value="${pkg.price}" type="number" maxFractionDigits="0"/></span>
                        <span class="text-sm text-gray-500"> / month</span>
                      </div>
                    </div>

                    <div class="space-y-4 mb-6">
                      <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${not empty pkg.gradient ? pkg.gradient : 'linear-gradient(135deg,#4facfe 0%,#a66bff 100%)'}; color: #fff;">
                          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M20 6L9 17l-5-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                          </svg>
                        </div>
                        <span style="color: var(--color-text-secondary);">${pkg.sessions} sessions</span>
                      </div>
                      <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${not empty pkg.gradient ? pkg.gradient : 'linear-gradient(135deg,#4facfe 0%,#a66bff 100%)'}; color: #fff;">
                          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="12" cy="12" r="9" stroke="rgba(255,255,255,0.12)" stroke-width="1.2" fill="none"/>
                            <path d="M12 7v5l3 2" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                          </svg>
                        </div>
                        <span style="color: var(--color-text-secondary);">15 per session</span>
                      </div>
                      <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${not empty pkg.gradient ? pkg.gradient : 'linear-gradient(135deg,#4facfe 0%,#a66bff 100%)'}; color: #fff;">
                          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                            <path d="M6 20v-1c0-2.21 3.58-4 6-4s6 1.79 6 4v1" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                          </svg>
                        </div>
                        <span style="color: var(--color-text-secondary);">Range Age : <c:out value="${pkg.ageRange}" default="-"/></span>
                      </div>
                    </div>

                    <p class="leading-relaxed mb-6" style="color: var(--color-text-muted);">${pkg.description}</p>
                  </div>
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
                  <div class="pkg-card-container transition-all duration-300 transform hover:-translate-y-2"
                       <c:if test="${pkg.popular}">
                         style="border-radius:18px; border:2px solid transparent; background-image: linear-gradient(#fff,#fff), ${not empty pkg.gradient ? fn:escapeXml(pkg.gradient) : 'linear-gradient(135deg,#b993d6,#8ca6db)'}; background-origin: padding-box, border-box; background-clip: padding-box, border-box;"
                       </c:if>
                  >
                    <%-- derive two hex colors from pkg.gradient so we can use them in SVG linearGradient --%>
                    <% model.Package __pkg = (model.Package) pageContext.getAttribute("pkg"); String __grad = (__pkg.getGradient()!=null)?__pkg.getGradient():""; String __c1 = "#b993d6"; String __c2 = "#8ca6db"; java.util.regex.Matcher __m = java.util.regex.Pattern.compile("#[0-9A-Fa-f]{3,6}").matcher(__grad); if(__m.find()){ __c1 = __m.group(); } if(__m.find()){ __c2 = __m.group(); } String __gid = "g" + __pkg.getPackageId(); %>
                  <div class="pkg-card">
                    <div class="text-center mb-6">
                      <h3 class="text-xl font-semibold mb-1" style="color: var(--color-text-primary);">${pkg.packageName}</h3>
                      <div class="mb-1">
                        <span class="package-price">RM<fmt:formatNumber value="${pkg.price}" type="number" maxFractionDigits="0"/></span>
                        <span class="text-sm text-gray-500"> / month</span>
                      </div>
                    </div>

                    <div class="space-y-4 mb-6">
                      <div class="flex items-center space-x-3">
                          <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${not empty pkg.gradient ? pkg.gradient : 'linear-gradient(135deg,#b993d6 0%,#8ca6db 100%)'}; color: #fff;">
                            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                              <path d="M20 6L9 17l-5-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                          </div>
                        <span style="color: var(--color-text-secondary);">${pkg.sessions} sessions</span>
                      </div>
                      <div class="flex items-center space-x-3">
                          <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${not empty pkg.gradient ? pkg.gradient : 'linear-gradient(135deg,#b993d6 0%,#8ca6db 100%)'}; color: #fff;">
                            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                              <circle cx="12" cy="12" r="9" stroke="rgba(255,255,255,0.12)" stroke-width="1.2" fill="none"/>
                              <path d="M12 7v5l3 2" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                          </div>
                        <span style="color: var(--color-text-secondary);">15 per session</span>
                      </div>
                      <div class="flex items-center space-x-3">
                          <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style="background: ${not empty pkg.gradient ? pkg.gradient : 'linear-gradient(135deg,#b993d6 0%,#8ca6db 100%)'}; color: #fff;">
                            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                              <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                              <path d="M6 20v-1c0-2.21 3.58-4 6-4s6 1.79 6 4v1" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                            </svg>
                          </div>
                        <span style="color: var(--color-text-secondary);">Range Age : <c:out value="${pkg.ageRange}" default="-"/></span>
                      </div>
                    </div>

                    <p class="leading-relaxed mb-6" style="color: var(--color-text-muted);">${pkg.description}</p>
                  </div>
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
  </main>
</body>
</html>
