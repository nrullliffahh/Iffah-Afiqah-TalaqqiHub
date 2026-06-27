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
                    p.rescheduled.add(b);
                } else {
                    p.cancelled.add(b);
                }
            } else if (b.isRescheduledReplacement()) {
                p.rescheduled.add(b);
            } else if (b.isNeedsReschedule()) {
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
}
