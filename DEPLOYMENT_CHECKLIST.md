# Quick Deployment Checklist - Student & Teacher Evaluation Database Connection

## Pre-Deployment

### 1. Database Preparation
```sql
-- Backup current database (IMPORTANT!)
BACKUP DATABASE TalaqqiHubDB TO DISK = 'backup_location.bak';

-- Run migration for teacher evaluation table
ALTER TABLE evaluation ADD COLUMN areas_for_improvement TEXT NULL;
ALTER TABLE evaluation ADD COLUMN performance_tag VARCHAR(50) NULL;
ALTER TABLE evaluation ADD COLUMN next_target VARCHAR(100) NULL;
ALTER TABLE evaluation ADD COLUMN teacher_comments TEXT NULL;
ALTER TABLE evaluation ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE evaluation ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Verify student evaluation table exists
DESCRIBE studentevaluation;

-- Create indexes
ALTER TABLE evaluation ADD INDEX idx_performance_tag (performance_tag);
ALTER TABLE evaluation ADD INDEX idx_created_at (created_at);
```

### 2. Verify Database Records
```sql
-- Check if student evaluations exist
SELECT COUNT(*) FROM studentevaluation;

-- Check if teacher evaluations exist
SELECT COUNT(*) FROM evaluation;

-- Get sample student ID for testing
SELECT DISTINCT studentId FROM studentevaluation LIMIT 1;

-- Get sample teacher ID for testing
SELECT DISTINCT teacher_id FROM evaluation LIMIT 1;
```

## Deployment Steps

### Step 1: Recompile Java Files
```bash
cd c:\xampp\tomcat\webapps\TalaqqiHub

# Student Evaluation classes
javac -cp "WEB-INF/lib/*" src/controller/StudentEvaluationServlet.java
javac -cp "WEB-INF/lib/*" src/dao/EvaluationDAO.java

# Teacher Evaluation classes  
javac -cp "WEB-INF/lib/*" src/com/talaqqihub/servlet/TeacherEvaluationServlet.java
javac -cp "WEB-INF/lib/*" src/com/talaqqihub/dao/TeacherEvaluationDAO.java
javac -cp "WEB-INF/lib/*" src/com/talaqqihub/model/Evaluation.java
```

### Step 2: Verify Files
- ✓ Check `WEB-INF/classes/controller/StudentEvaluationServlet.class` exists
- ✓ Check `WEB-INF/classes/dao/EvaluationDAO.class` exists
- ✓ Check `WEB-INF/classes/com/talaqqihub/servlet/TeacherEvaluationServlet.class` exists
- ✓ Check `WEB-INF/classes/com/talaqqihub/dao/TeacherEvaluationDAO.class` exists
- ✓ Verify `teacherEvaluation.jsp` has updated design

### Step 3: Stop Tomcat
```bash
# Windows
c:\xampp\tomcat\bin\shutdown.bat

# Wait 5 seconds for clean shutdown
timeout /t 5

# Linux/Mac
./shutdown.sh
```

### Step 4: Clear Tomcat Cache (Optional but Recommended)
```bash
# Windows
del c:\xampp\tomcat\work\Catalina\localhost\TalaqqiHub\*.*

# Linux/Mac
rm -rf ./work/Catalina/localhost/TalaqqiHub/*
```

### Step 5: Start Tomcat
```bash
# Windows
c:\xampp\tomcat\bin\startup.bat

# Linux/Mac
./startup.sh
```

### Step 6: Verify Startup
- Wait 30-60 seconds for Tomcat to start
- Check logs: `c:\xampp\tomcat\logs\catalina.out`
- Look for errors related to database connection

## Testing

### Test 1: Student Evaluation Access
```
URL: http://localhost:8080/TalaqqiHub/student/evaluation
Expected:
- Page loads without errors
- Dashboard shows data from database
- Charts display (if data exists)
- Forms are functional
```

### Test 2: Teacher Evaluation Access
```
URL: http://localhost:8080/TalaqqiHub/teacher/evaluation
Expected:
- Page loads without errors
- Dashboard summary displays
- Pending evaluations show
- Completed evaluations list appears
- Forms can be filled
```

### Test 3: Form Submission
```
Student:
1. Go to evaluation page
2. Click "Evaluate" on a session
3. Fill rating and feedback
4. Submit
5. Verify "success" appears

Teacher:
1. Go to evaluation page
2. Click "Evaluate Now" on pending
3. Fill all fields
4. Click "Create Evaluation"
5. Verify success message and data appears in completed list
```

### Test 4: Data Verification
```sql
-- Check new student evaluation was created
SELECT * FROM studentevaluation 
ORDER BY studentEvaluationId DESC LIMIT 1;

-- Check new teacher evaluation was created
SELECT * FROM evaluation 
WHERE status = 'COMPLETED' 
ORDER BY created_at DESC LIMIT 1;
```

## Rollback Plan (If Issues Occur)

### If Tomcat Won't Start
1. Stop Tomcat
2. Restore from backup (if available)
3. Clear Tomcat cache: `work/Catalina/localhost/TalaqqiHub/*`
4. Check logs for specific errors
5. Recompile classes

### If Database Errors Occur
1. Stop application
2. Restore database backup
3. Verify table structure
4. Re-run SQL migrations
5. Restart

### If Pages Won't Load
1. Check browser console for JavaScript errors
2. Verify servlet is responding: check Tomcat logs
3. Verify JSP page exists and has no syntax errors
4. Clear browser cache

## Production Checklist

- [ ] Database backup created
- [ ] SQL migrations tested on backup first
- [ ] Java files compiled without errors
- [ ] Files deployed to correct locations
- [ ] Tomcat restarted cleanly
- [ ] Both servlet endpoints respond
- [ ] Student evaluation page loads
- [ ] Teacher evaluation page loads
- [ ] Form submission works
- [ ] Data appears in database
- [ ] Logs show no errors
- [ ] Dashboard statistics update

## Log Files to Check

```
Tomcat Errors:
  c:\xampp\tomcat\logs\catalina.out
  c:\xampp\tomcat\logs\catalina.{date}.log

MySQL Errors:
  c:\xampp\mysql\data\*.err

Browser Console:
  F12 → Console tab
  Look for network errors, SQL errors, JavaScript errors
```

## Performance Verification

After deployment, verify performance:

```sql
-- Check response time for dashboard query
SELECT COUNT(*) FROM evaluation WHERE teacher_id = 1;

-- Check if indexes are being used
EXPLAIN SELECT * FROM evaluation 
WHERE performance_tag = 'Excellent' 
ORDER BY created_at DESC;

-- Verify average load time
SELECT AVG(TIMESTAMPDIFF(SECOND, created_at, updated_at)) 
FROM evaluation;
```

## Support Commands

```bash
# Check if port 8080 is in use
netstat -ano | findstr :8080

# Check Tomcat Java process
tasklist | findstr java

# View Tomcat version
type c:\xampp\tomcat\RELEASE-NOTES.txt

# Check database connection from command line
mysql -u root -p -h localhost -e "SELECT @@version;"
```

---

**Estimated Deployment Time:** 15-20 minutes
**Downtime:** 2-5 minutes (during Tomcat restart)
**Rollback Time:** 5-10 minutes (if needed)

**Contact Support If:**
- Tomcat won't start after changes
- Database connection fails
- Forms don't submit properly
- Data appears partially or not at all
