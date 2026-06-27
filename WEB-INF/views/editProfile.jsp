<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Edit Profile - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css" />
    <style>
        .content-max { max-width: 1100px; }
        .upload-form { position: absolute; right: 6px; bottom: 6px; }
        .upload-label { display: inline-flex; align-items: center; justify-content: center; width:36px; height:36px; border-radius:9999px; background:#ffffff; box-shadow:0 1px 4px rgba(0,0,0,0.08); cursor:pointer; }
        .upload-label input { display:none; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Edit Profile"/>
            <jsp:param name="notifPrefix" value="editProfileNotif"/>
        </jsp:include>

        <div class="page-content">
      <div class="content-max mx-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-1">
          <a href="<%= request.getContextPath() %>/student/edit-profile" class="flex items-center text-gray-800 hover:underline">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
            </svg>
            <span>Edit Profile</span>
          </a>
        </h2>
        <p class="text-gray-600 mb-6">Update your personal information</p>

        <div class="bg-white rounded-xl shadow-sm p-8">
          <div class="flex flex-col items-center">
            <div class="relative">
              <c:choose>
                <c:when test="${not empty sessionScope.profilePicPath}">
                  <img src="${pageContext.request.contextPath}${sessionScope.profilePicPath}?t=${param.photoUpdated != null ? param.photoUpdated : pageContext.request.requestTime}" alt="avatar" class="w-28 h-28 rounded-full object-cover" />
                </c:when>
                <c:otherwise>
                  <div class="w-28 h-28 rounded-full flex items-center justify-center text-white text-2xl font-bold" style="background: linear-gradient(180deg,#2fbf9b,#2d9f81);">
                    <c:out value="${initials}" default="AA" />
                  </div>
                </c:otherwise>
              </c:choose>

              <form id="uploadPhotoForm" action="<%= request.getContextPath() %>/student/upload-profile-pic" method="post" enctype="multipart/form-data" class="upload-form">
                <label class="upload-label" title="Change photo">
                  <input type="file" name="photo" accept="image/png,image/jpeg" onchange="document.getElementById('uploadPhotoForm').submit()" />
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536M9 11l6-6m2 2l-6 6M3 21v-4a4 4 0 014-4h4" />
                  </svg>
                </label>
              </form>
            </div>

            <p class="text-sm text-gray-500 mt-3">Click the camera icon to change your profile picture</p>
          </div>

          <form action="<%= request.getContextPath() %>/student/edit-profile" method="post" class="mt-8">
            <input type="hidden" name="studentId" value="${student.studentId}" />
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="md:col-span-2">
                <label class="text-xs text-gray-500">Full Name *</label>
                <input name="fullName" required value="${student.fullName}" class="mt-1 block w-full rounded border border-gray-200 p-3 focus:outline-none focus:ring-2 focus:ring-green-300" />
              </div>

              <div>
                <label class="text-xs text-gray-500">Email Address</label>
                <input name="email" value="${student.email}" disabled class="mt-1 block w-full rounded border border-gray-200 p-3 bg-gray-50" />
                <p class="text-xs text-gray-500 mt-1">Email cannot be changed</p>
              </div>

              <div>
                <label class="text-xs text-gray-500">Phone Number *</label>
                <input name="phoneNumber" required value="${student.phoneNumber}" class="mt-1 block w-full rounded border border-gray-200 p-3 focus:outline-none" />
              </div>

              <div>
                <label class="text-xs text-gray-500">Date of Birth *</label>
                <input type="date" name="dateOfBirth" required value="${student.dateOfBirth}" class="mt-1 block w-full rounded border border-gray-200 p-3" />
              </div>
            </div>

            <div class="mt-8 flex space-x-4">
              <button type="submit" class="px-6 py-3 bg-gradient-to-r from-teal-400 to-green-400 text-white rounded-full">Save Changes</button>
              <a href="<%= request.getContextPath() %>/student/profile" class="px-6 py-3 border border-gray-300 rounded-full">Cancel</a>
            </div>
          </form>

          <div class="mt-8">
            <div class="bg-gray-50 rounded-xl p-4 shadow-sm">
              <h4 class="font-semibold text-gray-800">Important Information</h4>
              <ul class="text-sm text-gray-600 mt-2 list-disc list-inside">
                <li>Email address cannot be changed for security reasons</li>
                <li>Fields marked with * are required</li>
                <li>Profile picture must be JPG or PNG format</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
        </div>
    </div>
</body>
</html>
