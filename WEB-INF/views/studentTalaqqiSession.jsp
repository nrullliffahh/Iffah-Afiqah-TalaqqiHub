<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.JitsiConfig" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Talaqqi Session – TalaqqiHub Student Portal</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="<%= JitsiConfig.getScriptUrl() %>" async></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">
    <style>
        body { font-family: 'Inter', system-ui, sans-serif; }
        .btn-green-gradient {
            background: var(--student-gradient-h);
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
        .verse-scroll {
            flex: 1;
            min-height: 0;
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: #d1d5db transparent;
        }
        .verse-scroll::-webkit-scrollbar { width: 6px; }
        .verse-scroll::-webkit-scrollbar-thumb { background: #cfd5e3; border-radius: 9999px; }

        .session-body { padding: 24px 30px 30px; }
        .session-main-grid { align-items: start; }

        .video-shell {
            border: 2px solid #99f6e4;
            border-radius: 20px;
            background: #000;
            overflow: hidden;
            min-height: 400px;
            height: 400px;
            position: relative;
        }
        @media (min-width: 1280px) {
            .video-shell { height: 480px; }
        }

        .quran-panel-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            display: flex;
            flex-direction: column;
            min-height: 400px;
            max-height: min(600px, calc(100vh - 280px));
            overflow: hidden;
        }
        @media (min-width: 1280px) {
            .quran-panel-card {
                height: 480px;
                max-height: 480px;
            }
        }

        .quran-panel-header {
            flex-shrink: 0;
            padding: 1.25rem 1.25rem 0;
        }

        .quran-panel-scroll {
            flex: 1;
            min-height: 0;
            overflow-y: auto;
            padding: 0 1.25rem 1.25rem;
            scrollbar-width: thin;
            scrollbar-color: #d1d5db transparent;
        }
        .quran-panel-scroll::-webkit-scrollbar { width: 6px; }
        .quran-panel-scroll::-webkit-scrollbar-thumb { background: #cfd5e3; border-radius: 9999px; }

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
        input:checked + .toggle-track { background: var(--student-green); }
        input:checked + .toggle-track::before { transform: translateX(22px); }

        /* ── Session status badge ──────────────────────────────────── */
        .badge-upcoming { background: #dcfce7; color: #166534; }
        .badge-active { background: #ccfbf1; color: #134e4a; }
        .badge-ended { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body class="antialiased">
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="talaqqi-sessions"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Talaqqi Session"/>
            <jsp:param name="notifPrefix" value="sessionNotif"/>
        </jsp:include>

        <div class="page-content" style="padding-top:0;padding-bottom:0;">
    <!-- Session Switcher -->
    <c:if test="${not empty upcomingSessions}">
    <div class="bg-white border-b border-gray-200 px-8 py-3 flex items-center gap-3 shadow-sm">
        <i class="fas fa-calendar-check text-teal-600"></i>
        <span class="text-sm font-semibold text-gray-700">Switch Session</span>
        <select class="ml-auto border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-400"
                onchange="if(this.value){location.href='${contextPath}/student/sessions?sessionId='+this.value;}">
            <c:forEach var="s" items="${upcomingSessions}">
                <option value="${s.sessionId}" ${s.sessionId == talaqqiSession.sessionId ? 'selected' : ''}>
                    ${s.teacherName} | ${s.sessionDate} | ${s.sessionStartTime} - ${s.sessionEndTime}
                </option>
            </c:forEach>
        </select>
    </div>
    </c:if>

    <!-- Content area -->
    <div class="session-body">

        <c:choose>
            <c:when test="${not empty talaqqiSession}">
                <!-- Session Card -->
                <div class="bg-white rounded-lg p-6 md:p-8 shadow-md border border-gray-100 mb-6">
                    <div class="flex items-start justify-between mb-4">
                        <div class="flex-1">
                            <h3 class="text-2xl md:text-3xl font-bold text-gray-900 mb-2">${talaqqiSession.className}</h3>
                            <div class="flex flex-wrap items-center gap-4 md:gap-6 text-gray-600 text-sm">
                                <span class="inline-flex items-center gap-2">
                                    <i class="far fa-calendar text-teal-600"></i>
                                    ${talaqqiSession.sessionDate}
                                </span>
                                <span class="inline-flex items-center gap-2">
                                    <i class="far fa-clock text-teal-600"></i>
                                    ${talaqqiSession.sessionStartTime} - ${talaqqiSession.sessionEndTime}
                                </span>
                                <span class="inline-flex items-center gap-2">
                                    <i class="fas fa-bolt text-teal-600"></i>
                                    ${talaqqiSession.duration} minutes
                                </span>
                            </div>
                        </div>
                        <div class="text-right">
                            <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Teacher</p>
                            <div class="flex items-center gap-3 justify-end">
                                <p class="text-sm font-bold text-gray-900">${talaqqiSession.teacherName}</p>
                                <div class="w-12 h-12 rounded-full bg-gradient-to-br from-teal-400 to-green-500 text-white grid place-items-center font-bold text-sm">
                                    ${talaqqiSession.teacherInitials}
                                </div>
                            </div>
                        </div>
                    </div>

                    <button id="joinButton"
                            class="w-full btn-green-gradient text-white font-bold py-4 rounded-lg text-lg transition flex items-center justify-center gap-3">
                        <i class="fas fa-video"></i>
                        <span>Join Live Session</span>
                    </button>
                </div>

                <!-- Video + Quran side by side (like teacher session) -->
                <section class="grid grid-cols-1 xl:grid-cols-3 gap-6 session-main-grid">
                    <div class="xl:col-span-2 space-y-3">
                        <div class="video-shell relative">
                            <div id="jitsiContainer" class="hidden absolute inset-0 w-full h-full"
                                 data-room-name="${talaqqiSession.roomName}"
                                 data-jitsi-domain="<%= JitsiConfig.getDomain() %>"
                                 data-session-id="${talaqqiSession.sessionId}"
                                 data-teacher-id="${talaqqiSession.teacherId}"></div>
                            <div id="sessionNotStarted" class="absolute inset-0 z-10 bg-white w-full h-full grid place-items-center text-center p-8">
                                <div>
                                    <div class="w-20 h-20 rounded-3xl bg-gradient-to-br from-teal-400 to-green-500 text-white grid place-items-center text-4xl mx-auto">
                                        <i class="fas fa-video"></i>
                                    </div>
                                    <h3 class="text-2xl md:text-3xl font-bold text-gray-900 mt-4 mb-2">Session Not Started</h3>
                                    <p class="text-sm text-gray-600 max-w-md mx-auto">Click the "Join Live Session" button above to start your Talaqqi session with ${talaqqiSession.teacherName}.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quran Display Panel -->
                    <div class="quran-panel-card">
                        <div class="quran-panel-header">
                            <div class="flex items-center justify-between mb-4 pb-4 border-b border-gray-200">
                                <h4 class="text-base md:text-lg font-bold text-gray-900">Quran Display</h4>
                                <span class="bg-gradient-to-r from-teal-400 to-green-400 text-white px-3 py-1 rounded-full text-xs md:text-sm font-bold">
                                    Read-Only
                                </span>
                            </div>

                            <div class="mb-4 text-center">
                                <div class="grid grid-cols-3 gap-3">
                                    <div>
                                        <p class="text-xs text-gray-600 font-medium mb-1">Juz</p>
                                        <p id="currentJuzDisplay" class="text-lg font-bold text-teal-600"><c:out value="${not empty talaqqiSession && talaqqiSession.currentJuzukNumber > 0 ? talaqqiSession.currentJuzukNumber : 1}" /></p>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-600 font-medium mb-1">Surah</p>
                                        <p id="currentSurahDisplay" class="text-lg font-bold text-teal-600"><c:out value="${not empty talaqqiSession ? talaqqiSession.currentSurahNumber : 2}" /></p>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-600 font-medium mb-1">Ayah</p>
                                        <p id="currentAyahDisplay" class="text-lg font-bold text-teal-600">
                                            <c:choose>
                                                <c:when test="${not empty talaqqiSession && talaqqiSession.currentAyahEnd > talaqqiSession.currentAyahNumber}">
                                                    <c:out value="${talaqqiSession.currentAyahNumber}-${talaqqiSession.currentAyahEnd}" />
                                                </c:when>
                                                <c:when test="${not empty talaqqiSession}">
                                                    <c:out value="${talaqqiSession.currentAyahNumber}" />
                                                </c:when>
                                                <c:otherwise>1</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="text-center mb-3 pb-3 border-b border-gray-200">
                                <h5 id="surahNameDisplay" class="text-base font-bold text-gray-900">Al-Baqarah</h5>
                                <p id="surahTranslationDisplay" class="text-xs text-gray-500 mt-1">The Cow</p>
                            </div>
                        </div>

                        <div class="quran-panel-scroll verse-scroll" id="quranVersesScroll">
                            <div class="text-center mb-4 pb-4 border-b border-gray-200">
                                <p id="bismillahArabic" class="arabic-verse text-center mb-2">بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</p>
                                <p class="text-xs text-gray-600 italic mb-2">Bismillahi r-rahmani r-rahim</p>
                                <p class="text-xs text-gray-600">In the name of Allah, the Entirely Merciful, the Especially Merciful.</p>
                            </div>

                            <div id="quranVersesInner">
                            <c:choose>
                                <c:when test="${not empty verses}">
                                    <c:forEach var="verse" items="${verses}" varStatus="status">
                                        <div class="mb-5 pb-4 border-b border-gray-100 last:border-b-0">
                                            <div class="flex items-start gap-3 mb-3">
                                                <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">
                                                    ${verse.ayahNumber}
                                                </div>
                                            </div>
                                            <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">${verse.arabicText}</p>
                                            <p class="text-xs text-gray-600 italic mb-2">Transliteration</p>
                                            <div class="flex items-center justify-between mb-3 text-sm">
                                                <label class="font-medium text-gray-700">Show Translation</label>
                                                <label class="toggle-wrap">
                                                    <input type="checkbox" class="translation-toggle" data-verse-id="${status.index}" checked>
                                                    <div class="toggle-track"></div>
                                                </label>
                                            </div>
                                            <div class="translation-content bg-green-50 rounded-lg p-3 text-xs text-gray-700 leading-relaxed">
                                                <p>${verse.translation}</p>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="mb-5 pb-4 border-b border-gray-100">
                                        <div class="flex items-start gap-3 mb-3">
                                            <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">1</div>
                                        </div>
                                        <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">الم</p>
                                        <p class="text-xs text-gray-600 italic mb-2">Alif-Lam-Mim</p>
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
                                            <div class="w-7 h-7 bg-gradient-to-br from-teal-400 to-green-500 text-white rounded-full grid place-items-center flex-shrink-0 text-xs font-bold">2</div>
                                        </div>
                                        <p class="arabic-verse text-center mb-3 py-3 leading-relaxed">ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ</p>
                                        <p class="text-xs text-gray-600 italic mb-2">Dhalika al-kitabu la rayba fihi</p>
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
                </section>

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
                    <a href="${contextPath}/student/class-booking" class="inline-block bg-gradient-to-r from-teal-400 to-green-500 text-white px-6 py-2 rounded-lg font-semibold hover:opacity-90 transition">
                        Book a Class
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
        </div>
    </div>

<!-- ══════════════════════════════════════════════════════════════════════ -->
<!--  JAVASCRIPT                                                            -->
<!-- ══════════════════════════════════════════════════════════════════════ -->
<script>
    // Configuration — verse text via server proxy to Al-Quran Cloud (same as teacher portal)
    const QURAN_API = '<c:out value="${contextPath}" />/teacher/quran-api';
    let jitsiApi = null;
    let isSessionActive = false;
    let attendanceRecorded = false;
    let leaveRecorded = false;

    // DOM Elements
    const joinButton = document.getElementById('joinButton');
    const jitsiContainer = document.getElementById('jitsiContainer');
    const sessionNotStarted = document.getElementById('sessionNotStarted');
    const translationToggles = document.querySelectorAll('.translation-toggle');

    // Initialize
    document.addEventListener('DOMContentLoaded', () => {
        const jitsiContainerEl = document.getElementById('jitsiContainer');
        STUDENT_SESSION_ID = '<c:out value="${not empty talaqqiSession ? talaqqiSession.sessionId : ''}" />'
            || (jitsiContainerEl ? jitsiContainerEl.getAttribute('data-session-id') : '')
            || '';

        setupEventListeners();
        
        // Load initial surah info and update display
        loadSurahInfo(currentQuranState.surah);
        updateQuranLocationDisplay(
            currentQuranState.surah,
            currentQuranState.ayah,
            currentQuranState.ayahEnd,
            currentQuranState.juzuk
        );
        updateVersesDisplay(currentQuranState.surah, currentQuranState.ayah, currentQuranState.ayahEnd);
        
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
        if (joinButton && joinButton.disabled) return;

        if (joinButton) {
            joinButton.disabled = true;
            joinButton.classList.add('opacity-50', 'cursor-not-allowed');
        }

        if (sessionNotStarted) {
            sessionNotStarted.classList.add('hidden');
        }

        jitsiContainer.classList.remove('hidden');

        const sessionId = jitsiContainer.getAttribute('data-session-id') || '';
        const body = new URLSearchParams();
        body.append('action', 'prepareJoin');
        body.append('sessionId', sessionId);

        fetch('<c:out value="${contextPath}" />/student/sessions', {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        })
        .then(response => response.json())
        .then(data => {
            if (!data || !data.success) {
                throw new Error((data && data.error) ? data.error : 'Could not join session');
            }
            startJitsiMeet(data.jwt || null);
        })
        .catch(error => {
            console.error('Join session failed:', error);
            alert(error.message || 'Failed to join session. Please try again.');
            if (joinButton) {
                joinButton.disabled = false;
                joinButton.classList.remove('opacity-50', 'cursor-not-allowed');
            }
            jitsiContainer.classList.add('hidden');
            if (sessionNotStarted) {
                sessionNotStarted.classList.remove('hidden');
            }
        });
    }

    function startJitsiMeet(jwt) {
        const roomName = jitsiContainer.getAttribute('data-room-name') || 'TalaqqiHub-' + Date.now();
        const jitsiDomain = jitsiContainer.getAttribute('data-jitsi-domain') || 'meet.jit.si';

        const options = {
            roomName: roomName,
            width: '100%',
            height: '100%',
            parentNode: jitsiContainer,
            userInfo: {
                displayName: '<c:out value="${studentName}" />'
            },
            configOverwrite: {
                prejoinPageEnabled: false,
                startWithAudioMuted: false,
                disableDeepLinking: true
            },
            interfaceConfigOverwrite: {
                TOOLBAR_BUTTONS: ['microphone', 'camera', 'settings', 'hangup', 'tileview'],
                SHOW_CHROME_EXTENSION_BANNER: false,
                SHOW_JITSI_WATERMARK: false
            }
        };

        if (jwt) {
            options.jwt = jwt;
        }

        try {
            jitsiApi = new JitsiMeetExternalAPI(jitsiDomain, options);

            jitsiApi.addEventListener('videoConferenceJoined', () => {
                isSessionActive = true;
                console.log('Student joined Jitsi session');
                recordSessionEvent('joinSession');
            });

            jitsiApi.addEventListener('videoConferenceLeft', () => {
                isSessionActive = false;
                console.log('Student left Jitsi session');
                recordLeaveSession();
            });

        } catch (error) {
            console.error('Failed to initialize Jitsi Meet:', error);
            alert('Failed to start video session. Please try again.');
            jitsiContainer.classList.add('hidden');
            if (sessionNotStarted) {
                sessionNotStarted.classList.remove('hidden');
            }
            if (joinButton) {
                joinButton.disabled = false;
                joinButton.classList.remove('opacity-50', 'cursor-not-allowed');
            }
        }
    }

    // ── Record session events ───────────────────────────────────────────

    function recordSessionEvent(action) {
        const sessionId = jitsiContainer ? jitsiContainer.getAttribute('data-session-id') : '';
        const body = new URLSearchParams();
        body.append('action', action);
        body.append('sessionId', sessionId || '');

        fetch('<c:out value="${contextPath}" />/student/sessions', {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        })
        .then(response => response.json())
        .then(data => {
            console.log('Event recorded:', data);
            if (action === 'joinSession' && data && data.success) {
                attendanceRecorded = true;
                if (data.status === 'Late') {
                    alert('You joined more than 5 minutes after the teacher started. Attendance marked as Late.');
                }
            }
        })
        .catch(error => {
            console.error('Error recording event:', error);
        });
    }

    function recordLeaveSession() {
        if (leaveRecorded) return;
        leaveRecorded = true;

        const sessionId = jitsiContainer ? jitsiContainer.getAttribute('data-session-id') : '';
        const body = new URLSearchParams();
        body.append('action', 'leaveSession');
        body.append('sessionId', sessionId || '');
        const url = '<c:out value="${contextPath}" />/student/sessions';

        if (navigator.sendBeacon) {
            navigator.sendBeacon(url, new Blob([body.toString()], { type: 'application/x-www-form-urlencoded' }));
        } else {
            recordSessionEvent('leaveSession');
        }
    }

    // Record leave time when student closes tab or navigates away during session
    window.addEventListener('pagehide', () => {
        if (isSessionActive || attendanceRecorded) {
            recordLeaveSession();
        }
    });

    // ── Responsive adjustments ──────────────────────────────────────────

    window.addEventListener('resize', () => {
        if (jitsiApi && jitsiContainer && !jitsiContainer.classList.contains('hidden')) {
            // Jitsi will auto-adjust
        }
    });

    // ── Poll for Quran reference updates (teacher-to-student sync) ─────────

    // Track current Quran reference to detect changes
    let currentQuranState = {
        surah: parseInt(new URLSearchParams(window.location.search).get('surah') || '<c:out value="${not empty talaqqiSession ? talaqqiSession.currentSurahNumber : ''}" />') || 2,
        ayah:  parseInt(new URLSearchParams(window.location.search).get('ayah') || '<c:out value="${not empty talaqqiSession ? talaqqiSession.currentAyahNumber : ''}" />') || 1,
        ayahEnd: parseInt(new URLSearchParams(window.location.search).get('ayahEnd') || '<c:out value="${not empty talaqqiSession ? talaqqiSession.currentAyahEnd : ''}" />') || 0,
        juzuk: parseInt('<c:out value="${not empty talaqqiSession ? talaqqiSession.currentJuzukNumber : ''}" />') || 1
    };
    let STUDENT_SESSION_ID = '';
    let quranPollSyncedOnce = false;

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
            const response = await fetch(QURAN_API + '?action=surahInfo&surah=' + surahNo);
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
    function updateQuranLocationDisplay(surah, ayah, ayahEnd, juzuk) {
        const juzDisplay = document.getElementById('currentJuzDisplay');
        const surahDisplay = document.getElementById('currentSurahDisplay');
        const ayahDisplay = document.getElementById('currentAyahDisplay');
        
        if (juzDisplay) juzDisplay.textContent = (juzuk && juzuk > 0) ? juzuk : '1';
        if (surahDisplay) surahDisplay.textContent = surah;
        if (ayahDisplay) {
            const end = parseInt(ayahEnd, 10);
            ayahDisplay.textContent = (end > ayah) ? (ayah + '-' + end) : ayah;
        }
    }

    /**
     * Poll the server for the latest Quran reference set by the teacher.
     * If it has changed, fetch and display the new verses.
     */
    async function pollQuranOnce() {
        try {
            const body = new URLSearchParams();
            body.append('action', 'getCurrentQuran');
            if (STUDENT_SESSION_ID) {
                body.append('sessionId', STUDENT_SESSION_ID);
            }

            const response = await fetch('<c:out value="${contextPath}" />/student/sessions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: body.toString()
            });

            if (!response.ok) return;

            const data = await response.json();
            if (!data.success) return;

            const newSurah = parseInt(data.surah, 10);
            const newAyah = parseInt(data.ayah, 10);
            const newAyahEnd = parseInt(data.ayahEnd, 10) || 0;
            const newJuzuk = parseInt(data.juzuk, 10) || 1;

            const prevSurah = currentQuranState.surah;
            const prevAyah = currentQuranState.ayah;
            const prevAyahEnd = currentQuranState.ayahEnd || 0;
            const prevJuzuk = currentQuranState.juzuk || 1;

            if (newSurah !== prevSurah ||
                newAyah !== prevAyah ||
                newAyahEnd !== prevAyahEnd ||
                newJuzuk !== prevJuzuk ||
                !quranPollSyncedOnce) {

                quranPollSyncedOnce = true;
                console.log('[Quran Update] Surah ' + newSurah + ':' + newAyah
                    + (newAyahEnd > newAyah ? ('-' + newAyahEnd) : '')
                    + ' (was ' + prevSurah + ':' + prevAyah + ')');

                currentQuranState = { surah: newSurah, ayah: newAyah, ayahEnd: newAyahEnd, juzuk: newJuzuk };

                if (newSurah !== prevSurah) {
                    await loadSurahInfo(newSurah);
                }

                updateQuranLocationDisplay(newSurah, newAyah, newAyahEnd, newJuzuk);
                await updateVersesDisplay(newSurah, newAyah, newAyahEnd);
            }
        } catch (error) {
            console.error('[Polling Error]', error);
        }
    }

    function startPollingQuranUpdates() {
        if (!STUDENT_SESSION_ID) {
            console.warn('[Quran Sync] No sessionId — polling disabled. Select the same session as your teacher.');
            return;
        }
        pollQuranOnce();
        pollTimerId = setInterval(pollQuranOnce, POLL_INTERVAL_MS);
    }

    /**
     * Fetch one ayah (Arabic + English) via server proxy to Al-Quran Cloud.
     */
    async function fetchAyahFromApi(surah, ayah) {
        const response = await fetch(QURAN_API + '?action=ayah&surah=' + surah + '&ayah=' + ayah);
        if (!response.ok) {
            throw new Error('Ayah fetch failed: ' + surah + ':' + ayah);
        }
        const json = await response.json();
        if (!json || !json.data) {
            return null;
        }
        let arabicText = '';
        let translation = '';
        if (Array.isArray(json.data)) {
            json.data.forEach(function (edition) {
                if (edition.edition && edition.edition.language === 'ar') {
                    arabicText = edition.text || '';
                } else if (edition.edition && edition.edition.language === 'en') {
                    translation = edition.text || '';
                }
            });
        }
        return {
            surah: surah,
            ayahNumber: ayah,
            arabicText: arabicText || 'تعذر جلب النص',
            translation: translation || 'Translation not available',
            transliteration: 'N/A'
        };
    }

    /**
     * Fetch verses for the given Quran reference and update the DOM.
     */
    async function updateVersesDisplay(surah, startAyah, endAyah) {
        try {
            const start = parseInt(startAyah, 10);
            let end = parseInt(endAyah, 10);
            if (!start || start < 1) return;
            if (!end || end < start) {
                end = start;
            }
            const count = Math.min(end - start + 1, 50);
            const verses = [];

            for (let ayah = start; ayah < start + count && ayah <= 286; ayah++) {
                try {
                    const verse = await fetchAyahFromApi(surah, ayah);
                    if (verse) {
                        verses.push(verse);
                    }
                } catch (e) {
                    console.error('Error fetching verse ' + surah + ':' + ayah + ':', e);
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
        const versesContainer = document.getElementById('quranVersesInner');
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
