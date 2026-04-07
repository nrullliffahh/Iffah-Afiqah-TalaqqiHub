package model;

import java.time.LocalDate;
import java.time.LocalTime;

public class ClassSchedule {
    private String scheduleId;
    private String className;
    private LocalDate scheduleDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private Integer duration;
    private String classStatus;
    private String teacherId;
    private String teacherName;
    private String bookingStatus;  // NEW: tracks if slot is booked/confirmed

    public String getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(String scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public LocalDate getScheduleDate() {
        return scheduleDate;
    }

    public void setScheduleDate(LocalDate scheduleDate) {
        this.scheduleDate = scheduleDate;
    }

    public void setScheduleDate(String scheduleDate) {
        if (scheduleDate == null || scheduleDate.isEmpty() || scheduleDate.contains("--")) {
            throw new IllegalArgumentException("Invalid date format: " + scheduleDate);
        }
        try {
            this.scheduleDate = LocalDate.parse(scheduleDate);
        } catch (Exception e) {
            throw new IllegalArgumentException("Cannot parse date '" + scheduleDate + "'. Expected format: yyyy-MM-dd", e);
        }
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public void setStartTime(String startTime) {
        if (startTime == null || startTime.isEmpty() || startTime.contains("--")) {
            throw new IllegalArgumentException("Invalid start time format: " + startTime);
        }
        try {
            this.startTime = LocalTime.parse(startTime);
        } catch (Exception e) {
            throw new IllegalArgumentException("Cannot parse start time '" + startTime + "'. Expected format: HH:mm:ss", e);
        }
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public void setEndTime(String endTime) {
        if (endTime == null || endTime.isEmpty() || endTime.contains("--")) {
            throw new IllegalArgumentException("Invalid end time format: " + endTime);
        }
        try {
            this.endTime = LocalTime.parse(endTime);
        } catch (Exception e) {
            throw new IllegalArgumentException("Cannot parse end time '" + endTime + "'. Expected format: HH:mm:ss", e);
        }
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public String getClassStatus() {
        return classStatus;
    }

    public void setClassStatus(String classStatus) {
        this.classStatus = classStatus;
    }

    public String getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(String teacherId) {
        this.teacherId = teacherId;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }
}
