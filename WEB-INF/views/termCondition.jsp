<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Terms &amp; Conditions - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .terms-header-gradient {
            background: linear-gradient(135deg, #2d6a66 0%, #4a6fa5 45%, #7c3aed 100%);
        }
        .terms-scroll::-webkit-scrollbar { width: 6px; }
        .terms-scroll::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 3px; }
        .terms-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .terms-scroll::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-gray-100">

<div id="termsPageOverlay" class="fixed inset-0 flex items-center justify-center p-4 bg-gray-900/50 z-50">
    <div class="w-full max-w-2xl mx-auto">

        <div id="termsModalBox" class="bg-white rounded-2xl shadow-2xl overflow-hidden">

            <!-- Header -->
            <div class="terms-header-gradient relative px-6 py-7 overflow-hidden">
                <div class="absolute -top-8 -right-8 w-36 h-36 rounded-full bg-white/10"></div>
                <div class="absolute top-4 right-24 w-20 h-20 rounded-full bg-white/5"></div>
                <div class="absolute -bottom-6 left-1/3 w-28 h-28 rounded-full bg-white/5"></div>
                <div class="relative flex items-start justify-between gap-4">
                    <div>
                        <h1 class="text-white text-2xl font-bold tracking-tight">Terms &amp; Conditions</h1>
                        <p class="text-white/80 mt-1 text-sm">Please read these terms carefully before using TalaqqiHub</p>
                    </div>
                    <button type="button" id="closeBtnTop" aria-label="Close" onclick="closeModal()"
                            class="text-white hover:bg-white/15 p-2 rounded-lg transition-colors flex-shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Scrollable content -->
            <div id="termsContent" class="terms-scroll px-5 py-5 max-h-[58vh] overflow-y-auto space-y-3">

                <!-- 1. Acceptance of Terms -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-pink-500 to-purple-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-purple-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">1</span>
                            <h3 class="font-bold text-gray-900 text-sm">Acceptance of Terms</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">By registering and using TalaqqiHub, students agree to follow all terms and conditions stated on this platform. These terms are created to ensure a safe, respectful, and effective Quran learning environment.</p>
                    </div>
                </div>

                <!-- 2. Eligibility and Account Responsibility -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-teal-500 to-cyan-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-teal-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">2</span>
                            <h3 class="font-bold text-gray-900 text-sm">Eligibility and Account Responsibility</h3>
                        </div>
                        <ul class="text-gray-500 text-sm leading-relaxed space-y-1 list-disc list-inside">
                            <li>Students must provide accurate personal information during registration.</li>
                            <li>Each account is for individual use only and must not be shared with others.</li>
                            <li>Students are responsible for keeping login credentials secure.</li>
                        </ul>
                    </div>
                </div>

                <!-- 3. Class Participation and Attendance -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-blue-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">3</span>
                            <h3 class="font-bold text-gray-900 text-sm">Class Participation and Attendance</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">Students are expected to attend scheduled classes on time. Attendance may be recorded automatically, and repeated absences may affect learning progress and require follow-up from teachers or administrators.</p>
                    </div>
                </div>

                <!-- 4. Class Booking and Cancellation -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-amber-500 to-orange-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-amber-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">4</span>
                            <h3 class="font-bold text-gray-900 text-sm">Class Booking and Cancellation</h3>
                        </div>
                        <ul class="text-gray-500 text-sm leading-relaxed space-y-1 list-disc list-inside">
                            <li>Students must book classes through the platform and follow booking rules.</li>
                            <li>Cancellations should include valid reasons; frequent cancellations may be monitored.</li>
                        </ul>
                    </div>
                </div>

                <!-- 5. Learning Conduct and Ethics -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-rose-500 to-red-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-rose-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">5</span>
                            <h3 class="font-bold text-gray-900 text-sm">Learning Conduct and Ethics</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">Students must behave respectfully toward teachers and peers. Offensive language, harassment, or misuse of the platform is strictly prohibited. TalaqqiHub is for Quran learning purposes only.</p>
                    </div>
                </div>

                <!-- 6. Evaluation, Feedback, and Progress Records -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-violet-500 to-purple-700 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-violet-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">6</span>
                            <h3 class="font-bold text-gray-900 text-sm">Evaluation, Feedback, and Progress Records</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">Teachers will evaluate recitation, provide feedback, and record progress. Students can review reports to track improvement and apply feedback for continued learning.</p>
                    </div>
                </div>

                <!-- 7. AI Assistance Usage -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-cyan-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">7</span>
                            <h3 class="font-bold text-gray-900 text-sm">AI Assistance Usage</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">AI chat assistance is available to support learning and answer questions, but it does not replace teachers. Do not use AI features for unrelated or inappropriate purposes.</p>
                    </div>
                </div>

                <!-- 8. Data Privacy and Security -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-emerald-500 to-green-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-emerald-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">8</span>
                            <h3 class="font-bold text-gray-900 text-sm">Data Privacy and Security</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">Student data is stored securely and used only for learning delivery and system management. TalaqqiHub will not share personal data without consent except where required by law.</p>
                    </div>
                </div>

                <!-- 9. System Availability -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-sky-500 to-blue-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-sky-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">9</span>
                            <h3 class="font-bold text-gray-900 text-sm">System Availability</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">TalaqqiHub strives for continuous access but may experience downtime due to maintenance or technical issues. Reliable internet access is required to use the platform.</p>
                    </div>
                </div>

                <!-- 10. Violation and Account Termination -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-red-500 to-rose-700 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-red-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">10</span>
                            <h3 class="font-bold text-gray-900 text-sm">Violation and Account Termination</h3>
                        </div>
                        <p class="text-gray-500 text-sm leading-relaxed">Violations of these terms may result in suspension or termination of access. Serious or repeated misconduct can lead to permanent account restriction.</p>
                    </div>
                </div>

                <!-- 11. Updates to Terms -->
                <div class="flex gap-3 p-4 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex-shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-fuchsia-500 to-purple-600 flex items-center justify-center shadow-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1.5">
                            <span class="w-5 h-5 rounded-full bg-fuchsia-600 text-white text-xs flex items-center justify-center font-bold flex-shrink-0">11</span>
                            <h3 class="font-bold text-gray-900 text-sm">Updates to Terms</h3>
                        </div>
                        <ul class="text-gray-500 text-sm leading-relaxed space-y-1">
                            <li class="flex items-start gap-2">
                                <span class="w-1.5 h-1.5 rounded-full bg-purple-500 mt-2 flex-shrink-0"></span>
                                <span>TalaqqiHub may update these Terms &amp; Conditions when necessary.</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="w-1.5 h-1.5 rounded-full bg-purple-500 mt-2 flex-shrink-0"></span>
                                <span>Continued use of the platform indicates acceptance of the updated terms.</span>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Important Notice -->
                <div class="p-4 rounded-xl border-2 border-green-200 bg-green-50 mt-2">
                    <div class="flex gap-3">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-green-600 flex items-center justify-center">
                            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/>
                            </svg>
                        </div>
                        <div>
                            <h4 class="font-bold text-green-800 text-sm mb-1">Important Notice</h4>
                            <p class="text-green-700 text-sm leading-relaxed">By clicking <strong>"I Understand and Agree"</strong>, you confirm that you have read, understood, and accepted all Terms &amp; Conditions of TalaqqiHub.</p>
                        </div>
                    </div>
                </div>

                <!-- Agree button -->
                <div class="pt-2 pb-1">
                    <button id="agreeBtn" type="button" onclick="agreeAction()"
                            class="w-full py-3.5 rounded-full text-white font-semibold text-sm shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 transition-all duration-200"
                            style="background: linear-gradient(135deg, #7c3aed 0%, #a855f7 50%, #2d6a66 100%);">
                        I Understand and Agree
                    </button>
                </div>

            </div>
        </div>

        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/home" class="text-gray-500 hover:text-gray-700 text-sm transition-colors">
                &larr; Back to Home
            </a>
        </div>
    </div>
</div>

<script>
    function closeModal() {
        if (document.referrer && document.referrer !== window.location.href) {
            location.href = document.referrer;
        } else {
            location.href = '${pageContext.request.contextPath}/home';
        }
    }
    function agreeAction() {
        if (document.referrer && document.referrer !== window.location.href) {
            location.href = document.referrer;
        } else {
            location.href = '${pageContext.request.contextPath}/student/register';
        }
    }
</script>

</body>
</html>
