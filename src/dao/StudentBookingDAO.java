package dao;

import model.StudentBooking;
import model.ClassSchedule;
import util.BookingStatus;
import util.DBConnection;
import util.TalaqqiSchemaUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class StudentBookingDAO {

    public Map<String, Object> getBookingSummary(String studentId) {
        Map<String, Object> summary = new HashMap<>();
        int totalSessions = resolvePackageSessionLimit(studentId);
        int usedSessions = 0;
        int bookedThisMonth = 0;

        String completedSql = "SELECT COUNT(*) as used FROM classbooking cb "
            + "WHERE cb.studentId = ? "
            + "AND MONTH(cb.bookingDate) = MONTH(CURRENT_DATE()) "
            + "AND YEAR(cb.bookingDate) = YEAR(CURRENT_DATE()) "
            + "AND cb.bookingStatus = 'Completed' "
            + "AND NOT EXISTS ("
            + "  SELECT 1 FROM attendance a "
            + "  WHERE a.studentId = cb.studentId AND a.scheduleId = cb.scheduleId "
            + "    AND a.attendanceStatus = 'Absent'"
            + "    AND (a.attendanceDate = cb.bookingDate OR a.attendanceDate = CURDATE())"
            + ")";

        String bookedSql = "SELECT COUNT(*) as booked FROM classbooking "
            + "WHERE studentId = ? "
            + "AND MONTH(bookingDate) = MONTH(CURRENT_DATE()) "
            + "AND YEAR(bookingDate) = YEAR(CURRENT_DATE()) "
            + "AND bookingStatus NOT IN ('Cancelled', 'Rejected')";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getBookingSummary: DB connection is null");
                return summary;
            }

            try (PreparedStatement ps = conn.prepareStatement(completedSql)) {
                ps.setString(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        usedSessions = rs.getInt("used");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(bookedSql)) {
                ps.setString(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        bookedThisMonth = rs.getInt("booked");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }

        int remainingSessions = Math.max(0, totalSessions - bookedThisMonth);
        double progressPercentage = totalSessions > 0 ? (usedSessions * 100.0 / totalSessions) : 0;

        summary.put("totalSessions", totalSessions);
        summary.put("usedSessions", usedSessions);
        summary.put("bookedThisMonth", bookedThisMonth);
        summary.put("remainingSessions", remainingSessions);
        summary.put("progressPercentage", String.format("%.0f", progressPercentage));

        return summary;
    }

    private int resolvePackageSessionLimit(String studentId) {
        int totalSessions = 16;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return totalSessions;
            }
            ps = conn.prepareStatement(
                "SELECT p.totalSessions FROM student s "
                + "LEFT JOIN packages p ON s.packageId = p.packageId "
                + "WHERE s.studentId = ? LIMIT 1");
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                int pkgTotal = rs.getInt("totalSessions");
                if (pkgTotal > 0) {
                    totalSessions = pkgTotal;
                }
            }
        } catch (SQLException e) {
            System.err.println("resolvePackageSessionLimit: " + e.getMessage());
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException ignored) {}
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException ignored) {}
            }
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
        return totalSessions;
    }

    public List<ClassSchedule> getAvailableSchedulesByDate(LocalDate date) {
        List<ClassSchedule> schedules = new ArrayList<>();
        // Return slots for the date that are not booked and are either explicitly Available
        // or were created by a teacher as Scheduled (teacher availability).
        String sql = "SELECT cs.scheduleId, cs.className, cs.scheduleDate, cs.startTime, cs.endTime, " +
                 "cs.duration, cs.classStatus, cs.teacherId, t.teacherName AS teacherName " +
                 "FROM classschedule cs " +
                 "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                 "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus NOT IN ('Cancelled', 'Rescheduled') " +
                     "WHERE cs.scheduleDate = ? " +
                     "AND (cb.bookingId IS NULL) " +
                     "AND (cs.classStatus = 'Available' OR (cs.teacherId IS NOT NULL AND cs.classStatus = 'Scheduled')) " +
                     "ORDER BY cs.startTime ASC";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAvailableSchedulesByDate: DB connection is null");
                return schedules;
            }

            System.out.println("[StudentBookingDAO] Executing getAvailableSchedulesByDate for date=" + date + " with SQL: " + sql);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, java.sql.Date.valueOf(date));

                try (ResultSet rs = ps.executeQuery()) {
                    int count = 0;
                    while (rs.next()) {
                        ClassSchedule schedule = new ClassSchedule();
                        schedule.setScheduleId(rs.getString("scheduleId"));
                        schedule.setClassName(rs.getString("className"));

                        if (rs.getDate("scheduleDate") != null) {
                            schedule.setScheduleDate(rs.getDate("scheduleDate").toLocalDate());
                        }
                        if (rs.getTime("startTime") != null) {
                            schedule.setStartTime(rs.getTime("startTime").toLocalTime());
                        }
                        if (rs.getTime("endTime") != null) {
                            schedule.setEndTime(rs.getTime("endTime").toLocalTime());
                        }

                        schedule.setDuration(rs.getInt("duration"));
                        schedule.setClassStatus(rs.getString("classStatus"));
                        schedule.setTeacherId(rs.getString("teacherId"));
                        // Try teacherName, fallback to teacherId if null
                        String tname = rs.getString("teacherName");
                        if (tname == null || tname.trim().isEmpty()) tname = rs.getString("teacherId");
                        schedule.setTeacherName(tname);

                        schedules.add(schedule);
                        count++;
                    }
                    System.out.println("[StudentBookingDAO] Rows found: " + count);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }

        return schedules;
    }

    public List<String> getAvailableDatesForMonth(int year, int month) {
        List<String> dates = new ArrayList<>();
        // Include dates that have either Available slots or teacher-created Scheduled availability
        String sql = "SELECT DISTINCT cs.scheduleDate FROM classschedule cs " +
                     "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus NOT IN ('Cancelled', 'Rescheduled') " +
                     "WHERE YEAR(cs.scheduleDate)=? AND MONTH(cs.scheduleDate)=? " +
                     "AND (cb.bookingId IS NULL) " +
                     "AND (cs.classStatus='Available' OR (cs.teacherId IS NOT NULL AND cs.classStatus='Scheduled'))";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            System.out.println("[StudentBookingDAO] Executing getAvailableDatesForMonth year=" + year + " month=" + month + " SQL: " + sql);
            ps.setInt(1, year);
            ps.setInt(2, month);

            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    if (rs.getDate("scheduleDate") != null) {
                        dates.add(rs.getDate("scheduleDate").toLocalDate().toString());
                        count++;
                    }
                }
                System.out.println("[StudentBookingDAO] Dates found: " + count);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return dates;
    }

    /**
     * Return distinct booking dates in a month where students have booked (excluding cancelled).
     */
    public List<String> getBookedDatesForMonth(int year, int month) {
        List<String> dates = new ArrayList<>();
        String sql = "SELECT DISTINCT bookingDate FROM classbooking " +
                     "WHERE YEAR(bookingDate)=? AND MONTH(bookingDate)=? " +
                     "AND bookingStatus != 'Cancelled'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, year);
            ps.setInt(2, month);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (rs.getDate("bookingDate") != null) {
                        dates.add(rs.getDate("bookingDate").toLocalDate().toString());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return dates;
    }

    /**
     * Return distinct booking dates in a month where the given student has booked (excluding cancelled).
     */
    public List<String> getBookedDatesForMonthForStudent(int year, int month, String studentId) {
        List<String> dates = new ArrayList<>();
        String sql = "SELECT DISTINCT bookingDate FROM classbooking " +
                     "WHERE YEAR(bookingDate)=? AND MONTH(bookingDate)=? " +
                     "AND bookingStatus != 'Cancelled' AND studentId = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, year);
            ps.setInt(2, month);
            ps.setString(3, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (rs.getDate("bookingDate") != null) {
                        dates.add(rs.getDate("bookingDate").toLocalDate().toString());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return dates;
    }

    /**
     * Return all schedules for a date including any booking info (if present).
     * Each map contains: scheduleId, startTime, endTime, duration, teacherName,
     * booked (boolean), bookingId, bookingStudentId, bookingStatus
     */
    public List<Map<String, Object>> getSchedulesWithBookingInfoByDate(LocalDate date) {
        String sqlWithCancellation =
            "SELECT cs.scheduleId, cs.startTime, cs.endTime, cs.duration, cs.teacherId, cs.classStatus, t.teacherName, "
                + "cb.bookingId, cb.studentId AS bookingStudentId, cb.bookingStatus, sc.cancellationReason AS cancellationReason "
                + "FROM classschedule cs "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
                + "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus NOT IN ('Cancelled', 'Rescheduled') "
                + "LEFT JOIN studentcancellation sc ON cb.bookingId = sc.bookingId "
                + "WHERE cs.scheduleDate = ? "
                + "ORDER BY cs.startTime ASC";
        String sqlWithoutCancellation =
            "SELECT cs.scheduleId, cs.startTime, cs.endTime, cs.duration, cs.teacherId, cs.classStatus, t.teacherName, "
                + "cb.bookingId, cb.studentId AS bookingStudentId, cb.bookingStatus, NULL AS cancellationReason "
                + "FROM classschedule cs "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
                + "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus NOT IN ('Cancelled', 'Rescheduled') "
                + "WHERE cs.scheduleDate = ? "
                + "ORDER BY cs.startTime ASC";

        for (String sql : new String[] { sqlWithCancellation, sqlWithoutCancellation }) {
            List<Map<String, Object>> list = querySchedulesWithBookingInfo(sql, date);
            if (list != null) {
                return list;
            }
        }
        return new ArrayList<>();
    }

    private List<Map<String, Object>> querySchedulesWithBookingInfo(String sql, LocalDate date) {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) {
                return list;
            }
            ps.setDate(1, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("scheduleId", rs.getString("scheduleId"));
                    m.put("startTime", rs.getTime("startTime") != null ? rs.getTime("startTime").toString() : "");
                    m.put("endTime", rs.getTime("endTime") != null ? rs.getTime("endTime").toString() : "");
                    m.put("duration", rs.getInt("duration"));
                    String tname = rs.getString("teacherName");
                    m.put("teacherName", tname != null ? tname : "");
                    m.put("teacherId", rs.getString("teacherId"));
                    String bookingId = rs.getString("bookingId");
                    m.put("bookingId", bookingId);
                    m.put("bookingStudentId", rs.getString("bookingStudentId"));
                    m.put("bookingStatus", rs.getString("bookingStatus"));
                    String classStatus = rs.getString("classStatus");
                    m.put("classStatus", classStatus != null ? classStatus : "");
                    boolean locked = classStatus != null && "Cancelled".equalsIgnoreCase(classStatus.trim());
                    m.put("locked", locked);
                    m.put("booked", bookingId != null || locked);
                    m.put("cancellationReason", rs.getString("cancellationReason"));
                    list.add(m);
                }
            }
            return list;
        } catch (SQLException e) {
            if (isSchemaMismatch(e)) {
                return null;
            }
            System.err.println("querySchedulesWithBookingInfo failed: " + e.getMessage());
            return list;
        }
    }

    public String bookSession(String studentId, String scheduleId, LocalDate bookingDate, LocalTime bookingTime) {
        Connection conn = null;
        String bookingId = generateBookingId(studentId);

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("bookSession: DB connection is null");
                return null;
            }

            conn.setAutoCommit(false);

            boolean insertedBooking = insertClassBooking(conn, bookingId, studentId, scheduleId, bookingDate, bookingTime);
            if (!insertedBooking) {
                conn.rollback();
                System.err.println("bookSession: INSERT into classbooking failed for scheduleId=" + scheduleId);
                return null;
            }

            boolean sessionLinked = ensureTalaqqiSessionForBooking(conn, bookingId, scheduleId, bookingDate);
            if (!sessionLinked) {
                System.err.println("bookSession: talaqqisession link failed for bookingId="
                    + bookingId + " — booking kept (session row can be auto-created later)");
            }

            conn.commit();

            try {
                new NotificationDAO().notifyTeacherOfNewBooking(bookingId, scheduleId, studentId);
            } catch (Exception ignore) {
                ignore.printStackTrace();
            }

            return bookingId;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    rollbackError.printStackTrace();
                }
            }
            System.err.println("bookSession failed: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    /** Tag a newly booked slot as the rescheduled replacement for a previous booking. */
    public void recordNewRescheduleSlot(String newBookingId, String previousBookingId) {
        if (newBookingId == null || newBookingId.trim().isEmpty()) {
            return;
        }
        String reason = buildRescheduleFromReason(previousBookingId);
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return;
            }
            recordRescheduleReason(conn, newBookingId, reason);
        } catch (SQLException e) {
            System.err.println("[StudentBookingDAO] recordNewRescheduleSlot failed: " + e.getMessage());
        }
    }

    /** UI label: "Rescheduled from Monday, 29 June 2026" (resolves legacy booking IDs too). */
    public String formatRescheduleDisplayReason(String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return reason;
        }
        String trimmed = reason.trim();
        java.util.regex.Matcher matcher = java.util.regex.Pattern
            .compile("(?i)^Rescheduled from\\s+(.+)$")
            .matcher(trimmed);
        if (!matcher.matches()) {
            return reason;
        }
        String tail = matcher.group(1).trim();
        if (looksLikeFormattedDate(tail)) {
            return trimmed;
        }
        LocalDate absentDate = lookupBookingDate(tail);
        if (absentDate != null) {
            return "Rescheduled from " + formatRescheduleFromDate(absentDate);
        }
        return reason;
    }

    private String buildRescheduleFromReason(String previousBookingId) {
        LocalDate absentDate = lookupBookingDate(previousBookingId);
        if (absentDate != null) {
            return "Rescheduled from " + formatRescheduleFromDate(absentDate);
        }
        String fallback = previousBookingId != null ? previousBookingId.trim() : "previous class";
        return "Rescheduled from " + fallback;
    }

    private static String formatRescheduleFromDate(LocalDate date) {
        return date.format(DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy", Locale.ENGLISH));
    }

    private static boolean looksLikeFormattedDate(String text) {
        if (text == null || text.isEmpty()) {
            return false;
        }
        return text.matches(".*\\d{4}.*")
            && (text.contains(",") || text.matches("(?i).*(january|february|march|april|may|june|july|august|september|october|november|december).*"));
    }

    private LocalDate lookupBookingDate(String bookingId) {
        if (bookingId == null || bookingId.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT bookingDate FROM classbooking WHERE bookingId = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingId.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getDate("bookingDate") != null) {
                        return rs.getDate("bookingDate").toLocalDate();
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[StudentBookingDAO] lookupBookingDate failed: " + e.getMessage());
        }
        return null;
    }

    /** Insert booking row; tries Pending/Upcoming/Confirmed for schema compatibility. */
    private boolean insertClassBooking(
        Connection conn, String bookingId, String studentId, String scheduleId,
        LocalDate bookingDate, LocalTime bookingTime
    ) throws SQLException {
        String sqlWithCreatedAt = "INSERT INTO classbooking (bookingId, studentId, scheduleId, bookingDate, bookingTime, "
            + "bookingStatus, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String sqlWithoutCreatedAt = "INSERT INTO classbooking (bookingId, studentId, scheduleId, bookingDate, bookingTime, bookingStatus) "
            + "VALUES (?, ?, ?, ?, ?, ?)";

        SQLException lastError = null;
        for (String status : BookingStatus.newBookingCandidates()) {
            try {
                if (executeClassBookingInsert(conn, sqlWithCreatedAt, bookingId, studentId, scheduleId,
                        bookingDate, bookingTime, status, true)) {
                    System.out.println("bookSession: inserted bookingId=" + bookingId + " status=" + status);
                    return true;
                }
            } catch (SQLException e) {
                if (isUnknownColumn(e, "createdAt")) {
                    try {
                        if (executeClassBookingInsert(conn, sqlWithoutCreatedAt, bookingId, studentId, scheduleId,
                                bookingDate, bookingTime, status, false)) {
                            System.out.println("bookSession: inserted bookingId=" + bookingId + " status=" + status);
                            return true;
                        }
                    } catch (SQLException e2) {
                        if (isInvalidEnumValue(e2)) {
                            lastError = e2;
                            continue;
                        }
                        throw e2;
                    }
                } else if (isInvalidEnumValue(e)) {
                    lastError = e;
                    continue;
                } else {
                    throw e;
                }
            }
        }
        if (lastError != null) {
            throw lastError;
        }
        return false;
    }

    private boolean executeClassBookingInsert(
            Connection conn, String sql, String bookingId, String studentId, String scheduleId,
            LocalDate bookingDate, LocalTime bookingTime, String status, boolean withCreatedAt)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bookingId);
            ps.setString(2, studentId);
            ps.setString(3, scheduleId);
            ps.setDate(4, java.sql.Date.valueOf(bookingDate));
            ps.setTime(5, java.sql.Time.valueOf(bookingTime));
            ps.setString(6, status);
            if (withCreatedAt) {
                ps.setDate(7, java.sql.Date.valueOf(LocalDate.now()));
            }
            return ps.executeUpdate() > 0;
        }
    }

    private static boolean isUnknownColumn(SQLException e, String column) {
        String message = e.getMessage();
        return message != null && message.contains("Unknown column") && message.contains(column);
    }

    private static boolean isInvalidEnumValue(SQLException e) {
        String message = e.getMessage();
        if (message == null) {
            return false;
        }
        return message.contains("Data truncated") || message.contains("Incorrect enum value");
    }

    /**
     * Link booking to talaqqisession. Supports modern schema (bookingId column)
     * and legacy production schema (scheduleId column only).
     */
    private boolean ensureTalaqqiSessionForBooking(
        Connection conn, String bookingId, String scheduleId, LocalDate sessionDate
    ) throws SQLException {
        try {
            return linkTalaqqiSessionByBookingId(conn, bookingId, sessionDate);
        } catch (SQLException e) {
            if (isTableMissing(e)) {
                System.out.println("ensureTalaqqiSessionForBooking: talaqqisession table missing — booking proceeds");
                return true;
            }
            if (!isUnknownColumn(e, "bookingId")) {
                throw e;
            }
            System.out.println("ensureTalaqqiSessionForBooking: legacy schema (scheduleId) — bookingId column absent");
        }

        if (scheduleId != null && !scheduleId.trim().isEmpty()) {
            try {
                return linkTalaqqiSessionByScheduleId(conn, scheduleId, sessionDate);
            } catch (SQLException e) {
                if (isTableMissing(e)) {
                    System.out.println("ensureTalaqqiSessionForBooking: talaqqisession unavailable — booking proceeds");
                    return true;
                }
                throw e;
            }
        }

        System.out.println("ensureTalaqqiSessionForBooking: skipped session link — booking proceeds");
        return true;
    }

    private boolean linkTalaqqiSessionByBookingId(Connection conn, String bookingId, LocalDate sessionDate)
            throws SQLException {
        String existsSql = "SELECT sessionId FROM talaqqisession WHERE bookingId = ? LIMIT 1";
        try (PreparedStatement existsPs = conn.prepareStatement(TalaqqiSchemaUtil.sql(existsSql, conn))) {
            existsPs.setString(1, bookingId);
            try (ResultSet rs = existsPs.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        }

        String nextSessionId = generateNextSessionId(conn);
        String insertSql =
            "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, bookingId) VALUES (?, 'Live Talaqqi', ?, ?)";
        try (PreparedStatement insertPs = conn.prepareStatement(TalaqqiSchemaUtil.sql(insertSql, conn))) {
            insertPs.setString(1, nextSessionId);
            insertPs.setDate(2, java.sql.Date.valueOf(sessionDate));
            insertPs.setString(3, bookingId);
            return insertPs.executeUpdate() > 0;
        }
    }

    private boolean linkTalaqqiSessionByScheduleId(Connection conn, String scheduleId, LocalDate sessionDate)
            throws SQLException {
        String existsSql = "SELECT sessionId FROM talaqqisession WHERE scheduleId = ? LIMIT 1";
        try (PreparedStatement existsPs = conn.prepareStatement(TalaqqiSchemaUtil.sql(existsSql, conn))) {
            existsPs.setString(1, scheduleId);
            try (ResultSet rs = existsPs.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        }

        String nextSessionId = generateNextSessionId(conn);
        String insertSql =
            "INSERT INTO talaqqisession (sessionId, sessionType, sessionDate, scheduleId) VALUES (?, 'Live Talaqqi', ?, ?)";
        try (PreparedStatement insertPs = conn.prepareStatement(TalaqqiSchemaUtil.sql(insertSql, conn))) {
            insertPs.setString(1, nextSessionId);
            insertPs.setDate(2, java.sql.Date.valueOf(sessionDate));
            insertPs.setString(3, scheduleId);
            return insertPs.executeUpdate() > 0;
        }
    }

    private static boolean isTableMissing(SQLException e) {
        if (TalaqqiSchemaUtil.isTableMissing(e)) {
            return true;
        }
        String msg = e.getMessage();
        return msg != null && (msg.contains("talaqqisession") || msg.contains("talaqisession"))
            && msg.contains("doesn't exist");
    }

    private String generateNextSessionId(Connection conn) throws SQLException {
        String sql = "SELECT sessionId FROM talaqqisession " +
                     "WHERE sessionId REGEXP '^S[0-9]+$' " +
                     "ORDER BY CAST(SUBSTRING(sessionId, 2) AS UNSIGNED) DESC LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(TalaqqiSchemaUtil.sql(sql, conn));
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

    /**
     * Check whether a scheduleId is valid and currently bookable for the given date/time.
     * Returns true if the schedule exists, matches the requested date/time, is available
     * (or scheduled by a teacher), and is not already booked (excluding cancelled bookings).
     */
    public boolean isScheduleBookable(String scheduleId, LocalDate bookingDate, LocalTime bookingTime) {
        if (scheduleId == null || scheduleId.trim().isEmpty()) return false;
        String sql = "SELECT cs.scheduleId FROM classschedule cs " +
                     "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus != 'Cancelled' " +
                     "WHERE cs.scheduleId = ? AND cs.scheduleDate = ? " +
                     "AND (cs.classStatus = 'Available' OR (cs.teacherId IS NOT NULL AND cs.classStatus = 'Scheduled')) " +
                     "AND cb.bookingId IS NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) return false;
            ps.setString(1, scheduleId);
            ps.setDate(2, java.sql.Date.valueOf(bookingDate));

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Ensure a row exists in `classschedule` for the given scheduleId. If missing,
     * create a minimal scheduled record so teacher-side queries that join
     * against `classschedule` will be able to pick up the booking.
     */
    public void ensureScheduleExists(String scheduleId, LocalDate scheduleDate, LocalTime startTime, String teacherId) {
        if (scheduleId == null || scheduleId.trim().isEmpty()) return;

        String checkSql = "SELECT scheduleId FROM classschedule WHERE scheduleId = ?";
        String insertSql = "INSERT INTO classschedule (scheduleId, className, scheduleDate, startTime, endTime, duration, classStatus, teacherId) " +
            "VALUES (?, ?, ?, ?, ?, ?, 'Scheduled', ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;

            ps = conn.prepareStatement(checkSql);
            ps.setString(1, scheduleId);
            rs = ps.executeQuery();
            if (rs.next()) return; // already exists
            rs.close(); ps.close();

            // compute a default endTime = startTime + 15 minutes
            java.time.LocalTime endTime = startTime != null ? startTime.plusMinutes(15) : null;
            int duration = 15;

            ps = conn.prepareStatement(insertSql);
            ps.setString(1, scheduleId);
            ps.setString(2, "Booked Session");
            ps.setDate(3, java.sql.Date.valueOf(scheduleDate));
            ps.setTime(4, startTime != null ? java.sql.Time.valueOf(startTime) : null);
            ps.setTime(5, endTime != null ? java.sql.Time.valueOf(endTime) : null);
            ps.setInt(6, duration);
            if (teacherId != null && !teacherId.trim().isEmpty()) ps.setString(7, teacherId); else ps.setNull(7, java.sql.Types.VARCHAR);

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    public List<StudentBooking> getMyBookings(String studentId) {
        return loadStudentBookings(studentId, false);
    }

    /** Load one booking for a student; null if not found or not owned. */
    public StudentBooking getStudentBooking(String studentId, String bookingId) {
        if (studentId == null || studentId.trim().isEmpty()
                || bookingId == null || bookingId.trim().isEmpty()) {
            return null;
        }
        for (StudentBooking b : getMyBookings(studentId)) {
            if (bookingId.trim().equalsIgnoreCase(b.getBookingId())) {
                return b;
            }
        }
        return null;
    }

    /**
     * Get bookings for the current month only
     * This resets booked classes at the beginning of each new month
     */
    public List<StudentBooking> getMyBookingsByMonth(String studentId) {
        return loadStudentBookings(studentId, true);
    }

    public List<StudentBooking> getTeacherBookings(String teacherId) {
        return loadTeacherBookings(teacherId);
    }

    public boolean cancelBooking(String bookingId, String reason) {
        ClassScheduleDAO scheduleDAO = new ClassScheduleDAO();
        if (!scheduleDAO.isCancellationAllowedByBookingId(bookingId)) {
            System.out.println("cancelBooking blocked: less than 12 hours before class. bookingId=" + bookingId);
            return false;
        }

        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        String scheduleId = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // get scheduleId for this booking so we can update classschedule after cancellation
            try (PreparedStatement ps0 = conn.prepareStatement("SELECT scheduleId FROM classbooking WHERE bookingId = ?")) {
                ps0.setString(1, bookingId);
                try (ResultSet rs0 = ps0.executeQuery()) {
                    if (rs0.next()) {
                        scheduleId = rs0.getString(1);
                    }
                }
            } catch (SQLException ignore) { ignore.printStackTrace(); }

            String updateSql = "UPDATE classbooking SET bookingStatus = 'Cancelled' WHERE bookingId = ?";
            ps1 = conn.prepareStatement(updateSql);
            ps1.setString(1, bookingId);
            int rowsUpdated = ps1.executeUpdate();

            if (rowsUpdated > 0) {
                // Insert or update cancellation reason into `studentcancellation` table
                String insertSql = "INSERT INTO studentcancellation (bookingId, cancellationReason, cancelledAt, cancelledBy) " +
                                   "SELECT bookingId, ?, NOW(), 'student' FROM classbooking WHERE bookingId = ? " +
                                   "ON DUPLICATE KEY UPDATE cancellationReason = VALUES(cancellationReason), cancelledAt = NOW(), cancelledBy = 'student'";
                ps2 = conn.prepareStatement(insertSql);
                ps2.setString(1, reason);
                ps2.setString(2, bookingId);
                ps2.executeUpdate();
            }

            // After successful cancellation, notify teacher and student
            try {
                String lookupSql =
                    "SELECT b.studentId, cs.teacherId, cs.className FROM classbooking b " +
                    "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId WHERE b.bookingId = ? LIMIT 1";
                try (PreparedStatement psT = conn.prepareStatement(lookupSql)) {
                    psT.setString(1, bookingId);
                    try (ResultSet rsT = psT.executeQuery()) {
                        if (rsT.next()) {
                            String teacherId = rsT.getString("teacherId");
                            String studentId = rsT.getString("studentId");
                            String className = rsT.getString("className");
                            NotificationDAO notifDao = new NotificationDAO();

                            if (teacherId != null && !teacherId.trim().isEmpty()) {
                                String classLabel = className != null ? className : "a class";
                                String msg = "Student cancelled " + classLabel + ". Reason: " + reason;
                                notifDao.createNotification(conn, teacherId, "teacher",
                                    NotificationDAO.TITLE_CLASS_CANCELLED, msg, bookingId, scheduleId);
                            }
                            if (studentId != null && !studentId.trim().isEmpty()) {
                                String classLabel = className != null ? className : "your class";
                                String msg = "You cancelled " + classLabel + ". Reason: " + reason;
                                notifDao.createNotification(conn, studentId, "student",
                                    NotificationDAO.TITLE_CLASS_CANCELLED, msg, bookingId, scheduleId);
                            }
                        }
                    }
                }
            } catch (SQLException ignore) { ignore.printStackTrace(); }

            if (rowsUpdated > 0) {
                try (PreparedStatement psDel = conn.prepareStatement(
                        "DELETE FROM talaqqisession WHERE bookingId = ?")) {
                    psDel.setString(1, bookingId);
                    psDel.executeUpdate();
                } catch (SQLException ignore) {
                    ignore.printStackTrace();
                }
            }

            conn.commit();
            // Student cancel: unlock slot so another student can book
            if (rowsUpdated > 0 && scheduleId != null) {
                try { new ClassScheduleDAO().updateClassStatus(scheduleId, "Scheduled"); } catch (Exception ignore) { ignore.printStackTrace(); }
            }
            return rowsUpdated > 0;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps1 != null) ps1.close();
                if (ps2 != null) ps2.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Mark a booking as 'Rescheduled' and record the reschedule reason.
     * This is similar to cancelBooking but uses the 'Rescheduled' status so
     * the UI can show rescheduled classes separately.
     */
    public boolean rescheduleBooking(String bookingId, String reason) {
        if (bookingId == null || bookingId.trim().isEmpty()) {
            return false;
        }

        Connection conn = null;
        String scheduleId = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return false;
            }
            conn.setAutoCommit(false);

            try (PreparedStatement ps0 = conn.prepareStatement("SELECT scheduleId FROM classbooking WHERE bookingId = ?")) {
                ps0.setString(1, bookingId);
                try (ResultSet rs0 = ps0.executeQuery()) {
                    if (rs0.next()) {
                        scheduleId = rs0.getString(1);
                    }
                }
            }

            int rowsUpdated = 0;
            String[] statusCandidates = {"Rescheduled", "Cancelled"};
            SQLException lastEnumError = null;
            for (String status : statusCandidates) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE classbooking SET bookingStatus = ? WHERE bookingId = ?")) {
                    ps.setString(1, status);
                    ps.setString(2, bookingId);
                    rowsUpdated = ps.executeUpdate();
                    if (rowsUpdated > 0) {
                        System.out.println("[StudentBookingDAO] rescheduleBooking applied status=" + status
                            + " bookingId=" + bookingId);
                        break;
                    }
                } catch (SQLException e) {
                    if (isInvalidEnumValue(e)) {
                        lastEnumError = e;
                        continue;
                    }
                    throw e;
                }
            }
            if (rowsUpdated == 0 && lastEnumError != null) {
                throw lastEnumError;
            }

            if (rowsUpdated > 0) {
                recordRescheduleReason(conn, bookingId, reason);
                try (PreparedStatement psDel = conn.prepareStatement(
                        "DELETE FROM talaqqisession WHERE bookingId = ?")) {
                    psDel.setString(1, bookingId);
                    psDel.executeUpdate();
                } catch (SQLException ignore) {
                    ignore.printStackTrace();
                }
            }

            conn.commit();

            if (rowsUpdated > 0 && scheduleId != null) {
                try {
                    new ClassScheduleDAO().updateClassStatus(scheduleId, "Scheduled");
                } catch (Exception ignore) {
                    ignore.printStackTrace();
                }
            }
            return rowsUpdated > 0;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.err.println("[StudentBookingDAO] rescheduleBooking failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void recordRescheduleReason(Connection conn, String bookingId, String reason) {
        String safeReason = reason != null ? reason : "Rescheduled by student";
        String[] insertVariants = {
            "INSERT INTO studentcancellation (bookingId, cancellationReason, cancelledAt, cancelledBy) "
                + "VALUES (?, ?, NOW(), 'student') "
                + "ON DUPLICATE KEY UPDATE cancellationReason = VALUES(cancellationReason), "
                + "cancelledAt = NOW(), cancelledBy = 'student'",
            "INSERT INTO studentcancellation (bookingId, cancellationReason) VALUES (?, ?) "
                + "ON DUPLICATE KEY UPDATE cancellationReason = VALUES(cancellationReason)"
        };
        for (String sql : insertVariants) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingId);
                ps.setString(2, safeReason);
                ps.executeUpdate();
                return;
            } catch (SQLException e) {
                if (!isSchemaMismatch(e)) {
                    System.err.println("[StudentBookingDAO] recordRescheduleReason: " + e.getMessage());
                    return;
                }
            }
        }
    }

    private List<StudentBooking> loadStudentBookings(String studentId, boolean currentMonthOnly) {
        List<StudentBooking> empty = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            System.err.println("loadStudentBookings: DB connection is null");
            return empty;
        }

        String monthFilter = currentMonthOnly
            ? " AND MONTH(b.bookingDate) = MONTH(CURRENT_DATE()) AND YEAR(b.bookingDate) = YEAR(CURRENT_DATE())"
            : "";
        String orderBy = " ORDER BY b.bookingDate DESC, b.bookingTime DESC";
        String baseFrom =
            " FROM classbooking b "
                + "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId ";

        String attendanceSubquery = bookingAttendanceSubquery();

        String[] sqlVariants = {
            "SELECT b.bookingId, b.studentId, b.scheduleId, b.bookingDate, b.bookingTime, b.bookingStatus, b.createdAt, "
                + "cs.className, t.teacherName AS teacherName, cs.teacherId, cs.duration, sc.cancellationReason AS cancellationReason, "
                + attendanceSubquery + " "
                + baseFrom + "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId "
                + "WHERE b.studentId = ?" + monthFilter + orderBy,
            "SELECT b.bookingId, b.studentId, b.scheduleId, b.bookingDate, b.bookingTime, b.bookingStatus, NULL AS createdAt, "
                + "cs.className, t.teacherName AS teacherName, cs.teacherId, cs.duration, sc.cancellationReason AS cancellationReason, "
                + attendanceSubquery + " "
                + baseFrom + "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId "
                + "WHERE b.studentId = ?" + monthFilter + orderBy,
            "SELECT b.bookingId, b.studentId, b.scheduleId, b.bookingDate, b.bookingTime, b.bookingStatus, NULL AS createdAt, "
                + "cs.className, t.teacherName AS teacherName, cs.teacherId, cs.duration, NULL AS cancellationReason, "
                + attendanceSubquery + " "
                + baseFrom + "WHERE b.studentId = ?" + monthFilter + orderBy
        };

        try {
            for (String sql : sqlVariants) {
                try {
                    List<StudentBooking> bookings = new ArrayList<>();
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, studentId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                StudentBooking booking = new StudentBooking();
                                mapStudentBookingRow(rs, booking);
                                if (booking.getCancellationReason() != null) {
                                    booking.setCancellationReason(
                                        formatRescheduleDisplayReason(booking.getCancellationReason()));
                                }
                                bookings.add(booking);
                            }
                        }
                    }
                    return bookings;
                } catch (SQLException e) {
                    if (!isSchemaMismatch(e)) {
                        System.err.println("loadStudentBookings failed: " + e.getMessage());
                        break;
                    }
                }
            }
        } finally {
            try {
                conn.close();
            } catch (SQLException ignored) {}
        }
        return empty;
    }

    private List<StudentBooking> loadTeacherBookings(String teacherId) {
        List<StudentBooking> empty = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            System.err.println("loadTeacherBookings: DB connection is null");
            return empty;
        }

        String orderBy = " ORDER BY b.bookingDate DESC, b.bookingTime DESC";
        String baseFrom =
            " FROM classbooking b "
                + "INNER JOIN classschedule cs ON b.scheduleId = cs.scheduleId "
                + "INNER JOIN student s ON b.studentId = s.studentId "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId ";

        String attendanceSubquery = bookingAttendanceSubquery();

        String[] sqlVariants = {
            "SELECT b.bookingId, b.studentId, b.scheduleId, b.bookingDate, b.bookingTime, b.bookingStatus, b.createdAt, "
                + "cs.className, t.teacherName AS teacherName, cs.teacherId, cs.duration, s.studentName AS studentName, "
                + "sc.cancellationReason AS cancellationReason, " + attendanceSubquery + " "
                + baseFrom + "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId "
                + "WHERE cs.teacherId = ?" + orderBy,
            "SELECT b.bookingId, b.studentId, b.scheduleId, b.bookingDate, b.bookingTime, b.bookingStatus, NULL AS createdAt, "
                + "cs.className, t.teacherName AS teacherName, cs.teacherId, cs.duration, s.studentName AS studentName, "
                + "sc.cancellationReason AS cancellationReason, " + attendanceSubquery + " "
                + baseFrom + "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId "
                + "WHERE cs.teacherId = ?" + orderBy,
            "SELECT b.bookingId, b.studentId, b.scheduleId, b.bookingDate, b.bookingTime, b.bookingStatus, NULL AS createdAt, "
                + "cs.className, t.teacherName AS teacherName, cs.teacherId, cs.duration, s.studentName AS studentName, "
                + "NULL AS cancellationReason, " + attendanceSubquery + " "
                + baseFrom + "WHERE cs.teacherId = ?" + orderBy
        };

        try {
            for (String sql : sqlVariants) {
                try {
                    List<StudentBooking> bookings = new ArrayList<>();
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, teacherId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                StudentBooking booking = new StudentBooking();
                                mapStudentBookingRow(rs, booking);
                                if (booking.getCancellationReason() != null) {
                                    booking.setCancellationReason(
                                        formatRescheduleDisplayReason(booking.getCancellationReason()));
                                }
                                bookings.add(booking);
                            }
                        }
                    }
                    return bookings;
                } catch (SQLException e) {
                    if (!isSchemaMismatch(e)) {
                        System.err.println("loadTeacherBookings failed: " + e.getMessage());
                        break;
                    }
                }
            }
        } finally {
            try {
                conn.close();
            } catch (SQLException ignored) {}
        }
        return empty;
    }

    /**
     * Match attendance to a booking by scheduleId, or same student/date/time/teacher
     * when session attendance was stored under a different schedule row.
     */
    private static String bookingAttendanceSubquery() {
        return "(SELECT a.attendanceStatus FROM attendance a "
            + "LEFT JOIN classschedule cs_a ON cs_a.scheduleId = a.scheduleId "
            + "WHERE a.studentId = b.studentId "
            + "AND a.attendanceDate = b.bookingDate "
            + "AND (a.scheduleId = b.scheduleId "
            + "     OR (cs_a.startTime = b.bookingTime AND cs_a.teacherId = cs.teacherId)) "
            + "ORDER BY "
            + "CASE a.attendanceStatus WHEN 'Absent' THEN 0 WHEN 'Late' THEN 1 WHEN 'Present' THEN 2 ELSE 3 END, "
            + "a.attendanceId DESC LIMIT 1) AS attendanceStatus";
    }

    private static void mapStudentBookingRow(ResultSet rs, StudentBooking booking) throws SQLException {
        booking.setBookingId(rs.getString("bookingId"));
        booking.setStudentId(rs.getString("studentId"));
        booking.setScheduleId(rs.getString("scheduleId"));
        if (rs.getDate("bookingDate") != null) {
            booking.setBookingDate(rs.getDate("bookingDate").toLocalDate());
        }
        if (rs.getTime("bookingTime") != null) {
            booking.setBookingTime(rs.getTime("bookingTime").toLocalTime());
        }
        booking.setBookingStatus(rs.getString("bookingStatus"));
        if (rs.getDate("createdAt") != null) {
            booking.setCreatedAt(rs.getDate("createdAt").toLocalDate());
        }
        booking.setClassName(rs.getString("className"));
        booking.setTeacherName(rs.getString("teacherName"));
        booking.setTeacherId(rs.getString("teacherId"));
        booking.setDuration(rs.getInt("duration"));
        booking.setCancellationReason(rs.getString("cancellationReason"));
        try {
            booking.setStudentName(rs.getString("studentName"));
        } catch (SQLException ignored) {
            booking.setStudentName(null);
        }
        try {
            booking.setAttendanceStatus(rs.getString("attendanceStatus"));
        } catch (SQLException ignored) {
            booking.setAttendanceStatus(null);
        }
    }

    private static boolean isSchemaMismatch(SQLException e) {
        String msg = e.getMessage();
        return msg != null && (msg.contains("Unknown column") || msg.contains("doesn't exist"));
    }

    /**
     * Generate a readable, non-hashed booking id (B001, B002, ...).
     */
    private String generateBookingId(String studentId) {
        // Generate a short, sequential booking id in the form B001, B002, ...
        // Query the DB for the current max bookingId starting with 'B' and increment.
        String defaultId = "B001";
        String sql = "SELECT bookingId FROM classbooking WHERE bookingId LIKE 'B%' ORDER BY bookingId DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return defaultId;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String maxId = rs.getString(1);
                        if (maxId != null) {
                            // Extract digits from the end of the id
                            String digits = maxId.replaceAll("\\D", "");
                            int num = 0;
                            try { num = Integer.parseInt(digits); } catch (NumberFormatException nfe) { num = 0; }
                            int next = num + 1;
                            // Use 3-digit padding (B001). If it grows beyond 999, switch to 6 digits.
                            String fmt = next <= 999 ? "%03d" : "%06d";
                            return "B" + String.format(fmt, next);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return defaultId;
    }
}
