<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Teacher" %>
<div class="p-6">
    <div class="flex items-start justify-between">
        <div>
            <h3 class="text-2xl font-semibold text-gray-900">Teacher Profile</h3>
            <p class="text-sm text-gray-500 mt-1">View-only access</p>
        </div>
        <div class="text-sm">
            <a href="#" onclick="document.getElementById('teacherProfileModal').classList.add('hidden'); return false;" class="text-gray-400 hover:text-gray-600">Close</a>
        </div>
    </div>

    <div class="mt-6 grid grid-cols-2 gap-8">
        <div>
            <h4 class="text-sm font-semibold text-gray-700 mb-4">Personal Information</h4>
            <div class="grid grid-cols-2 gap-y-4 text-sm text-gray-600">
                <div>
                    <p class="text-xs text-gray-500">Full Name</p>
                    <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null) ? ((Teacher)request.getAttribute("teacher")).getFullName() : "-" %></p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Email</p>
                    <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null) ? ((Teacher)request.getAttribute("teacher")).getEmail() : "-" %></p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Phone Number</p>
                    <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null) ? ((Teacher)request.getAttribute("teacher")).getPhone() : "-" %></p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Date of Birth</p>
                    <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null && ((Teacher)request.getAttribute("teacher")).getDateOfBirth() != null) ? ((Teacher)request.getAttribute("teacher")).getDateOfBirth().toString() : "-" %></p>
                </div>
            </div>
        </div>

        <div>
            <h4 class="text-sm font-semibold text-gray-700 mb-4">Professional Information</h4>
            <div class="grid grid-cols-1 gap-y-4 text-sm text-gray-600">
                <div>
                    <p class="text-xs text-gray-500">Specialty Area</p>
                    <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null) ? ((Teacher)request.getAttribute("teacher")).getSpecialty() : "-" %></p>
                </div>
                <div>
                    <p class="text-xs text-gray-500">Qualifications</p>
                    <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null) ? ((Teacher)request.getAttribute("teacher")).getQualification() : "-" %></p>
                </div>
            </div>
        </div>
    </div>

    <div class="mt-8">
        <h4 class="text-sm font-semibold text-gray-700 mb-4">Account Status</h4>
        <div class="grid grid-cols-3 gap-6 text-sm">
            <div>
                <p class="text-xs text-gray-500">Registration Date</p>
                <p class="font-medium text-gray-800"><%= ((Teacher)request.getAttribute("teacher") != null && ((Teacher)request.getAttribute("teacher")).getDateOfBirth() != null) ? ((Teacher)request.getAttribute("teacher")).getDateOfBirth().toString() : "-" %></p>
            </div>
            <div>
                <p class="text-xs text-gray-500">Approval Status</p>
                <p class="font-medium text-gray-800"><span class="px-3 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-full"><%= ((Teacher)request.getAttribute("teacher") != null && ((Teacher)request.getAttribute("teacher")).getStatus() != null) ? ((Teacher)request.getAttribute("teacher")).getStatus() : "-" %></span></p>
            </div>
            <div>
                <p class="text-xs text-gray-500">Rating</p>
                <p class="font-medium text-gray-800"><%= request.getAttribute("avgRating") != null ? String.format("%.1f", request.getAttribute("avgRating")) : "-" %></p>
            </div>
        </div>
    
    <div class="mt-6">
        <h4 class="text-sm font-semibold text-gray-700 mb-4">Certification</h4>
        <div class="text-sm text-gray-600">
            <% String cert = ((Teacher)request.getAttribute("teacher") != null) ? ((Teacher)request.getAttribute("teacher")).getCertificationPath() : null; %>
            <% if (cert != null && !cert.isEmpty()) { %>
                <% String lower = cert.toLowerCase(); %>
                <% if (lower.endsWith(".pdf")) { %>
                    <a href="<%= request.getContextPath() %>/<%= cert %>" download="<%= cert.substring(cert.lastIndexOf('/')+1) %>" class="text-purple-600 hover:underline">Download PDF Certification</a>
                <% } else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png") || lower.endsWith(".gif")) { %>
                    <div class="flex items-start space-x-4">
                        <img src="<%= request.getContextPath() %>/<%= cert %>" alt="Certification" class="max-w-full rounded mt-2 border max-h-48" />
                        <div class="flex items-center">
                            <a href="<%= request.getContextPath() %>/<%= cert %>" download="<%= cert.substring(cert.lastIndexOf('/')+1) %>" class="px-3 py-2 bg-purple-500 text-white rounded-md text-sm">Download</a>
                        </div>
                    </div>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/<%= cert %>" download="<%= cert.substring(cert.lastIndexOf('/')+1) %>" class="text-purple-600 hover:underline">Download Certification</a>
                <% } %>
            <% } else { %>
                <p class="text-sm text-gray-500">No certification uploaded.</p>
            <% } %>
        </div>
    </div>

        <!-- Total Students removed as requested -->
    </div>
</div>
