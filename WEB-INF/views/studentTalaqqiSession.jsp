<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Talaqqi Session – TalaqqiHub Student Portal</title>

    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Jitsi Meet External API -->
    <script src="https://meet.jit.si/external_api.js"></script>

    <!-- Google Fonts: Amiri for Arabic, Inter for UI -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">

    <style>
        /* ── Base ──────────────────────────────────────────────────────── */
        body { font-family: 'Inter', system-ui, sans-serif; }

        /* ── Sidebar: deep green gradient matching student portal ──────── */
        .sidebar-gradient { background: linear-gradient(180deg, #1a7a5c 0%, #0d4a38 100%); }

        /* ── Green gradient button for Join Session ────────────────────── */
        .btn-green-gradient {
            background: linear-gradient(90deg, #16a34a 0%, #22c55e 50%, #4ade80 100%);
            transition: filter .2s, transform .15s;
        }
        .btn-green-gradient:hover { filter: brightness(1.1); transform: translateY(-1px); }

        /* ── Arabic verse text ──────────────────────────────────────────── */
        .arabic-verse {
            font-family: 'Amiri', serif;
            font-size: 1.5rem;
            line-height: 3rem;
            direction: rtl;
            text-align: center;
        }

        /* ── Thin scrollbar for Quran panel ───────────────────────────── */
        .verse-scroll { scrollbar-width: thin; scrollbar-color: #d1d5db transparent; }
        .verse-scroll::-webkit-scrollbar { width: 5px; }
        .verse-scroll::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 9999px; }

        /* ── Pulse dot for live indicator ────────────────────────────── */
        @keyframes pulse-dot { 0%,100% { opacity: 1; } 50% { opacity: 0.3; } }
        .pulse-dot { animation: pulse-dot 2s infinite; }

        /* ── Loading spinner ──────────────────────────────────────────── */
        @keyframes spin { to { transform: rotate(360deg); } }
        .spinner { animation: spin 1s linear infinite; }

        /* ── Card hover effect ──────────────────────────────────────── */
        .card-lift { transition: box-shadow .2s, transform .2s; }
        .card-lift:hover { transform: translateY(-2px); box-shadow: 0 8px 24px -4px rgba(0,0,0,.09); }

        /* ── Toggle switch for showing translation ──────────────────── */
        .toggle-wrap { position: relative; display: inline-block; width: 48px; height: 26px; }
        .toggle-wrap input { opacity: 0; width: 0; height: 0; }
        .toggle-track {
            position: absolute; inset: 0; cursor: pointer;
            background: #d1d5db; border-radius: 9999px; transition: background .25s;
        }
        .toggle-track::before {
            content: ""; position: absolute;
            width: 20px; height: 20px; left: 3px; bottom: 3px;
            background: #fff; border-radius: 50%;
            transition: transform .25s; box-shadow: 0 1px 3px rgba(0,0,0,.2);
        }
        input:checked + .toggle-track { background: #16a34a; }
        input:checked + .toggle-track::before { transform: translateX(22px); }

        /* ── Session status badge ──────────────────────────────────── */
        .badge-upcoming { background: #dcfce7; color: #166534; }
        .badge-active { background: #ccfbf1; color: #134e4a; }
        .badge-ended { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body class="bg-gray-50 antialiased">
<div class="flex h-screen overflow-hidden">

<!-- ══════════════════════════════════════════════════════════════════════ -->
<!--  SIDEBAR – deep green, matches student portal                         -->
<!-- ══════════════════════════════════════════════════════════════════════ -->
<aside class="sidebar-gradient w-64 flex-shrink-0 flex flex-col overflow-y-auto">
    <div class="p-6 flex-1">
        <!-- Brand mark -->
        <div class="text-white mb-8">
            <h1 class="text-2xl font-bold tracking-tight">TalaqqiHub</h1>
            <p class="text-green-200 text-sm mt-1">Student Portal</p>
        </div>

        <!-- Navigation links -->
        <nav class="space-y-2">
            <a href="${contextPath}/student/dashboard"
               class="flex items-center space-x-3 px-4 py-3 text-green-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                <i class="fas fa-home w-5"></i>
                <span>Dashboard</span>
            </a>

            <a href="${contextPath}/student/profile"
               class="flex items-center space-x-3 px-4 py-3 text-green-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                <i class="far fa-calendar w-5"></i>
                <span>Class Booking</span>
            </a>

            <a href="${contextPath}/student/profile"
               class="flex items-center space-x-3 px-4 py-3 text-green-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                <i class="far fa-clipboard w-5"></i>
                <span>Attendance</span>
            </a>

            <a href="${contextPath}/student/sessions"
               class="flex items-center space-x-3 px-4 py-3 bg-white bg-opacity-15 text-white rounded-lg transition">
                <i class="fas fa-book w-5"></i>
                <span>Talaqqi Sessions</span>
            </a>

            <a href="${contextPath}/student/profile"
               class="flex items-center space-x-3 px-4 py-3 text-green-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                <i class="fas fa-star w-5"></i>
                <span>Evaluation</span>
            </a>

            <a href="${contextPath}/student/profile"
               class="flex items-center space-x-3 px-4 py-3 text-green-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                <i class="fas fa-bullhorn w-5"></i>
                <span>Announcements</span>
            </a>

            <a href="${contextPath}/student/profile"
               class="flex items-center space-x-3 px-4 py-3 text-green-200 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
                <i class="fas fa-lightbulb w-5"></i>
                <span>Al Assistance</span>
            </a>
        </nav>
    </div>

    <!-- Logout button -->
    <div class="border-t border-green-700 p-6">
        <a href="${contextPath}/student/logout"
           class="flex items-center space-x-3 w-full px-4 py-3 text-red-300 hover:bg-white hover:bg-opacity-10 rounded-lg transition">
            <i class="fas fa-sign-out-alt w-5"></i>
            <span>Logout</span>
        </a>
    </div>
</aside>

<!-- ══════════════════════════════════════════════════════════════════════ -->
<!--  MAIN CONTENT                                                          -->
<!-- ══════════════════════════════════════════════════════════════════════ -->
<div class="flex-1 flex flex-col overflow-y-auto">

    <!-- Header -->
    <header class="bg-white border-b border-gray-200 shadow-sm sticky top-0 z-10">
        <div class="px-8 py-6 flex items-center justify-between">
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Talaqqi Session</h2>
            </div>

            <!-- Right side: Notification + Profile -->
            <div class="flex items-center space-x-6">
                <!-- Notification icon -->
                <button class="relative p-2 text-gray-600 hover:text-gray-900 transition">
                    <i class="far fa-bell text-xl"></i>
                    <span class="absolute top-0 right-0 w-3 h-3 bg-red-500 rounded-full"></span>
                </button>

                <!-- User profile -->
                <div class="flex items-center space-x-3">
                    <div class="flex items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-green-400 to-teal-500 text-white font-semibold text-sm">
                        <c:choose>
                            <c:when test="${not empty studentInitials}">
                                ${studentInitials}
                            </c:when>
                            <c:otherwise>
                                ST
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-900">
                            <c:choose>
                                <c:when test="${not empty studentName}">
                                    ${studentName}
                                </c:when>
                                <c:otherwise>
                                    Student
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <p class="text-xs text-gray-500">Student</p>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- Content area -->
    <div class="flex-1 flex flex-col lg:flex-row gap-6 p-8 overflow-hidden">

        <!-- Main session view (left + center) -->
        <div class="flex-1 flex flex-col gap-6 overflow-y-auto">

            <!-- Session Card -->
            <c:choose>
                <c:when test="${not empty session}">
                    <div class="bg-white rounded-lg p-8 shadow-md border border-gray-100">
                        <!-- Session header -->
                        <div class="flex items-start justify-between mb-4">
                            <div class="flex-1">
                                <h3 class="text-3xl font-bold text-gray-900 mb-2">${session.className}</h3>
                                <div class="flex flex-wrap items-center gap-6 text-gray-600 text-sm">
                                    <span class="inline-flex items-center gap-2">
                                        <i class="far fa-calendar text-teal-600"></i>
                                        ${session.sessionDate}
                                    </span>
                                    <span class="inline-flex items-center gap-2">
                                        <i class="far fa-clock text-teal-600"></i>
                                        ${session.sessionStartTime} - ${session.sessionEndTime}
                                    </span>
                                    <span class="inline-flex items-center gap-2">
                                        <i class="fas fa-bolt text-teal-600"></i>
                                        ${session.duration} minutes
                                    </span>
                                </div>
                            </div>
                            <div class="text-right">
                                <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Teacher</p>
                                <div class="flex items-center gap-3 justify-end">
                                    <p class="text-sm font-bold text-gray-900">${session.teacherName}</p>
                                    <div class="w-12 h-12 rounded-full bg-gradient-to-br from-teal-400 to-green-500 text-white grid place-items-center font-bold text-sm">
                                        ${session.teacherInitials}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Join Button -->
                        <button id="joinButton"
                                class="w-full btn-green-gradient text-white font-bold py-4 rounded-lg text-lg transition flex items-center justify-center gap-3 mt-6">
                            <i class="fas fa-video"></i>
                            <span>Join Live Session</span>
                        </button>
                    </div>

                    <!-- Jitsi Container (hidden by default) -->
                    <div id="jitsiContainer" class="hidden rounded-2xl overflow-hidden shadow-lg bg-black" style="min-height: 500px;" data-room-name="${session.roomName}" data-session-id="${session.sessionId}" data-teacher-id="${session.teacherId}">
                        <!-- Jitsi Meet API will inject content here -->
                    </div>

                    <!-- Post-Session Message (shown after session ends) -->
                    <div id="sessionNotStarted" class="flex flex-col items-center justify-center h-96 text-center border-2 border-teal-400 rounded-lg p-8">
                        <div class="w-24 h-24 rounded-full bg-gradient-to-br from-teal-400 to-green-500 text-white grid place-items-center text-5xl mb-6">
                            <i class="fas fa-video"></i>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900 mb-3">Session Not Started</h3>
                        <p class="text-gray-600 max-w-sm">Click the "Join Live Session" button above to start your Talaqqi session with ${session.teacherName}.</p>
                    </div>

                </c:when>
                <c:otherwise>
                    <!-- No session scheduled -->
                    <div class="bg-gradient-to-br from-blue-50 to-teal-50 rounded-lg border-2 border-teal-200 p-12 text-center min-h-96 flex flex-col items-center justify-center">
                        <div class="w-20 h-20 mx-auto rounded-3xl bg-gradient-to-br from-teal-400 to-green-500 text-white grid place-items-center text-4xl mb-4">
                            <i class="fas fa-calendar-times"></i>
                        </div>
                        <h3 class="text-3xl font-bold text-gray-900 mb-3">No Sessions Scheduled</h3>
                        <p class="text-gray-600 mb-6 max-w-sm mx-auto">
                            You don't have any upcoming Talaqqi sessions scheduled.
                        </p>
                        <a href="${contextPath}/student/profile" class="inline-block bg-gradient-to-r from-teal-400 to-green-500 text-white px-6 py-2 rounded-lg font-semibold hover:opacity-90 transition">
                            Book a Class
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Quran Display Panel (right sidebar) -->
        <div class="w-full lg:w-96 flex flex-col min-h-0">

            <!-- Quran Panel Card -->
            <div class="bg-white rounded-xl border border-gray-200 p-5 flex flex-col h-full min-h-0">
                <div class="flex items-center justify-between mb-4 pb-4 border-b border-gray-200">
                    <h4 class="text-base md:text-lg font-bold text-gray-900">Quran Display</h4>
                    <span class="bg-gradient-to-r from-teal-400 to-green-400 text-white px-3 py-1 rounded-full text-xs md:text-sm font-bold">
                        Read-Only
                    </span>
                </div>

                <!-- Juz, Surah, Ayah Display -->
                <div class="mb-4 text-center">
                    <div class="grid grid-cols-3 gap-3">
                        <div>
                            <p class="text-xs text-gray-600 font-medium mb-1">Juz</p>
                            <p id="currentJuzDisplay" class="text-lg font-bold text-teal-600">1</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-600 font-medium mb-1">Surah</p>
                            <p id="currentSurahDisplay" class="text-lg font-bold text-teal-600">2</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-600 font-medium mb-1">Ayah</p>
                            <p id="currentAyahDisplay" class="text-lg font-bold text-teal-600">1</p>
                        </div>
                    </div>
                </div>

                <hr class="my-3 border-gray-200">

                <!-- Surah Info -->
                <div class="text-center mb-4 pb-3 border-b border-gray-200">
                    <h5 id="surahNameDisplay" class="text-base font-bold text-gray-900">Al-Baqarah</h5>
                    <p id="surahTranslationDisplay" class="text-xs text-gray-500 mt-1">The Cow</p>
                </div>

                <!-- Bismillah Section -->
                <div class="text-center mb-4 pb-4 border-b border-gray-200">
                    <p id="bismillahArabic" class="arabic-verse text-center mb-2">بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</p>
                    <p class="text-xs text-gray-600 italic mb-2">Bismillahi r-rahmani r-rahim</p>
                    <p class="text-xs text-gray-600">In the name of Allah, the Entirely Merciful, the Especially Merciful.</p>
                </div>

                <!-- Verses Container (scrollable) -->
                <div class="flex-1 overflow-y-auto verse-scroll">
                    <c:choose>
                        <c:when test="${not empty verses}">
                            <c:forEach var="verse" items="${verses}" varStatus="status">
                                <div class="mb-5 pb-4 border-b border-gray-100 last:border-b-0">
                                    <!-- Ayah badge and number -->
                                    <div class="flex items-start gap-3 mb-3">
                                        <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">
                                            ${verse.ayahNumber}
                                        </div>
                                    </div>

                                    <!-- Arabic text -->
                                    <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">
                                        ${verse.arabicText}
                                    </p>

                                    <!-- Transliteration -->
                                    <p class="text-xs text-gray-600 italic mb-2">
                                        Transliteration
                                    </p>

                                    <!-- Translation toggle -->
                                    <div class="flex items-center justify-between mb-3 text-sm">
                                        <label class="font-medium text-gray-700">Show Translation</label>
                                        <label class="toggle-wrap">
                                            <input type="checkbox" class="translation-toggle" data-verse-id="${status.index}" checked>
                                            <div class="toggle-track"></div>
                                        </label>
                                    </div>

                                    <!-- Translation -->
                                    <div class="translation-content bg-green-50 rounded-lg p-3 text-xs text-gray-700 leading-relaxed">
                                        <p>${verse.translation}</p>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Sample/Default Verses Display -->
                            <div class="mb-5 pb-4 border-b border-gray-100">
                                <div class="flex items-start gap-3 mb-3">
                                    <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">
                                        1
                                    </div>
                                </div>
                                <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">
                                    الم
                                </p>
                                <p class="text-xs text-gray-600 italic mb-2">
                                    Alif-Lam-Mim
                                </p>
                                <div class="flex items-center justify-between mb-3 text-sm">
                                    <label class="font-medium text-gray-700">Show Translation</label>
                                    <label class="toggle-wrap">
                                        <input type="checkbox" class="translation-toggle" checked>
                                        <div class="toggle-track"></div>
                                    </label>
                                </div>
                                <div class="translation-content bg-green-50 rounded-lg p-3 text-xs text-gray-700 leading-relaxed">
                                    <p>Alif, Laam, Meem.</p>
                                </div>
                            </div>

                            <div class="mb-5 pb-4 border-b border-gray-100">
                                <div class="flex items-start gap-3 mb-3">
                                    <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">
                                        2
                                    </div>
                                </div>
                                <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">
                                    ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ
                                </p>
                                <p class="text-xs text-gray-600 italic mb-2">
                                    Dhalika al-kitabu la rayba fihi
                                </p>
                                <div class="flex items-center justify-between mb-3 text-sm">
                                    <label class="font-medium text-gray-700">Show Translation</label>
                                    <label class="toggle-wrap">
                                        <input type="checkbox" class="translation-toggle" checked>
                                        <div class="toggle-track"></div>
                                    </label>
                                </div>
                                <div class="translation-content bg-green-50 rounded-lg p-3 text-xs text-gray-700 leading-relaxed">
                                    <p>This is the Book about which there is no doubt, a guidance for those conscious of Allah.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

<!-- ══════════════════════════════════════════════════════════════════════ -->
<!--  JAVASCRIPT                                                            -->
<!-- ══════════════════════════════════════════════════════════════════════ -->
<script>
    // Configuration
    const API_BASE = 'https://api.alquran.cloud/v1';
    let jitsiApi = null;
    let isSessionActive = false;

    // DOM Elements
    const joinButton = document.getElementById('joinButton');
    const jitsiContainer = document.getElementById('jitsiContainer');
    const sessionNotStarted = document.getElementById('sessionNotStarted');
    const translationToggles = document.querySelectorAll('.translation-toggle');

    // Initialize
    document.addEventListener('DOMContentLoaded', () => {
        setupEventListeners();
        
        // Load initial surah info and update display
        loadSurahInfo(currentQuranState.surah);
        updateQuranLocationDisplay(currentQuranState.surah, currentQuranState.ayah);
        
        startPollingQuranUpdates();
    });

    // ── Event listeners ─────────────────────────────────────────────────

    function setupEventListeners() {
        // Join Live Session button
        if (joinButton) {
            joinButton.addEventListener('click', handleJoinSession);
        }

        // Translation toggles
        translationToggles.forEach(toggle => {
            toggle.addEventListener('change', (e) => {
                const verseId = e.target.getAttribute('data-verse-id');
                const content = document.querySelector(
                    '.translation-content[data-verse-id="' + verseId + '"]'
                ) || e.target.closest('.mb-8').querySelector('.translation-content');

                if (e.target.checked) {
                    content.classList.remove('hidden');
                } else {
                    content.classList.add('hidden');
                }
            });
        });
    }

    // ── Join Live Session ──────────────────────────────────────────────

    function handleJoinSession() {
        // Hide the session-not-started message
        if (sessionNotStarted) {
            sessionNotStarted.style.display = 'none';
        }

        // Show the Jitsi container
        jitsiContainer.classList.remove('hidden');

        // Get room name from data attribute (set by server)
        const roomName = jitsiContainer.getAttribute('data-room-name') || 'TalaqqiHub-' + Date.now();
        const sessionId = jitsiContainer.getAttribute('data-session-id');
        const teacherId = jitsiContainer.getAttribute('data-teacher-id');

        // Initialize Jitsi Meet
        const options = {
            roomName: roomName,
            width: '100%',
            height: 500,
            parentNode: jitsiContainer,
            userInfo: {
                displayName: '<c:out value="${studentName}" />'
            },
            configOverwrite: {
                 startAudioOnly: true
            },
            interfaceConfigOverwrite: {
                TOOLBAR_BUTTONS: ['microphone', 'camera', 'settings', 'hangup'],
                SHOW_CHROME_EXTENSION_BANNER: false
            }
        };

        try {
            jitsiApi = new JitsiMeetExternalAPI('meet.jit.si', options);

            // Listen for join event
            jitsiApi.addEventListener('videoConferenceJoined', () => {
                isSessionActive = true;
                console.log('Student joined Jitsi session');
                recordSessionEvent('joinSession');
            });

            // Listen for leave/hangup event
            jitsiApi.addEventListener('videoConferenceLeft', () => {
                isSessionActive = false;
                console.log('Student left Jitsi session');
                recordSessionEvent('leaveSession');
            });

            // Disable join button during session
            joinButton.disabled = true;
            joinButton.classList.add('opacity-50', 'cursor-not-allowed');

        } catch (error) {
            console.error('Failed to initialize Jitsi Meet:', error);
            alert('Failed to start video session. Please try again.');
            jitsiContainer.classList.add('hidden');
            if (sessionNotStarted) {
                sessionNotStarted.style.display = '';
            }
        }
    }

    // ── Record session events ───────────────────────────────────────────

    function recordSessionEvent(action) {
        const formData = new FormData();
        formData.append('action', action);

        fetch('<c:out value="${contextPath}" />/student/sessions', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            console.log('Event recorded:', data);
        })
        .catch(error => {
            console.error('Error recording event:', error);
        });
    }

    // ── Responsive adjustments ──────────────────────────────────────────

    window.addEventListener('resize', () => {
        if (jitsiApi && jitsiContainer && !jitsiContainer.classList.contains('hidden')) {
            // Jitsi will auto-adjust
        }
    });

    // ── Poll for Quran reference updates (teacher-to-student sync) ─────────

    // Track current Quran reference to detect changes
    let currentQuranState = {
        surah: parseInt(new URLSearchParams(window.location.search).get('surah') || '<c:out value="${not empty session ? session.currentSurahNumber : ''}" />') || 2,
        ayah:  parseInt(new URLSearchParams(window.location.search).get('ayah') || '<c:out value="${not empty session ? session.currentAyahNumber : ''}" />') || 1,
        ayahEnd: parseInt(new URLSearchParams(window.location.search).get('ayahEnd') || '<c:out value="${not empty session ? session.currentAyahEnd : ''}" />') || 0
    };

    const POLL_INTERVAL_MS = 3000; // Check every 3 seconds
    let pollTimerId = null;

    // Fallback surah names for offline or API failures
    const surahFallbacks = {
        1: { name: "Al-Fatiha", translation: "The Opening" },
        2: { name: "Al-Baqarah", translation: "The Cow" },
        3: { name: "Ali Imran", translation: "The Family of Imran" },
        4: { name: "An-Nisa", translation: "The Women" },
        5: { name: "Al-Ma'idah", translation: "The Table Spread" }
    };

    /**
     * Load surah metadata (name, translation) and update the display
     */
    async function loadSurahInfo(surahNo) {
        try {
            const response = await fetch('<c:out value="${contextPath}" />/teacher/quran-api?action=surahInfo&surah=' + surahNo);
            if (!response.ok) throw new Error('API call failed');
            
            const data = await response.json();
            if (data.data) {
                const surahData = data.data;
                const engName = surahData.englishName || surahData.enName || '';
                const engTrans = surahData.englishNameTranslation || surahData.englishTranslation || '';
                
                // Update DOM
                const surahNameEl = document.getElementById('surahNameDisplay');
                const surahTransEl = document.getElementById('surahTranslationDisplay');
                if (surahNameEl) surahNameEl.textContent = engName || 'Surah ' + surahNo;
                if (surahTransEl) surahTransEl.textContent = engTrans || '';
                
                console.log('[Surah Loaded] ' + surahNo + ': ' + engName);
            }
        } catch (error) {
            console.warn('Failed to load surah info, using fallback:', error);
            applySurahFallback(surahNo);
        }
    }

    /**
     * Apply fallback surah names when API is unavailable
     */
    function applySurahFallback(surahNo) {
        const fallback = surahFallbacks[surahNo];
        const surahNameEl = document.getElementById('surahNameDisplay');
        const surahTransEl = document.getElementById('surahTranslationDisplay');
        
        if (surahNameEl) {
            surahNameEl.textContent = fallback ? fallback.name : ('Surah ' + surahNo);
        }
        if (surahTransEl) {
            surahTransEl.textContent = fallback ? fallback.translation : '';
        }
    }

    /**
     * Update the Juz, Surah, Ayah display numbers
     */
    function updateQuranLocationDisplay(surah, ayah) {
        const juzDisplay = document.getElementById('currentJuzDisplay');
        const surahDisplay = document.getElementById('currentSurahDisplay');
        const ayahDisplay = document.getElementById('currentAyahDisplay');
        
        if (juzDisplay) juzDisplay.textContent = '1'; // Simplified: always show Juz 1
        if (surahDisplay) surahDisplay.textContent = surah;
        if (ayahDisplay) ayahDisplay.textContent = ayah;
    }

    /**
     * Poll the server for the latest Quran reference set by the teacher.
     * If it has changed, fetch and display the new verses.
     */
    function startPollingQuranUpdates() {
        // Only start polling if there is an active session
        <c:if test="${not empty session}">
        pollTimerId = setInterval(async () => {
            try {
                const response = await fetch('<c:out value="${contextPath}" />/student/sessions', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=getCurrentQuran'
                });

                if (!response.ok) return; // Silent fail if server error

                const data = await response.json();
                if (!data.success) return; // Silent fail if no session

                const newSurah = data.surah;
                const newAyah = data.ayah;
                const newAyahEnd = data.ayahEnd;

                // Check if Quran reference has changed
                if (newSurah !== currentQuranState.surah || 
                    newAyah !== currentQuranState.ayah ||
                    newAyahEnd !== currentQuranState.ayahEnd) {
                    
                    console.log('[Quran Update] Surah ' + newSurah + ':' + newAyah + ' (was ' + currentQuranState.surah + ':' + currentQuranState.ayah + ')');
                    
                    // Update local state
                    currentQuranState = { surah: newSurah, ayah: newAyah, ayahEnd: newAyahEnd };

                    // Load surah info if surah changed
                    if (newSurah !== currentQuranState.surah) {
                        await loadSurahInfo(newSurah);
                    }
                    
                    // Update location display
                    updateQuranLocationDisplay(newSurah, newAyah);

                    // Fetch and display new verses
                    await updateVersesDisplay(newSurah, newAyah, newAyahEnd);
                }
            } catch (error) {
                console.error('[Polling Error]', error);
                // Silent fail - don't disrupt user experience
            }
        }, POLL_INTERVAL_MS);
        </c:if>
    }

    /**
     * Fetch verses for the given Quran reference and update the DOM.
     */
    async function updateVersesDisplay(surah, startAyah, endAyah) {
        try {
            // Determine how many verses to load
            let count = 5; // Default: next 5 verses
            if (endAyah > 0 && endAyah > startAyah) {
                count = (endAyah - startAyah) + 1;
            }

            // Fetch verses from Al-Quran Cloud API
            const verses = [];
            let currentSurah = surah;
            let currentAyah = startAyah;

            for (let i = 0; i < count && currentSurah <= 114; i++) {
                try {
                    const url = API_BASE + '/ayah/' + currentSurah + ':' + currentAyah + '/editions/quran-uthmani,en.sahih';
                    const verseResponse = await fetch(url);
                    
                    if (!verseResponse.ok) {
                        console.warn('Failed to fetch ' + currentSurah + ':' + currentAyah);
                        break;
                    }

                    const verseData = await verseResponse.json();
                    if (verseData.data) {
                        // Extract data for each edition
                        let arabicText = '';
                        let transliteration = '';
                        let translation = '';

                        if (Array.isArray(verseData.data)) {
                            verseData.data.forEach(edition => {
                                if (edition.edition && edition.edition.language === 'ar') {
                                    arabicText = edition.text;
                                } else if (edition.edition && edition.edition.language === 'en') {
                                    translation = edition.text;
                                }
                            });
                        }

                        verses.push({
                            surah: currentSurah,
                            ayahNumber: currentAyah,
                            arabicText: arabicText || 'تعذر جلب النص',
                            translation: translation || 'Translation not available',
                            transliteration: transliteration || 'N/A'
                        });

                        currentAyah++;
                        if (currentAyah > 300) { // Safety limit
                            break;
                        }
                    }
                } catch (e) {
                    console.error('Error fetching verse ' + currentSurah + ':' + currentAyah + ':', e);
                    break;
                }
            }

            if (verses.length > 0) {
                renderVersesInDOM(verses);
            }
        } catch (error) {
            console.error('[Update Verses Error]', error);
        }
    }

    /**
     * Replace the verses container with newly fetched verses.
     */
    function renderVersesInDOM(verses) {
        const versesContainer = document.querySelector('.flex-1.overflow-y-auto');
        if (!versesContainer) return;

        let html = '';
        verses.forEach((verse, index) => {
            html += `
                <div class="mb-5 pb-4 border-b border-gray-100 last:border-b-0">
                    <div class="flex items-start gap-3 mb-3">
                        <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">
                            ` + verse.ayahNumber + `
                        </div>
                    </div>
                    <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">
                        ` + verse.arabicText + `
                    </p>
                    <p class="text-xs text-gray-600 italic mb-2">
                        ` + verse.transliteration + `
                    </p>
                    <div class="flex items-center justify-between mb-3 text-sm">
                        <label class="font-medium text-gray-700">Show Translation</label>
                        <label class="toggle-wrap">
                            <input type="checkbox" class="translation-toggle" data-verse-id="` + index + `" checked>
                            <div class="toggle-track"></div>
                        </label>
                    </div>
                    <div class="translation-content bg-green-50 rounded-lg p-3 text-xs text-gray-700 leading-relaxed">
                        <p>` + verse.translation + `</p>
                    </div>
                </div>
            `;
        });

        versesContainer.innerHTML = html;
        
        // Re-attach translation toggle listeners
        const newToggles = versesContainer.querySelectorAll('.translation-toggle');
        newToggles.forEach(toggle => {
            toggle.addEventListener('change', (e) => {
                const content = e.target.closest('.mb-5').querySelector('.translation-content');
                if (e.target.checked) {
                    content.classList.remove('hidden');
                } else {
                    content.classList.add('hidden');
                }
            });
        });

        console.log(`[Verses Updated] Displaying ` + verses.length + ` verse(s)`);
    }

    // Cleanup polling when page unloads
    window.addEventListener('beforeunload', () => {
        if (pollTimerId) clearInterval(pollTimerId);
    });
</script>

</body>
</html>
