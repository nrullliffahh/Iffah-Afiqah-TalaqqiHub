package util;

import model.StudentBooking;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/** Shared booking list partition: Upcoming → Rescheduled → Completed → Cancelled. */
public final class BookingPartitionUtil {

    private BookingPartitionUtil() {}

    public static class Partition {
        public final List<StudentBooking> upcoming = new ArrayList<>();
        public final List<StudentBooking> rescheduled = new ArrayList<>();
        public final List<StudentBooking> completed = new ArrayList<>();
        public final List<StudentBooking> cancelled = new ArrayList<>();
    }

    public static Partition partition(List<StudentBooking> bookings) {
        Partition p = new Partition();
        if (bookings == null) {
            return p;
        }
        for (StudentBooking b : bookings) {
            String status = b.getBookingStatus();
            if (status == null) {
                status = "";
            }
            if ("Cancelled".equalsIgnoreCase(status) || "Rescheduled".equalsIgnoreCase(status)) {
                if (b.isRescheduled()) {
                    // Old slot replaced by a new booking — hide; only the replacement appears under Rescheduled
                    continue;
                } else {
                    p.cancelled.add(b);
                }
            } else if (b.isRescheduledReplacement()) {
                p.rescheduled.add(b);
            } else if (isActiveUpcomingBooking(b, status)) {
                p.upcoming.add(b);
            } else if (b.isNeedsReschedule() || b.isCompletedDisplay()) {
                p.completed.add(b);
            } else if ("Completed".equalsIgnoreCase(status)) {
                if (b.isFutureSession()) {
                    p.upcoming.add(b);
                } else {
                    p.completed.add(b);
                }
            } else {
                p.upcoming.add(b);
            }
        }
        p.completed.sort(Comparator.comparing(StudentBooking::isNeedsReschedule).reversed());
        return p;
    }

    /**
     * Bookings eligible for the Talaqqi Switch Session picker on student and teacher portals:
     * same Upcoming + Rescheduled partitions as Class Booking, future slots only.
     */
    public static List<StudentBooking> switchableOnly(List<StudentBooking> bookings) {
        Partition p = partition(bookings);
        List<StudentBooking> out = new ArrayList<>();
        for (StudentBooking b : p.upcoming) {
            if (isSwitchableTalaqqiBooking(b)) {
                out.add(b);
            }
        }
        for (StudentBooking b : p.rescheduled) {
            if (isSwitchableTalaqqiBooking(b)) {
                out.add(b);
            }
        }
        out.sort(Comparator
            .comparing(StudentBooking::getBookingDate, Comparator.nullsLast(Comparator.naturalOrder()))
            .thenComparing(b -> b.getBookingTime() != null ? b.getBookingTime() : java.time.LocalTime.MIN));
        return out;
    }

    /** Switch Session picker: Upcoming + Rescheduled only (not completed / not-completed / ended). */
    private static boolean isSwitchableTalaqqiBooking(StudentBooking b) {
        if (b == null) {
            return false;
        }
        if (!b.isFutureSession()) {
            return false;
        }
        if (b.isTalaqqiSessionEnded()) {
            return false;
        }
        if (b.isNeedsReschedule()) {
            return false;
        }
        if (b.isCompletedDisplay()) {
            return false;
        }
        if (BookingStatus.isCompleted(b.getBookingStatus())) {
            return false;
        }
        return BookingStatus.isActive(b.getBookingStatus()) || b.isRescheduledReplacement();
    }

    /** Active future booking with no ended live session → always Upcoming (never Not Completed). */
    private static boolean isActiveUpcomingBooking(StudentBooking b, String status) {
        if (b == null) {
            return false;
        }
        if (b.isRescheduledReplacement()) {
            return false;
        }
        if (!BookingStatus.isActive(status)) {
            return false;
        }
        if (b.isTalaqqiSessionEnded()) {
            return false;
        }
        if (b.isNeedsReschedule()) {
            return false;
        }
        if (b.isCompletedDisplay()) {
            return false;
        }
        return b.isFutureSession() || !b.isSessionEnded();
    }
}
