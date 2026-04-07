<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Registration - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            background: linear-gradient(135deg, #e0f2fe 0%, #fce7f3 100%);
            min-height: 100vh;
        }
        .gradient-button {
            background: linear-gradient(135deg, #a855f7 0%, #ec4899 100%);
        }
        .gradient-button:hover {
            background: linear-gradient(135deg, #9333ea 0%, #db2777 100%);
        }
    </style>
</head>
<body class="flex flex-col min-h-screen">
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

    <div class="flex-grow flex items-center justify-center px-4 py-12">
        <div class="max-w-2xl w-full">
                <div class="text-center mb-8">
                    <h1 class="text-4xl font-bold text-purple-600 mb-2">TalaqqiHub</h1>
            </div>

            <div class="bg-white rounded-3xl shadow-2xl p-8">
                <div class="flex justify-center mb-6">
                    <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M9 4.804A7.968 7.968 0 005.5 4c-1.255 0-2.443.29-3.5.804v10A7.969 7.969 0 015.5 14c1.669 0 3.218.51 4.5 1.385A7.962 7.962 0 0114.5 14c1.255 0 2.443.29 3.5.804v-10A7.968 7.968 0 0014.5 4c-1.255 0-2.443.29-3.5.804V12a1 1 0 11-2 0V4.804z"/>
                        </svg>
                    </div>
                </div>

                <div class="text-center mb-8">
                    <h2 class="text-3xl font-bold text-gray-800 mb-2">Create Teacher Account</h2>
                    <p class="text-sm text-gray-600">Register as a teacher to guide students through talaqqi sessions.</p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                        <p class="text-sm text-red-600 font-medium">${errorMessage}</p>
                    </div>
                </c:if>

                <c:if test="${not empty successMessage}">
                    <div class="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl">
                        <p class="text-sm text-green-600 font-medium">${successMessage}</p>
                    </div>
                </c:if>

                <form method="POST" action="<%= request.getContextPath() %>/teacher/register" enctype="multipart/form-data">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Full Name</label>
                            <input type="text" name="fullName" placeholder="Enter your full name" required
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                            <input type="email" name="email" placeholder="teacher@example.com" required
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Phone Number</label>
                            <input type="tel" name="phone" placeholder="+1 (555) 123-4567" required
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Date of Birth</label>
                            <input type="date" name="dateOfBirth" required
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Qualification / Certification</label>
                        <input type="text" name="qualification" placeholder="e.g., Ijazah in Quran, Bachelor in Islamic Studies" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        <div class="mt-3">
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Upload Certification (PDF/JPG/PNG)</label>
                            <input type="file" name="certification" accept="application/pdf,image/*" class="w-full" />
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Specialty Area</label>
                            <select name="specialty" required
                                    class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                                <option value="">Select your specialty...</option>
                                <option value="Quran Recitation">Quran Recitation</option>
                                <option value="Tajweed">Tajweed</option>
                                <option value="Qiraat">Qiraat</option>
                                <option value="Hifz">Hifz</option>
                                <option value="Islamic Studies">Islamic Studies</option>
                                <option value="Arabic Language">Arabic Language</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Years of Teaching Experience</label>
                            <input type="number" name="experienceYears" placeholder="e.g., 5" min="0" required
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Password</label>
                            <input type="password" name="password" id="password" placeholder="Create a strong password" required minlength="6"
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                            <p class="text-xs text-gray-500 mt-1">Minimum 6 characters</p>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Confirm Password</label>
                            <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Re-enter your password" required minlength="6"
                                   class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                            <p id="passwordMatch" class="text-xs mt-1 hidden"></p>
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Security Question</label>
                        <p class="text-xs text-gray-600 mb-2">Select a security question</p>
                        <select name="securityQuestion" required
                                class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors mb-4">
                            <option value="">Choose a question...</option>
                            <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
                            <option value="What was the name of your first school?">What was the name of your first school?</option>
                            <option value="What is your favorite book?">What is your favorite book?</option>
                            <option value="What city were you born in?">What city were you born in?</option>
                            <option value="What is your favorite Surah?">What is your favorite Surah?</option>
                        </select>

                        <label class="block text-sm font-semibold text-gray-700 mb-2">Your answer</label>
                        <input type="text" name="securityAnswer" placeholder="Enter your answer" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:outline-none focus:border-purple-500 transition-colors">
                    </div>

                    <div class="flex items-center mb-6">
                        <input type="checkbox" id="terms" required class="w-4 h-4 text-purple-600 border-gray-300 rounded focus:ring-purple-500">
                        <label for="terms" class="ml-2 text-sm text-gray-700">
                            I agree to the <a href="#" id="openTermsLink" class="text-purple-600 hover:text-purple-700 font-semibold">Terms & Conditions</a>
                        </label>
                    </div>

                    <button type="submit" class="w-full py-3 gradient-button text-white font-bold rounded-xl shadow-lg transition-all duration-300 transform hover:scale-105 mb-6">
                        Register
                    </button>

                    <div class="text-center">
                        <p class="text-sm text-gray-600">
                            Already have an account? 
                            <a href="<%= request.getContextPath() %>/teacher/login" class="text-purple-600 hover:text-purple-700 font-semibold">Login here</a>
                        </p>
                    </div>
                </form>
            </div>

            <div class="text-center mt-8">
                <a href="<%= request.getContextPath() %>/home" class="text-gray-600 hover:text-gray-800 text-sm font-medium">
                    ← Back to Home
                </a>
            </div>
        </div>
    </div>

    <script>
        // Password matching validation
        const password = document.getElementById('password');
        const confirmPassword = document.getElementById('confirmPassword');
        const passwordMatch = document.getElementById('passwordMatch');
        const form = document.querySelector('form');

        function checkPasswordMatch() {
            if (confirmPassword.value === '') {
                passwordMatch.classList.add('hidden');
                confirmPassword.style.borderColor = '';
                return;
            }

            if (password.value === confirmPassword.value) {
                passwordMatch.textContent = '✓ Passwords match';
                passwordMatch.className = 'text-xs mt-1 text-green-600';
                confirmPassword.style.borderColor = '#10b981';
            } else {
                passwordMatch.textContent = '✗ Passwords do not match';
                passwordMatch.className = 'text-xs mt-1 text-red-600';
                confirmPassword.style.borderColor = '#ef4444';
            }
        }

        confirmPassword.addEventListener('input', checkPasswordMatch);
        password.addEventListener('input', checkPasswordMatch);

        form.addEventListener('submit', function(e) {
            if (password.value !== confirmPassword.value) {
                e.preventDefault();
                alert('Passwords do not match. Please check and try again.');
                confirmPassword.focus();
            }
        });

        // Inline Terms modal handling (load student terms inline, don't navigate away)
        document.addEventListener('DOMContentLoaded', function(){
            const openTermsLink = document.getElementById('openTermsLink');
            const termsModal = document.getElementById('termsModal');
            const termsClose = document.getElementById('termsClose');
            const termsAgree = document.getElementById('termsAgree');
            const termsModalContent = document.getElementById('termsModalContent');
            const teacherTermsPath = '<%= request.getContextPath() %>/teacher/terms';

            async function loadTeacherTerms() {
                if (!termsModalContent) return;
                try {
                    const res = await fetch(teacherTermsPath, { cache: 'no-store' });
                    if (!res.ok) throw new Error('HTTP ' + res.status);
                    const text = await res.text();
                    const doc = new DOMParser().parseFromString(text, 'text/html');
                    // Find the main content container in the fetched page
                    // Select only the main body of the teacher terms (exclude the purple header to avoid duplication)
                    const fetchedInner = doc.querySelector('div.bg-white.p-6') || doc.querySelector('div.max-w-3xl') || doc.body;
                    termsModalContent.innerHTML = fetchedInner.innerHTML;

                    // Remove svg icons from injected content (user requested no icons)
                    termsModalContent.querySelectorAll('svg').forEach(s => s.remove());
                    // Hide empty icon wrappers (leftover circles) if present
                    termsModalContent.querySelectorAll('div.w-10, div.w-12, div[class*="w-10"], div[class*="w-12"]').forEach(el => {
                        if (!el.querySelector('*') || el.querySelectorAll('*').length === 0) el.style.display = 'none';
                    });

                    // Bind agree/cancel/close inside injected content
                    const injectedAgree = termsModalContent.querySelector('#agreeBtn') || termsModalContent.querySelector('#termsAgree');
                    const injectedCancel = termsModalContent.querySelector('#cancelBtn') || termsModalContent.querySelector('#closeBtnTop');
                    if (injectedAgree) {
                        injectedAgree.addEventListener('click', function(){
                            const termsCheckbox = document.getElementById('terms');
                            if (termsCheckbox) termsCheckbox.checked = true;
                            termsModal.classList.add('hidden');
                            document.body.style.overflow = '';
                        });
                    }
                    if (injectedCancel) {
                        injectedCancel.addEventListener('click', function(){
                            termsModal.classList.add('hidden');
                            document.body.style.overflow = '';
                        });
                    }
                } catch (err) {
                    if (termsModalContent) termsModalContent.innerHTML = '<div class="p-4 text-sm text-red-600">Failed to load teacher terms. Please try again later.</div>';
                    console.error('Failed to fetch teacher terms:', err);
                }
            }

            if (openTermsLink && termsModal) {
                openTermsLink.addEventListener('click', async function(evt){
                    evt.preventDefault();
                    // load teacher terms content into the modal
                    await loadTeacherTerms();
                    termsModal.classList.remove('hidden');
                    document.body.style.overflow = 'hidden';
                });
            }

            if (termsClose) {
                termsClose.addEventListener('click', function(){
                    termsModal.classList.add('hidden');
                    document.body.style.overflow = '';
                });
            }

            if (termsAgree) {
                termsAgree.addEventListener('click', function(){
                    const termsCheckbox = document.getElementById('terms');
                    if (termsCheckbox) termsCheckbox.checked = true;
                    termsModal.classList.add('hidden');
                    document.body.style.overflow = '';
                });
            }
        });
    </script>

    <!-- Inline Terms & Conditions Modal -->
    <div id="termsModal" class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center p-4 hidden z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-3xl w-full max-h-[90vh] overflow-y-auto">
            <div class="flex items-start justify-between p-6 bg-gradient-to-r from-purple-600 to-purple-400 text-white rounded-t-xl">
                <div>
                    <h2 class="text-xl font-semibold">Terms &amp; Conditions (Teacher)</h2>
                    <p class="text-sm opacity-90">Please read these terms carefully before teaching on TalaqqiHub</p>
                </div>
                <button id="termsClose" class="p-2 rounded-full hover:bg-white/20">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-white" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 011.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" /></svg>
                </button>
            </div>
            <div id="termsModalContent" class="p-6 space-y-4">
                <div class="p-4 rounded-lg bg-green-50 border border-green-100">
                    <p class="text-green-800 font-medium">Important:</p>
                    <p class="text-sm text-green-700">Clicking "Understand and Agree" confirms you accept and will comply with these Terms &amp; Conditions.</p>
                </div>
                <div class="text-sm text-gray-700">Loading terms...</div>
                <div class="mt-6 flex items-center justify-end space-x-3">
                    <button id="termsAgree" class="px-4 py-2 rounded-lg bg-purple-600 text-white hover:bg-purple-700">Understand and Agree</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
