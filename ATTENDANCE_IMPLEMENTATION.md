# Attendance Marking Implementation

## Overview
Implemented automatic attendance marking for the student Talaqqi portal with the following rules:
- **ABSENT**: Student has a booking but doesn't join the talaqqi session after class time passes
- **LATE**: Student joins the session more than 5 minutes after the session start time

## Implementation Details

### 1. TalaqqiSessionDAO Updates

#### New Method: `markMissingStudentsAsAbsent(String sessionId, String teacherId)`
**Purpose**: Automatically marks all students who booked a session but did NOT join as ABSENT.

**When Called**: 
- Invoked when teacher ends the session (in `TeacherTalaqqiSessionServlet.endSession()`)

**Logic**:
1. Query all students with bookings for the session
2. Filter students who have NO attendance record for today
3. For each missing student: INSERT ABSENT attendance record
4. Returns count of students marked absent

**Example**:
```java
int absentCount = talaqqiSessionDAO.markMissingStudentsAsAbsent(sessionId, teacherId);
// If 2 students booked but didn't join → absentCount = 2
```

#### New Method: `determineAttendanceStatus(String sessionId, String studentId)`
**Purpose**: Determines if a student should be marked as PRESENT or LATE based on join time.

**When Called**: 
- Invoked when student joins the session (in `StudentTalaqqiSessionServlet.joinSession()`)

**Logic**:
1. Get session start time from `talaqqisession.sessionStartTime`
2. Calculate time difference between current time and session start
3. If difference > 5 minutes → return "Late"
4. Otherwise → return "Present"

**Example**:
```java
String status = talaqqiSessionDAO.determineAttendanceStatus(sessionId, studentId);
// If joined at 14:32 and session started at 14:25 (7 min) → "Late"
// If joined at 14:29 and session started at 14:25 (4 min) → "Present"
```

### 2. StudentTalaqqiSessionServlet Updates

#### `joinSession` Action Implementation
**Endpoint**: `POST /student/talaqqi-session?action=joinSession`

**Parameters**:
- `sessionId` (required) - The session ID

**Response**:
```json
{
  "success": true,
  "message": "Joined session as Present",
  "status": "Present"
}
```

**Flow**:
1. Validates session belongs to authenticated student
2. Calls `determineAttendanceStatus()` to check if joining is > 5 minutes late
3. Records attendance with automatic status determination
4. Returns status to student (feedback that they're on time or late)

#### `leaveSession` Action Implementation
**Endpoint**: `POST /student/talaqqi-session?action=leaveSession`

**Parameters**:
- `sessionId` (required) - The session ID

**Response**:
```json
{
  "success": true,
  "message": "Left session"
}
```

**Flow**:
1. Records leave time in attendance table
2. Used for calculating session duration

### 3. TeacherTalaqqiSessionServlet Updates

#### `endSession` Action Enhancement
**Endpoint**: `POST /teacher/sessions?action=endSession`

**New Behavior**:
1. Records leave time (as before)
2. **NEW**: Calls `markMissingStudentsAsAbsent()` to auto-mark no-shows
3. Completes session (as before)

**Response**:
```json
{
  "success": true,
  "absentMarked": 2,
  "message": "Session ended, 2 student(s) marked absent"
}
```

**Example Flow**:
- 3 students booked for class
- Only 2 students joined
- Teacher clicks "End Session"
- System automatically:
  - Marks the 1 no-show student as ABSENT
  - Records status for joined students (Present/Late based on join time)
  - Completes the session
  - Returns confirmation with count

## Database Schema

### Attendance Table Columns Used
```sql
attendanceId        -- Unique identifier
attendanceDate      -- Date of attendance (CURDATE)
attendanceStatus    -- 'Present', 'Late', or 'Absent'
joinTime            -- Time student joined (recorded by system)
leaveTime           -- Time student left (optional)
studentId           -- FK to student
teacherId           -- FK to teacher
scheduleId          -- FK to classschedule
markAutoAttendance  -- Boolean flag (true if recorded automatically)
```

## Data Flow Diagrams

### Scenario 1: Student Joins On Time
```
Student clicks "Join" 
  → StudentTalaqqiSessionServlet.joinSession()
    → TalaqqiSessionDAO.determineAttendanceStatus()
      → Check: current_time - sessionStartTime
      → Result: 3 minutes → "Present"
    → TalaqqiSessionDAO.recordAttendance(status="Present")
      → INSERT INTO attendance ... attendanceStatus='Present'
    → Response to student: "Joined session as Present"
```

### Scenario 2: Student Joins Late
```
Student clicks "Join" (7 minutes late)
  → StudentTalaqqiSessionServlet.joinSession()
    → TalaqqiSessionDAO.determineAttendanceStatus()
      → Check: 14:32 - 14:25 = 7 minutes
      → Result: "Late"
    → TalaqqiSessionDAO.recordAttendance(status="Late")
      → INSERT INTO attendance ... attendanceStatus='Late'
    → Response to student: "Joined session as Late"
```

### Scenario 3: Student No-show
```
Session Time: 14:25 - 14:55
Student booked but doesn't join
  
Teacher clicks "End Session" at 14:55
  → TeacherTalaqqiSessionServlet.endSession()
    → TalaqqiSessionDAO.completeSession()
    → TalaqqiSessionDAO.markMissingStudentsAsAbsent()
      → Query: students booked for this session with NO attendance record
      → For each missing student:
        → INSERT INTO attendance ... attendanceStatus='Absent'
    → Response: "Session ended, 1 student(s) marked absent"
```

## System Logs

When automatic processing occurs, logs are generated:

```
[TalaqqiSessionDAO] Marked 2 students as ABSENT for session S001
[TalaqqiSessionDAO] Student STU-005 joined 7 minutes after session start - marking as LATE
```

## API Endpoints

### For Students

**Join Session**
```
POST /student/talaqqi-session
Parameters:
  action=joinSession
  sessionId=TSB001
  
Response: 
  {
    "success": true,
    "status": "Present|Late",
    "message": "..."
  }
```

**Leave Session**
```
POST /student/talaqqi-session
Parameters:
  action=leaveSession
  sessionId=TSB001
  
Response:
  {
    "success": true,
    "message": "Left session"
  }
```

### For Teachers

**End Session (now with auto-absence marking)**
```
POST /teacher/sessions
Parameters:
  action=endSession
  sessionId=TSB001
  studentId=STU-001 (optional)
  
Response:
  {
    "success": true,
    "absentMarked": 2,
    "message": "Session ended, 2 student(s) marked absent"
  }
```

## Configuration

The 5-minute threshold for marking a student as LATE is hardcoded in `TalaqqiSessionDAO.determineAttendanceStatus()`:

```java
// If more than 5 minutes late, mark as LATE
if (diffMinutes > 5) {
    return "Late";
}
```

To change this threshold, modify the value `5` to your desired minute count.

## Testing Checklist

- [x] Student joins session on time → marked PRESENT
- [x] Student joins > 5 minutes after start → marked LATE
- [x] Student doesn't join before session ends → marked ABSENT when teacher ends session
- [x] Multiple students with mixed statuses → each marked correctly
- [x] Project compiles without errors

## Future Enhancements

Possible improvements:
1. Make the 5-minute threshold configurable (admin setting)
2. Add a grace period option (e.g., allow < 2 minutes grace for all students)
3. Email notifications to students if they're marked LATE
4. Automatic session cleanup task to mark ABSENT students without teacher intervention
5. Dashboard showing real-time attendance status during active sessions
