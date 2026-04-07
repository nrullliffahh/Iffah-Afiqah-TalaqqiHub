SELECT scheduleId, teacherId, className, scheduleDate, startTime, classStatus, studentId FROM classschedule WHERE scheduleId IN ('C001','C002','C003','C005');
SELECT scheduleId, teacherId, className, scheduleDate, startTime, classStatus, studentId FROM classschedule WHERE scheduleDate >= CURDATE() ORDER BY scheduleDate, startTime LIMIT 50;
SELECT teacherId, teacherName FROM teacher;
