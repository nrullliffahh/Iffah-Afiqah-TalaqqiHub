package dao;

import model.TalaqqiSession;
import util.DBConnection;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * TalaqqiSessionDAO
 *
 * Provides all database operations for the Talaqqi Session feature.
 *
 * Database join chain (every query starts here):
 *   talaqqisession  → classbooking  (ON ts.bookingId  = cb.bookingId)
 *   classbooking    → classschedule (ON cb.scheduleId = cs.scheduleId)
 *   classbooking    → student       (ON cb.studentId  = s.studentId)
 *   classschedule   → teacher       (ON cs.teacherId  = t.teacherId)
 *
 * talaqqisession schema : sessionId (PK), sessionType, sessionDate, bookingId (FK)
 * classbooking schema   : bookingId (PK), bookingDate, bookingTime, bookingStatus,
 *                         studentId (FK), scheduleId (FK)
 * classschedule schema  : scheduleId (PK), teacherId, studentId, className,
 *                         scheduleDate, startTime, endTime, duration,
 *                         classStatus, classJuzuk, classSurah, classAyah
 */
public class TalaqqiSessionDAO {

    // ── Common SELECT columns shared by every query ──────────────────────────
    private static final String BASE_SELECT =
        "SELECT ts.sessionId, ts.sessionType, ts.sessionDate AS tsDate, ts.sessionStartTime, ts.sessionDuration, " +
        "       ts.bookingId, " +
        "       cb.studentId, cb.scheduleId, cb.bookingStatus, " +
        "       cs.teacherId, cs.className, cs.startTime, cs.endTime, cs.duration, " +
        "       cs.classSurah, cs.classAyah, cs.classAyahEnd, " +
        "       s.studentName, " +
        "       t.teacherName AS teacherName " +
        "FROM talaqqisession ts " +
        "JOIN classbooking cb ON ts.bookingId  = cb.bookingId " +
        "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
        "LEFT JOIN student  s ON cb.studentId  = s.studentId " +
        "LEFT JOIN teacher  t ON cs.teacherId  = t.teacherId ";

    // ══════════════════════════════════════════════════════════════════════════
    //  AUTO-PROVISION
    //  Creates talaqqisession rows for any upcoming booking that doesn't
    //  have one yet.  Call this before every read operation so the table
    //  stays in sync with classbooking.
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Ensures a talaqqisession row exists for every upcoming classbooking
     * belonging to the given teacher.
     */
    private void ensureTalaqqiSessionsExist(String teacherId) {
        String missingSql =
            "SELECT cb.bookingId, cs.scheduleDate " +
            "FROM classbooking cb " +
            "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
            "WHERE cs.teacherId = ? " +
            "  AND cb.bookingStatus = 'Upcoming' " +
            "  AND NOT EXISTS (" +
            "      SELECT 1 FROM talaqqisession ts2 WHERE ts2.bookingId = cb.bookingId" +
            "  ) " +
            "ORDER BY cs.scheduleDate ASC, cb.bookingTime ASC, cb.bookingId ASC";

        String insertSql =
            "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, bookingId) VALUES (?, 'Live Talaqqi', ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;

            conn.setAutoCommit(false);

            try (PreparedStatement missingPs = conn.prepareStatement(missingSql)) {
                missingPs.setString(1, teacherId);

                try (ResultSet rs = missingPs.executeQuery()) {
                    while (rs.next()) {
                        String bookingId = rs.getString("bookingId");
                        java.sql.Date sessionDate = rs.getDate("scheduleDate");

                        boolean inserted = false;
                        int attempts = 0;
                        while (!inserted && attempts < 3) {
                            attempts++;
                            String sessionId = generateNextSessionId(conn);
                            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                                insertPs.setString(1, sessionId);
                                insertPs.setDate(2, sessionDate);
                                insertPs.setString(3, bookingId);
                                inserted = insertPs.executeUpdate() > 0;
                            } catch (SQLIntegrityConstraintViolationException duplicateKey) {
                                inserted = false;
                            }
                        }
                    }
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {}
            }
            System.err.println("[TalaqqiSessionDAO] ensureTalaqqiSessionsExist: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    private String generateNextSessionId(Connection conn) throws SQLException {
        String sql =
            "SELECT sessionId FROM talaqqisession " +
            "WHERE sessionId REGEXP '^S[0-9]+$' " +
            "ORDER BY CAST(SUBSTRING(sessionId, 2) AS UNSIGNED) DESC LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String latest = rs.getString(1);
                int current = 0;
                if (latest != null && latest.length() > 1) {
                    try {
                        current = Integer.parseInt(latest.substring(1));
                    } catch (NumberFormatException ignored) {
                        current = 0;
                    }
                }
                int next = current + 1;
                String format = next <= 999 ? "%03d" : "%06d";
                return "S" + String.format(format, next);
            }
        }
        return "S001";
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  READ OPERATIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Returns the single best upcoming session for the given teacher.
     * Filters: ts.sessionDate >= TODAY, scoped to teacherId.
     * Order:   earliest sessionDate + startTime first.
     *
     * @param teacherId  Teacher primary key (e.g. "T-001")
     * @return populated TalaqqiSession, or {@code null} if none found
     */
    public TalaqqiSession getUpcomingSessionForTeacher(String teacherId) {
        // Step 1: Auto-create any missing talaqqisession rows for this teacher
        ensureTalaqqiSessionsExist(teacherId);

        String sql = BASE_SELECT +
            "WHERE cs.teacherId  = ? " +
            "  AND ts.sessionDate >= CURDATE() " +
            "ORDER BY ts.sessionDate ASC, cs.startTime ASC " +
            "LIMIT 1";

        return querySingleSession(sql, teacherId);
    }

    /**
     * Ensures talaqqisession rows exist for all upcoming bookings of the given student.
     * Called before student queries to guarantee session data is available.
     *
     * @param studentId  Student primary key (e.g. "STU-001")
     */
    private void ensureTalaqqiSessionsExistForStudent(String studentId) {
        String missingSql =
            "SELECT cb.bookingId, cs.scheduleDate " +
            "FROM classbooking cb " +
            "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
            "WHERE cb.studentId = ? " +
            "  AND cb.bookingStatus = 'Upcoming' " +
            "  AND NOT EXISTS (" +
            "      SELECT 1 FROM talaqqisession ts2 WHERE ts2.bookingId = cb.bookingId" +
            "  ) " +
            "ORDER BY cs.scheduleDate ASC, cb.bookingTime ASC, cb.bookingId ASC";

        String insertSql =
            "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, bookingId) VALUES (?, 'Live Talaqqi', ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;

            conn.setAutoCommit(false);

            try (PreparedStatement missingPs = conn.prepareStatement(missingSql)) {
                missingPs.setString(1, studentId);

                try (ResultSet rs = missingPs.executeQuery()) {
                    while (rs.next()) {
                        String bookingId = rs.getString("bookingId");
                        java.sql.Date sessionDate = rs.getDate("scheduleDate");

                        boolean inserted = false;
                        int attempts = 0;
                        while (!inserted && attempts < 3) {
                            attempts++;
                            String sessionId = generateNextSessionId(conn);
                            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                                insertPs.setString(1, sessionId);
                                insertPs.setDate(2, sessionDate);
                                insertPs.setString(3, bookingId);
                                inserted = insertPs.executeUpdate() > 0;
                            } catch (SQLIntegrityConstraintViolationException duplicateKey) {
                                inserted = false;
                            }
                        }
                    }
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {}
            }
            System.err.println("[TalaqqiSessionDAO] ensureTalaqqiSessionsExistForStudent: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Returns the single best upcoming session for the given student.
     * Filters: ts.sessionDate >= TODAY, scoped to studentId.
     * Order:   earliest sessionDate + startTime first.
     *
     * @param studentId  Student primary key (e.g. "STU-001")
     * @return populated TalaqqiSession, or {@code null} if none found
     */
    public TalaqqiSession getUpcomingSessionForStudent(String studentId) {
        // Step 1: Auto-create any missing talaqqisession rows for this student
        ensureTalaqqiSessionsExistForStudent(studentId);

        String sql = BASE_SELECT +
            "WHERE cb.studentId  = ? " +
            "  AND ts.sessionDate >= CURDATE() " +
            "ORDER BY ts.sessionDate ASC, cs.startTime ASC " +
            "LIMIT 1";

        return querySingleSession(sql, studentId);
    }

    /**
     * Returns a list of upcoming sessions for the student (used by the
     * session picker or history view in student UI).
     *
     * @param studentId  Student primary key
     * @param limit      Maximum number of sessions to return
     */
    public List<TalaqqiSession> getUpcomingSessionsListForStudent(String studentId, int limit) {
        // Step 1: Auto-create any missing talaqqisession rows for this student
        ensureTalaqqiSessionsExistForStudent(studentId);

        List<TalaqqiSession> list = new ArrayList<>();
        String sql = BASE_SELECT +
            "WHERE cb.studentId  = ? " +
            "  AND ts.sessionDate >= CURDATE() " +
            "ORDER BY ts.sessionDate ASC, cs.startTime ASC " +
            "LIMIT ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return list;
            ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setInt(2, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getUpcomingSessionsListForStudent: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return list;
    }

    /**
     * Returns the TalaqqiSession for a specific talaqqisession.sessionId,
     * scoped to a teacher.
     *
     * @param sessionId  talaqqisession primary key (e.g. "TSB003")
     * @param teacherId  authenticated teacher's ID
     */
    public TalaqqiSession getSessionBySessionId(String sessionId, String teacherId) {
        boolean scoped = (teacherId != null && !teacherId.isEmpty());
        String sql = BASE_SELECT +
            "WHERE ts.sessionId = ? " +
            (scoped ? "AND cs.teacherId = ? " : "") +
            "LIMIT 1";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            if (scoped) ps.setString(2, teacherId);
            rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getSessionBySessionId: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
    }

    /**
     * Returns a list of upcoming sessions for the teacher (used by the
     * session-picker dropdown in the UI).
     *
     * @param teacherId  Teacher primary key
     * @param limit      Maximum number of sessions to return
     */
    public List<TalaqqiSession> getUpcomingSessionsList(String teacherId, int limit) {
        // Step 1: Auto-create any missing talaqqisession rows for this teacher
        ensureTalaqqiSessionsExist(teacherId);

        List<TalaqqiSession> list = new ArrayList<>();
        String sql = BASE_SELECT +
            "WHERE cs.teacherId  = ? " +
            "  AND ts.sessionDate >= CURDATE() " +
            "ORDER BY ts.sessionDate ASC, cs.startTime ASC " +
            "LIMIT ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return list;
            ps = conn.prepareStatement(sql);
            ps.setString(1, teacherId);
            ps.setInt(2, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getUpcomingSessionsList: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return list;
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  WRITE OPERATIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Updates the Quran reference (classSurah, classAyah, classAyahEnd) in classschedule.
     * Resolves the classschedule row through the talaqqisession → classbooking chain.
     *
     * @param sessionId   talaqqisession primary key
     * @param teacherId   owning teacher (scope guard)
     * @param surahNumber 1–114
     * @param ayahStart   first ayah of the range (≥ 1)
     * @param ayahEnd     last ayah of the range (≥ ayahStart); 0 means single-ayah
     * @return true if the row was updated
     */
    public boolean updateQuranReference(String sessionId, String teacherId,
                                        int surahNumber, int ayahStart, int ayahEnd) {
        // First, update classschedule (for backward compatibility)
        String sql =
            "UPDATE classschedule cs " +
            "JOIN classbooking cb   ON cs.scheduleId = cb.scheduleId " +
            "JOIN talaqqisession ts ON ts.bookingId  = cb.bookingId " +
            "SET cs.classSurah = ?, cs.classAyah = ?, cs.classAyahEnd = ? " +
            "WHERE ts.sessionId = ? AND cs.teacherId = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        boolean classScheduleUpdated = false;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            ps = conn.prepareStatement(sql);
            ps.setInt(1, surahNumber);
            ps.setInt(2, ayahStart);
            if (ayahEnd > 0) ps.setInt(3, ayahEnd); else ps.setNull(3, java.sql.Types.INTEGER);
            ps.setString(4, sessionId);
            ps.setString(5, teacherId);
            classScheduleUpdated = ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] updateQuranReference: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }

        // Then, save to qurandisplay table (primary storage for display data)
        boolean quranDisplaySaved = saveQuranDisplay(sessionId, surahNumber, ayahStart);
        
        return classScheduleUpdated && quranDisplaySaved;
    }

    /**
     * Save or update Quran display data to the qurandisplay table.
     * This is where the teacher's Quran control during sessions is stored.
     * DisplayIds are sequential: Q001, Q002, Q003, etc.
     */
    public boolean saveQuranDisplay(String sessionId, int surah, int ayah) {
        // Check if qurandisplay record already exists for this session
        String checkSql = "SELECT displayId FROM qurandisplay WHERE sessionId = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String existingDisplayId = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            
            ps = conn.prepareStatement(checkSql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                existingDisplayId = rs.getString("displayId");
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] saveQuranDisplay check: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(rs, ps, conn);
        }

        // If record exists, update it; otherwise, insert new record with sequential displayId
        String sql;
        if (existingDisplayId != null) {
            // UPDATE existing record
            sql = "UPDATE qurandisplay SET currentSurah = ?, currentAyah = ? WHERE sessionId = ?";
        } else {
            // INSERT new record with sequential displayId (Q001, Q002, Q003, etc.)
            sql = "INSERT INTO qurandisplay (displayId, currentSurah, currentAyah, currentJuzuk, sessionId) " +
                  "VALUES (?, ?, ?, 1, ?)";
        }

        conn = null;
        ps = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            
            ps = conn.prepareStatement(sql);
            
            if (existingDisplayId != null) {
                // UPDATE case
                ps.setInt(1, surah);
                ps.setInt(2, ayah);
                ps.setString(3, sessionId);
            } else {
                // INSERT case - generate sequential displayId (Q001, Q002, etc.)
                String displayId = generateNextDisplayId();
                ps.setString(1, displayId);
                ps.setInt(2, surah);
                ps.setInt(3, ayah);
                ps.setString(4, sessionId);
            }
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] saveQuranDisplay: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    /**
     * Generate the next sequential displayId (Q001, Q002, Q003, etc.)
     * Queries the database for the highest existing displayId and increments it.
     */
    private String generateNextDisplayId() {
        String sql = "SELECT MAX(CAST(SUBSTRING(displayId, 2) AS UNSIGNED)) as maxNum FROM qurandisplay";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return "Q001";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            int nextNum = 1;
            if (rs.next()) {
                Object maxObj = rs.getObject("maxNum");
                if (maxObj != null) {
                    int maxNum = rs.getInt("maxNum");
                    nextNum = maxNum + 1;
                }
            }
            
            // Format as Q001, Q002, Q003, etc.
            return String.format("Q%03d", nextNum);
            
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] generateNextDisplayId: " + e.getMessage());
            return "Q001";
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    /** Backward-compatible overload – single ayah, no end range. */
    public boolean updateQuranReference(String sessionId, String teacherId,
                                        int surahNumber, int ayahNumber) {
        return updateQuranReference(sessionId, teacherId, surahNumber, ayahNumber, 0);
    }

    /**
     * Marks the classbooking row as 'Completed' when a session ends.
     * Scope-guarded via the classschedule teacherId.
     *
     * @param sessionId  talaqqisession primary key
     * @param teacherId  owning teacher
     * @return true on success
     */
    /**
     * Records the session start time when teacher initiates the session.
     * @param sessionId The session ID
     * @return true on success
     */
    public boolean recordSessionStartTime(String sessionId) {
        String sql = "UPDATE talaqqisession SET sessionStartTime = NOW() WHERE sessionId = ?";
        
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] recordSessionStartTime: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    /**
     * Completes a session and calculates the actual duration in fractional minutes.
     * Ensures both sessionStartTime and sessionDuration are saved.
     * Duration is calculated in seconds and divided by 60.0 for decimal precision.
     * Example: 1 min 20 sec = 80 seconds ÷ 60 = 1.33 minutes
     * 
     * @param sessionId The session ID
     * @param teacherId The teacher ID (for permission check)
     * @return true on success
     */
    public boolean completeSession(String sessionId, String teacherId) {
        // Step 1: Fetch session details - check if sessionStartTime exists
        String fetchSql = "SELECT ts.sessionStartTime FROM talaqqisession ts WHERE ts.sessionId = ?";
        java.sql.Timestamp sessionStartTime = null;
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            
            ps = conn.prepareStatement(fetchSql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                sessionStartTime = rs.getTimestamp("sessionStartTime");
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] completeSession (fetch startTime): " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        // Step 2: Close session and calculate duration in fractional minutes
        // If sessionStartTime was not recorded, use a safe default
        double durationMinutes = 0.0;
        
        if (sessionStartTime != null) {
            // Calculate actual duration from recorded start time
            // Use SECOND precision and divide by 60.0 for decimal minutes
            String durationSql = 
                "SELECT TIMESTAMPDIFF(SECOND, ?, NOW()) / 60.0 as durationMins";
            
            try {
                conn = DBConnection.getConnection();
                if (conn == null) return false;
                
                ps = conn.prepareStatement(durationSql);
                ps.setTimestamp(1, sessionStartTime);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    durationMinutes = rs.getDouble("durationMins");
                    if (durationMinutes < 0) durationMinutes = 0.0;
                }
            } catch (SQLException e) {
                System.err.println("[TalaqqiSessionDAO] completeSession (calculate duration): " + e.getMessage());
            } finally {
                closeQuietly(rs, ps, conn);
            }
        }
        
        // Step 3: Update session with completion date and duration
        // If sessionStartTime is NULL, set it to NOW() - sessionDuration*60 seconds
        String updateSql =
            "UPDATE classbooking cb " +
            "JOIN talaqqisession ts ON ts.bookingId  = cb.bookingId " +
            "JOIN classschedule cs  ON cb.scheduleId = cs.scheduleId " +
            "SET cb.bookingStatus = 'Completed', " +
            "    ts.sessionDate = CURDATE(), " +
            "    ts.sessionStartTime = IF(ts.sessionStartTime IS NULL, NOW(), ts.sessionStartTime), " +
            "    ts.sessionDuration = ? " +
            "WHERE ts.sessionId = ? AND cs.teacherId = ?";

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            
            ps = conn.prepareStatement(updateSql);
            ps.setDouble(1, durationMinutes);
            ps.setString(2, sessionId);
            ps.setString(3, teacherId);
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0) {
                System.out.println("[TalaqqiSessionDAO] completeSession: sessionId=" + sessionId + 
                    ", startTime=" + (sessionStartTime != null ? sessionStartTime : "NOW()") + 
                    ", duration=" + durationMinutes + " minutes (with fractional precision)");
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] completeSession (update): " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    /**
     * Records (or updates) an attendance row for the session.
     * Resolves the scheduleId from talaqqisession → classbooking internally.
     *
     * @param sessionId           talaqqisession primary key
     * @param studentId           student primary key
     * @param teacherId           teacher primary key
     * @param status              "Present" | "Absent" | "Late"
     * @param joinTime            time student joined (nullable)
     * @param markAutoAttendance  true if recorded automatically by Jitsi event
     * @return true on success
     */
    public boolean recordAttendance(String sessionId, String studentId,
                                    String teacherId, String status,
                                    Time joinTime, boolean markAutoAttendance) {
        // Step 1: Resolve scheduleId from talaqqisession chain
        String scheduleId = getScheduleIdBySessionId(sessionId);
        if (scheduleId == null) {
            System.err.println("[TalaqqiSessionDAO] recordAttendance: scheduleId not found for sessionId=" + sessionId);
            return false;
        }

        // Step 2: Generate attendance ID (AT + 8 random hex chars)
        String attendanceId = "AT" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        java.sql.Date today = java.sql.Date.valueOf(LocalDate.now());

        // Step 3: Try upsert (requires UNIQUE key on studentId+scheduleId+attendanceDate)
        String upsertSql =
            "INSERT INTO attendance (attendanceId, attendanceDate, attendanceStatus, " +
            "  joinTime, markAutoAttendance, studentId, teacherId, scheduleId) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
            "ON DUPLICATE KEY UPDATE " +
            "  attendanceStatus     = VALUES(attendanceStatus), " +
            "  joinTime             = VALUES(joinTime), " +
            "  markAutoAttendance   = VALUES(markAutoAttendance)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            ps = conn.prepareStatement(upsertSql);
            ps.setString(1, attendanceId);
            ps.setDate(2, today);
            ps.setString(3, status);
            ps.setTime(4, joinTime);
            ps.setBoolean(5, markAutoAttendance);
            ps.setString(6, studentId);
            ps.setString(7, teacherId);
            ps.setString(8, scheduleId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            // Fallback: plain INSERT IGNORE when no unique key exists
            System.err.println("[TalaqqiSessionDAO] recordAttendance upsert failed, trying INSERT IGNORE: " + e.getMessage());
            closeQuietly(null, ps, null);
            try {
                String insertSql =
                    "INSERT IGNORE INTO attendance " +
                    "(attendanceId, attendanceDate, attendanceStatus, joinTime, " +
                    " markAutoAttendance, studentId, teacherId, scheduleId) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, attendanceId);
                ps.setDate(2, today);
                ps.setString(3, status);
                ps.setTime(4, joinTime);
                ps.setBoolean(5, markAutoAttendance);
                ps.setString(6, studentId);
                ps.setString(7, teacherId);
                ps.setString(8, scheduleId);
                ps.executeUpdate();
                return true;
            } catch (SQLException e2) {
                System.err.println("[TalaqqiSessionDAO] recordAttendance INSERT IGNORE failed: " + e2.getMessage());
                return false;
            }
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    /**
     * Sets the leaveTime on an existing attendance row (called when session ends).
     * Resolves scheduleId from talaqqisession chain internally.
     *
     * @param sessionId  talaqqisession primary key
     * @param studentId  student primary key
     * @param leaveTime  time the student left
     */
    public boolean updateLeaveTime(String sessionId, String studentId, Time leaveTime) {
        // Resolve scheduleId through the chain
        String scheduleId = getScheduleIdBySessionId(sessionId);
        if (scheduleId == null) return false;

        String sql =
            "UPDATE attendance SET leaveTime = ? " +
            "WHERE scheduleId = ? AND studentId = ? " +
            "  AND attendanceDate = CURDATE()";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            ps = conn.prepareStatement(sql);
            ps.setTime(1, leaveTime);
            ps.setString(2, scheduleId);
            ps.setString(3, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] updateLeaveTime: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Private helpers
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Resolves the classschedule.scheduleId that corresponds to a given
     * talaqqisession.sessionId.  Returns null if not found.
     */
    private String getScheduleIdBySessionId(String sessionId) {
        String sql =
            "SELECT cb.scheduleId " +
            "FROM talaqqisession ts " +
            "JOIN classbooking cb ON ts.bookingId = cb.bookingId " +
            "WHERE ts.sessionId = ? LIMIT 1";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            return rs.next() ? rs.getString("scheduleId") : null;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getScheduleIdBySessionId: " + e.getMessage());
            return null;
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    /**
     * Runs the supplied BASE_SELECT SQL with a single String WHERE parameter
     * and maps the first result row to a TalaqqiSession.
     */
    private TalaqqiSession querySingleSession(String sql, String param) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            ps = conn.prepareStatement(sql);
            ps.setString(1, param);
            rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] querySingleSession: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
    }

    /**
     * Maps a ResultSet row (using the BASE_SELECT column aliases) to a
     * fully populated TalaqqiSession object.
     */
    private TalaqqiSession mapRow(ResultSet rs) throws SQLException {
        TalaqqiSession ts = new TalaqqiSession();

        // ── talaqqisession columns ────────────────────────────────────────────
        ts.setSessionId(rs.getString("sessionId"));
        ts.setSessionType(rs.getString("sessionType"));
        ts.setBookingId(rs.getString("bookingId"));

        // ── classbooking + classschedule columns ──────────────────────────────
        ts.setScheduleId(rs.getString("scheduleId"));
        ts.setTeacherId(rs.getString("teacherId"));
        ts.setStudentId(rs.getString("studentId"));
        ts.setClassName(rs.getString("className"));
        
        // ── Duration: ONLY use recorded sessionDuration if session has been completed ──
        // Fresh sessions will have recordedSessionDuration = 0, so timer will start from 00:00
        // Completed sessions will have recordedSessionDuration > 0, so timer will display actual duration
        // Now supports fractional precision (double) for accurate timing
        double recordedSessionDuration = 0.0;
        try {
            recordedSessionDuration = rs.getDouble("sessionDuration");  // from talaqqisession (now DOUBLE type)
        } catch (SQLException ignored) {}
        
        // Set duration with fractional precision (0.0 if not recorded yet)
        ts.setDuration(recordedSessionDuration);

        // ── Participant names ─────────────────────────────────────────────────
        String sName = rs.getString("studentName");
        ts.setStudentName(sName != null ? sName : "Unknown Student");

        String tName = rs.getString("teacherName");
        ts.setTeacherName(tName != null ? tName : "Teacher");

        // ── Date / time formatting ────────────────────────────────────────────
        java.sql.Date sessionDate = rs.getDate("tsDate");   // from talaqqisession
        java.sql.Time startTime   = rs.getTime("startTime");
        java.sql.Time endTime     = rs.getTime("endTime");

        SimpleDateFormat dateFmt = new SimpleDateFormat("EEEE, MMMM d, yyyy");
        SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

        ts.setSessionDate(sessionDate != null ? dateFmt.format(sessionDate) : "TBD");
        ts.setSessionStartTime(startTime != null ? timeFmt.format(startTime) : "--:--");
        ts.setSessionEndTime(endTime     != null ? timeFmt.format(endTime)   : "--:--");

        // ── Quran reference from classschedule (classSurah / classAyah / classAyahEnd) ─
        // Defaults: Surah 2 (Al-Baqarah), Ayah 1 if database values are not set
        int dbSurah    = rs.getInt("classSurah");
        int dbAyah     = rs.getInt("classAyah");
        int dbAyahEnd  = 0;
        try { dbAyahEnd = rs.getInt("classAyahEnd"); } catch (SQLException ignored) {}
        
        // Set defaults if database values are zero or null
        ts.setCurrentSurahNumber(dbSurah > 0 ? dbSurah : 2);      // Default: Surah 2 (Al-Baqarah)
        ts.setCurrentAyahNumber(dbAyah > 0 ? dbAyah : 1);         // Default: Ayah 1
        if (dbAyahEnd > 0) ts.setCurrentAyahEnd(dbAyahEnd);

        TalaqqiSession.QuranReference qRef = new TalaqqiSession.QuranReference(
                ts.getCurrentSurahNumber(), ts.getCurrentAyahNumber());
        ts.setCurrentQuranReference(qRef);

        // ── Generate Jitsi room name from sessionId ───────────────────────────
        ts.setRoomName(ts.generateRoomName());

        return ts;
    }

    /** Silently closes JDBC resources to prevent connection leaks. */
    private void closeQuietly(ResultSet rs, PreparedStatement ps, Connection conn) {
        try { if (rs   != null) rs.close();   } catch (SQLException ignored) {}
        try { if (ps   != null) ps.close();   } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }

    /**
     * Fetch all completed Talaqqi sessions for admin dashboard.
     * Used by AdminTalaqqiSessionServlet for displaying session list.
     */
    public List<java.util.Map<String, Object>> getAllSessions() {
        List<java.util.Map<String, Object>> sessions = new ArrayList<>();
        
        String sql = "SELECT ts.sessionId, s.studentName, t.teacherName, cs.className, " +
                     "       cs.scheduleDate, cs.startTime, cs.endTime, cs.duration, " +
                     "       qd.currentSurah, qd.currentAyah, qd.currentJuzuk, " +
                     "       CASE WHEN ts.sessionDate IS NOT NULL THEN 'Completed' ELSE 'Upcoming' END as status, " +
                     "       'Present' as attendanceStatus, " +
                     "       ts.sessionDate as completedAt " +
                     "FROM talaqqisession ts " +
                     "JOIN classbooking cb ON ts.bookingId = cb.bookingId " +
                     "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                     "LEFT JOIN qurandisplay qd ON ts.sessionId = qd.sessionId " +
                     "LEFT JOIN student s ON cb.studentId = s.studentId " +
                     "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                     "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                java.util.Map<String, Object> session = new java.util.HashMap<>();
                session.put("sessionId", rs.getString("sessionId"));
                session.put("studentName", rs.getString("studentName"));
                session.put("teacherName", rs.getString("teacherName"));
                session.put("classType", rs.getString("className"));
                session.put("sessionDate", rs.getDate("scheduleDate"));
                session.put("timeStart", rs.getString("startTime"));
                session.put("timeEnd", rs.getString("endTime"));
                session.put("duration", rs.getInt("duration"));
                
                // Quran data from qurandisplay table
                Object surahObj = rs.getObject("currentSurah");
                Object ayahObj = rs.getObject("currentAyah");
                Object juzukObj = rs.getObject("currentJuzuk");
                
                int surahNum = surahObj != null ? (Integer) surahObj : 0;
                int ayahNum = ayahObj != null ? (Integer) ayahObj : 0;
                int juzukNum = juzukObj != null ? (Integer) juzukObj : 0;
                
                session.put("surahNumber", surahNum);
                session.put("ayahNumber", ayahNum);
                session.put("juzukNumber", juzukNum);
                session.put("surahName", getSurahName(surahNum));
                
                session.put("status", rs.getString("status"));
                session.put("attendanceStatus", rs.getString("attendanceStatus"));
                session.put("completedAt", rs.getTimestamp("completedAt"));
                
                sessions.add(session);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        return sessions;
    }

    /**
     * Fetch a single Talaqqi session by ID for modal detail view.
     */
    public java.util.Map<String, Object> getSessionById(String sessionId) {
        String sql = "SELECT ts.sessionId, s.studentName, t.teacherName, cs.className, " +
                     "       cs.scheduleDate, cs.startTime, cs.endTime, cs.duration, " +
                     "       qd.currentSurah, qd.currentAyah, qd.currentJuzuk, " +
                     "       cs.classAyahEnd, " +
                     "       CASE WHEN ts.sessionDate IS NOT NULL THEN 'Completed' ELSE 'Upcoming' END as status, " +
                     "       'Present' as attendanceStatus, " +
                     "       ts.sessionDate as completedAt " +
                     "FROM talaqqisession ts " +
                     "JOIN classbooking cb ON ts.bookingId = cb.bookingId " +
                     "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                     "LEFT JOIN qurandisplay qd ON ts.sessionId = qd.sessionId " +
                     "LEFT JOIN student s ON cb.studentId = s.studentId " +
                     "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                     "WHERE ts.sessionId = ?";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                java.util.Map<String, Object> session = new java.util.HashMap<>();
                session.put("sessionId", rs.getString("sessionId"));
                session.put("studentName", rs.getString("studentName"));
                session.put("teacherName", rs.getString("teacherName"));
                session.put("classType", rs.getString("className"));
                session.put("sessionDate", rs.getDate("scheduleDate"));
                session.put("timeStart", rs.getString("startTime"));
                session.put("timeEnd", rs.getString("endTime"));
                session.put("duration", rs.getInt("duration"));
                
                // Quran data from qurandisplay table
                Object surahObj = rs.getObject("currentSurah");
                Object ayahObj = rs.getObject("currentAyah");
                Object juzukObj = rs.getObject("currentJuzuk");
                Object ayahEndObj = rs.getObject("classAyahEnd");
                
                int surahNum = surahObj != null ? (Integer) surahObj : 0;
                int ayahNum = ayahObj != null ? (Integer) ayahObj : 0;
                int juzukNum = juzukObj != null ? (Integer) juzukObj : 0;
                int ayahEndNum = ayahEndObj != null ? (Integer) ayahEndObj : 0;
                
                session.put("surahNumber", surahNum);
                session.put("ayahNumber", ayahNum);
                session.put("ayahEndNumber", ayahEndNum);
                session.put("juzukNumber", juzukNum);
                session.put("surahName", getSurahName(surahNum));
                
                session.put("status", rs.getString("status"));
                session.put("attendanceStatus", rs.getString("attendanceStatus"));
                session.put("completedAt", rs.getTimestamp("completedAt"));
                
                return session;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        return null;
    }

    /**
     * Fetch all unique teacher names from completed sessions.
     * Used for filter dropdown in admin dashboard.
     */
    public List<String> getAllTeachers() {
        List<String> teachers = new ArrayList<>();
        
        String sql = "SELECT DISTINCT t.teacherName FROM teacher t " +
                     "INNER JOIN classschedule cs ON t.teacherId = cs.teacherId " +
                     "INNER JOIN classbooking cb ON cs.scheduleId = cb.scheduleId " +
                     "INNER JOIN talaqqisession ts ON cb.bookingId = ts.bookingId " +
                     "WHERE t.teacherName IS NOT NULL " +
                     "ORDER BY t.teacherName ASC";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                String teacherName = rs.getString("teacherName");
                if (teacherName != null && !teacherName.trim().isEmpty()) {
                    teachers.add(teacherName);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        return teachers;
    }

    /**
     * Get count of completed Talaqqi sessions.
     */
    public int getCompletedSessionsCount() {
        String sql = "SELECT COUNT(*) as total FROM talaqqisession";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        return 0;
    }

    /**
     * Get count of active teachers (teachers with completed sessions).
     */
    public int getActiveTeachersCount() {
        String sql = "SELECT COUNT(DISTINCT t.teacherId) as total FROM teacher t " +
                     "INNER JOIN classschedule cs ON t.teacherId = cs.teacherId " +
                     "INNER JOIN classbooking cb ON cs.scheduleId = cb.scheduleId " +
                     "INNER JOIN talaqqisession ts ON cb.bookingId = ts.bookingId";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        return 0;
    }

    /**
     * Get count of active students (students with completed sessions).
     */
    public int getActiveStudentsCount() {
        String sql = "SELECT COUNT(DISTINCT cb.studentId) as total FROM student s " +
                     "INNER JOIN classbooking cb ON s.studentId = cb.studentId " +
                     "INNER JOIN talaqqisession ts ON cb.bookingId = ts.bookingId";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        
        return 0;
    }

    /**
     * Convert Surah number to Surah name in English
     * Surahs 1-114 of the Quran
     */
    public String getSurahName(int surahNumber) {
        String[] surahNames = {
            "", // 0 - placeholder
            "Al-Fatihah", "Al-Baqarah", "Ali Imran", "An-Nisa", "Al-Maidah",
            "Al-Anam", "Al-Araf", "Al-Anfal", "At-Taubah", "Yunus",
            "Hud", "Yusuf", "Ar-Rad", "Ibrahim", "Al-Hijr",
            "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Ta-Ha",
            "Al-Anbiya", "Al-Hajj", "Al-Muminun", "An-Nur", "Al-Furqan",
            "Ash-Shuara", "An-Naml", "Al-Qasas", "Al-Ankabut", "Ar-Rum",
            "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir",
            "Ya-Sin", "As-Saffat", "Sa-d", "Az-Zumar", "Ghafir",
            "Fussilat", "Ash-Shura", "Az-Zukhruf", "Ad-Dukhan", "Al-Jasiyah",
            "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
            "Ad-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman",
            "Al-Waqi'ah", "Al-Hadid", "Al-Mujadilah", "Al-Hashr", "Al-Mumtahanah",
            "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq",
            "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Ma'arij",
            "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah",
            "Al-Insan", "Al-Mursalat", "An-Naba", "An-Naziat", "Abasa",
            "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj",
            "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
            "Ash-Shams", "Al-Layl", "Ad-Duha", "Ash-Sharh", "At-Tin",
            "Al-Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah", "Al-Adiyat",
            "Al-Qari'ah", "At-Takathur", "Al-Asr", "Al-Humazah", "Al-Fil",
            "Quraish", "Al-Maun", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
            "Al-Lahab", "Al-Ikhlas", "Al-Falaq", "An-Nas"
        };
        
        if (surahNumber >= 1 && surahNumber <= 114) {
            return surahNames[surahNumber];
        }
        return "Unknown Surah";
    }

    /**
     * Marks all students who booked this session but did NOT join as ABSENT.
     * Called when a session ends to auto-mark no-shows.
     * 
     * Logic:
     * - Find all bookings matched to this talaqqisession
     * - For each booking WITHOUT an attendance record → create ABSENT record
     * 
     * @param sessionId   talaqqisession primary key
     * @param teacherId   teacher ownership (permission check)
     * @return number of students marked as ABSENT
     */
    public int markMissingStudentsAsAbsent(String sessionId, String teacherId) {
        int markedCount = 0;
        
        // Step 1: Get all students booked for this session who have NO attendance record
        String findMissingStudentsSql =
            "SELECT DISTINCT cb.studentId, cb.scheduleId, cs.teacherId " +
            "FROM talaqqisession ts " +
            "JOIN classbooking cb ON ts.bookingId = cb.bookingId " +
            "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
            "WHERE ts.sessionId = ? " +
            "  AND cs.teacherId = ? " +
            "  AND cb.bookingStatus IN ('Upcoming', 'Approved') " +
            "  AND NOT EXISTS (" +
            "      SELECT 1 FROM attendance a " +
            "      WHERE a.scheduleId = cb.scheduleId " +
            "        AND a.studentId = cb.studentId " +
            "        AND a.attendanceDate = CURDATE()" +
            "  )";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            ps = conn.prepareStatement(findMissingStudentsSql);
            ps.setString(1, sessionId);
            ps.setString(2, teacherId);
            rs = ps.executeQuery();

            conn.setAutoCommit(false);

            while (rs.next()) {
                String studentId = rs.getString("studentId");
                String scheduleId = rs.getString("scheduleId");

                // Record ABSENT attendance
                String attendanceId = "AT" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
                java.sql.Date today = java.sql.Date.valueOf(LocalDate.now());

                String insertAbsentSql =
                    "INSERT INTO attendance (attendanceId, attendanceDate, attendanceStatus, " +
                    "  studentId, teacherId, scheduleId, markAutoAttendance) " +
                    "VALUES (?, ?, 'Absent', ?, ?, ?, true) " +
                    "ON DUPLICATE KEY UPDATE attendanceStatus = 'Absent', " +
                    "  markAutoAttendance = true, attendanceDate = VALUES(attendanceDate)";

                try (PreparedStatement insertPs = conn.prepareStatement(insertAbsentSql)) {
                    insertPs.setString(1, attendanceId);
                    insertPs.setDate(2, today);
                    insertPs.setString(3, studentId);
                    insertPs.setString(4, teacherId);
                    insertPs.setString(5, scheduleId);
                    if (insertPs.executeUpdate() > 0) {
                        markedCount++;
                    }
                } catch (SQLException ignored) {}
            }

            conn.commit();
            System.out.println("[TalaqqiSessionDAO] Marked " + markedCount + " students as ABSENT for session " + sessionId);

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {}
            }
            System.err.println("[TalaqqiSessionDAO] markMissingStudentsAsAbsent: " + e.getMessage());
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException ignored) {}
            closeQuietly(rs, ps, conn);
        }

        return markedCount;
    }

    /**
     * Marks a student as LATE if they joined the session more than 5 minutes after it started.
     * Called when a student joins the session.
     * 
     * Logic:
     * - Get session start time from talaqqisession.sessionStartTime
     * - Calculate join time (current time)
     * - If join time > start time + 5 minutes, mark as LATE
     * Otherwise, mark as PRESENT
     * 
     * @param sessionId   talaqqisession primary key
     * @param studentId   student primary key
     * @param teacherId   teacher primary key
     * @return attendance status: "Present" or "Late"
     */
    public String determineAttendanceStatus(String sessionId, String studentId) {
        String statusSql =
            "SELECT ts.sessionStartTime " +
            "FROM talaqqisession ts " +
            "WHERE ts.sessionId = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return "Present";  // Safety default

            ps = conn.prepareStatement(statusSql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();

            if (rs.next()) {
                java.sql.Timestamp sessionStartTime = rs.getTimestamp("sessionStartTime");
                
                if (sessionStartTime != null) {
                    // Get current time
                    java.sql.Timestamp currentTime = new java.sql.Timestamp(System.currentTimeMillis());
                    
                    // Calculate difference in minutes
                    long diffMs = currentTime.getTime() - sessionStartTime.getTime();
                    long diffMinutes = diffMs / (60 * 1000);  // convert milliseconds to minutes
                    
                    // If more than 5 minutes late, mark as LATE
                    if (diffMinutes > 5) {
                        System.out.println("[TalaqqiSessionDAO] Student " + studentId + " joined " + diffMinutes + " minutes after session start - marking as LATE");
                        return "Late";
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] determineAttendanceStatus: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }

        return "Present";
    }
}
