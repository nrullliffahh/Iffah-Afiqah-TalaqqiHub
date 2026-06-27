package util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Detects production vs modern {@code talaqqisession} schema and builds compatible SQL fragments.
 * Production Aiven: {@code talaqqisession.scheduleId} → {@code classschedule}.
 * Modern/dev: {@code talaqqisession.bookingId} → {@code classbooking}.
 */
public final class TalaqqiSchemaUtil {

    private static volatile Boolean linkByBookingId;
    private static volatile Boolean sessionTimingColumns;
    private static volatile Boolean classAyahEndColumn;
    private static volatile Boolean announcementTable;

    private TalaqqiSchemaUtil() {
    }

    public static boolean usesBookingIdLink(Connection conn) {
        if (linkByBookingId != null) {
            return linkByBookingId;
        }
        synchronized (TalaqqiSchemaUtil.class) {
            if (linkByBookingId != null) {
                return linkByBookingId;
            }
            linkByBookingId = columnExists(probe(conn), "talaqqisession", "bookingId");
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
            sessionTimingColumns = columnExists(probe(conn), "talaqqisession", "sessionStartTime");
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
            boolean exists = false;
            if (probe != null) {
                try {
                    DatabaseMetaData meta = probe.getMetaData();
                    try (ResultSet tables = meta.getTables(probe.getCatalog(), null, "announcement", new String[] {"TABLE"})) {
                        exists = tables.next();
                    }
                } catch (SQLException ignored) {
                    exists = false;
                } finally {
                    closeIfOwned(probe, conn);
                }
            }
            announcementTable = exists;
            return exists;
        }
    }

    /** INNER JOIN chain ts → cb → cs (fixed aliases). */
    public static String innerSessionBookingSchedule(Connection conn) {
        if (usesBookingIdLink(conn)) {
            return "FROM talaqqisession ts "
                + "JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "FROM talaqqisession ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON cb.scheduleId = cs.scheduleId ";
    }

    /** LEFT JOIN ts → cb → cs anchored on studentfeedback sf. */
    public static String leftJoinSessionFromFeedback(Connection conn) {
        if (usesBookingIdLink(conn)) {
            return "LEFT JOIN talaqqisession ts ON sf.sessionId = ts.sessionId "
                + "LEFT JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "LEFT JOIN talaqqisession ts ON sf.sessionId = ts.sessionId "
            + "LEFT JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = sf.studentId ";
    }

    /** LEFT JOIN ts → cb → cs anchored on studentevaluation se. */
    public static String leftJoinSessionFromEvaluation(Connection conn) {
        if (usesBookingIdLink(conn)) {
            return "LEFT JOIN talaqqisession ts ON se.sessionId = ts.sessionId "
                + "LEFT JOIN classbooking cb ON ts.bookingId = cb.bookingId "
                + "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId ";
        }
        return "LEFT JOIN talaqqisession ts ON se.sessionId = ts.sessionId "
            + "LEFT JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = se.studentId ";
    }

    /** JOIN talaqqisession ts to classbooking cb (both aliases must exist). */
    public static String joinSessionToBooking(Connection conn) {
        return usesBookingIdLink(conn)
            ? "JOIN talaqqisession ts ON ts.bookingId = cb.bookingId "
            : "JOIN talaqqisession ts ON ts.scheduleId = cb.scheduleId ";
    }

    /** LEFT JOIN talaqqisession ts to classbooking cb. */
    public static String leftJoinSessionToBooking(Connection conn) {
        return usesBookingIdLink(conn)
            ? "LEFT JOIN talaqqisession ts ON ts.bookingId = cb.bookingId "
            : "LEFT JOIN talaqqisession ts ON ts.scheduleId = cb.scheduleId ";
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
