# Component Relationship Map - Quick Reference

## 🎯 Quick Component Overview

```
┌────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (Browser)               │
├────────────────────────────────────────────────────────────────┤
│                   studentTalaqqiSession.jsp                     │
│  • Location: WEB-INF/views/                                    │
│  • Size: 700 lines                                             │
│  • Receives: session, verses (from request attributes)         │
│  • Uses: JSTL <c:forEach>, <c:choose>, <c:out>               │
│  • Displays: Session card + Quran verses                       │
│  • CSS: Tailwind (green theme, responsive)                     │
│  • JS: Jitsi Meet API integration                              │
└────────────────────────────────────────────────────────────────┘
                              ▲
                              │ request.setAttribute()
                              │ forward()
                              │
┌────────────────────────────────────────────────────────────────┐
│                    CONTROLLER LAYER (Servlet)                  │
├────────────────────────────────────────────────────────────────┤
│             StudentTalaqqiSessionServlet.java                   │
│  • Location: src/controller/                                    │
│  • URL: /student/talaqqi-session                               │
│  • Methods: doGet(), doPost()                                   │
│  • Process: Auth → DAO calls → Set attributes → Forward JSP    │
│  • Returns: HTML page or JSON                                   │
│                                                                 │
│  Key Functions:                                                 │
│  ├─ Authentication: Check studentId in HTTP session            │
│  ├─ Get Session: talaqqiSessionDAO.getUpcomingSessionFor...    │
│  ├─ Get Verses: loadVerseSequence() → QuranDAO.getAyah()      │
│  └─ Set Attributes: session, verses, studentName, contextPath │
│                                                                 │
│  AJAX Handlers (POST):                                          │
│  ├─ action=joinSession                                         │
│  ├─ action=leaveSession                                        │
│  └─ action=acknowledgeVerse                                    │
│                                                                 │
│  Import References:                                             │
│  ├─ import dao.TalaqqiSessionDAO;                             │
│  ├─ import dao.QuranDAO;                                       │
│  ├─ import model.TalaqqiSession;                              │
│  └─ import model.QuranVerse;                                   │
└────────────────────────────────────────────────────────────────┘
         ▲                              ▲
         │                              │
         │ DAO calls                    │ DAO calls
         │ (read)                       │ (read)
         │                              │
    ┌────────────────────────┐    ┌────────────────────────────┐
    │  DATABASE LAYER (DAO)  │    │    API INTEGRATION (DAO)   │
    ├────────────────────────┤    ├────────────────────────────┤
    │ TalaqqiSessionDAO      │    │ QuranDAO                    │
    │ (Extended: +2 methods) │    │ (New)                       │
    │                        │    │                             │
    │ Methods Used:          │    │ Methods Used:               │
    │ • getUpcoming...       │    │ • getAyah(surah, ayah)     │
    │   ForStudent()         │    │ • getSurahVerses()         │
    │   └─ Returns:          │    │ • getAyahByKey()           │
    │     TalaqqiSession     │    │   └─ Returns:              │
    │                        │    │     QuranVerse             │
    │ SQL Joins:             │    │                             │
    │ ├─ talaqqisession      │    │ HTTP Calls:                 │
    │ ├─ classbooking        │    │ ├─ GET to Al-Quran API     │
    │ ├─ classschedule       │    │ ├─ Timeout: 10s/15s        │
    │ ├─ student             │    │ ├─ Parse JSON             │
    │ └─ teacher             │    │ └─ Return QuranVerse obj   │
    │                        │    │                             │
    │ Query Filter:          │    │ Dependencies:               │
    │ WHERE studentId = ?    │    │ ├─ org.json.*              │
    │ AND sessionDate >=     │    │ ├─ java.net.*              │
    │ TODAY                  │    │ └─ java.io.*               │
    └────────────────────────┘    └────────────────────────────┘
             ▲                              ▲
             │ SQL Queries                  │ HTTP Requests
             │                              │
             │                    ┌─────────┘
             │                    │
             │          ┌──────────────────┐
             │          │                  │
    ┌────────┴──────┐   │  ┌───────────────────────────┐
    │  MySQL        │   │  │  Al-Quran Cloud API       │
    │  Database     │   │  │ https://api.alquran...    │
    │               │   │  │ • /ayah/{N}:{M}/editions  │
    │  Tables Used: │   │  │ • /surah/{N}              │
    │  • talaqqi... │   │  │ • /surah                  │
    │  • classbooking   │  │                           │
    │  • classschedule  │  │ Returns JSON:             │
    │  • student    │   │  │ • surah name/number       │
    │  • teacher    │   │  │ • ayah number             │
    │  • attendance │   │  │ • arabic text             │
    │               │   │  │ • english translation     │
    └───────────────┘   │  └───────────────────────────┘
                        │
                        └─ External Service
└─ Network Dependent, 0.5-1s latency
```

---

## 📊 Data Flow - Step by Step

### Step 1: Student Opens Page
```
Browser GET: /TalaqqiHub/student/talaqqi-session
         ↓
Servlet: StudentTalaqqiSessionServlet.doGet()
         ↓
Check: session.getAttribute("studentId") != null?
         ↓ YES
Get: String studentId = (String) session.getAttribute("studentId")
         ↓ (e.g., "STU-001")
```

### Step 2: Fetch Session Data
```
Servlet calls: talaqqiSessionDAO.getUpcomingSessionForStudent(studentId)
         ↓
DAO executes SQL query joining 5 tables
         ↓
Database returns single row
         ↓
DAO maps result → TalaqqiSession object
         ↓
Object contains:
  • sessionId: "TSB001"
  • className: "Tajweed & Quran Recitation"
  • teacherName: "Ustadh Ibrahim Khan"
  • sessionDate: "Tuesday, December 30, 2025"
  • currentSurahNumber: 1
  • currentAyahNumber: 1
         ↓
Return to Servlet
```

### Step 3: Load Quran Verses
```
Servlet gets: surahNumber = 1, ayahNumber = 1
         ↓
Servlet calls: loadVerseSequence(1, 1, 5)
         ↓
Loop 5 times:
  i=0: quranDAO.getAyah(1, 1)
         ↓ (HTTP GET to Al-Quran Cloud API)
         ↓ API returns JSON
         ↓ Parse → QuranVerse object
         ↓ Add to List

  i=1: quranDAO.getAyah(1, 2)
       ... (repeat)
  i=2: quranDAO.getAyah(1, 3)
       ... (repeat)
  i=3: quranDAO.getAyah(1, 4)
       ... (repeat)
  i=4: quranDAO.getAyah(1, 5)
       ... (repeat)
         ↓
Result: List<QuranVerse> with 5 objects
         ↓
Return to Servlet
```

### Step 4: Set Request Attributes
```
Servlet executes:
  request.setAttribute("session", session)
  request.setAttribute("verses", verses)
  request.setAttribute("studentName", studentName)
  request.setAttribute("contextPath", "/TalaqqiHub")
         ↓
JSP can now access via: ${session}, ${verses}, ${studentName}, ${contextPath}
```

### Step 5: Forward to JSP
```
Servlet forwards: request.getRequestDispatcher("/WEB-INF/views/studentTalaqqiSession.jsp")
                  .forward(request, response)
         ↓
JSP file loaded and compiled
```

### Step 6: JSP Rendering
```
JSP loads CSS/JS from CDN:
  ✓ Tailwind CSS
  ✓ Font Awesome icons
  ✓ Jitsi Meet External API
  ✓ Google Fonts

Renders Sidebar: Green gradient, navigation links

Renders Header: Title, notification icon, user profile

Renders Session Card:
  <c:choose>
    <c:when test="${not empty session}">
      <h3>${session.className}</h3>
      <p>${session.sessionDate}</p>
      <p>${session.teacherName}</p>
      <button id="joinButton">Join Live Session</button>
    </c:when>
  </c:choose>

Renders Quran Panel:
  <c:forEach var="verse" items="${verses}">
    <p>${verse.surahNameEnglish}</p>
    <p class="arabic-verse">${verse.arabicText}</p>
    <p>${verse.translation}</p>
  </c:forEach>
         ↓
HTML sent to browser
```

### Step 7: Browser Displays Page
```
✓ Green sidebar with navigation
✓ Session card with teacher info
✓ Green "Join Live Session" button
✓ Quran verses in right panel
✓ Translation toggles per verse
```

### Step 8: Student Clicks "Join"
```
JavaScript: handleJoinSession() triggered
         ↓
Show Jitsi container
         ↓
var api = new JitsiMeetExternalAPI("meet.jit.si", options)
         ↓
Jitsi loads video/audio streams
         ↓
Events: videoConferenceJoined
         ↓
AJAX POST: /student/talaqqi-session?action=joinSession
         ↓
Servlet logs attendance
         ↓
Student can now see teacher (if present)
```

---

## 🔀 Model Relationships

```
┌─────────────────────────┐          ┌─────────────────────────┐
│  TalaqqiSession         │          │  QuranVerse             │
│  (Existing + Extended)  │          │  (New)                  │
├─────────────────────────┤          ├─────────────────────────┤
│ -sessionId              │          │ -surahNumber            │
│ -studentId              │          │ -surahName              │
│ -teacherId              │          │ -surahNameEnglish       │
│ -className              │          │ -ayahNumber             │
│ -teacherName            │          │ -totalAyahs             │
│ -sessionDate            │          │ -arabicText             │
│ -sessionStartTime       │          │ -transliteration        │
│ -sessionEndTime         │          │ -translation            │
│ -duration               │          │                         │
│ -currentSurahNumber     │◄──┐      │ + getters/setters       │
│ -currentAyahNumber      │   │      │ + getFullDisplay()      │
│ -roomName               │   │      │ + toString()            │
│ + getters/setters       │   │      └─────────────────────────┘
│ + getFormattedRef...()  │   │              △
│                         │   │              │
│ Source: MySQL DB        │   │              │ Used by JSP to
│                         │   │              │ display verses
└─────────────────────────┘   │              │
         △                     │              │
         │                     └──────────────┘
         │
    Created by:
    TalaqqiSessionDAO
    .getUpcomingSessionForStudent()
    
    Used in JSP:
    ├─ ${session.className}
    ├─ ${session.teacherName}
    ├─ ${session.duration}
    └─ ${session.currentSurahNumber}
```

---

## 🔌 API Contracts

### QuranDAO Contract
```
┌─ Input: int surah, int ayah
├─ Method: getAyah(surah, ayah)
├─ HTTP: GET https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/editions/...
├─ Timeout: 10s connect, 15s read
├─ Response: JSON
└─ Output: QuranVerse object
   ├─ surahName
   ├─ surahNameEnglish
   ├─ ayahNumber
   ├─ arabicText
   ├─ translation
   └─ [null if error]
```

### TalaqqiSessionDAO Contract
```
┌─ Input: String studentId
├─ Method: getUpcomingSessionForStudent(studentId)
├─ SQL: SELECT * FROM [5 tables] WHERE studentId=? AND sessionDate>=TODAY
├─ Database: MySQL
└─ Output: TalaqqiSession object
   ├─ sessionId
   ├─ className
   ├─ teacherName
   ├─ teacherName
   ├─ duration
   ├─ currentSurahNumber
   ├─ currentAyahNumber
   └─ [null if no session]
```

### Servlet Contract
```
┌─ URL: /student/talaqqi-session
├─ GET:
│  ├─ Input: ?sessionId=X (optional)
│  ├─ Session: studentId (required)
│  ├─ Processing: Auth → DAO calls → Set attrs
│  └─ Output: HTML (studentTalaqqiSession.jsp)
│
└─ POST:
   ├─ Input: action=joinSession|leaveSession|acknowledgeVerse
   ├─ Session: studentId (required)
   ├─ Processing: Execute action
   └─ Output: JSON { "success": true/false }
```

### JSP Contract
```
┌─ Input (from request attributes):
│  ├─ ${session}: TalaqqiSession object
│  ├─ ${verses}: List<QuranVerse>
│  ├─ ${studentName}: String
│  ├─ ${studentInitials}: String
│  └─ ${contextPath}: String
│
└─ Output: HTML page
   ├─ Session card
   ├─ Quran verses
   ├─ Jitsi container (empty initially)
   └─ Translation toggles
```

---

## 📦 Compilation Dependencies

```
StudentTalaqqiSessionServlet.java (new)
├─ Requires: TalaqqiSessionDAO.class
├─ Requires: QuranDAO.class
├─ Requires: TalaqqiSession.class
├─ Requires: QuranVerse.class
├─ Requires: javax.servlet.*
└─ Compiles: WEB-INF/classes/controller/StudentTalaqqiSessionServlet.class

QuranDAO.java (new)
├─ Requires: QuranVerse.class
├─ Requires: org.json.* (org-json library)
├─ Requires: java.net.* (built-in)
├─ Requires: java.io.* (built-in)
└─ Compiles: WEB-INF/classes/dao/QuranDAO.class

QuranVerse.java (new)
├─ Requires: (none - base class only)
└─ Compiles: WEB-INF/classes/model/QuranVerse.class

studentTalaqqiSession.jsp
├─ Requires: JSTL library (jakarta.servlet.jsp.jstl.*)
├─ Imports: TagLib declarations
└─ Compiles: WEB-INF/classes/.jsp (JSP compiled servlet)
```

---

## 🧪 Testing Flow

```
1. Unit Test (Individual Components)
   ├─ QuranDAO.getAyah(1, 1) → Should return QuranVerse
   ├─ TalaqqiSessionDAO.getUpcomingSessionForStudent("STU-001")
   │  → Should return TalaqqiSession or null
   └─ StudentTalaqqiSessionServlet.isAuthenticated(session)
      → Should return true/false

2. Integration Test (Component Interaction)
   ├─ Servlet calls DAO → DAO queries DB → Returns object
   ├─ Servlet calls QuranDAO → DAO calls API → Returns object
   └─ Servlet sets attributes → JSP accesses via ${}

3. End-to-End Test (Full User Journey)
   ├─ Login as student
   ├─ Navigate to /student/talaqqi-session
   ├─ Verify session card displays
   ├─ Verify Quran verses display
   ├─ Click "Join Live Session"
   ├─ Verify Jitsi initializes
   └─ Verify events post to servlet

4. Error Scenarios
   ├─ No session: Should display "No Sessions Scheduled"
   ├─ API timeout: Should display verses placeholder
   ├─ DB error: Should show error page
   └─ Auth failure: Should redirect to login
```

---

## ✨ Key Integration Points

```
1. HTTP Session Integration
   Browser ──[sessionId]──> Servlet
   Servlet checks studentId from HTTP session
   
2. Database Integration
   Servlet ──[studentId]──> TalaqqiSessionDAO
   DAO ──[SQL Query]──> MySQL DB
   DB ──[Row Data]──> DAO
   DAO maps → TalaqqiSession object ──> Servlet

3. External API Integration
   Servlet ──[surah:ayah]──> QuranDAO
   QuranDAO ──[HTTP GET]──> Al-Quran Cloud API
   API ──[JSON Response]──> QuranDAO
   QuranDAO parses → QuranVerse object ──> Servlet

4. MVC Integration
   Model (TalaqqiSession, QuranVerse)
   ↓
   Controller (StudentTalaqqiSessionServlet)
   ↓
   View (studentTalaqqiSession.jsp via JSTL)
   ↓
   Browser (HTML + CSS + JS)

5. Client-Server Integration
   JSP renders static HTML with embedded JavaScriptcript
   JavaScript listens for button clicks
   On click: JavaScript ──[AJAX POST]──> Servlet
   Servlet processes → Returns JSON
   JavaScript processes JSON → Updates DOM
```

---

## 🎓 Component Responsibility

| Component | Responsibility | Returns |
|-----------|-----------------|---------|
| **QuranVerse** | Data model for Quran verses | Object with getters |
| **TalaqqiSession** | Data model for sessions | Object with getters |
| **QuranDAO** | Fetch verses from Al-Quran API | QuranVerse or List |
| **TalaqqiSessionDAO** | Fetch sessions from MySQL DB | TalaqqiSession or List |
| **StudentTalaqqiSessionServlet** | Route requests, orchestrate DAOs | HTML or JSON |
| **studentTalaqqiSession.jsp** | Render UI, display data | Web page (HTML) |
| **JavaScript** | Handle user interactions | AJAX calls, DOM updates |
| **Jitsi Meet API** | Video/audio streaming | Video conference room |

---

**Document Purpose**: Complete system relationship visualization  
**Created**: March 28, 2026  
**Status**: Production Reference
