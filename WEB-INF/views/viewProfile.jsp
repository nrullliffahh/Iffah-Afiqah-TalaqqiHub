<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
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
<body>
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="View Profile"/>
            <jsp:param name="notifPrefix" value="profileNotif"/>
        </jsp:include>

        <div class="page-content">
      <div class="content-max mx-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-1">My Profile</h2>
        <p class="text-gray-600 mb-6">View your personal information and account details</p>

        <c:if test="${saved}">
          <div class="mb-4 rounded-xl bg-green-50 border border-green-200 text-green-800 px-4 py-3 text-sm">
            Profile updated successfully.
          </div>
        </c:if>

        <c:choose>
          <c:when test="${student != null}">
        <div class="bg-white rounded-xl shadow-sm p-8">
          <div class="flex flex-col md:flex-row md:items-center md:justify-between md:space-x-6">
            <div class="flex items-center space-x-6">
              <div class="relative">
                <c:choose>
                  <c:when test="${not empty sessionScope.profilePicPath}">
                    <img src="${pageContext.request.contextPath}${sessionScope.profilePicPath}?t=${pageContext.request.requestTime}" alt="avatar" class="w-28 h-28 rounded-full object-cover" />
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
          </c:when>
          <c:otherwise>
            <div class="bg-white rounded-xl shadow-sm p-8 text-center text-gray-600">
              <p>Could not load your profile.</p>
              <a href="<%= request.getContextPath() %>/student/edit-profile" class="inline-block mt-4 px-6 py-3 bg-gradient-to-r from-teal-400 to-green-400 text-white rounded-full">Edit Profile</a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
        </div>
    </div>
</body>
</html>
