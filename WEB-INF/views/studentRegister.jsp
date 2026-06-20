<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Student Account - TalaqqiHub</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss@3.4.1/base.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/colors.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fonts.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/animations.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>
    <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8" style="background: var(--gradient-bg);">
        <div class="max-w-md w-full">
            <div class="text-center mb-8">
                <a href="${pageContext.request.contextPath}/home" class="inline-block">
                    <h1 class="text-3xl font-bold text-gradient-primary">TalaqqiHub</h1>
                </a>
            </div>

            <div class="bg-white rounded-3xl p-8 sm:p-10" style="box-shadow: var(--shadow-xl);">
                <div class="text-center mb-8">
                    <div class="w-16 h-16 mx-auto rounded-2xl flex items-center justify-center mb-4" style="background: var(--gradient-feature-purple);">
                        <svg class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                    </div>
                    <h2 class="text-3xl font-bold mb-2" style="color: var(--color-text-primary);">
                        Create Student Account
                    </h2>
                    <p style="color: var(--color-text-muted);">
                        Start your Quran learning journey with guided talaqqi sessions.
                    </p>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="mb-5 p-4 rounded-xl" style="background-color: #fee; border: 1px solid #fcc;">
                        <p style="color: #c33;">${errorMessage}</p>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/student/register" method="post" class="space-y-5">
                    <div>
                        <label for="fullName" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Full Name
                        </label>
                        <input
                            id="fullName"
                            name="fullName"
                            type="text"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                            placeholder="Enter your full name"
                            value="${param.fullName}"
                        />
                    </div>

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
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                            placeholder="student@example.com"
                            value="${param.email}"
                        />
                    </div>

                    <div>
                        <label for="phoneNumber" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Phone Number
                        </label>
                        <input
                            id="phoneNumber"
                            name="phoneNumber"
                            type="tel"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                            placeholder="+1 (555) 123-4567"
                            value="${param.phoneNumber}"
                        />
                    </div>

                    <div>
                        <label for="dateOfBirth" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Date of Birth
                        </label>
                        <input
                            id="dateOfBirth"
                            name="dateOfBirth"
                            type="date"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                            value="${param.dateOfBirth}"
                        />
                    </div>

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
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                            placeholder="Create a strong password"
                        />
                    </div>

                    <div>
                        <label for="confirmPassword" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                            Confirm Password
                        </label>
                        <input
                            id="confirmPassword"
                            name="confirmPassword"
                            type="password"
                            required
                            class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                            style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                            onfocus="this.style.borderColor='var(--color-primary-500)'"
                            onblur="this.style.borderColor='var(--color-neutral-200)'"
                            placeholder="Re-enter your password"
                        />
                    </div>

                    <div class="pt-2">
                        <h3 class="font-semibold mb-3" style="color: var(--color-text-primary);">
                            Security Question
                        </h3>
                        
                        <div class="mb-4">
                            <label for="securityQuestion" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                                Select a security question
                            </label>
                            <select
                                id="securityQuestion"
                                name="securityQuestion"
                                required
                                class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                                style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                                onfocus="this.style.borderColor='var(--color-primary-500)'"
                                onblur="this.style.borderColor='var(--color-neutral-200)'"
                            >
                                <option value="">Choose a question...</option>
                                <option value="What was the name of your first school?" ${param.securityQuestion == 'What was the name of your first school?' ? 'selected' : ''}>What was the name of your first school?</option>
                                <option value="What is your mother's maiden name?" ${param.securityQuestion == "What is your mother's maiden name?" ? 'selected' : ''}>What is your mother's maiden name?</option>
                                <option value="What was the name of your first pet?" ${param.securityQuestion == 'What was the name of your first pet?' ? 'selected' : ''}>What was the name of your first pet?</option>
                                <option value="What city were you born in?" ${param.securityQuestion == 'What city were you born in?' ? 'selected' : ''}>What city were you born in?</option>
                                <option value="What is your favorite Surah from the Quran?" ${param.securityQuestion == 'What is your favorite Surah from the Quran?' ? 'selected' : ''}>What is your favorite Surah from the Quran?</option>
                                <option value="What was your childhood nickname?" ${param.securityQuestion == 'What was your childhood nickname?' ? 'selected' : ''}>What was your childhood nickname?</option>
                            </select>
                        </div>

                        <div>
                            <label for="securityAnswer" class="block mb-2 font-medium" style="color: var(--color-text-primary);">
                                Your answer
                            </label>
                            <input
                                id="securityAnswer"
                                name="securityAnswer"
                                type="text"
                                required
                                class="w-full px-4 py-3 rounded-xl border-2 focus:outline-none transition-all duration-200"
                                style="border-color: var(--color-neutral-200); background-color: var(--color-bg-light);"
                                onfocus="this.style.borderColor='var(--color-primary-500)'"
                                onblur="this.style.borderColor='var(--color-neutral-200)'"
                                placeholder="Enter your answer"
                                value="${param.securityAnswer}"
                            />
                        </div>
                    </div>

                    <div class="pt-2">
                        <label class="flex items-start cursor-pointer">
                            <input
                                type="checkbox"
                                id="agreeToTerms"
                                name="agreeToTerms"
                                class="w-4 h-4 mt-1 rounded cursor-pointer"
                                style="accent-color: var(--color-primary-500);"
                                required
                            />
                            <span class="ml-2" style="color: var(--color-text-muted);">
                                I agree to the
                                <a href="#" id="openTermsLink" style="color: var(--color-primary-500);" class="hover:opacity-80 font-semibold">
                                    Terms &amp; Conditions
                                </a>
                            </span>
                        </label>
                    </div>

                    <button
                        type="submit"
                        class="w-full px-6 py-4 text-white rounded-full transform hover:-translate-y-1 transition-all duration-200"
                        style="background: var(--gradient-feature-purple); box-shadow: var(--shadow-lg);"
                    >
                        Register
                    </button>

                    <p class="text-center" style="color: var(--color-text-muted);">
                        Already have an account? 
                        <a 
                            href="${pageContext.request.contextPath}/student/login" 
                            style="color: var(--color-primary-500);"
                            class="font-medium hover:opacity-80 transition-opacity"
                        >
                            Login here
                        </a>
                    </p>
                </form>
            </div>

            <div class="text-center mt-6">
                <a href="${pageContext.request.contextPath}/home" style="color: var(--color-text-muted);" class="hover:opacity-80 transition-opacity">
                    ← Back to Home
                </a>
            </div>
        </div>
    </div>

    <!-- Terms & Conditions Modal -->
    <div id="termsModal" class="fixed inset-0 bg-gray-900/50 flex items-center justify-center p-4 hidden z-50">
        <div class="w-full max-w-2xl mx-auto">
            <div class="bg-white rounded-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
                <div class="terms-header-gradient relative px-6 py-7 overflow-hidden flex-shrink-0" style="background: linear-gradient(135deg, #2d6a66 0%, #4a6fa5 45%, #7c3aed 100%);">
                    <div class="absolute -top-8 -right-8 w-36 h-36 rounded-full bg-white/10"></div>
                    <div class="absolute top-4 right-24 w-20 h-20 rounded-full bg-white/5"></div>
                    <div class="relative flex items-start justify-between gap-4">
                        <div>
                            <h2 class="text-white text-2xl font-bold tracking-tight">Terms &amp; Conditions</h2>
                            <p class="text-white/80 mt-1 text-sm">Please read these terms carefully before using TalaqqiHub</p>
                        </div>
                        <button type="button" id="termsClose" aria-label="Close" class="text-white hover:bg-white/15 p-2 rounded-lg transition-colors flex-shrink-0">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>
                <div id="termsModalContent" class="overflow-y-auto flex-1 px-5 py-5 space-y-3" style="scrollbar-width: thin;">
                    <div class="text-sm text-gray-500 text-center py-8">Loading terms...</div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const openTermsLink = document.getElementById('openTermsLink');
            const termsModal = document.getElementById('termsModal');
            const termsClose = document.getElementById('termsClose');
            const termsModalContent = document.getElementById('termsModalContent');
            const termsPath = '${pageContext.request.contextPath}/termCondition.jsp';
            let termsLoaded = false;

            function closeTermsModal() {
                termsModal.classList.add('hidden');
                document.body.style.overflow = '';
            }

            function agreeToTerms() {
                const checkbox = document.getElementById('agreeToTerms');
                if (checkbox) checkbox.checked = true;
                closeTermsModal();
            }

            async function loadTerms() {
                if (termsLoaded || !termsModalContent) return;
                try {
                    const res = await fetch(termsPath, { cache: 'no-store' });
                    if (!res.ok) throw new Error('HTTP ' + res.status);
                    const text = await res.text();
                    const doc = new DOMParser().parseFromString(text, 'text/html');
                    const fetchedContent = doc.getElementById('termsContent');
                    if (fetchedContent) {
                        termsModalContent.innerHTML = fetchedContent.innerHTML;
                        const agreeBtn = termsModalContent.querySelector('#agreeBtn');
                        if (agreeBtn) {
                            agreeBtn.removeAttribute('onclick');
                            agreeBtn.addEventListener('click', agreeToTerms);
                        }
                        termsLoaded = true;
                    } else {
                        termsModalContent.innerHTML = '<div class="p-4 text-sm text-red-600">Failed to load terms content.</div>';
                    }
                } catch (err) {
                    termsModalContent.innerHTML = '<div class="p-4 text-sm text-red-600">Failed to load terms. Please try again later.</div>';
                    console.error('Failed to fetch terms:', err);
                }
            }

            if (openTermsLink && termsModal) {
                openTermsLink.addEventListener('click', async function (evt) {
                    evt.preventDefault();
                    await loadTerms();
                    termsModal.classList.remove('hidden');
                    document.body.style.overflow = 'hidden';
                });
            }

            if (termsClose) {
                termsClose.addEventListener('click', closeTermsModal);
            }

            termsModal.addEventListener('click', function (evt) {
                if (evt.target === termsModal) closeTermsModal();
            });
        });
    </script>
</body>
</html>
