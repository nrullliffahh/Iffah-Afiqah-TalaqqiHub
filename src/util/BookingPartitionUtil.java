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
            } else if (BookingStatus.isActive(status) && !b.isAttended() && !b.isNeedsReschedule()) {
                p.upcoming.add(b);
            } else if (b.isAttended()) {
                p.completed.add(b);
            } else if (b.isNeedsReschedule() || b.isAbsent()) {
                p.completed.add(b);
            } else if ("Completed".equalsIgnoreCase(status)) {
                p.completed.add(b);
            } else {
                p.upcoming.add(b);
            }
        }
        p.completed.sort(Comparator.comparing(StudentBooking::isAbsent).reversed());
        return p;
    }

    /**
     * Bookings eligible for the Talaqqi Switch Session picker on student and teacher portals:
     * same Upcoming + Rescheduled partitions as Class Booking.
     */
    public static List<StudentBooking> switchableOnly(List<StudentBooking> bookings) {
        Partition p = partition(bookings);
        List<StudentBooking> out = new ArrayList<>();
        for (StudentBooking b : p.upcoming) {
            if (b != null && !b.isAttended()) {
                out.add(b);
            }
        }
        for (StudentBooking b : p.rescheduled) {
            if (b != null && !b.isAttended()) {
                out.add(b);
            }
        }
        out.sort(Comparator
            .comparing(StudentBooking::getBookingDate, Comparator.nullsLast(Comparator.naturalOrder()))
            .thenComparing(b -> b.getBookingTime() != null ? b.getBookingTime() : java.time.LocalTime.MIN));
        return out;
    }
}
