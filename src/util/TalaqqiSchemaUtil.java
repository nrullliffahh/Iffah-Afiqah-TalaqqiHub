package util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;

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
            linkByBookingId = columnExists(probe(conn), sessionTable(conn), "bookingId");
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
        if (usesBookingIdLink(conn)) {
            return "FROM " + t + " ts "
                + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "FROM " + t + " ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON cb.scheduleId = cs.scheduleId ";
    }

    public static String leftJoinSessionFromFeedback(Connection conn) {
        String t = sessionTable(conn);
        if (usesBookingIdLink(conn)) {
            return "LEFT JOIN " + t + " ts ON sf.sessionId = ts.sessionId "
                + "LEFT JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "LEFT JOIN " + t + " ts ON sf.sessionId = ts.sessionId "
            + "LEFT JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = sf.studentId ";
    }

    public static String leftJoinSessionFromEvaluation(Connection conn) {
        String t = sessionTable(conn);
        if (usesBookingIdLink(conn)) {
            return "LEFT JOIN " + t + " ts ON se.sessionId = ts.sessionId "
                + "LEFT JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "LEFT JOIN " + t + " ts ON se.sessionId = ts.sessionId "
            + "LEFT JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = se.studentId ";
    }

    public static String joinSessionToBooking(Connection conn) {
        String t = sessionTable(conn);
        return usesBookingIdLink(conn)
            ? "JOIN " + t + " ts ON ts.bookingId = cb.bookingId "
            : "JOIN " + t + " ts ON ts.scheduleId = cb.scheduleId ";
    }

    public static String leftJoinSessionToBooking(Connection conn) {
        String t = sessionTable(conn);
        return usesBookingIdLink(conn)
            ? "LEFT JOIN " + t + " ts ON ts.bookingId = cb.bookingId "
            : "LEFT JOIN " + t + " ts ON ts.scheduleId = cb.scheduleId ";
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
