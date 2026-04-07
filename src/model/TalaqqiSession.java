package model;

import java.time.LocalDateTime;

/**
 * TalaqqiSession Model
 *
 * Represents a live Talaqqi (Islamic recitation) session between a teacher and student.
 * Tracks session identity, timing, video-call room, current Quran reference, and
 * student attendance state.
 *
 * MVC Role: Model – pure data container with no Servlet/DAO dependencies.
 */
public class TalaqqiSession {

    // ─── Core identifiers ──────────────────────────────────────────────────────
    private String sessionId;       // talaqqisession.sessionId (PK)
    private String bookingId;       // classbooking.bookingId (FK in talaqqisession)
    private String sessionType;     // "Live Talaqqi" (from talaqqisession)
    private String scheduleId;      // classschedule.scheduleId (resolved via classbooking)
    private String studentId;
    private String teacherId;

    // ─── Participant info ──────────────────────────────────────────────────────
    private String studentName;
    private String studentInitials;
    private String teacherName;
    private String teacherInitials;
    private String className;

    // ─── Timing ────────────────────────────────────────────────────────────────
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String sessionDate;        // formatted "EEEE, MMMM d, yyyy"
    private String sessionStartTime;   // formatted "hh:mm a"
    private String sessionEndTime;     // formatted "hh:mm a"
    private double duration;           // minutes (now supports fractional precision, e.g., 1.33 for 1 min 20 sec)

    // ─── Session lifecycle ─────────────────────────────────────────────────────
    /** "pending" | "active" | "ended" – stored only in HTTP session, not in DB */
    private String status;

    /** "waiting" | "connected" | "disconnected" */
    private String attendanceStatus;

    /** Jitsi Meet room identifier derived from scheduleId + teacherId */
    private String roomName;

    // ─── Current Quran reference ───────────────────────────────────────────────
    private int currentSurahNumber;
    private int currentAyahNumber;
    private int currentAyahEnd;     // 0 means not set (single-ayah mode)
    private QuranReference currentQuranReference;

    // ══════════════════════════════════════════════════════════════════════════
    //  Inner class: QuranReference
    //  Holds the verse data fetched from the Al-Quran Cloud API
    //  (https://api.alquran.cloud/v1)
    // ══════════════════════════════════════════════════════════════════════════
    public static class QuranReference {

        private int    surahNumber;
        private String surahName;           // Arabic name
        private String surahNameEnglish;    // e.g. "Al-Fatiha"
        private int    ayahNumber;
        private int    totalAyahs;          // total ayahs in the surah
        private String arabicText;          // Uthmani script
        private String transliteration;     // romanised pronunciation
        private String translation;         // English meaning

        /** Default constructor – seeds Surah 1 Ayah 1 as a safe default. */
        public QuranReference() {
            this.surahNumber     = 1;
            this.surahName       = "الفاتحة";
            this.surahNameEnglish = "Al-Fatiha";
            this.ayahNumber      = 1;
            this.totalAyahs      = 7;
            this.arabicText      = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";
            this.transliteration = "Bismi llāhi r-raḥmāni r-raḥīm";
            this.translation     = "In the name of Allah, the Entirely Merciful, the Especially Merciful.";
        }

        public QuranReference(int surahNumber, int ayahNumber) {
            this();
            this.surahNumber = surahNumber;
            this.ayahNumber  = ayahNumber;
        }

        // ── getters / setters ─────────────────────────────────────────────────
        public int    getSurahNumber()         { return surahNumber; }
        public void   setSurahNumber(int v)    { this.surahNumber = v; }

        public String getSurahName()           { return surahName; }
        public void   setSurahName(String v)   { this.surahName = v; }

        public String getSurahNameEnglish()             { return surahNameEnglish; }
        public void   setSurahNameEnglish(String v)     { this.surahNameEnglish = v; }

        public int    getAyahNumber()          { return ayahNumber; }
        public void   setAyahNumber(int v)     { this.ayahNumber = v; }

        public int    getTotalAyahs()          { return totalAyahs; }
        public void   setTotalAyahs(int v)     { this.totalAyahs = v; }

        public String getArabicText()          { return arabicText; }
        public void   setArabicText(String v)  { this.arabicText = v; }

        public String getTransliteration()          { return transliteration; }
        public void   setTransliteration(String v)  { this.transliteration = v; }

        public String getTranslation()          { return translation; }
        public void   setTranslation(String v)  { this.translation = v; }

        /**
         * Returns true if the previous ayah exists (i.e. this is not the first ayah
         * of the surah AND not the very first ayah of the Quran).
         */
        public boolean hasPreviousAyah() {
            return ayahNumber > 1;
        }

        /**
         * Returns true if a next ayah exists within this surah.
         */
        public boolean hasNextAyah() {
            return totalAyahs > 0 && ayahNumber < totalAyahs;
        }

        @Override
        public String toString() {
            return surahNameEnglish + " " + surahNumber + ":" + ayahNumber;
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Constructor
    // ══════════════════════════════════════════════════════════════════════════
    public TalaqqiSession() {
        this.status               = "pending";
        this.attendanceStatus     = "waiting";
        this.currentSurahNumber   = 1;
        this.currentAyahNumber    = 1;
        this.currentAyahEnd       = 0;
        this.currentQuranReference = new QuranReference();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Helper Methods
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Derives a deterministic Jitsi Meet room name for this session.
     * Format: "TalaqqiHub-{teacherId}-{scheduleId}" (alphanumeric only).
     * The same room name is used by both the teacher and the student.
     */
    public String generateRoomName() {
        String tId = (teacherId != null) ? teacherId.replaceAll("[^a-zA-Z0-9]", "") : "T";
        // Use the talaqqisession sessionId as the unique room identifier
        String sid = (sessionId != null) ? sessionId.replaceAll("[^a-zA-Z0-9]", "") : "S";
        return "TalaqqiHub-" + tId + "-" + sid;
    }

    /**
     * Returns the two-letter initials for the student name (e.g. "Ahmad Hassan" → "AH").
     * Falls back to the first two characters of studentId if name is absent.
     */
    public String resolveStudentInitials() {
        if (studentName != null && !studentName.trim().isEmpty()) {
            String[] parts = studentName.trim().split("\\s+");
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < Math.min(parts.length, 2); i++) {
                sb.append(Character.toUpperCase(parts[i].charAt(0)));
            }
            return sb.toString();
        }
        return (studentId != null && studentId.length() >= 2) ? studentId.substring(0, 2).toUpperCase() : "??";
    }

    /**
     * Returns the two-letter initials for the teacher name (e.g. "Fatima Ahmed" → "FA").
     * Falls back to the first two characters of teacherId if name is absent.
     */
    public String resolveTeacherInitials() {
        if (teacherName != null && !teacherName.trim().isEmpty()) {
            String[] parts = teacherName.trim().split("\\s+");
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < Math.min(parts.length, 2); i++) {
                sb.append(Character.toUpperCase(parts[i].charAt(0)));
            }
            return sb.toString();
        }
        return (teacherId != null && teacherId.length() >= 2) ? teacherId.substring(0, 2).toUpperCase() : "??";
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Getters & Setters
    // ══════════════════════════════════════════════════════════════════════════

    public String getSessionId()               { return sessionId; }
    public void   setSessionId(String v)       { this.sessionId = v; }

    public String getBookingId()               { return bookingId; }
    public void   setBookingId(String v)       { this.bookingId = v; }

    public String getSessionType()             { return sessionType; }
    public void   setSessionType(String v)     { this.sessionType = v; }

    public String getScheduleId()              { return scheduleId; }
    public void   setScheduleId(String v)      { this.scheduleId = v; }

    public String getStudentId()               { return studentId; }
    public void   setStudentId(String v)       { this.studentId = v; }

    public String getTeacherId()               { return teacherId; }
    public void   setTeacherId(String v)       { this.teacherId = v; }

    public String getStudentName()             { return studentName; }
    public void   setStudentName(String v)     { this.studentName = v; this.studentInitials = resolveStudentInitials(); }

    public String getStudentInitials()         { return studentInitials != null ? studentInitials : resolveStudentInitials(); }
    public void   setStudentInitials(String v) { this.studentInitials = v; }

    public String getTeacherName()             { return teacherName; }
    public void   setTeacherName(String v)     { this.teacherName = v; this.teacherInitials = resolveTeacherInitials(); }

    public String getTeacherInitials()         { return teacherInitials != null ? teacherInitials : resolveTeacherInitials(); }
    public void   setTeacherInitials(String v) { this.teacherInitials = v; }

    public String getClassName()               { return className; }
    public void   setClassName(String v)       { this.className = v; }

    public LocalDateTime getStartTime()              { return startTime; }
    public void          setStartTime(LocalDateTime v) { this.startTime = v; }

    public LocalDateTime getEndTime()                { return endTime; }
    public void          setEndTime(LocalDateTime v)   { this.endTime = v; }

    public String getSessionDate()             { return sessionDate; }
    public void   setSessionDate(String v)     { this.sessionDate = v; }

    public String getSessionStartTime()        { return sessionStartTime; }
    public void   setSessionStartTime(String v){ this.sessionStartTime = v; }

    public String getSessionEndTime()          { return sessionEndTime; }
    public void   setSessionEndTime(String v)  { this.sessionEndTime = v; }

    public double getDuration()         { return duration; }
    public void   setDuration(double v) { this.duration = v; }

    public String getStatus()          { return status; }
    public void   setStatus(String v)  { this.status = v; }

    public String getAttendanceStatus()         { return attendanceStatus; }
    public void   setAttendanceStatus(String v) { this.attendanceStatus = v; }

    public String getRoomName()          { return roomName; }
    public void   setRoomName(String v)  { this.roomName = v; }

    public int  getCurrentSurahNumber()       { return currentSurahNumber; }
    public void setCurrentSurahNumber(int v)  { this.currentSurahNumber = v; }

    public int  getCurrentAyahNumber()        { return currentAyahNumber; }
    public void setCurrentAyahNumber(int v)   { this.currentAyahNumber = v; }

    public int  getCurrentAyahEnd()           { return currentAyahEnd; }
    public void setCurrentAyahEnd(int v)      { this.currentAyahEnd = v; }

    public QuranReference getCurrentQuranReference()                   { return currentQuranReference; }
    public void           setCurrentQuranReference(QuranReference ref) { this.currentQuranReference = ref; }
}
