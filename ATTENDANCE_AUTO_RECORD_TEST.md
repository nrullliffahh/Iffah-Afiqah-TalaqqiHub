# Attendance Auto-Recording Test Guide

## What Was Fixed

When a student joins the Talaqqi session (kelas live session), their attendance is now automatically recorded in the system, even if they don't click a specific button.

### Before
- Student had to click a button for attendance to be recorded
- If forgot to click → marked ABSENT
- Even if student was actively in the Jitsi room

### After  
- Attendance automatically recorded when:
  - Student clicks "Join Live Session" button, OR
  - Student's Jitsi client joins the conference (videoConferenceJoined event)
- Status determined by server:
  - **PRESENT**: joined within 2 minutes of session start time
  - **LATE**: joined more than 2 minutes after session start time

---

## Test Scenario 1: Normal Button Click (Most Common)

### Setup
- Create a scheduled class for a student at a specific time (e.g., 3:00 PM)
- Have the student access their Talaqqi session page at class time

### Test Steps
1. Student opens Talaqqi session in browser
2. Student sees "Join Live Session" button
3. Student clicks the button
4. Jitsi Meet video conference appears
5. Note the exact time student's camera/audio connects
6. Student stays in conference for 2-3 minutes

### Expected Results
- ✅ Browser console shows: "Student joined Jitsi session"
- ✅ Server logs: "Joined session as Present" or "Joined session as Late"
- ✅ In database (attendance table):
  - attendanceStatus = 'Present' (if joined ≤5 min after class start time)
  - attendanceStatus = 'Late' (if joined >5 min after class start time)
  - joinTime = timestamp of when Jitsi event fired

### Verification
Run this SQL query:
```sql
SELECT attendanceId, attendanceDate, attendanceStatus, joinTime, leaveTime
FROM attendance
WHERE studentId = '[STUDENT_ID]' 
  AND attendanceDate = CURDATE()
ORDER BY attendanceDate DESC
LIMIT 1;
```

Should show recent attendance record with status Present or Late.

---

## Test Scenario 2: Late Join (After 2 Minute Grace Period)

### Setup
- Schedule a class for 3:00 PM
- Prepare to have student join at 3:03 PM (3 minutes late)

### Test Steps
1. Start the session at exactly 3:00 PM (as teacher)
2. Wait until 3:03 PM
3. Student clicks "Join Live Session" button
4. Wait for Jitsi to load and student to join

### Expected Results
- ✅ Server logs: "Joined session as Late"
- ✅ Database shows: attendanceStatus = 'Late'
- ✅ Message displayed: "Joined session as Late"

---

## Test Scenario 3: Teacher End Session Mark Absent

Any student with a booking who DID NOT join the session should be marked ABSENT when the teacher ends the session.

### Setup
- Schedule class with 2 students: StudentA and StudentB
- Only StudentA joins the session

### Test Steps
1. Student A clicks "Join Live Session" and joins Jitsi
2. Student B does NOT join (ignores the class)
3. Teacher ends the session (clicks "End Session" button in teacher panel)
4. Wait 2-3 seconds for processing

### Expected Results
- ✅ Teacher sees message: "Session ended, 1 student(s) marked absent"
- ✅ Student B's attendance record shows: attendanceStatus = 'Absent'  
- ✅ Student A's record unchanged (still shows Present or Late)

---

## Test Scenario 4: How to Check/Debug Attendance Issues

### Check Database Records
```sql
-- See all attendance for a specific student today
SELECT a.attendanceId, a.attendanceStatus, a.joinTime, a.leaveTime, 
       a.attendanceDate, s.scheduleDate, s.scheduleStartTime
FROM attendance a
JOIN classschedule s ON a.scheduleId = s.scheduleId  
WHERE a.studentId = '[STUDENT_ID]'
  AND DATE(a.attendanceDate) = CURDATE()
ORDER BY a.attendanceDate DESC;

-- Check if session exists and has a booking
SELECT ts.sessionId, ts.bookingId, ts.sessionStartTime, ts.sessionEndTime,
       cb.studentId, cb.bookingStatus
FROM talaqqisession ts
JOIN classbooking cb ON ts.bookingId = cb.bookingId
WHERE ts.sessionId = '[SESSION_ID]';
```

### Check Browser Console
When student joins, look for these logs:
```
[Auto-Attendance] Recorded attendance for active session: [sessionId]
Student joined Jitsi session
Event recorded: {success: true, message: "Joined session as Present", status: "Present"}
```

### Check Server Logs
Look for:
```
[StudentTalaqqiSessionServlet] Student [studentId] joined session [sessionId]
[TalaqqiSessionDAO] determineAttendanceStatus: Student [studentId] joined X minutes after session start - marking as [Present/Late]
[TalaqqiSessionDAO] recordAttendance: Attendance recorded for student [studentId]
```

---

## Troubleshooting

### Problem: "Joined session" not showing in browser
- Check if student is authenticated (logged in)
- Check if sessionId is being passed correctly
- Check browser DevTools → Network tab for POST requests to `/student/talaqqi-session`
- Verify response status is 200 (not 401, 403, or 500)

### Problem: Attendance status wrong (marked Late when should be Present)
- Check actual database: `SELECT sessionStartTime FROM talaqqisession WHERE sessionId = '[ID]'`
- Verify system time on server is correct
- Check join time in attendance table vs session start time
- The calculation is: `joinTime > (sessionStartTime + 5 minutes)` → mark LATE

### Problem: Student NOT marked absent at session end
- Verify student has a BOOKING for that session (check classbooking table)
- Verify booking status is 'Upcoming' or 'Approved'
- Verify NO attendance record exists for that student+schedule on that date
- Check if teacher clicked "End Session" button in the session end control (not just closed Jitsi)

---

## Changing the Grace Period

If you want to change from 2 minutes to a different value:

1. Edit `src/dao/TalaqqiSessionDAO.java`
2. Find method: `determineAttendanceStatus()`
3. Look for line: `if (diffMinutes > 2) {`
4. Change 2 to your desired minutes (e.g., 5 for 5-minute grace period)
5. Recompile and redeploy

Current setting: **2 minutes**

---

## Summary

The attendance system now automatically tracks when students join the live Talaqqi session through Jitsi. The fix ensures that:

✅ Students who click "Join Live Session" are properly recorded  
✅ Students are marked Present or Late based on join timing  
✅ Students who don't join are auto-marked Absent when teacher ends session  
✅ Attendance data flows correctly to the database for reporting  

Run the test scenarios above to verify the system is working correctly in your environment.
