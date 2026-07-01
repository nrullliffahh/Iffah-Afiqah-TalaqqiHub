package util;

/**
 * Shared SQL helpers so portal list/stats views reset each calendar month
 * without changing write/booking/attendance business logic.
 */
public final class MonthlyScopeUtil {

    private MonthlyScopeUtil() {}

    /** {@code AND MONTH(col) = MONTH(CURRENT_DATE()) AND YEAR(col) = YEAR(CURRENT_DATE())} */
    public static String andCurrentMonth(String dateColumn) {
        return " AND MONTH(" + dateColumn + ") = MONTH(CURRENT_DATE())"
            + " AND YEAR(" + dateColumn + ") = YEAR(CURRENT_DATE())";
    }

    /** {@code MONTH(col) = MONTH(CURRENT_DATE()) AND YEAR(col) = YEAR(CURRENT_DATE())} */
    public static String currentMonthWhere(String dateColumn) {
        return "MONTH(" + dateColumn + ") = MONTH(CURRENT_DATE())"
            + " AND YEAR(" + dateColumn + ") = YEAR(CURRENT_DATE())";
    }
}
