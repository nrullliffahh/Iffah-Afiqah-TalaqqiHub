package util;

/**
 * Normalizes {@code classbooking.bookingStatus} across schema variants.
 * Production DB: ENUM('Pending','Confirmed','Cancelled','Completed','Approved','Rejected').
 * Some dev DBs use VARCHAR or ENUM with 'Upcoming'.
 */
public final class BookingStatus {

    /** Active / not-yet-completed bookings (for SELECT filters). */
    public static final String SQL_ACTIVE =
        "('Pending','Confirmed','Approved','Upcoming')";

    /** Status values to try on INSERT, in order. */
    private static final String[] NEW_BOOKING_CANDIDATES = {
        "Pending", "Upcoming", "Confirmed"
    };

    private BookingStatus() {
    }

    public static String[] newBookingCandidates() {
        return NEW_BOOKING_CANDIDATES.clone();
    }

    public static boolean isCancelled(String status) {
        if (status == null) {
            return false;
        }
        String s = status.trim();
        return "Cancelled".equalsIgnoreCase(s) || "Rejected".equalsIgnoreCase(s);
    }

    public static boolean isCompleted(String status) {
        return status != null && "Completed".equalsIgnoreCase(status.trim());
    }

    public static boolean isActive(String status) {
        if (status == null || status.isEmpty()) {
            return true;
        }
        return !isCancelled(status) && !isCompleted(status);
    }
}
