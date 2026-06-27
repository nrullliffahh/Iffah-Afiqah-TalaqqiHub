package model;

import java.time.LocalDate;
import java.time.LocalTime;

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
    private String className;
    private Integer duration;
    private String teacherId;
    private String cancellationReason;
    private boolean cancellationAllowed = true;
    private String attendanceStatus;

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

    public boolean isAbsent() {
        return attendanceStatus != null && "Absent".equalsIgnoreCase(attendanceStatus.trim());
    }

    public boolean isFutureSession() {
        if (bookingDate == null) {
            return false;
        }
        java.time.LocalDate today = java.time.LocalDate.now();
        if (bookingDate.isAfter(today)) {
            return true;
        }
        if (bookingDate.isBefore(today) || bookingTime == null) {
            return false;
        }
        return bookingTime.isAfter(java.time.LocalTime.now());
    }

    public boolean isRescheduled() {
        if (bookingStatus != null && "Rescheduled".equalsIgnoreCase(bookingStatus.trim())) {
            return true;
        }
        if (cancellationReason == null) {
            return false;
        }
        return cancellationReason.toLowerCase().contains("rescheduled");
    }

    /** Completed session the student did not attend (or attendance was never recorded). */
    public boolean isNotCompleted() {
        if (bookingStatus == null || !"Completed".equalsIgnoreCase(bookingStatus.trim())) {
            return false;
        }
        if (isFutureSession()) {
            return false;
        }
        if (isAbsent()) {
            return true;
        }
        if (attendanceStatus == null || attendanceStatus.trim().isEmpty()) {
            return true;
        }
        String att = attendanceStatus.trim();
        return !"Present".equalsIgnoreCase(att) && !"Late".equalsIgnoreCase(att);
    }
}
