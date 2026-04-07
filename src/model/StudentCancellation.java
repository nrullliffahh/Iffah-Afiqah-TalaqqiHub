package model;

import java.time.LocalDate;
import java.time.LocalTime;

public class StudentCancellation {
    private String cancellationId;
    private String bookingId;
    private String studentId;
    private LocalDate cancellationDate;
    private LocalTime cancellationTime;
    private String reason;
    private String status;
    private String processedBy;
    private LocalDate processedAt;
    private String refundStatus;
    private String remarks;

    public String getCancellationId() {
        return cancellationId;
    }

    public void setCancellationId(String cancellationId) {
        this.cancellationId = cancellationId;
    }

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

    public LocalDate getCancellationDate() {
        return cancellationDate;
    }

    public void setCancellationDate(LocalDate cancellationDate) {
        this.cancellationDate = cancellationDate;
    }

    public LocalTime getCancellationTime() {
        return cancellationTime;
    }

    public void setCancellationTime(LocalTime cancellationTime) {
        this.cancellationTime = cancellationTime;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getProcessedBy() {
        return processedBy;
    }

    public void setProcessedBy(String processedBy) {
        this.processedBy = processedBy;
    }

    public LocalDate getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(LocalDate processedAt) {
        this.processedAt = processedAt;
    }

    public String getRefundStatus() {
        return refundStatus;
    }

    public void setRefundStatus(String refundStatus) {
        this.refundStatus = refundStatus;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}
