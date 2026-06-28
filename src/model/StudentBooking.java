package model;

import java.time.LocalDate;
import java.time.LocalTime;
import util.BookingStatus;

public class StudentBooking {
    private String bookingId;
    private String studentId;
    private String scheduleId;
    private String classId;
    private LocalDate bookingDate;
    private LocalTime bookingTime;
    private String bookingStatus;
    private LocalDate createdAt;
    private String teacherName;
    private String studentName;
    private String className;
    private Integer duration;
    private String teacherId;
    private String cancellationReason;
    private boolean cancellationAllowed = true;
    private String attendanceStatus;
    /** True when linked talaqqisession.sessionDate is set (teacher ended live session). */
    private boolean talaqqiSessionEnded;

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(String scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getClassId() {
        return classId;
    }

    public void setClassId(String classId) {
        this.classId = classId;
    }

    public LocalDate getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(LocalDate bookingDate) {
        this.bookingDate = bookingDate;
    }

    public LocalTime getBookingTime() {
        return bookingTime;
    }

    public void setBookingTime(LocalTime bookingTime) {
        this.bookingTime = bookingTime;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public LocalDate getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDate createdAt) {
        this.createdAt = createdAt;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public String getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(String teacherId) {
        this.teacherId = teacherId;
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public void setCancellationReason(String cancellationReason) {
        this.cancellationReason = cancellationReason;
    }

    public boolean isCancellationAllowed() {
        return cancellationAllowed;
    }

    public void setCancellationAllowed(boolean cancellationAllowed) {
        this.cancellationAllowed = cancellationAllowed;
    }

    public String getAttendanceStatus() {
        return attendanceStatus;
    }

    public void setAttendanceStatus(String attendanceStatus) {
        this.attendanceStatus = attendanceStatus;
    }

    public boolean isTalaqqiSessionEnded() {
        return talaqqiSessionEnded;
    }

    public void setTalaqqiSessionEnded(boolean talaqqiSessionEnded) {
        this.talaqqiSessionEnded = talaqqiSessionEnded;
    }

    /** Student joined (Present/Late) and session ended but booking row not yet Completed. */
    public boolean isConductedPendingCompletion() {
        if (BookingStatus.isCompleted(bookingStatus)) {
            return false;
        }
        if (!talaqqiSessionEnded) {
            return false;
        }
        if (attendanceStatus == null) {
            return false;
        }
        String att = attendanceStatus.trim();
        return "Present".equalsIgnoreCase(att) || "Late".equalsIgnoreCase(att);
    }

    /** JSP EL: ${booking.needsReschedule} — only after teacher ended live session without completing booking. */
    public boolean isNeedsReschedule() {
        if (BookingStatus.isCompleted(bookingStatus)) {
            return false;
        }
        if (isConductedPendingCompletion()) {
            return false;
        }
        // New/future bookings: teacher has not ended the session yet → stay Upcoming
        return talaqqiSessionEnded;
    }

    public boolean isAbsent() {
        return attendanceStatus != null && "Absent".equalsIgnoreCase(attendanceStatus.trim());
    }

    /** True when booking should appear under Completed (not Upcoming/Rescheduled). */
    public boolean isCompletedDisplay() {
        return BookingStatus.isCompleted(bookingStatus) || isConductedPendingCompletion();
    }
    public boolean isFutureSession() {
        if (bookingDate == null) {
            return false;
        }
        java.time.ZoneId zone = util.AppTimeUtil.APP_ZONE;
        LocalDate today = LocalDate.now(zone);
        LocalTime now = LocalTime.now(zone);
        if (bookingDate.isAfter(today)) {
            return true;
        }
        if (bookingDate.isBefore(today) || bookingTime == null) {
            return false;
        }
        return bookingTime.isAfter(now);
    }

    /** True when scheduled start + duration has passed. */
    public boolean isSessionEnded() {
        if (bookingDate == null || bookingTime == null) {
            return false;
        }
        java.time.ZoneId zone = util.AppTimeUtil.APP_ZONE;
        LocalDate today = LocalDate.now(zone);
        LocalTime now = LocalTime.now(zone);
        if (bookingDate.isBefore(today)) {
            return true;
        }
        if (bookingDate.isAfter(today)) {
            return false;
        }
        int mins = duration != null && duration > 0 ? duration : 15;
        LocalTime endTime = bookingTime.plusMinutes(mins);
        return !now.isBefore(endTime);
    }

    /** New slot booked to replace a missed class. */
    public boolean isRescheduledReplacement() {
        if (cancellationReason == null) {
            return false;
        }
        return cancellationReason.toLowerCase().contains("rescheduled from");
    }

    /** Old booking marked rescheduled after student picks a new slot. */
    public boolean isRescheduled() {
        if (bookingStatus != null && "Rescheduled".equalsIgnoreCase(bookingStatus.trim())) {
            return true;
        }
        if (cancellationReason == null || bookingStatus == null) {
            return false;
        }
        return "Cancelled".equalsIgnoreCase(bookingStatus.trim())
            && cancellationReason.toLowerCase().contains("rescheduled to");
    }
}
