<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.TalaqqiSession,java.util.List,util.JitsiConfig" %>
<%
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }

    TalaqqiSession ts = (TalaqqiSession) request.getAttribute("session");
    List<TalaqqiSession> upcoming = (List<TalaqqiSession>) request.getAttribute("upcomingSessions");
    String teacherName = (String) request.getAttribute("teacherName");
    String teacherInitials = (String) request.getAttribute("teacherInitials");
    Boolean isActiveFlag = (Boolean) request.getAttribute("isSessionActive");
    boolean isSessionActive = isActiveFlag != null && isActiveFlag;
    String teacherId = (String) request.getAttribute("teacherId");
    String contextPath = request.getContextPath();

    boolean hasSession = (ts != null);
    String className = hasSession ? ts.getClassName() : "No Session Scheduled";
    String studentName = hasSession ? ts.getStudentName() : "-";
    String studentInitials = hasSession ? ts.getStudentInitials() : "--";
    String studentId = hasSession ? ts.getStudentId() : "";
    String sessionId = hasSession ? ts.getSessionId() : "";
    String sessionDate = hasSession ? ts.getSessionDate() : "-";
    String startTime = hasSession ? ts.getSessionStartTime() : "-";
    String endTime = hasSession ? ts.getSessionEndTime() : "-";
    double duration = hasSession ? ts.getDuration() : 0.0;
    // isSessionCompleted is true if sessionDuration > 0 (only set when session is explicitly ended)
    boolean isSessionCompleted = hasSession && duration > 0;
    String roomName = hasSession ? ts.getRoomName() : "";
    int initSurah = hasSession ? ts.getCurrentSurahNumber() : 2;
    int initAyah = hasSession ? ts.getCurrentAyahNumber() : 1;
    int initAyahEnd = hasSession && ts.getCurrentAyahEnd() > 0
            ? ts.getCurrentAyahEnd()
            : initAyah + 3;

    String safeTeacherName = (teacherName != null ? teacherName : "Teacher")
            .replace("&", "&amp;").replace("\"", "&quot;");
    String safeTeacherInit = (teacherInitials != null ? teacherInitials : "T")
            .replace("&", "&amp;").replace("\"", "&quot;");
    String safeRoomName = (roomName != null ? roomName : "")
            .replace("&", "&amp;").replace("\"", "&quot;");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Talaqqi Session</title>

    <%@ include file="/WEB-INF/views/includes/teacherLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="<%= JitsiConfig.getScriptUrl() %>" async></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --purple-900: #4c1d95;
            --purple-800: #5b21b6;
            --purple-700: #6d28d9;
            --purple-600: #7c3aed;
            --purple-500: #8b5cf6;
            --ink-900: #1f2a44;
            --ink-700: #607090;
            --line-200: #e5e7eb;
            --surface: #f6f7fb;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(180deg, #f8f9fc 0%, #f3f5fb 100%);
            color: var(--ink-900);
        }

        .join-gradient,
        .next-gradient,
        .apply-gradient {
            background: linear-gradient(90deg, #7c3aed 0%, #be185d 100%);
        }

        .join-gradient:hover,
        .next-gradient:hover,
        .apply-gradient:hover {
            filter: brightness(1.06);
        }

        .video-shell {
            border: 2px solid #d6bcfa;
            border-radius: 20px;
            background: #ffffff;
        }

        .teacher-pill {
            background: linear-gradient(90deg, #7c3aed 0%, #be185d 100%);
        }

        .ayah-badge {
            background: linear-gradient(90deg, #7c3aed 0%, #be185d 100%);
        }

        .arabic-text {
            font-family: 'Amiri', serif;
            direction: rtl;
            text-align: center;
            line-height: 3rem;
            font-size: 1.5rem;
            color: #13294b;
        }

        .translit {
            color: #6f7fa0;
            font-style: italic;
        }

        .verse-scroll {
            max-height: 720px;
            overflow-y: auto;
        }

        .verse-scroll::-webkit-scrollbar {
            width: 8px;
        }

        .verse-scroll::-webkit-scrollbar-thumb {
            background: #cfd5e3;
            border-radius: 9999px;
        }

        #surahInfoWrap {
            min-height: 60px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        #surahInfoWrap h6 {
            min-height: 1.5em;
        }

        #surahInfoWrap p {
            min-height: 1.2em;
        }

        .toggle-wrap {
            width: 52px;
            height: 30px;
            position: relative;
            display: inline-block;
        }

        .toggle-wrap input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .toggle-track {
            position: absolute;
            inset: 0;
            border-radius: 9999px;
            background: #d5d9e2;
            transition: background .2s;
        }

        .toggle-track::before {
            content: "";
            position: absolute;
            width: 22px;
            height: 22px;
            left: 4px;
            top: 4px;
            border-radius: 9999px;
            background: #fff;
            transition: transform .2s;
            box-shadow: 0 1px 4px rgba(0,0,0,.2);
        }

        .toggle-wrap input:checked + .toggle-track {
            background: linear-gradient(90deg, #7c3aed 0%, #be185d 100%);
        }

        .toggle-wrap input:checked + .toggle-track::before {
            transform: translateX(22px);
        }

        .sync-banner {
            background: #f3e8bb;
            color: #b45309;
        }

        .soft-card {
            border: 1px solid var(--line-200);
            border-radius: 18px;
            background: #fff;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/includes/teacherSidebar.jsp">
    <jsp:param name="activePage" value="talaqqi-sessions"/>
</jsp:include>

<div class="main-content">
    <jsp:include page="/WEB-INF/views/includes/teacherTopNavbar.jsp">
        <jsp:param name="pageTitle" value="Talaqqi Session"/>
        <jsp:param name="notifPrefix" value="sessionNotif"/>
    </jsp:include>

    <div class="page-content space-y-6" style="padding-top:24px;">
            <% if (upcoming != null && !upcoming.isEmpty()) { %>
            <div class="bg-white rounded-lg border border-gray-200 p-4 text-sm flex gap-3 items-center shadow-sm">
                <i class="fas fa-calendar-check text-purple-600"></i>
                <span class="font-semibold">Switch Session</span>
                <select id="sessionPicker" class="ml-auto border border-gray-300 rounded-lg px-3 py-2 text-sm"
                        onchange="if(this.value){location.href='<%= contextPath %>/teacher/sessions?sessionId='+this.value;}">
                    <% for (TalaqqiSession s : upcoming) { %>
                    <option value="<%= s.getSessionId() %>" <%= s.getSessionId() != null && s.getSessionId().equals(sessionId) ? "selected" : "" %>>
                        <%= s.getClassName() %> | <%= s.getStudentName() %> | <%= s.getSessionDate() %>
                    </option>
                    <% } %>
                </select>
            </div>
            <% } %>

            <% if (!hasSession) { %>
            <div class="soft-card p-12 text-center">
                <div class="w-20 h-20 mx-auto rounded-3xl join-gradient grid place-items-center text-white text-4xl mb-4">
                    <i class="fas fa-video"></i>
                </div>
                <h3 class="text-3xl font-bold text-[#243451]">No Upcoming Sessions</h3>
                <p class="text-base text-[#6c7b9b] mt-2">When a class booking is created, the Talaqqi session will appear here.</p>
            </div>
            <% } else { %>

            <section class="soft-card px-4 md:px-6 py-4 md:py-5">
                <div class="flex flex-col lg:flex-row justify-between items-start gap-4 mb-3">
                    <div class="flex-1">
                        <h3 class="text-2xl md:text-3xl font-bold text-[#0f172a] leading-tight"><%= className %></h3>
                        <div class="flex flex-wrap items-center gap-4 md:gap-6 text-[#6f7fa0] text-xs md:text-sm mt-2">
                            <span class="inline-flex items-center gap-2"><i class="far fa-calendar"></i><%= sessionDate %></span>
                            <span class="inline-flex items-center gap-2"><i class="far fa-clock"></i><%= startTime %> - <%= endTime %></span>
                            <span class="inline-flex items-center gap-2"><i class="fas fa-bolt"></i><%= duration %> minutes</span>
                        </div>
                    </div>
                    <div class="text-right flex items-center gap-3">
                        <div>
                            <p class="text-[#8e98b2] text-xs uppercase tracking-wide">Student</p>
                            <p class="text-[#0f172a] font-bold text-base md:text-lg leading-tight"><%= studentName %></p>
                            <p class="text-[#6f7fa0] text-xs"><%= studentId %></p>
                        </div>
                        <div class="w-14 h-14 rounded-full teacher-pill text-white grid place-items-center font-bold text-base"><%= studentInitials %></div>
                    </div>
                </div>

                <button id="joinSessionBtn" class="mt-4 w-full h-11 md:h-12 text-white text-base md:text-lg font-bold rounded-3xl <%= isSessionActive ? "bg-red-500 hover:bg-red-600" : "join-gradient" %>">
                    <i class="fas <%= isSessionActive ? "fa-stop-circle" : "fa-video" %> mr-2"></i>
                    <span><%= isSessionActive ? "End Session" : "Join Live Session" %></span>
                </button>
            </section>

            <section class="grid grid-cols-1 xl:grid-cols-3 gap-6">
                <div class="xl:col-span-2 space-y-3">
                    <div class="video-shell h-[400px] xl:h-[480px] relative overflow-hidden">
                        <div id="jitsi-container" class="w-full h-full hidden"></div>
                        <div id="session-placeholder" class="w-full h-full grid place-items-center text-center <%= isSessionActive ? "hidden" : "" %>">
                            <div>
                                <div class="w-20 h-20 rounded-3xl join-gradient text-white grid place-items-center text-4xl mx-auto">
                                    <i class="fas fa-video"></i>
                                </div>
                                <p class="text-2xl md:text-3xl font-bold text-[#243451] mt-4">Session Not Started</p>
                                <p class="text-xs md:text-sm text-[#6f7fa0] max-w-2xl mt-2">Click the "Join Live Session" button above to start your Talaqqi session with <%= studentName %>.</p>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <div class="soft-card p-4">
                            <p class="uppercase tracking-wide text-[#8a95ad] font-bold text-xs">Student Status</p>
                            <div class="flex items-center gap-2 mt-2">
                                <div class="w-10 h-10 rounded-full teacher-pill grid place-items-center text-white font-bold text-xs"><%= studentInitials %></div>
                                <div>
                                    <p class="text-[#243451] font-semibold text-sm"><%= studentName %></p>
                                    <p id="status-label" class="text-xs text-[#8a95ad]">Waiting to join</p>
                                </div>
                                <span id="status-dot" class="ml-auto w-2 h-2 rounded-full bg-gray-300"></span>
                            </div>
                        </div>
                        <div class="soft-card p-4">
                            <p class="uppercase tracking-wide text-[#8a95ad] font-bold text-xs">Session Duration</p>
                            <p id="session-timer" class="text-2xl font-mono font-bold text-[#5b21b6] mt-2">00:00</p>
                            <p id="timer-label" class="text-xs text-[#8a95ad]">Not started</p>
                        </div>
                    </div>
                </div>

                <div class="soft-card p-4 verse-scroll">
                    <div class="flex items-center justify-between mb-3">
                        <h4 class="text-base md:text-lg font-bold text-[#0f172a]">Quran Display</h4>
                        <span class="teacher-pill text-white px-4 py-2 rounded-full text-sm md:text-base font-bold">Teacher Control</span>
                    </div>

                    <div class="sync-banner mt-2 rounded-lg px-3 py-2 text-sm md:text-base flex items-center justify-center gap-2 font-semibold">
                        <i class="fas fa-circle text-yellow-400 text-xs"></i>
                        <span id="syncStatus">Syncing...</span>
                    </div>

                    <hr class="my-2 border-gray-200">

                    <h5 class="text-base md:text-lg font-bold text-[#0f172a] mb-2">Select Quran Display</h5>

                    <div class="mt-2 space-y-2">
                        <div>
                            <label class="text-xs md:text-sm text-[#64748b] font-semibold block mb-1">Juz (Part)</label>
                            <select id="juzSelector" class="w-full border border-gray-300 rounded-lg h-9 px-2 text-xs md:text-sm focus:outline-none focus:ring-2 focus:ring-purple-500"></select>
                        </div>

                        <div>
                            <label class="text-xs md:text-sm text-[#64748b] font-semibold block mb-1">Surah (Chapter)</label>
                            <select id="surahSelector" class="w-full border border-gray-300 rounded-lg h-9 px-2 text-xs md:text-sm focus:outline-none focus:ring-2 focus:ring-purple-500"></select>
                        </div>

                        <div>
                            <label class="text-xs md:text-sm text-[#64748b] font-semibold block mb-1">Starting Ayah (Verse)</label>
                            <input id="ayahStartInput" type="number" min="1" value="<%= initAyah %>" class="w-full border border-gray-300 rounded-lg h-9 px-2 text-xs md:text-sm focus:outline-none focus:ring-2 focus:ring-purple-500">
                        </div>

                        <div>
                            <label class="text-xs md:text-sm text-[#64748b] font-semibold block mb-1">Ending Ayah (Verse)</label>
                            <input id="ayahEndInput" type="number" min="1" value="<%= initAyahEnd %>" class="w-full border border-gray-300 rounded-lg h-9 px-2 text-xs md:text-sm focus:outline-none focus:ring-2 focus:ring-purple-500">
                        </div>

                        <div class="grid grid-cols-2 gap-2 pt-1">
                            <button id="applyDisplayBtn" class="apply-gradient text-white rounded-lg h-9 text-xs md:text-sm font-bold hover:opacity-90 transition">Apply</button>
                            <button id="resetDisplayBtn" class="rounded-lg h-9 text-xs md:text-sm font-bold border border-gray-300 text-[#395277] bg-white hover:bg-gray-50 transition">Reset</button>
                        </div>
                    </div>

                    <div class="mt-2">
                        <h6 class="text-xs md:text-sm font-bold text-[#0f172a] mb-2 uppercase tracking-wide">Current Display</h6>
                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div>
                                <p class="text-xs text-[#64748b] font-medium">Juz</p>
                                <p id="currentJuz" class="text-base md:text-lg font-bold text-teal-600 mt-1">1</p>
                            </div>
                            <div>
                                <p class="text-xs text-[#64748b] font-medium">Surah</p>
                                <p id="currentSurah" class="text-base md:text-lg font-bold text-teal-600 mt-1"><%= initSurah %></p>
                            </div>
                            <div>
                                <p class="text-xs text-[#64748b] font-medium">Ayah</p>
                                <p id="currentAyah" class="text-base md:text-lg font-bold text-teal-600 mt-1"><%= initAyah %></p>
                            </div>
                        </div>
                    </div>

                    <div class="mt-2 text-center border-t border-gray-200 pt-2" id="surahInfoWrap">
                        <h6 id="surahNameEn" class="text-base md:text-lg font-bold text-[#0f172a]" data-surah="<%= initSurah %>">Loading surah...</h6>
                        <p id="surahNameSub" class="text-xs text-[#64748b] mt-1">Please wait...</p>
                    </div>

                    <hr class="my-2 border-gray-200">

                    <div class="text-center px-2 py-3">
                        <p id="bismillahText" class="arabic-text mb-2"></p>
                        <p id="bismillahTranslit" class="translit text-xs mt-2"></p>
                        <p id="bismillahTranslation" class="text-xs text-[#44597e] mt-2"></p>
                    </div>

                    <div id="verseCards" class="mt-2 space-y-2"></div>

                    <div class="mt-2 flex items-center justify-between border-t border-gray-200 pt-2">
                        <p class="text-xs md:text-sm font-bold text-[#0f172a]">Show Translation</p>
                        <label class="toggle-wrap">
                            <input type="checkbox" id="showTranslation" checked>
                            <span class="toggle-track"></span>
                        </label>
                    </div>

                    <hr class="my-2 border-gray-200">

                    <div class="flex items-center justify-between gap-2">
                        <button id="prevAyahBtn" class="h-9 px-3 rounded-lg border border-emerald-300 text-emerald-700 text-xs md:text-sm font-bold hover:bg-emerald-50 disabled:opacity-40 transition">
                            <i class="fas fa-chevron-left mr-1"></i>Prev
                        </button>
                        <p class="text-xs md:text-sm font-semibold text-[#0f172a]">Ayah <span id="centerAyahLabel"><%= initAyah %></span></p>
                        <button id="nextAyahBtn" class="next-gradient text-white h-9 px-3 rounded-lg text-xs md:text-sm font-bold disabled:opacity-40 hover:opacity-90 transition">
                            Next<i class="fas fa-chevron-right ml-1"></i>
                        </button>
                    </div>
                </div>
            </section>
            <% } %>
        </div>
    </div>
</div>

<div id="talaqqi-config" style="display:none"
     data-ctx="<%= contextPath %>"
     data-session-id="<%= sessionId %>"
     data-student-id="<%= studentId %>"
     data-teacher-id="<%= teacherId %>"
     data-room-name="<%= safeRoomName %>"
     data-teacher-name="<%= safeTeacherName %>"
     data-init-surah="<%= initSurah %>"
     data-init-ayah="<%= initAyah %>"
     data-init-ayah-end="<%= initAyahEnd %>"
     data-is-active="<%= isSessionActive %>"
     data-session-duration="<%= duration %>"
     data-is-completed="<%= isSessionCompleted %>"
     data-jitsi-domain="<%= JitsiConfig.getDomain() %>">
</div>

<script>
(function () {
    "use strict";

    var cfg = document.getElementById("talaqqi-config").dataset;
    var JITSI_DOMAIN = cfg.jitsiDomain || "meet.jit.si";
    var JITSI_JWT = <%
        String teacherJwt = (String) request.getAttribute("teacherJitsiJwt");
        if (teacherJwt != null && !teacherJwt.isEmpty()) {
            out.print("\"" + teacherJwt.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "") + "\"");
        } else {
            out.print("null");
        }
    %>;
    var CTX = cfg.ctx || "";
    var SESSION_ID = cfg.sessionId || "";
    var STUDENT_ID = cfg.studentId || "";
    var RECORDED_DURATION = parseFloat(cfg.sessionDuration || "0");  // Support fractional minutes
    var IS_COMPLETED = cfg.isCompleted === "true";

    var SessionModel = {
        currentSurah: parseInt(cfg.initSurah || "2", 10),
        currentAyah: parseInt(cfg.initAyah || "1", 10),
        currentAyahEnd: parseInt(cfg.initAyahEnd || String(parseInt(cfg.initAyah || "1", 10) + 3), 10),
        appliedAyahStart: parseInt(cfg.initAyah || "1", 10),
        appliedAyahEnd: parseInt(cfg.initAyahEnd || String(parseInt(cfg.initAyah || "1", 10) + 3), 10),
        focusAyah: parseInt(cfg.initAyah || "1", 10),
        totalAyahs: 286,
        isActive: cfg.isActive === "true",
        studentAttendance: "waiting",
        verses: []
    };

    var joinBtn = document.getElementById("joinSessionBtn");
    var jitsiContainer = document.getElementById("jitsi-container");
    var placeholder = document.getElementById("session-placeholder");
    var statusLabel = document.getElementById("status-label");
    var statusDot = document.getElementById("status-dot");
    var timerEl = document.getElementById("session-timer");
    var timerLabel = document.getElementById("timer-label");

    var surahSelector = document.getElementById("surahSelector");
    var ayahStartInput = document.getElementById("ayahStartInput");
    var ayahEndInput = document.getElementById("ayahEndInput");
    var applyDisplayBtn = document.getElementById("applyDisplayBtn");
    var resetDisplayBtn = document.getElementById("resetDisplayBtn");
    var showTranslation = document.getElementById("showTranslation");
    var prevAyahBtn = document.getElementById("prevAyahBtn");
    var nextAyahBtn = document.getElementById("nextAyahBtn");

    var currentJuz = document.getElementById("currentJuz");
    var currentSurah = document.getElementById("currentSurah");
    var currentAyah = document.getElementById("currentAyah");
    var centerAyahLabel = document.getElementById("centerAyahLabel");

    var surahNameEn = document.getElementById("surahNameEn");
    var surahNameSub = document.getElementById("surahNameSub");
    var bismillahText = document.getElementById("bismillahText");
    var bismillahTranslit = document.getElementById("bismillahTranslit");
    var bismillahTranslation = document.getElementById("bismillahTranslation");
    var verseCards = document.getElementById("verseCards");
    var syncStatus = document.getElementById("syncStatus");

    // Fallback surah names in case API is slow
    var surahFallbackNames = {
        1: { name: "Al-Fatiha", translation: "The Opening" },
        2: { name: "Al-Baqarah", translation: "The Cow" },
        3: { name: "Ali Imran", translation: "The Family of Imran" }
    };

    var jitsiApi = null;
    var timer = null;
    var elapsed = 0;

    function apiFetch(path, options) {
        options = options || {};
        options.credentials = "same-origin";
        return fetch(CTX + path, options).then(function (r) {
            if (r.status === 401) {
                toast("Session expired. Please log in again.", "warning");
                setTimeout(function () {
                    window.location.href = CTX + "/teacher/login";
                }, 1200);
                return Promise.reject(new Error("unauthorized"));
            }
            return r;
        });
    }

    function init() {
        if (!SESSION_ID) return;

        loadJuzList();
        loadSurahList();
        loadSurahInfo(SessionModel.currentSurah).then(function () {
            return loadVerseRange(SessionModel.currentSurah, SessionModel.currentAyah, SessionModel.currentAyahEnd, true);
        });

        if (joinBtn) joinBtn.addEventListener("click", toggleSession);
        if (applyDisplayBtn) applyDisplayBtn.addEventListener("click", applyDisplay);
        if (resetDisplayBtn) resetDisplayBtn.addEventListener("click", resetDisplay);
        if (showTranslation) showTranslation.addEventListener("change", applyTranslationVisibility);
        if (prevAyahBtn) prevAyahBtn.addEventListener("click", function () { moveWindow(-1); });
        if (nextAyahBtn) nextAyahBtn.addEventListener("click", function () { moveWindow(1); });

        // Display recorded duration only if session has been completed
        if (IS_COMPLETED && RECORDED_DURATION > 0) {
            // RECORDED_DURATION is in fractional minutes (e.g., 1.33 for 1 min 20 sec)
            // Convert to total seconds, then extract MM:SS
            var totalSeconds = RECORDED_DURATION * 60;
            var m = Math.floor(totalSeconds / 60);
            var s = Math.round(totalSeconds % 60);
            if (timerEl) timerEl.textContent = pad(m) + ":" + pad(s);
            if (timerLabel) timerLabel.textContent = "Completed";
        }

        if (SessionModel.isActive) {
            startJitsi(cfg.roomName, cfg.teacherName, JITSI_JWT);
            startTimer();
            setJoinButton(true);
        }
    }

    function toggleSession() {
        if (SessionModel.isActive) {
            endSession();
        } else {
            startSession();
        }
    }

    function startSession() {
        apiFetch("/teacher/sessions", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "action=startSession&sessionId=" + encodeURIComponent(SESSION_ID)
        }).then(function (r) {
            return r.json();
        }).then(function (data) {
            if (!data || !data.success) {
                var reason = (data && data.error) ? data.error : "Could not start session";
                toast(reason, "error");
                return;
            }
            SessionModel.isActive = true;
            setJoinButton(true);
            startJitsi(data.roomName || cfg.roomName, cfg.teacherName, data.jwt || JITSI_JWT);
            startTimer();
            toast("Live session started", "success");
        }).catch(function () {
            toast("Failed to start session", "error");
        });
    }

    function endSession() {
        apiFetch("/teacher/sessions", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "action=endSession&sessionId=" + encodeURIComponent(SESSION_ID)
                + "&studentId=" + encodeURIComponent(STUDENT_ID)
        }).then(function () {
            stopSessionUI();
            toast("Session ended", "info");
        }).catch(function () {
            stopSessionUI();
        });
    }

    function setJoinButton(active) {
        if (!joinBtn) return;
        if (active) {
            joinBtn.className = "mt-6 w-full h-14 md:h-16 text-white text-xl md:text-2xl font-bold rounded-3xl bg-red-500 hover:bg-red-600";
            joinBtn.innerHTML = '<i class="fas fa-stop-circle mr-3"></i><span>End Session</span>';
        } else {
            joinBtn.className = "mt-6 w-full h-14 md:h-16 text-white text-xl md:text-2xl font-bold rounded-3xl join-gradient";
            joinBtn.innerHTML = '<i class="fas fa-video mr-3"></i><span>Join Live Session</span>';
        }
    }

    function stopSessionUI() {
        SessionModel.isActive = false;
        setJoinButton(false);
        clearInterval(timer);
        if (timerLabel) timerLabel.textContent = "Session ended";
        if (jitsiApi) {
            try { jitsiApi.dispose(); } catch (e) {}
            jitsiApi = null;
        }
        if (jitsiContainer) jitsiContainer.classList.add("hidden");
        if (placeholder) placeholder.classList.remove("hidden");
        setStudentStatus("waiting");
    }

    function startJitsi(room, teacherName, jwt) {
        if (typeof JitsiMeetExternalAPI === "undefined") return;
        if (jitsiContainer) jitsiContainer.classList.remove("hidden");
        if (placeholder) placeholder.classList.add("hidden");

        var jitsiOpts = {
            roomName: room,
            width: "100%",
            height: "100%",
            parentNode: jitsiContainer,
            userInfo: { displayName: teacherName || "Teacher" },
            configOverwrite: {
                prejoinPageEnabled: false,
                startWithAudioMuted: false,
                startWithVideoMuted: false,
                disableDeepLinking: true
            },
            interfaceConfigOverwrite: {
                SHOW_JITSI_WATERMARK: false,
                TOOLBAR_BUTTONS: ["microphone", "camera", "chat", "hangup", "raisehand", "tileview"]
            }
        };
        var token = jwt || JITSI_JWT;
        if (token) {
            jitsiOpts.jwt = token;
        }
        jitsiApi = new JitsiMeetExternalAPI(JITSI_DOMAIN, jitsiOpts);

        jitsiApi.addEventListener("participantJoined", function (participant) {
            if (participant && participant.local) return;
            setStudentStatus("connected");
            toast("Student joined the session", "success");
        });

        jitsiApi.addEventListener("participantLeft", function () {
            setStudentStatus("disconnected");
            toast("Student disconnected", "warning");
        });
    }

    function setStudentStatus(state) {
        if (!statusDot || !statusLabel) return;
        if (state === "connected") {
            statusDot.className = "ml-auto w-3 h-3 rounded-full bg-green-500";
            statusLabel.className = "text-sm text-green-600";
            statusLabel.textContent = "Connected";
        } else if (state === "disconnected") {
            statusDot.className = "ml-auto w-3 h-3 rounded-full bg-red-400";
            statusLabel.className = "text-sm text-red-500";
            statusLabel.textContent = "Disconnected";
        } else {
            statusDot.className = "ml-auto w-3 h-3 rounded-full bg-gray-300";
            statusLabel.className = "text-sm text-[#8a95ad]";
            statusLabel.textContent = "Waiting to join";
        }
    }

    function startTimer() {
        // Only show recorded duration if session is completed
        if (IS_COMPLETED) {
            // RECORDED_DURATION is in fractional minutes (e.g., 1.33 for 1 min 20 sec)
            // Convert to total seconds, then extract MM:SS
            var totalSeconds = RECORDED_DURATION * 60;
            var m = Math.floor(totalSeconds / 60);
            var s = Math.round(totalSeconds % 60);
            if (timerEl) timerEl.textContent = pad(m) + ":" + pad(s);
            if (timerLabel) timerLabel.textContent = "Session ended";
            return;  // Don't start a live timer for completed sessions
        }
        
        // Otherwise start a live timer from 0
        elapsed = 0;
        if (timerLabel) timerLabel.textContent = "In progress";
        timer = setInterval(function () {
            elapsed += 1;
            var m = Math.floor(elapsed / 60);
            var s = elapsed % 60;
            if (timerEl) timerEl.textContent = pad(m) + ":" + pad(s);
        }, 1000);
    }

    function recordAttendance(status, auto) {
        return apiFetch("/teacher/sessions", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "action=recordAttendance"
                + "&sessionId=" + encodeURIComponent(SESSION_ID)
                + "&studentId=" + encodeURIComponent(STUDENT_ID)
                + "&status=" + encodeURIComponent(status)
                + "&auto=" + (auto ? "true" : "false")
        }).then(function (r) { return r.json(); }).catch(function () { return null; });
    }

    function loadJuzList() {
        if (!document.getElementById("juzSelector")) return;
        var juzSel = document.getElementById("juzSelector");
        juzSel.innerHTML = "";
        for (var i = 1; i <= 30; i++) {
            var opt = document.createElement("option");
            opt.value = i;
            opt.textContent = "Juz " + i;
            juzSel.appendChild(opt);
        }
    }

    function loadSurahList() {
        if (!surahSelector) return;
        apiFetch("/teacher/quran-api?action=surahList")
            .then(function (r) { return r.json(); })
            .then(function (json) {
                var list = json && json.data ? json.data : [];
                surahSelector.innerHTML = "";
                list.forEach(function (s) {
                    var opt = document.createElement("option");
                    opt.value = s.number;
                    opt.textContent = s.number + ". " + s.englishName;
                    if (parseInt(s.number, 10) === SessionModel.currentSurah) {
                        opt.selected = true;
                        SessionModel.totalAyahs = s.numberOfAyahs || SessionModel.totalAyahs;
                    }
                    surahSelector.appendChild(opt);
                });
            }).catch(function () {
                surahSelector.innerHTML = "<option value='2'>2. Al-Baqarah</option>";
            });
    }

    function loadSurahInfo(surahNo) {
        return apiFetch("/teacher/quran-api?action=surahInfo&surah=" + surahNo)
            .then(function (r) { return r.json(); })
            .then(function (json) {
                if (!json || !json.data) {
                    console.warn("loadSurahInfo: No data in response for surah " + surahNo, json);
                    // Use fallback
                    applyFallbackSurahName(surahNo);
                    return;
                }
                var s = json.data;
                SessionModel.totalAyahs = s.numberOfAyahs || SessionModel.totalAyahs;
                
                // Handle field name variations from the API
                var engName = s.englishName || s.enName || "";
                var engTrans = s.englishNameTranslation || s.englishTranslation || "";
                
                if (surahNameEn) {
                    surahNameEn.textContent = engName || "";
                    // Ensure visibility of the wrapper if we have content
                    if (engName || engTrans) {
                        var wrapper = document.getElementById("surahInfoWrap");
                        if (wrapper) wrapper.style.display = "";
                    }
                }
                if (surahNameSub) surahNameSub.textContent = engTrans || "";
                
                console.log("Loaded surah info - Surah: " + surahNo + ", Name: " + engName + ", Trans: " + engTrans);
            }).catch(function (err) {
                console.error("loadSurahInfo fetch error for surah " + surahNo + ":", err);
                // Use fallback when API fails
                applyFallbackSurahName(surahNo);
            });
    }

    function applyFallbackSurahName(surahNo) {
        var fallback = surahFallbackNames[surahNo];
        if (surahNameEn) {
            surahNameEn.textContent = fallback ? fallback.name : ("Surah " + surahNo);
        }
        if (surahNameSub) {
            surahNameSub.textContent = fallback ? fallback.translation : "";
        }
        console.log("Using fallback surah names for surah " + surahNo);
    }

    function fetchAyah(surah, ayah) {
        return apiFetch("/teacher/quran-api?action=ayah&surah=" + surah + "&ayah=" + ayah)
            .then(function (r) { return r.json(); })
            .then(function (json) {
                if (!json || !json.data || !json.data[0]) return null;
                var ar = json.data[0];
                var en = json.data[1] || {};
                return {
                    number: ayah,
                    arabic: ar.text || "",
                    transliteration: "",
                    translation: en.text || "",
                    surahName: ar.surah ? ar.surah.englishName : ""
                };
            });
    }

    function loadVerseRange(surah, ayahStart, ayahEnd, pushToServer) {
        syncStatusText("Syncing...");

        if (ayahEnd < ayahStart) ayahEnd = ayahStart;
        if (SessionModel.totalAyahs > 0 && ayahEnd > SessionModel.totalAyahs) {
            ayahEnd = SessionModel.totalAyahs;
        }

        var jobs = [];
        for (var i = ayahStart; i <= ayahEnd; i++) {
            jobs.push(fetchAyah(surah, i));
        }

        return Promise.all(jobs).then(function (rows) {
            SessionModel.currentSurah = surah;
            SessionModel.currentAyah = ayahStart;
            SessionModel.currentAyahEnd = ayahEnd;
            SessionModel.appliedAyahStart = ayahStart;
            SessionModel.appliedAyahEnd = ayahEnd;
            SessionModel.focusAyah = ayahStart;
            SessionModel.verses = rows.filter(Boolean);

            renderVerses();
            updateCurrentDisplay();
            updateNavButtons();
            applyTranslationVisibility();

            if (pushToServer) {
                persistQuranRef(surah, ayahStart, ayahEnd);
            }
            syncStatusText("Synced");
        }).catch(function () {
            syncStatusText("Sync failed");
        });
    }

    function renderVerses() {
        if (!verseCards) return;
        verseCards.innerHTML = "";

        if (!SessionModel.verses.length) {
            verseCards.innerHTML = '<div class="text-center text-[#8a95ad] py-8">No verses loaded</div>';
            return;
        }

        // Always show Bismillah at the top
        if (bismillahText) bismillahText.textContent = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ";
        if (bismillahTranslit) bismillahTranslit.textContent = "Bismillahi r-rahmani r-rahim";
        if (bismillahTranslation) bismillahTranslation.textContent = "In the name of Allah, the Entirely Merciful, the Especially Merciful.";

        // Show all verses including ayah 1
        for (var i = 0; i < SessionModel.verses.length; i++) {
            var v = SessionModel.verses[i];
            var arabicText = v.arabic || "";
            
            // Remove Bismillah from first ayah if it appears at the start
            if (i === 0) {
                // Remove various forms of Bismillah using regex to handle diacritics
                arabicText = arabicText.replace(/^.*?بسم.*?الرحيم\s*/g, "").trim();
            }
            
            var card = document.createElement("div");
            card.className = "soft-card p-5 mb-4 border border-gray-200 rounded-lg hover:shadow-md transition";
            card.setAttribute("data-ayah", String(v.number));
            card.innerHTML = ''
                + '<div class="flex items-start gap-3 mb-4">'
                + '<div class="w-8 h-8 ayah-badge rounded-full text-white font-bold grid place-items-center flex-shrink-0 text-sm">' + v.number + '</div>'
                + '</div>'
                + '<p class="arabic-text mb-3 text-center py-4">' + escapeHtml(arabicText) + '</p>'
                + '<p class="translit text-xs text-[#6f7fa0] mb-2 italic">' + escapeHtml(v.transliteration || fallbackTranslit(v.number)) + '</p>'
                + '<p class="text-xs text-[#44597e] translation-line leading-relaxed">' + escapeHtml(v.translation) + '</p>';
            verseCards.appendChild(card);
        }

        if (centerAyahLabel) centerAyahLabel.textContent = String(SessionModel.focusAyah || SessionModel.appliedAyahStart);
        updateNavButtons();
    }

    function updateNavButtons() {
        var start = SessionModel.appliedAyahStart;
        var end = SessionModel.appliedAyahEnd;
        var focus = SessionModel.focusAyah || start;
        if (prevAyahBtn) prevAyahBtn.disabled = focus <= start;
        if (nextAyahBtn) nextAyahBtn.disabled = focus >= end;
    }

    function scrollToAyahCard(ayahNum) {
        if (!verseCards) return;
        var card = verseCards.querySelector('[data-ayah="' + ayahNum + '"]');
        if (card) {
            card.scrollIntoView({ behavior: "smooth", block: "center" });
        }
    }

    function fallbackTranslit(ayah) {
        if (ayah === 1) return "Alif-Lam-Mim";
        if (ayah === 2) return "Dhalika al-kitabu la rayba fihi";
        if (ayah === 3) return "Alladhina yu'minuna bil-ghayb";
        return "";
    }

    function applyDisplay() {
        var surah = parseInt(surahSelector ? surahSelector.value : SessionModel.currentSurah, 10);
        var start = parseInt(ayahStartInput ? ayahStartInput.value : SessionModel.currentAyah, 10);
        var end = parseInt(ayahEndInput ? ayahEndInput.value : SessionModel.currentAyahEnd, 10);

        if (!surah || surah < 1 || surah > 114) {
            toast("Please choose a valid surah", "error");
            return;
        }
        if (!start || start < 1) {
            toast("Please enter a valid starting ayah", "error");
            return;
        }
        if (!end || end < start) {
            end = start;
            if (ayahEndInput) ayahEndInput.value = String(end);
        }

        loadSurahInfo(surah).then(function () {
            if (SessionModel.totalAyahs > 0 && end > SessionModel.totalAyahs) {
                end = SessionModel.totalAyahs;
                if (ayahEndInput) ayahEndInput.value = String(end);
            }
            loadVerseRange(surah, start, end, true);
            
            // SAVE TO DATABASE: Save Quran display to qurandisplay table
            persistQuranRef(surah, start, end);
            
            // Update current display UI
            if (currentSurah) currentSurah.textContent = String(surah);
            if (currentAyah) currentAyah.textContent = String(start);
            SessionModel.currentSurah = surah;
            SessionModel.currentAyah = start;
            SessionModel.currentAyahEnd = end;
            SessionModel.appliedAyahStart = start;
            SessionModel.appliedAyahEnd = end;
            SessionModel.focusAyah = start;
            
            toast("Quran display saved", "success");
        });
    }

    function resetDisplay() {
        if (surahSelector) surahSelector.value = String(SessionModel.currentSurah);
        if (ayahStartInput) ayahStartInput.value = String(SessionModel.currentAyah);
        if (ayahEndInput) ayahEndInput.value = String(SessionModel.currentAyahEnd);
        applyTranslationVisibility();
        toast("Display reset to original", "info");
        loadVerseRange(SessionModel.currentSurah, SessionModel.currentAyah, SessionModel.currentAyahEnd, false);
    }

    function moveWindow(delta) {
        var start = SessionModel.appliedAyahStart;
        var end = SessionModel.appliedAyahEnd;
        var focus = (SessionModel.focusAyah || start) + delta;
        if (focus < start || focus > end) return;
        SessionModel.focusAyah = focus;
        if (centerAyahLabel) centerAyahLabel.textContent = String(focus);
        scrollToAyahCard(focus);
        updateNavButtons();
    }

    function updateCurrentDisplay() {
        if (currentJuz) currentJuz.textContent = "1";
        if (currentSurah) currentSurah.textContent = String(SessionModel.currentSurah);
        if (currentAyah) {
            currentAyah.textContent = SessionModel.appliedAyahEnd > SessionModel.appliedAyahStart
                ? (SessionModel.appliedAyahStart + "-" + SessionModel.appliedAyahEnd)
                : String(SessionModel.appliedAyahStart);
        }
    }

    function applyTranslationVisibility() {
        var show = showTranslation ? showTranslation.checked : true;
        var lines = document.querySelectorAll('.translation-line');
        for (var i = 0; i < lines.length; i++) {
            lines[i].style.display = show ? '' : 'none';
        }
        if (bismillahTranslation) bismillahTranslation.style.display = show ? '' : 'none';
        if (bismillahTranslit) bismillahTranslit.style.display = show ? '' : 'none';
    }

    function persistQuranRef(surah, ayah, ayahEnd) {
        apiFetch("/teacher/sessions", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "action=updateQuran"
                + "&sessionId=" + encodeURIComponent(SESSION_ID)
                + "&surah=" + encodeURIComponent(String(surah))
                + "&ayah=" + encodeURIComponent(String(ayah))
                + "&ayahEnd=" + encodeURIComponent(String(ayahEnd))
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                console.log("[Quran Display] Saved to database - Surah:" + surah + ", Ayah:" + ayah);
            } else {
                console.warn("[Quran Display] Save failed:", data.error);
            }
        })
        .catch(function(err) {
            console.error("[Quran Display] Error:", err);
        });
    }

    function syncStatusText(text) {
        if (syncStatus) syncStatus.textContent = text;
    }

    function pad(v) {
        return v < 10 ? "0" + v : String(v);
    }

    function toast(message, kind) {
        var bg = "bg-[#5b21b6]";
        if (kind === "success") bg = "bg-green-600";
        if (kind === "error") bg = "bg-red-600";
        if (kind === "warning") bg = "bg-amber-500";

        var t = document.createElement("div");
        t.className = "fixed bottom-6 right-6 z-50 text-white px-5 py-3 rounded-xl shadow-xl " + bg;
        t.textContent = message;
        document.body.appendChild(t);
        setTimeout(function () {
            t.style.opacity = "0";
            t.style.transition = "opacity .3s";
            setTimeout(function () { if (t && t.parentNode) t.parentNode.removeChild(t); }, 350);
        }, 2500);
    }

    function escapeHtml(str) {
        return (str || "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    window.updateQuranDisplay = function (surah, ayah) {
        var end = ayah + 3;
        if (ayahStartInput) ayahStartInput.value = String(ayah);
        if (ayahEndInput) ayahEndInput.value = String(end);
        if (surahSelector) surahSelector.value = String(surah);
        loadSurahInfo(surah).then(function () {
            loadVerseRange(surah, ayah, end, true);
        });
    };

    window.addEventListener("DOMContentLoaded", init);
})();
</script>
</body>
</html>
