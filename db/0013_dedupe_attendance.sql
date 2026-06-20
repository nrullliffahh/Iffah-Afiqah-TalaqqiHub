-- Remove duplicate attendance rows (keep earliest joinTime per student/schedule/date)
DELETE a FROM attendance a
INNER JOIN (
    SELECT studentId, scheduleId, attendanceDate, MIN(attendanceId) AS keepId
    FROM attendance
    GROUP BY studentId, scheduleId, attendanceDate
    HAVING COUNT(*) > 1
) d ON a.studentId = d.studentId
   AND a.scheduleId = d.scheduleId
   AND a.attendanceDate = d.attendanceDate
   AND a.attendanceId <> d.keepId;

-- Prevent future duplicates
ALTER TABLE attendance
    ADD UNIQUE KEY uq_attendance_student_schedule_date (studentId, scheduleId, attendanceDate);
