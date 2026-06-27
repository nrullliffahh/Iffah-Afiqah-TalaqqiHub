package dao;

import model.StudentBooking;
import model.TalaqqiSession;
import util.BookingPartitionUtil;
import util.DBConnection;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

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

    /** Minutes after teacher starts before a joining student is marked Late. */
    public static final int LATE_THRESHOLD_MINUTES = 5;
    /** Seconds after teacher starts before marking Late (> 5 minutes). */
    private static final long LATE_THRESHOLD_SECONDS = LATE_THRESHOLD_MINUTES * 60L;
    private static final ConcurrentHashMap<String, Long> LIVE_SESSION_START_EPOCH = new ConcurrentHashMap<>();

    private static final String ACTIVE_SESSION_FILTER =
        "  AND cb.bookingStatus NOT IN ('Cancelled', 'Rescheduled', 'Completed', 'Rejected') " +
        "  AND cs.classStatus NOT IN ('Cancelled') ";

    // ── Common SELECT: modern (bookingId FK) vs legacy production (scheduleId FK) ──
    private static final String MODERN_BASE_SELECT =
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

    /** Production Aiven dump: talaqqisession.scheduleId → classschedule, not bookingId. */
    private static final String LEGACY_BASE_SELECT =
        "SELECT ts.sessionId, ts.sessionType, ts.sessionDate AS tsDate, " +
        "NULL AS sessionStartTime, NULL AS sessionDuration, " +
        "cb.bookingId, cb.studentId, cs.scheduleId, cb.bookingStatus, " +
        "cs.teacherId, cs.className, cs.startTime, cs.endTime, cs.duration, " +
        "cs.classSurah, cs.classAyah, NULL AS classAyahEnd, " +
        "s.studentName, t.teacherName AS teacherName " +
        "FROM talaqqisession ts " +
        "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId " +
        "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId " +
        "  AND cb.bookingStatus NOT IN ('Cancelled','Rejected','Completed','Rescheduled') " +
        "LEFT JOIN student s ON cb.studentId = s.studentId " +
        "LEFT JOIN teacher t ON cs.teacherId = t.teacherId ";

    private static boolean usesBookingIdLink(Connection conn) {
        return util.TalaqqiSchemaUtil.usesBookingIdLink(conn);
    }

    private static String baseSelect(Connection conn) {
        return util.TalaqqiSchemaUtil.sessionBaseSelect(conn);
    }

    /** Join fragment: talaqqisession ↔ classbooking (alias ts, cb already in query). */
    static String joinSessionToBooking(Connection conn) {
        return util.TalaqqiSchemaUtil.joinSessionToBooking(conn);
    }

    /** Predicate for inline JOIN/WHERE (both sides already aliased ts, cb). */
    private static String sessionBookingLinkPredicate(Connection conn) {
        return usesBookingIdLink(conn) ? "ts.bookingId = cb.bookingId" : "ts.scheduleId = cb.scheduleId";
    }

    private static boolean hasSessionTimingColumns(Connection conn) {
        return util.TalaqqiSchemaUtil.hasSessionTimingColumns(conn);
    }

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
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return;
            }
            boolean modern = usesBookingIdLink(conn);
            String missingSql = modern
                ? "SELECT cb.bookingId, cs.scheduleDate, cb.scheduleId "
                    + "FROM classbooking cb "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "WHERE cs.teacherId = ? "
                    + "  AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " "
                    + "  AND NOT EXISTS (SELECT 1 FROM talaqqisession ts2 WHERE "
                    + "    (ts2.bookingId IS NOT NULL AND ts2.bookingId <> '' AND ts2.bookingId = cb.bookingId) "
                    + "    OR ((ts2.bookingId IS NULL OR ts2.bookingId = '') AND ts2.scheduleId = cb.scheduleId)) "
                    + "ORDER BY cs.scheduleDate ASC, cb.bookingTime ASC, cb.bookingId ASC"
                : "SELECT cb.scheduleId, cs.scheduleDate "
                    + "FROM classbooking cb "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "WHERE cs.teacherId = ? "
                    + "  AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " "
                    + "  AND NOT EXISTS (SELECT 1 FROM talaqqisession ts2 WHERE ts2.scheduleId = cb.scheduleId) "
                    + "ORDER BY cs.scheduleDate ASC, cb.bookingTime ASC, cb.bookingId ASC";
            String insertSql = modern
                ? "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, bookingId) VALUES (?, 'Live Talaqqi', ?, ?)"
                : "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, scheduleId) VALUES (?, 'Live Talaqqi', ?, ?)";

            conn.setAutoCommit(false);
            try (PreparedStatement missingPs = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(missingSql, conn))) {
                missingPs.setString(1, teacherId);
                try (ResultSet rs = missingPs.executeQuery()) {
                    while (rs.next()) {
                        java.sql.Date sessionDate = rs.getDate("scheduleDate");
                        String linkValue = modern ? rs.getString("bookingId") : rs.getString("scheduleId");
                        insertSessionRow(conn, insertSql, sessionDate, linkValue);
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

    private void insertSessionRow(Connection conn, String insertSql, java.sql.Date sessionDate, String linkValue)
            throws SQLException {
        boolean inserted = false;
        for (int attempt = 0; !inserted && attempt < 3; attempt++) {
            String sessionId = generateNextSessionId(conn);
            try (PreparedStatement insertPs = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(insertSql, conn))) {
                insertPs.setString(1, sessionId);
                insertPs.setDate(2, sessionDate);
                insertPs.setString(3, linkValue);
                inserted = insertPs.executeUpdate() > 0;
            } catch (SQLIntegrityConstraintViolationException duplicateKey) {
                inserted = false;
            }
        }
    }

    private String generateNextSessionId(Connection conn) throws SQLException {
        String sql =
            "SELECT sessionId FROM talaqqisession " +
            "WHERE sessionId REGEXP '^S[0-9]+$' " +
            "ORDER BY CAST(SUBSTRING(sessionId, 2) AS UNSIGNED) DESC LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        ensureTalaqqiSessionsExist(teacherId);
        return querySingleSession(
            "WHERE cs.teacherId  = ? " +
            "  AND ts.sessionDate >= CURDATE() " +
            ACTIVE_SESSION_FILTER +
            "ORDER BY ts.sessionDate ASC, cs.startTime ASC " +
            "LIMIT 1",
            teacherId);
    }

    private void ensureTalaqqiSessionsExistForStudent(String studentId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return;
            }
            boolean modern = usesBookingIdLink(conn);
            String missingSql = modern
                ? "SELECT cb.bookingId, cs.scheduleDate, cb.scheduleId "
                    + "FROM classbooking cb "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "WHERE cb.studentId = ? "
                    + "  AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " "
                    + "  AND NOT EXISTS (SELECT 1 FROM talaqqisession ts2 WHERE "
                    + "    (ts2.bookingId IS NOT NULL AND ts2.bookingId <> '' AND ts2.bookingId = cb.bookingId) "
                    + "    OR ((ts2.bookingId IS NULL OR ts2.bookingId = '') AND ts2.scheduleId = cb.scheduleId)) "
                    + "ORDER BY cs.scheduleDate ASC, cb.bookingTime ASC, cb.bookingId ASC"
                : "SELECT cb.scheduleId, cs.scheduleDate "
                    + "FROM classbooking cb "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "WHERE cb.studentId = ? "
                    + "  AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " "
                    + "  AND NOT EXISTS (SELECT 1 FROM talaqqisession ts2 WHERE ts2.scheduleId = cb.scheduleId) "
                    + "ORDER BY cs.scheduleDate ASC, cb.bookingTime ASC, cb.bookingId ASC";
            String insertSql = modern
                ? "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, bookingId) VALUES (?, 'Live Talaqqi', ?, ?)"
                : "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, scheduleId) VALUES (?, 'Live Talaqqi', ?, ?)";

            conn.setAutoCommit(false);
            try (PreparedStatement missingPs = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(missingSql, conn))) {
                missingPs.setString(1, studentId);
                try (ResultSet rs = missingPs.executeQuery()) {
                    while (rs.next()) {
                        java.sql.Date sessionDate = rs.getDate("scheduleDate");
                        String linkValue = modern ? rs.getString("bookingId") : rs.getString("scheduleId");
                        insertSessionRow(conn, insertSql, sessionDate, linkValue);
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
        ensureTalaqqiSessionsExistForStudent(studentId);
        return querySingleSession(
            "WHERE cb.studentId  = ? " +
            "  AND ts.sessionDate >= CURDATE() " +
            ACTIVE_SESSION_FILTER +
            "ORDER BY ts.sessionDate ASC, cs.startTime ASC " +
            "LIMIT 1",
            studentId);
    }

    /**
     * Returns a list of switchable sessions for the student (Upcoming + Rescheduled only).
     */
    public List<TalaqqiSession> getUpcomingSessionsListForStudent(String studentId, int limit) {
        return getSwitchableSessionsList(studentId, false, limit);
    }

    /**
     * Returns a list of switchable sessions for the teacher (Upcoming + Rescheduled only).
     */
    public List<TalaqqiSession> getUpcomingSessionsList(String teacherId, int limit) {
        return getSwitchableSessionsList(teacherId, true, limit);
    }

    /**
     * Session picker: only bookings in Upcoming or Rescheduled partitions (same as class booking UI).
     */
    private List<TalaqqiSession> getSwitchableSessionsList(String userId, boolean forTeacher, int limit) {
        List<TalaqqiSession> sessions = new ArrayList<>();
        if (userId == null || userId.trim().isEmpty()) {
            return sessions;
        }

        if (forTeacher) {
            ensureTalaqqiSessionsExist(userId);
        } else {
            ensureTalaqqiSessionsExistForStudent(userId);
        }

        StudentBookingDAO bookingDAO = new StudentBookingDAO();
        List<StudentBooking> bookings = forTeacher
            ? bookingDAO.getTeacherBookings(userId)
            : bookingDAO.getMyBookingsByMonth(userId);
        BookingPartitionUtil.Partition partitioned = BookingPartitionUtil.partition(bookings);

        List<StudentBooking> switchable = new ArrayList<>();
        switchable.addAll(partitioned.upcoming);
        switchable.addAll(partitioned.rescheduled);

        switchable.sort(Comparator
            .comparing(StudentBooking::getBookingDate, Comparator.nullsLast(Comparator.naturalOrder()))
            .thenComparing(b -> b.getBookingTime() != null ? b.getBookingTime() : LocalTime.MIN));

        for (StudentBooking booking : switchable) {
            ensureSessionForBooking(booking);
            TalaqqiSession session = resolveSessionForBooking(
                booking,
                forTeacher ? userId : null,
                forTeacher ? null : userId);
            if (session != null) {
                sessions.add(session);
                if (limit > 0 && sessions.size() >= limit) {
                    break;
                }
            }
        }
        return sessions;
    }

    private TalaqqiSession resolveSessionForBooking(
            StudentBooking booking, String teacherId, String studentId) {
        if (booking == null) {
            return null;
        }
        TalaqqiSession session = null;
        if (booking.getBookingId() != null && !booking.getBookingId().trim().isEmpty()) {
            session = querySessionByBookingId(booking.getBookingId(), teacherId, studentId);
        }
        if (session == null && booking.getScheduleId() != null && !booking.getScheduleId().trim().isEmpty()) {
            session = querySessionByScheduleId(booking.getScheduleId(), teacherId, studentId);
        }
        return session;
    }

    private void ensureSessionForBooking(StudentBooking booking) {
        if (booking == null) {
            return;
        }
        String bookingId = booking.getBookingId();
        String scheduleId = booking.getScheduleId();
        if ((bookingId == null || bookingId.trim().isEmpty())
                && (scheduleId == null || scheduleId.trim().isEmpty())) {
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return;
            }
            boolean modern = usesBookingIdLink(conn);
            if (sessionExistsForBooking(conn, modern, bookingId, scheduleId)) {
                return;
            }

            java.sql.Date sessionDate = booking.getBookingDate() != null
                ? java.sql.Date.valueOf(booking.getBookingDate())
                : null;
            if (sessionDate == null && scheduleId != null) {
                sessionDate = loadScheduleDate(conn, scheduleId);
            }
            if (sessionDate == null) {
                return;
            }

            String insertSql = modern
                ? "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, bookingId) VALUES (?, 'Live Talaqqi', ?, ?)"
                : "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, scheduleId) VALUES (?, 'Live Talaqqi', ?, ?)";
            String linkValue = modern ? bookingId : scheduleId;
            if (linkValue == null || linkValue.trim().isEmpty()) {
                return;
            }
            insertSessionRow(conn, insertSql, sessionDate, linkValue.trim());
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] ensureSessionForBooking: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    private static boolean sessionExistsForBooking(
            Connection conn, boolean modern, String bookingId, String scheduleId) throws SQLException {
        if (modern && bookingId != null && !bookingId.trim().isEmpty()) {
            String sql = "SELECT 1 FROM talaqqisession WHERE bookingId = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn))) {
                ps.setString(1, bookingId.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return true;
                    }
                }
            }
        }
        if (scheduleId != null && !scheduleId.trim().isEmpty()) {
            String sql = "SELECT 1 FROM talaqqisession WHERE scheduleId = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn))) {
                ps.setString(1, scheduleId.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        }
        return false;
    }

    private static java.sql.Date loadScheduleDate(Connection conn, String scheduleId) throws SQLException {
        String sql = "SELECT scheduleDate FROM classschedule WHERE scheduleId = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDate("scheduleDate");
                }
            }
        }
        return null;
    }

    private TalaqqiSession querySessionByScheduleId(String scheduleId, String teacherId, String studentId) {
        if (scheduleId == null || scheduleId.trim().isEmpty()) {
            return null;
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return null;
            }
            StringBuilder where = new StringBuilder("WHERE cs.scheduleId = ? ");
            if (teacherId != null && !teacherId.isEmpty()) {
                where.append("AND cs.teacherId = ? ");
            }
            if (studentId != null && !studentId.isEmpty()) {
                where.append("AND cb.studentId = ? ");
            }
            where.append("LIMIT 1");
            String sql = baseSelect(conn) + where;
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            int idx = 1;
            ps.setString(idx++, scheduleId.trim());
            if (teacherId != null && !teacherId.isEmpty()) {
                ps.setString(idx++, teacherId);
            }
            if (studentId != null && !studentId.isEmpty()) {
                ps.setString(idx, studentId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] querySessionByScheduleId: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
    }

    private TalaqqiSession querySessionByBookingId(String bookingId, String teacherId, String studentId) {
        if (bookingId == null || bookingId.trim().isEmpty()) {
            return null;
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return null;
            }
            StringBuilder where = new StringBuilder("WHERE cb.bookingId = ? ");
            if (teacherId != null && !teacherId.isEmpty()) {
                where.append("AND cs.teacherId = ? ");
            }
            if (studentId != null && !studentId.isEmpty()) {
                where.append("AND cb.studentId = ? ");
            }
            where.append("LIMIT 1");
            String sql = baseSelect(conn) + where;
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            int idx = 1;
            ps.setString(idx++, bookingId.trim());
            if (teacherId != null && !teacherId.isEmpty()) {
                ps.setString(idx++, teacherId);
            }
            if (studentId != null && !studentId.isEmpty()) {
                ps.setString(idx, studentId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] querySessionByBookingId: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
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
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            String sql = baseSelect(conn) +
                "WHERE ts.sessionId = ? " +
                (scoped ? "AND cs.teacherId = ? " : "") +
                "LIMIT 1";
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        Connection conn = null;
        PreparedStatement ps = null;
        boolean classScheduleUpdated = false;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String sessionTable = util.TalaqqiSchemaUtil.sessionTable(conn);
            String sessionLink = util.TalaqqiSchemaUtil.sessionToBookingOnClause("ts", conn);
            String sql = usesBookingIdLink(conn)
                ? "UPDATE classschedule cs "
                    + "JOIN classbooking cb ON cs.scheduleId = cb.scheduleId "
                    + "JOIN " + sessionTable + " ts ON " + sessionLink + " "
                    + "SET cs.classSurah = ?, cs.classAyah = ?, cs.classAyahEnd = ? "
                    + "WHERE ts.sessionId = ? AND cs.teacherId = ?"
                : util.TalaqqiSchemaUtil.hasClassAyahEnd(conn)
                    ? "UPDATE classschedule cs "
                        + "JOIN talaqqisession ts ON ts.scheduleId = cs.scheduleId "
                        + "SET cs.classSurah = ?, cs.classAyah = ?, cs.classAyahEnd = ? "
                        + "WHERE ts.sessionId = ? AND cs.teacherId = ?"
                    : "UPDATE classschedule cs "
                        + "JOIN talaqqisession ts ON ts.scheduleId = cs.scheduleId "
                        + "SET cs.classSurah = ?, cs.classAyah = ? "
                        + "WHERE ts.sessionId = ? AND cs.teacherId = ?";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setInt(1, surahNumber);
            ps.setInt(2, ayahStart);
            if (usesBookingIdLink(conn) || util.TalaqqiSchemaUtil.hasClassAyahEnd(conn)) {
                if (ayahEnd > 0) {
                    ps.setInt(3, ayahEnd);
                } else {
                    ps.setNull(3, java.sql.Types.INTEGER);
                }
                ps.setString(4, sessionId);
                ps.setString(5, teacherId);
            } else {
                ps.setString(3, sessionId);
                ps.setString(4, teacherId);
            }
            classScheduleUpdated = ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] updateQuranReference: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }

        if (!classScheduleUpdated) {
            classScheduleUpdated = updateQuranOnScheduleFallback(sessionId, teacherId, surahNumber, ayahStart, ayahEnd);
        }

        // Save to qurandisplay (start ayah only — end range lives on classschedule.classAyahEnd)
        boolean savedDisplay = saveQuranDisplay(sessionId, surahNumber, ayahStart);

        return classScheduleUpdated || savedDisplay;
    }

    /** Fallback when booking-linked UPDATE matches no row (legacy/hybrid session rows). */
    private boolean updateQuranOnScheduleFallback(String sessionId, String teacherId,
            int surahNumber, int ayahStart, int ayahEnd) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return false;
            }
            String sessionTable = util.TalaqqiSchemaUtil.sessionTable(conn);
            String sql = util.TalaqqiSchemaUtil.hasClassAyahEnd(conn)
                ? "UPDATE classschedule cs "
                    + "JOIN " + sessionTable + " ts ON ts.scheduleId = cs.scheduleId "
                    + "SET cs.classSurah = ?, cs.classAyah = ?, cs.classAyahEnd = ? "
                    + "WHERE ts.sessionId = ? AND cs.teacherId = ?"
                : "UPDATE classschedule cs "
                    + "JOIN " + sessionTable + " ts ON ts.scheduleId = cs.scheduleId "
                    + "SET cs.classSurah = ?, cs.classAyah = ? "
                    + "WHERE ts.sessionId = ? AND cs.teacherId = ?";
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setInt(1, surahNumber);
            ps.setInt(2, ayahStart);
            if (util.TalaqqiSchemaUtil.hasClassAyahEnd(conn)) {
                if (ayahEnd > 0) {
                    ps.setInt(3, ayahEnd);
                } else {
                    ps.setNull(3, java.sql.Types.INTEGER);
                }
                ps.setString(4, sessionId);
                ps.setString(5, teacherId);
            } else {
                ps.setString(3, sessionId);
                ps.setString(4, teacherId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] updateQuranOnScheduleFallback: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    private static void applyResolvedQuranReference(TalaqqiSession ts,
            int dbSurah, int dbAyah, int dbAyahEnd,
            int displaySurah, int displayAyah, int displayJuzuk) {
        int resolvedSurah = dbSurah > 0 ? dbSurah : displaySurah;
        int resolvedAyah = dbAyah > 0 ? dbAyah : displayAyah;

        ts.setCurrentSurahNumber(resolvedSurah > 0 ? resolvedSurah : 2);
        ts.setCurrentAyahNumber(resolvedAyah > 0 ? resolvedAyah : 1);
        if (dbAyahEnd > 0) {
            ts.setCurrentAyahEnd(dbAyahEnd);
        } else {
            ts.setCurrentAyahEnd(0);
        }
        ts.setCurrentJuzukNumber(displayJuzuk > 0 ? displayJuzuk : 0);

        TalaqqiSession.QuranReference qRef = new TalaqqiSession.QuranReference(
                ts.getCurrentSurahNumber(), ts.getCurrentAyahNumber());
        ts.setCurrentQuranReference(qRef);
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
            
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(checkSql, conn));
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
            
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            
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
            
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            rs = ps.executeQuery();
            
            int nextNum = 1;
            if (rs.next()) {
                Object maxObj = rs.getObject("maxNum");
                if (maxObj != null) {
                    int maxNum = rs.getInt("maxNum");
                    nextNum = maxNum + 1;
                }
            }
            
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
        LIVE_SESSION_START_EPOCH.put(sessionId, System.currentTimeMillis());
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            if (!hasSessionTimingColumns(conn)) {
                return true;
            }
            String sql = "UPDATE talaqqisession SET sessionStartTime = COALESCE(sessionStartTime, NOW()) WHERE sessionId = ?";
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        java.sql.Timestamp sessionStartTime = null;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            if (hasSessionTimingColumns(conn)) {
                String fetchSql = "SELECT ts.sessionStartTime FROM talaqqisession ts WHERE ts.sessionId = ?";
                ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(fetchSql, conn));
                ps.setString(1, sessionId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    sessionStartTime = rs.getTimestamp("sessionStartTime");
                }
                closeQuietly(rs, ps, null);
                rs = null;
                ps = null;
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] completeSession (fetch startTime): " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
            conn = null;
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
                
                ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(durationSql, conn));
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
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String updateSql;
            String absentExclusion = absentBookingExclusionClause();
            if (usesBookingIdLink(conn) && hasSessionTimingColumns(conn)) {
                updateSql =
                    "UPDATE classbooking cb "
                    + joinSessionToBooking(conn)
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "SET cb.bookingStatus = 'Completed', "
                    + "    ts.sessionDate = CURDATE(), "
                    + "    ts.sessionStartTime = IF(ts.sessionStartTime IS NULL, NOW(), ts.sessionStartTime), "
                    + "    ts.sessionDuration = ? "
                    + "WHERE ts.sessionId = ? AND cs.teacherId = ? "
                    + absentExclusion;
            } else if (usesBookingIdLink(conn)) {
                updateSql =
                    "UPDATE classbooking cb "
                    + joinSessionToBooking(conn)
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "SET cb.bookingStatus = 'Completed', ts.sessionDate = CURDATE() "
                    + "WHERE ts.sessionId = ? AND cs.teacherId = ? "
                    + absentExclusion;
            } else {
                updateSql =
                    "UPDATE classbooking cb "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "JOIN talaqqisession ts ON ts.scheduleId = cs.scheduleId "
                    + "SET cb.bookingStatus = 'Completed', ts.sessionDate = CURDATE() "
                    + "WHERE ts.sessionId = ? AND cs.teacherId = ? "
                    + absentExclusion;
            }

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(updateSql, conn));
            int param = 1;
            if (usesBookingIdLink(conn) && hasSessionTimingColumns(conn)) {
                ps.setDouble(param++, durationMinutes);
            }
            ps.setString(param++, sessionId);
            ps.setString(param, teacherId);
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated <= 0) {
                rowsUpdated = completeSessionFallback(conn, sessionId, teacherId, durationMinutes);
            }

            if (rowsUpdated > 0) {
                backfillSessionBookingId(conn, sessionId);
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

    /** Fallback when the primary completeSession UPDATE matches zero rows (hybrid schema). */
    private int completeSessionFallback(Connection conn, String sessionId, String teacherId, double durationMinutes)
            throws SQLException {
        String sessionTable = util.TalaqqiSchemaUtil.sessionTable(conn);
        String linkClause =
            "((ts.bookingId IS NOT NULL AND ts.bookingId <> '' AND ts.bookingId = cb.bookingId) "
            + "OR ((ts.bookingId IS NULL OR ts.bookingId = '') AND ts.scheduleId = cb.scheduleId))";

        String updateSql;
        String absentExclusion = absentBookingExclusionClause();
        if (hasSessionTimingColumns(conn)) {
            updateSql =
                "UPDATE classbooking cb "
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                + "JOIN " + sessionTable + " ts ON ts.sessionId = ? "
                + "SET cb.bookingStatus = 'Completed', "
                + "    ts.sessionDate = CURDATE(), "
                + "    ts.sessionStartTime = IF(ts.sessionStartTime IS NULL, NOW(), ts.sessionStartTime), "
                + "    ts.sessionDuration = ? "
                + "WHERE cs.teacherId = ? AND " + linkClause + " " + absentExclusion;
        } else {
            updateSql =
                "UPDATE classbooking cb "
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                + "JOIN " + sessionTable + " ts ON ts.sessionId = ? "
                + "SET cb.bookingStatus = 'Completed', ts.sessionDate = CURDATE() "
                + "WHERE cs.teacherId = ? AND " + linkClause + " " + absentExclusion;
        }

        try (PreparedStatement ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(updateSql, conn))) {
            int param = 1;
            ps.setString(param++, sessionId);
            if (hasSessionTimingColumns(conn)) {
                ps.setDouble(param++, durationMinutes);
            }
            ps.setString(param, teacherId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[TalaqqiSessionDAO] completeSessionFallback: sessionId=" + sessionId
                    + ", rows=" + rows);
            }
            return rows;
        }
    }

    /** Skip absent students when marking bookings completed after session end. */
    private static String absentBookingExclusionClause() {
        return "AND NOT EXISTS ("
            + "  SELECT 1 FROM attendance a "
            + "  WHERE a.studentId = cb.studentId AND a.scheduleId = cb.scheduleId "
            + "    AND a.attendanceStatus = 'Absent'"
            + "    AND (a.attendanceDate = cb.bookingDate OR a.attendanceDate = CURDATE())"
            + ")";
    }

    /** Link legacy session rows to their bookingId for future joins. */
    private void backfillSessionBookingId(Connection conn, String sessionId) {
        String sessionTable = util.TalaqqiSchemaUtil.sessionTable(conn);
        if (!util.TalaqqiSchemaUtil.hasColumn(conn, sessionTable, "bookingId")) {
            return;
        }
        String sql =
            "UPDATE " + sessionTable + " ts "
            + "JOIN classbooking cb ON cb.scheduleId = ts.scheduleId "
            + "SET ts.bookingId = cb.bookingId "
            + "WHERE ts.sessionId = ? "
            + "  AND (ts.bookingId IS NULL OR ts.bookingId = '') "
            + "  AND cb.bookingStatus = 'Completed' "
            + "LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn))) {
            ps.setString(1, sessionId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] backfillSessionBookingId: " + e.getMessage());
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
        String scheduleId = getScheduleIdBySessionId(sessionId);
        if (scheduleId == null) {
            System.err.println("[TalaqqiSessionDAO] recordAttendance: scheduleId not found for sessionId=" + sessionId);
            return false;
        }

        java.sql.Date sessionDate = getSessionDateBySessionId(sessionId);
        if (sessionDate == null) {
            sessionDate = java.sql.Date.valueOf(LocalDate.now());
        }

        ensureAttendanceUniqueIndex();

        String attendanceId = "AT" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        String upsertSql =
            "INSERT INTO attendance (attendanceId, attendanceDate, attendanceStatus, joinTime, " +
            "  markAutoAttendance, studentId, teacherId, scheduleId) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
            "ON DUPLICATE KEY UPDATE " +
            "  attendanceStatus   = CASE " +
            "    WHEN attendanceStatus = 'Late' OR VALUES(attendanceStatus) = 'Late' THEN 'Late' " +
            "    WHEN attendanceStatus = 'Present' OR VALUES(attendanceStatus) = 'Present' THEN 'Present' " +
            "    ELSE VALUES(attendanceStatus) END, " +
            "  joinTime           = COALESCE(VALUES(joinTime), joinTime), " +
            "  markAutoAttendance = VALUES(markAutoAttendance)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(upsertSql, conn));
            ps.setString(1, attendanceId);
            ps.setDate(2, sessionDate);
            ps.setString(3, status);
            ps.setTime(4, joinTime);
            ps.setBoolean(5, markAutoAttendance);
            ps.setString(6, studentId);
            ps.setString(7, teacherId);
            ps.setString(8, scheduleId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] recordAttendance failed: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    /**
     * Removes duplicate attendance rows and adds a unique key so one student
     * can only have one record per schedule per day.
     */
    private void ensureAttendanceUniqueIndex() {
        Connection conn = null;
        Statement st = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;
            st = conn.createStatement();
            try {
                st.executeUpdate(
                    "DELETE a FROM attendance a " +
                    "INNER JOIN (" +
                    "  SELECT studentId, scheduleId, attendanceDate, MIN(attendanceId) AS keepId " +
                    "  FROM attendance " +
                    "  GROUP BY studentId, scheduleId, attendanceDate " +
                    "  HAVING COUNT(*) > 1" +
                    ") d ON a.studentId = d.studentId " +
                    "   AND a.scheduleId = d.scheduleId " +
                    "   AND a.attendanceDate = d.attendanceDate " +
                    "   AND a.attendanceId <> d.keepId");
            } catch (SQLException ignored) {}
            try {
                st.execute(
                    "ALTER TABLE attendance " +
                    "ADD UNIQUE KEY uq_att_student_schedule_date (studentId, scheduleId, attendanceDate)");
            } catch (SQLException ignored) {}
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] ensureAttendanceUniqueIndex: " + e.getMessage());
        } finally {
            if (st != null) {
                try { st.close(); } catch (SQLException ignored) {}
            }
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Sets leaveTime on attendance row(s) for a student in this session.
     * Uses the talaqqisession → booking chain so attendanceDate mismatches do not block updates.
     */
    public boolean updateLeaveTime(String sessionId, String studentId, Time leaveTime) {
        if (sessionId == null || sessionId.isEmpty() || leaveTime == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String sql =
                "UPDATE attendance a "
                + "JOIN classbooking cb ON cb.scheduleId = a.scheduleId AND cb.studentId = a.studentId "
                + joinSessionToBooking(conn)
                + "SET a.leaveTime = ? "
                + "WHERE ts.sessionId = ? "
                + "  AND a.joinTime IS NOT NULL "
                + "  AND (a.leaveTime IS NULL)";

            if (studentId != null && !studentId.isEmpty()) {
                sql += " AND a.studentId = ?";
            }

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setTime(1, leaveTime);
            ps.setString(2, sessionId);
            if (studentId != null && !studentId.isEmpty()) {
                ps.setString(3, studentId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] updateLeaveTime: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    /**
     * Sets leaveTime for every student who joined this session (teacher end session).
     */
    public int updateLeaveTimesForSession(String sessionId, Time leaveTime) {
        if (sessionId == null || sessionId.isEmpty() || leaveTime == null) {
            return 0;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            String sql =
                "UPDATE attendance a "
                + "JOIN classbooking cb ON cb.scheduleId = a.scheduleId AND cb.studentId = a.studentId "
                + joinSessionToBooking(conn)
                + "SET a.leaveTime = ? "
                + "WHERE ts.sessionId = ? "
                + "  AND a.joinTime IS NOT NULL "
                + "  AND a.leaveTime IS NULL";
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setTime(1, leaveTime);
            ps.setString(2, sessionId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] updateLeaveTimesForSession: " + e.getMessage());
            return 0;
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
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql = usesBookingIdLink(conn)
                ? "SELECT cb.scheduleId FROM talaqqisession ts "
                    + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                    + "WHERE ts.sessionId = ? LIMIT 1"
                : "SELECT scheduleId FROM talaqqisession WHERE sessionId = ? LIMIT 1";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
     * Runs a schema-aware SELECT with a single String WHERE parameter
     * and maps the first result row to a TalaqqiSession.
     */
    private TalaqqiSession querySingleSession(String whereSuffix, String param) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            String sql = baseSelect(conn) + whereSuffix;
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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

        // ── Quran reference: classschedule (teacher Apply) is source of truth; qurandisplay is fallback ─
        int dbSurah    = rs.getInt("classSurah");
        int dbAyah     = rs.getInt("classAyah");
        int dbAyahEnd  = 0;
        try { dbAyahEnd = rs.getInt("classAyahEnd"); } catch (SQLException ignored) {}

        int displaySurah = 0;
        int displayAyah = 0;
        int displayJuzuk = 0;
        try {
            Object surahObj = rs.getObject("displaySurah");
            if (surahObj instanceof Number) {
                displaySurah = ((Number) surahObj).intValue();
            }
        } catch (SQLException ignored) {}
        try {
            Object ayahObj = rs.getObject("displayAyah");
            if (ayahObj instanceof Number) {
                displayAyah = ((Number) ayahObj).intValue();
            }
        } catch (SQLException ignored) {}
        try {
            Object juzObj = rs.getObject("displayJuzuk");
            if (juzObj instanceof Number) {
                displayJuzuk = ((Number) juzObj).intValue();
            }
        } catch (SQLException ignored) {}

        applyResolvedQuranReference(ts, dbSurah, dbAyah, dbAyahEnd, displaySurah, displayAyah, displayJuzuk);

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

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return sessions;

            String sql = "SELECT ts.sessionId, s.studentName, t.teacherName, cs.className, "
                + "       cs.scheduleDate, cs.startTime, cs.endTime, cs.duration, "
                + "       qd.currentSurah, qd.currentAyah, qd.currentJuzuk, "
                + "       CASE WHEN ts.sessionDate IS NOT NULL THEN 'Completed' ELSE 'Upcoming' END as status, "
                + "       'Present' as attendanceStatus, "
                + "       ts.sessionDate as completedAt "
                + util.TalaqqiSchemaUtil.adminSessionFromJoin(conn)
                + "LEFT JOIN qurandisplay qd ON ts.sessionId = qd.sessionId "
                + "LEFT JOIN student s ON cb.studentId = s.studentId "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
                + "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql = "SELECT ts.sessionId, s.studentName, t.teacherName, cs.className, "
                + "       cs.scheduleDate, cs.startTime, cs.endTime, cs.duration, "
                + "       qd.currentSurah, qd.currentAyah, qd.currentJuzuk, "
                + "       cs.classAyahEnd, "
                + "       CASE WHEN ts.sessionDate IS NOT NULL THEN 'Completed' ELSE 'Upcoming' END as status, "
                + "       'Present' as attendanceStatus, "
                + "       ts.sessionDate as completedAt "
                + util.TalaqqiSchemaUtil.adminSessionFromJoin(conn)
                + "LEFT JOIN qurandisplay qd ON ts.sessionId = qd.sessionId "
                + "LEFT JOIN student s ON cb.studentId = s.studentId "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
                + "WHERE ts.sessionId = ?";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return teachers;

            String join = usesBookingIdLink(conn)
                ? "INNER JOIN talaqqisession ts ON cb.bookingId = ts.bookingId "
                : "INNER JOIN talaqqisession ts ON cb.scheduleId = ts.scheduleId ";

            String sql = "SELECT DISTINCT t.teacherName FROM teacher t "
                + "INNER JOIN classschedule cs ON t.teacherId = cs.teacherId "
                + "INNER JOIN classbooking cb ON cs.scheduleId = cb.scheduleId "
                + join
                + "WHERE t.teacherName IS NOT NULL "
                + "ORDER BY t.teacherName ASC";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            String join = usesBookingIdLink(conn)
                ? "INNER JOIN talaqqisession ts ON cb.bookingId = ts.bookingId"
                : "INNER JOIN talaqqisession ts ON cb.scheduleId = ts.scheduleId";

            String sql = "SELECT COUNT(DISTINCT t.teacherId) as total FROM teacher t "
                + "INNER JOIN classschedule cs ON t.teacherId = cs.teacherId "
                + "INNER JOIN classbooking cb ON cs.scheduleId = cb.scheduleId "
                + " " + join;

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            String join = usesBookingIdLink(conn)
                ? "INNER JOIN talaqqisession ts ON cb.bookingId = ts.bookingId"
                : "INNER JOIN talaqqisession ts ON cb.scheduleId = ts.scheduleId";

            String sql = "SELECT COUNT(DISTINCT cb.studentId) as total FROM student s "
                + "INNER JOIN classbooking cb ON s.studentId = cb.studentId "
                + " " + join;

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
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
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            String findMissingStudentsSql = usesBookingIdLink(conn)
                ? "SELECT DISTINCT cb.studentId, cb.scheduleId, cs.teacherId, cb.bookingDate "
                    + "FROM talaqqisession ts "
                    + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "WHERE ts.sessionId = ? "
                    + "  AND cs.teacherId = ? "
                    + "  AND cb.bookingStatus NOT IN ('Cancelled', 'Completed', 'Rescheduled') "
                    + "  AND NOT EXISTS ("
                    + "      SELECT 1 FROM attendance a "
                    + "      WHERE a.scheduleId = cb.scheduleId "
                    + "        AND a.studentId = cb.studentId "
                    + "        AND a.attendanceDate = cb.bookingDate "
                    + "        AND a.attendanceStatus IN ('Present', 'Late')"
                    + "  )"
                : "SELECT DISTINCT cb.studentId, cb.scheduleId, cs.teacherId, cb.bookingDate "
                    + "FROM talaqqisession ts "
                    + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
                    + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId "
                    + "  AND cb.bookingStatus NOT IN ('Cancelled', 'Completed', 'Rescheduled') "
                    + "WHERE ts.sessionId = ? "
                    + "  AND cs.teacherId = ? "
                    + "  AND cb.studentId IS NOT NULL "
                    + "  AND NOT EXISTS ("
                    + "      SELECT 1 FROM attendance a "
                    + "      WHERE a.scheduleId = cb.scheduleId "
                    + "        AND a.studentId = cb.studentId "
                    + "        AND a.attendanceDate = cb.bookingDate "
                    + "        AND a.attendanceStatus IN ('Present', 'Late')"
                    + "  )";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(findMissingStudentsSql, conn));
            ps.setString(1, sessionId);
            ps.setString(2, teacherId);
            rs = ps.executeQuery();

            conn.setAutoCommit(false);

            while (rs.next()) {
                String studentId = rs.getString("studentId");
                String scheduleId = rs.getString("scheduleId");
                java.sql.Date bookingDate = rs.getDate("bookingDate");
                if (bookingDate == null) {
                    bookingDate = java.sql.Date.valueOf(LocalDate.now());
                }

                // Record ABSENT on the booking date so student portal can match it
                String attendanceId = "AT" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();

                String insertAbsentSql =
                    "INSERT INTO attendance (attendanceId, attendanceDate, attendanceStatus, " +
                    "  studentId, teacherId, scheduleId, markAutoAttendance) " +
                    "VALUES (?, ?, 'Absent', ?, ?, ?, true)";

                try (PreparedStatement insertPs = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(insertAbsentSql, conn))) {
                    insertPs.setString(1, attendanceId);
                    insertPs.setDate(2, bookingDate);
                    insertPs.setString(3, studentId);
                    insertPs.setString(4, teacherId);
                    insertPs.setString(5, scheduleId);
                    if (insertPs.executeUpdate() > 0) {
                        markedCount++;
                    }
                } catch (SQLException ignored) {}
            }

            conn.commit();

            if (markedCount == 0) {
                TalaqqiSession session = getSessionBySessionId(sessionId, teacherId);
                if (session != null && session.getStudentId() != null) {
                    String scheduleId = getScheduleIdBySessionId(sessionId);
                    if (scheduleId != null
                            && recordAttendance(sessionId, session.getStudentId(), teacherId, "Absent", null, true)) {
                        markedCount = 1;
                    }
                }
            }

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
     * Present if student joins within 5 minutes of teacher starting the live session.
     */
    public String determineAttendanceStatus(String sessionId, String studentId, Time joinTime) {
        if (joinTime == null) {
            joinTime = new Time(System.currentTimeMillis());
        }
        LocalDateTime sessionStart = resolveLiveSessionStart(sessionId);
        if (sessionStart == null) {
            System.out.println("[TalaqqiSessionDAO] determineAttendanceStatus: no start time for " + sessionId);
            return "Present";
        }

        LocalDateTime studentJoin = LocalDateTime.of(sessionStart.toLocalDate(), joinTime.toLocalTime());
        long secondsLate = Duration.between(sessionStart, studentJoin).getSeconds();

        if (secondsLate <= 0) {
            return "Present";
        }
        if (secondsLate > LATE_THRESHOLD_SECONDS) {
            System.out.println("[TalaqqiSessionDAO] Student " + studentId
                    + " joined " + (secondsLate / 60) + " min after teacher start — Late");
            return "Late";
        }
        System.out.println("[TalaqqiSessionDAO] Student " + studentId
                + " joined within 5 min of teacher start — Present");
        return "Present";
    }

    public void clearLiveSessionStart(String sessionId) {
        if (sessionId != null) {
            LIVE_SESSION_START_EPOCH.remove(sessionId);
        }
    }

    private LocalDateTime resolveLiveSessionStart(String sessionId) {
        LocalDateTime fromDb = getSessionStartDateTime(sessionId);
        if (fromDb != null) {
            return fromDb;
        }
        Long epoch = LIVE_SESSION_START_EPOCH.get(sessionId);
        if (epoch != null) {
            return LocalDateTime.ofInstant(
                java.time.Instant.ofEpochMilli(epoch), java.time.ZoneId.systemDefault());
        }
        return getScheduledStartDateTime(sessionId);
    }

    private LocalDateTime getScheduledStartDateTime(String sessionId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql = usesBookingIdLink(conn)
                ? "SELECT COALESCE(ts.sessionDate, cs.scheduleDate) AS sessionDate, cs.startTime "
                    + "FROM talaqqisession ts "
                    + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                    + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                    + "WHERE ts.sessionId = ? LIMIT 1"
                : "SELECT COALESCE(ts.sessionDate, cs.scheduleDate) AS sessionDate, cs.startTime "
                    + "FROM talaqqisession ts "
                    + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
                    + "WHERE ts.sessionId = ? LIMIT 1";

            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            if (!rs.next()) return null;

            java.sql.Date sessionDate = rs.getDate("sessionDate");
            Time startTime = rs.getTime("startTime");
            if (sessionDate == null || startTime == null) return null;
            return LocalDateTime.of(sessionDate.toLocalDate(), startTime.toLocalTime());
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getScheduledStartDateTime: " + e.getMessage());
            return null;
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    /**
     * Actual live-session start (when teacher clicked Join). Used for duration only.
     */
    private LocalDateTime getSessionStartDateTime(String sessionId) {
        String sql = "SELECT ts.sessionDate, ts.sessionStartTime FROM talaqqisession ts WHERE ts.sessionId = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            if (!rs.next()) return null;

            java.sql.Date sessionDate = rs.getDate("sessionDate");
            java.sql.Timestamp startTs = rs.getTimestamp("sessionStartTime");
            if (startTs != null) {
                return startTs.toLocalDateTime();
            }
            Time startTime = rs.getTime("sessionStartTime");
            if (sessionDate == null || startTime == null) return null;

            LocalDate date = sessionDate.toLocalDate();
            LocalTime time = startTime.toLocalTime();
            return LocalDateTime.of(date, time);
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getSessionStartDateTime: " + e.getMessage());
            return null;
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    private java.sql.Date getSessionDateBySessionId(String sessionId) {
        String sql = "SELECT sessionDate FROM talaqqisession WHERE sessionId = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            ps = conn.prepareStatement(util.TalaqqiSchemaUtil.sql(sql, conn));
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDate("sessionDate");
            }
        } catch (SQLException e) {
            System.err.println("[TalaqqiSessionDAO] getSessionDateBySessionId: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
    }
}
