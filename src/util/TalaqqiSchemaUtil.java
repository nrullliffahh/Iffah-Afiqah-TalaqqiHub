package util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Detects production vs modern {@code talaqqisession} schema and builds compatible SQL fragments.
 * Also resolves legacy dump typo {@code talaqisession} (one "q") vs {@code talaqqisession}.
 */
public final class TalaqqiSchemaUtil {

    private static final String CANONICAL_TABLE = "talaqqisession";
    private static final String LEGACY_TYPO_TABLE = "talaqisession";

    private static volatile String sessionTableName;
    private static volatile Boolean linkByBookingId;
    private static volatile Boolean sessionTimingColumns;
    private static volatile Boolean classAyahEndColumn;
    private static volatile Boolean announcementTable;
    private static volatile Boolean quranDisplayTable;

    private TalaqqiSchemaUtil() {
    }

    /** Actual MySQL table name (talaqqisession or legacy typo talaqisession). */
    public static String sessionTable(Connection conn) {
        if (sessionTableName != null) {
            return sessionTableName;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (sessionTableName != null) {
                return sessionTableName;
            }
            Connection probe = probe(conn);
            try {
                if (tableExists(probe, CANONICAL_TABLE)) {
                    sessionTableName = CANONICAL_TABLE;
                } else if (tableExists(probe, LEGACY_TYPO_TABLE)) {
                    sessionTableName = LEGACY_TYPO_TABLE;
                    System.err.println("[TalaqqiSchemaUtil] Using legacy typo table 'talaqisession' — "
                        + "run db/0016_ensure_talaqqisession_table.sql to rename");
                } else {
                    sessionTableName = CANONICAL_TABLE;
                    System.err.println("[TalaqqiSchemaUtil] WARNING: no talaqqisession/talaqisession table found");
                }
            } finally {
                closeIfOwned(probe, conn);
            }
            System.out.println("[TalaqqiSchemaUtil] session table: " + sessionTableName);
            return sessionTableName;
        }
    }

    /** Replace canonical table token with the resolved physical table name. */
    public static String sql(String template, Connection conn) {
        if (template == null) {
            return null;
        }
        return template.replace(CANONICAL_TABLE, sessionTable(conn));
    }

    public static boolean usesBookingIdLink(Connection conn) {
        if (linkByBookingId != null) {
            return linkByBookingId;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (linkByBookingId != null) {
                return linkByBookingId;
            }
            linkByBookingId = columnExistsProbe(probe(conn), sessionTable(conn), "bookingId", conn);
            System.out.println("[TalaqqiSchemaUtil] talaqqisession link: "
                + (linkByBookingId ? "bookingId" : "scheduleId"));
            return linkByBookingId;
        }
    }

    public static boolean hasSessionTimingColumns(Connection conn) {
        if (sessionTimingColumns != null) {
            return sessionTimingColumns;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (sessionTimingColumns != null) {
                return sessionTimingColumns;
            }
            sessionTimingColumns = columnExists(probe(conn), sessionTable(conn), "sessionStartTime");
            System.out.println("[TalaqqiSchemaUtil] session timing columns: "
                + (sessionTimingColumns ? "present" : "absent (using NULL aliases)"));
            return sessionTimingColumns;
        }
    }

    public static boolean hasClassAyahEnd(Connection conn) {
        if (classAyahEndColumn != null) {
            return classAyahEndColumn;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (classAyahEndColumn != null) {
                return classAyahEndColumn;
            }
            classAyahEndColumn = columnExists(probe(conn), "classschedule", "classAyahEnd");
            return classAyahEndColumn;
        }
    }

    public static boolean hasAnnouncementTable(Connection conn) {
        if (announcementTable != null) {
            return announcementTable;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (announcementTable != null) {
                return announcementTable;
            }
            Connection probe = probe(conn);
            boolean exists = tableExists(probe, "announcement");
            closeIfOwned(probe, conn);
            announcementTable = exists;
            return exists;
        }
    }

    public static String innerSessionBookingSchedule(Connection conn) {
        String t = sessionTable(conn);
        if (hasColumn(conn, t, "bookingId")) {
            return "FROM " + t + " ts "
                + "JOIN classbooking cb ON " + sessionToBookingOnClause(t)
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "FROM " + t + " ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON cb.scheduleId = cs.scheduleId ";
    }

    public static String leftJoinSessionFromFeedback(Connection conn) {
        String t = sessionTable(conn);
        if (hasColumn(conn, t, "bookingId")) {
            return "LEFT JOIN " + t + " ts ON sf.sessionId = ts.sessionId "
                + "LEFT JOIN classbooking cb ON " + sessionToBookingOnClause(t)
                + "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "LEFT JOIN " + t + " ts ON sf.sessionId = ts.sessionId "
            + "LEFT JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = sf.studentId ";
    }

    public static String leftJoinSessionFromEvaluation(Connection conn) {
        String t = sessionTable(conn);
        String sessionJoin;
        if (hasColumn(conn, "studentevaluation", "sessionId")) {
            sessionJoin = "LEFT JOIN " + t + " ts ON se.sessionId = ts.sessionId ";
        } else if (hasColumn(conn, "studentevaluation", "scheduleId")) {
            sessionJoin = "LEFT JOIN " + t + " ts ON se.scheduleId = ts.scheduleId ";
        } else {
            sessionJoin = "LEFT JOIN " + t + " ts ON ts.teacherId = se.teacherId ";
        }
        if (hasColumn(conn, t, "bookingId")) {
            return sessionJoin
                + "LEFT JOIN classbooking cb ON " + sessionToBookingOnClause(t)
                + "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return sessionJoin
            + "LEFT JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = se.studentId ";
    }

    public static String joinSessionToBooking(Connection conn) {
        String t = sessionTable(conn);
        if (hasColumn(conn, t, "bookingId")) {
            return "JOIN " + t + " ts ON " + sessionToBookingOnClause(t);
        }
        return "JOIN " + t + " ts ON ts.scheduleId = cb.scheduleId ";
    }

    public static String leftJoinSessionToBooking(Connection conn) {
        String t = sessionTable(conn);
        if (hasColumn(conn, t, "bookingId")) {
            return "LEFT JOIN " + t + " ts ON " + sessionToBookingOnClause(t);
        }
        return "LEFT JOIN " + t + " ts ON ts.scheduleId = cb.scheduleId ";
    }

    /**
     * Match session rows to bookings when production has {@code bookingId} column but legacy rows
     * still link via {@code scheduleId} only.
     */
    private static String sessionToBookingOnClause(String sessionTableAlias) {
        return "(" + sessionTableAlias + ".bookingId IS NOT NULL AND "
            + sessionTableAlias + ".bookingId <> '' AND "
            + sessionTableAlias + ".bookingId = cb.bookingId) OR (("
            + sessionTableAlias + ".bookingId IS NULL OR "
            + sessionTableAlias + ".bookingId = '') AND "
            + sessionTableAlias + ".scheduleId = cb.scheduleId)";
    }

    public static String adminSessionFromJoin(Connection conn) {
        String t = sessionTable(conn);
        if (usesBookingIdLink(conn)) {
            return "FROM " + t + " ts "
                + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "FROM " + t + " ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId "
            + "  AND cb.bookingStatus NOT IN ('Cancelled','Rejected') ";
    }

    public static String ayahRangeExpr(Connection conn) {
        if (hasClassAyahEnd(conn)) {
            return "CONCAT(cs.classAyah,'-',COALESCE(cs.classAyahEnd,cs.classAyah))";
        }
        return "CAST(cs.classAyah AS CHAR)";
    }

    /**
     * Full row SELECT for TalaqqiSessionDAO mapRow(). Handles hybrid production schema
     * (e.g. bookingId present but sessionStartTime/sessionDuration absent).
     */
    public static String sessionBaseSelect(Connection conn) {
        boolean byBooking = usesBookingIdLink(conn);
        boolean timing = hasSessionTimingColumns(conn);
        boolean ayahEnd = hasClassAyahEnd(conn);

        String timingCols = timing
            ? "ts.sessionStartTime, ts.sessionDuration, "
            : "NULL AS sessionStartTime, NULL AS sessionDuration, ";
        String ayahEndCol = ayahEnd ? "cs.classAyahEnd, " : "NULL AS classAyahEnd, ";

        String sql;
        if (byBooking) {
            sql = "SELECT ts.sessionId, ts.sessionType, ts.sessionDate AS tsDate, "
                + timingCols
                + "ts.bookingId, "
                + "cb.studentId, cb.scheduleId, cb.bookingStatus, "
                + "cs.teacherId, cs.className, cs.startTime, cs.endTime, cs.duration, "
                + "cs.classSurah, cs.classAyah, " + ayahEndCol
                + "s.studentName, t.teacherName AS teacherName "
                + "FROM talaqqisession ts "
                + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
                + "LEFT JOIN student s ON cb.studentId = s.studentId "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId ";
        } else {
            sql = "SELECT ts.sessionId, ts.sessionType, ts.sessionDate AS tsDate, "
                + timingCols
                + "cb.bookingId, cb.studentId, cs.scheduleId, cb.bookingStatus, "
                + "cs.teacherId, cs.className, cs.startTime, cs.endTime, cs.duration, "
                + "cs.classSurah, cs.classAyah, " + ayahEndCol
                + "s.studentName, t.teacherName AS teacherName "
                + "FROM talaqqisession ts "
                + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
                + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId "
                + "  AND cb.bookingStatus NOT IN ('Cancelled','Rejected') "
                + "LEFT JOIN student s ON cb.studentId = s.studentId "
                + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId ";
        }
        return sql(sql, conn);
    }

    public static boolean hasColumn(Connection conn, String table, String column) {
        return columnExistsProbe(probe(conn), table, column, conn);
    }

    /** Probe with {@code SELECT col FROM table LIMIT 0} — reliable on Aiven/MySQL. */
    private static boolean columnExistsProbe(Connection conn, String table, String column, Connection ownerConn) {
        if (conn == null || table == null || column == null) {
            return false;
        }
        String safeTable = table.replace("`", "");
        String safeCol = column.replace("`", "");
        try (Statement st = conn.createStatement()) {
            st.executeQuery("SELECT `" + safeCol + "` FROM `" + safeTable + "` LIMIT 0");
            return true;
        } catch (SQLException e) {
            return false;
        } finally {
            closeIfOwned(conn, ownerConn);
        }
    }

    /** Add {@code bookingId} to talaqqisession when production dump predates migration. */
    public static void ensureSessionBookingIdColumn(Connection conn) {
        String table = sessionTable(conn);
        if (hasColumn(conn, table, "bookingId")) {
            return;
        }
        Connection probe = probe(conn);
        try (Statement st = probe.createStatement()) {
            st.execute("ALTER TABLE `" + table.replace("`", "") + "` ADD COLUMN bookingId VARCHAR(10) DEFAULT NULL");
            linkByBookingId = true;
            System.out.println("[TalaqqiSchemaUtil] added bookingId column to " + table);
        } catch (SQLException e) {
            if (e.getMessage() == null || !e.getMessage().contains("Duplicate column")) {
                System.err.println("[TalaqqiSchemaUtil] ensureSessionBookingIdColumn: " + e.getMessage());
            }
        } finally {
            closeIfOwned(probe, conn);
        }
    }

    /** Subquery: resolve sessionId for a classbooking row (legacy scheduleId or bookingId). */
    public static String sessionIdForBookingSubquery(Connection conn) {
        String t = sessionTable(conn);
        if (hasColumn(conn, t, "bookingId")) {
            return "(SELECT ts2.sessionId FROM " + t + " ts2 "
                + "WHERE (ts2.bookingId IS NOT NULL AND ts2.bookingId <> '' AND ts2.bookingId = cb.bookingId) "
                + "   OR ((ts2.bookingId IS NULL OR ts2.bookingId = '') AND ts2.scheduleId = cb.scheduleId) "
                + "LIMIT 1)";
        }
        return "(SELECT ts2.sessionId FROM " + t + " ts2 WHERE ts2.scheduleId = cb.scheduleId LIMIT 1)";
    }

    public static boolean hasQuranDisplayTable(Connection conn) {
        if (quranDisplayTable != null) {
            return quranDisplayTable;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (quranDisplayTable != null) {
                return quranDisplayTable;
            }
            Connection probe = probe(conn);
            try {
                quranDisplayTable = tableExists(probe, "qurandisplay");
            } finally {
                closeIfOwned(probe, conn);
            }
            return quranDisplayTable;
        }
    }

    /** {@code se.createdAt} or {@code se.created_at}, whichever exists. */
    public static String studentEvalCreatedColumn(Connection conn, String alias) {
        if (hasColumn(conn, "studentevaluation", "createdAt")) {
            return alias + ".createdAt";
        }
        if (hasColumn(conn, "studentevaluation", "created_at")) {
            return alias + ".created_at";
        }
        return "NOW()";
    }

    /** {@code se.updated_at} or {@code se.updatedAt}, whichever exists. */
    public static String studentEvalUpdatedColumn(Connection conn, String alias) {
        if (hasColumn(conn, "studentevaluation", "updated_at")) {
            return alias + ".updated_at";
        }
        if (hasColumn(conn, "studentevaluation", "updatedAt")) {
            return alias + ".updatedAt";
        }
        return "NULL";
    }

    public static boolean isTableMissing(SQLException e) {
        String msg = e.getMessage();
        return msg != null && msg.contains("doesn't exist");
    }

    public static boolean isSessionTableMissing(Connection conn) {
        Connection probe = probe(conn);
        try {
            return !tableExists(probe, CANONICAL_TABLE) && !tableExists(probe, LEGACY_TYPO_TABLE);
        } finally {
            closeIfOwned(probe, conn);
        }
    }

    private static Connection probe(Connection conn) {
        if (conn != null) {
            return conn;
        }
        return DBConnection.getConnection();
    }

    private static void closeIfOwned(Connection probe, Connection callerConn) {
        if (callerConn == null && probe != null) {
            try {
                probe.close();
            } catch (SQLException ignored) {
            }
        }
    }

    private static boolean tableExists(Connection conn, String table) {
        if (conn == null) {
            return false;
        }
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet tables = meta.getTables(conn.getCatalog(), null, table, new String[] {"TABLE"})) {
                return tables.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    private static boolean columnExists(Connection conn, String table, String column) {
        if (conn == null) {
            return false;
        }
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet cols = meta.getColumns(conn.getCatalog(), null, table, column)) {
                return cols.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }
}
