SELECT cs.scheduleId, cs.startTime, cs.endTime, cs.duration, t.teacherName, cb.bookingId, cb.studentId AS bookingStudentId, cb.bookingStatus
FROM classschedule cs
LEFT JOIN teacher t ON cs.teacherId = t.teacherId
LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus != 'Cancelled'
WHERE cs.scheduleDate = '2026-01-22'
ORDER BY cs.startTime ASC;
