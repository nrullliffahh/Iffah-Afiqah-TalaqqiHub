<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css" />
    <style>
      /* small helper to limit card width on large screens */
      .content-max { max-width: 1100px; }
      /* upload control styling */
      .upload-form { position: absolute; right: 6px; bottom: 6px; }
      .upload-label { display: inline-flex; align-items: center; justify-content: center; width:36px; height:36px; border-radius:9999px; background:#ffffff; box-shadow:0 1px 4px rgba(0,0,0,0.08); cursor:pointer; }
      .upload-label input { display:none; }
      .upload-label svg { display:block; }
    </style>
</head>
<body class="bg-gray-50">
  <div class="flex min-h-screen">
    <!-- Sidebar -->
    <aside class="w-64 fixed h-screen" style="background: linear-gradient(180deg, #2d5f4f 0%, #1a3d30 100%);">
      <div class="p-6">
        <h1 class="text-2xl font-bold text-white">TalaqqiHub</h1>
        <p class="text-sm text-green-200">Student Portal</p>
      </div>
      <nav class="mt-6">
        <a href="<%= request.getContextPath() %>/student/dashboard" class="flex items-center px-6 py-3 text-white bg-green-800 bg-opacity-50">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
            Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/student/class-booking" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            Class Booking
        </a>
        <a href="<%= request.getContextPath() %>/student/attendance" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            Attendance
        </a>
        <a href="<%= request.getContextPath() %>/student/sessions" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
            Talaqqi Sessions
        </a>
        <a href="<%= request.getContextPath() %>/student/evaluation" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
            </svg>
            Evaluation
        </a>
        <a href="<%= request.getContextPath() %>/student/announcements" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z" />
            </svg>
            Announcements
        </a>
        <a href="<%= request.getContextPath() %>/student/ai-assistance" class="flex items-center px-6 py-3 text-green-200 hover:bg-green-800 hover:bg-opacity-30">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
            </svg>
            AI Assistance
        </a>
      </nav>

      <div class="absolute bottom-0 w-64 p-6">
        <a href="<%= request.getContextPath() %>/student/logout" class="flex items-center px-4 py-2 text-green-200 hover:bg-red-600 hover:text-white rounded-lg transition-colors">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
            Logout
        </a>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 ml-64 p-8">
      <div class="content-max mx-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-1">My Profile</h2>
        <p class="text-gray-600 mb-6">View your personal information and account details</p>

        <div class="bg-white rounded-xl shadow-sm p-8">
          <div class="flex flex-col md:flex-row md:items-center md:justify-between md:space-x-6">
            <div class="flex items-center space-x-6">
              <div class="relative">
                <c:choose>
                  <c:when test="${not empty sessionScope.profilePicPath}">
                    <img src="${pageContext.request.contextPath}${sessionScope.profilePicPath}" alt="avatar" class="w-28 h-28 rounded-full object-cover" />
                  </c:when>
                  <c:otherwise>
                    <div class="w-28 h-28 rounded-full flex items-center justify-center text-white text-2xl font-bold" style="background: linear-gradient(180deg,#2fbf9b,#2d9f81);">
                      <c:out value="${initials}" default="U" />
                    </div>
                  </c:otherwise>
                </c:choose>

                <!-- small edit photo button -->
                <form id="uploadPhotoForm" action="<%= request.getContextPath() %>/student/upload-profile-pic" method="post" enctype="multipart/form-data" class="upload-form">
                  <label class="upload-label" title="Change photo">
                    <input type="file" name="photo" accept="image/*" onchange="document.getElementById('uploadPhotoForm').submit()" />
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536M9 11l6-6m2 2l-6 6M3 21v-4a4 4 0 014-4h4" />
                    </svg>
                  </label>
                </form>
              </div>
              <div>
                <h3 class="text-xl font-bold text-gray-800"><c:out value="${student.fullName}" /></h3>
                <p class="text-sm text-gray-500 mt-1">Student Account</p>
              </div>
            </div>

            <div class="mt-6 md:mt-0 flex space-x-3">
              <a href="<%= request.getContextPath() %>/student/edit-profile" class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-teal-400 to-green-400 text-white rounded-full shadow">Edit Profile</a>
              <a href="<%= request.getContextPath() %>/student/change-password" class="inline-flex items-center px-6 py-3 border border-gray-300 rounded-full">Change Password</a>
            </div>
          </div>

          <div class="mt-8 border-t pt-8">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <p class="text-xs text-gray-500">Full Name</p>
                <p class="font-medium text-gray-800 mt-1"><c:out value="${student.fullName}" /></p>
              </div>
              <div>
                <p class="text-xs text-gray-500">Email Address</p>
                <p class="font-medium text-gray-800 mt-1"><c:out value="${student.email}" /></p>
              </div>

              <div>
                <p class="text-xs text-gray-500">Phone Number</p>
                <p class="font-medium text-gray-800 mt-1"><c:out value="${student.phoneNumber}" /></p>
              </div>
              <div>
                <p class="text-xs text-gray-500">Date of Birth</p>
                <p class="font-medium text-gray-800 mt-1"><c:out value="${student.dateOfBirth}" /></p>
              </div>

              <div>
                <p class="text-xs text-gray-500">Selected Package</p>
                <p class="font-medium text-gray-800 mt-1"><c:out value="${selectedPackage}" default="-" /></p>
              </div>
              <div>
                <p class="text-xs text-gray-500">Account Status</p>
                <p class="mt-1">
                  <c:choose>
                    <c:when test="${selectedPackage != null && accountStatus == 'Active'}">
                      <span class="px-3 py-1 rounded-full bg-green-100 text-green-700 text-sm font-medium">Active</span>
                    </c:when>
                    <c:otherwise>
                      <span class="px-3 py-1 rounded-full bg-gray-100 text-gray-700 text-sm font-medium">Inactive</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
            </div>
          </div>

          <div class="mt-8">
            <div class="bg-gray-50 rounded-xl p-4 shadow-sm">
              <h4 class="font-semibold text-gray-800">Account Information</h4>
              <p class="text-sm text-gray-600 mt-2">Member since <c:out value="${student.registrationDate}" default="(unknown)" />. Your email address is used for login and important account notifications. To update your package or subscription, please contact our admin team.</p>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
