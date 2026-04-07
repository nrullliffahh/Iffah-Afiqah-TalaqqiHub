SELECT scheduleId, bookingId, bookingStatus, studentId FROM classbooking WHERE scheduleId IN ('C001','C002','C003','C005');

SELECT cs.scheduleId, cs.className, cs.scheduleDate, cs.startTime, cs.endTime, cs.duration, cs.classStatus,
       cb.studentId AS bookedStudentId, s2.studentName AS bookedStudentName, cs.studentId AS assignedStudentId, s1.studentName AS assignedStudentName
FROM classschedule cs
LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.bookingDate = cs.scheduleDate AND (cb.bookingStatus = 'Upcoming' OR cb.bookingStatus = 'Confirmed' OR cb.bookingStatus = 'Approved')
LEFT JOIN student s2 ON cb.studentId = s2.studentId
LEFT JOIN student s1 ON cs.studentId = s1.studentId
WHERE cs.teacherId = 'T001' AND cs.scheduleDate >= CURDATE()
GROUP BY cs.scheduleId
ORDER BY cs.scheduleDate ASC, cs.startTime ASC
LIMIT 5;
