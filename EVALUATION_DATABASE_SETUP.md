# Quick Setup: Evaluation Form Database Connection

## What's Connected?

✅ **Frontend**: Teacher evaluation modal form (teacherEvaluation.jsp)
✅ **Backend**: TeacherEvaluationServlet - processes form data
✅ **Database Layer**: TeacherEvaluationDAO - saves to database
✅ **Model**: Evaluation.java - handles data objects

## Database Changes Required

### Run This SQL to Add New Columns:

```sql
ALTER TABLE evaluation ADD COLUMN areas_for_improvement TEXT NULL;
ALTER TABLE evaluation ADD COLUMN performance_tag VARCHAR(50) NULL;
ALTER TABLE evaluation ADD COLUMN next_target VARCHAR(100) NULL;
ALTER TABLE evaluation ADD COLUMN teacher_comments TEXT NULL;
ALTER TABLE evaluation ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE evaluation ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```

## How It Works

1. **Teacher fills form** → All fields captured (including Areas for Improvement, Next Target, etc.)
2. **Form submitted** → POST to TeacherEvaluationServlet
3. **Servlet processes** → Extracts all parameters and validates
4. **DAO saves** → Inserts/updates record in `evaluation` table
5. **Dashboard refreshes** → Shows updated evaluation

## Form Fields Saved to Database

| Field | Saves As | In Database As |
|-------|----------|-----------------|
| Session Date | sessionDate | session_date |
| Session Time | startTime/endTime | start_time, end_time |
| Surah | surah | surah |
| Tajweed Score | tajweedScore | tajweed_score |
| Fluency Score | fluencyScore | fluency_score |
| Accuracy Score | accuracyScore | accuracy_score |
| **Performance Tag** | performanceTag | **performance_tag** |
| **Strengths** | comments | **comments** |
| **Areas for Improvement** | areasForImprovement | **areas_for_improvement** |
| **Improvement Suggestions** | suggestions | **suggestions** |
| **Next Target** | nextTarget | **next_target** |
| **Teacher Comments** | teacherComments | **teacher_comments** |

## Deployment Steps

### Step 1: Apply Database Changes
```bash
# Open MySQL command line and run:
mysql -u root -p TalaqqiHubDB < add_evaluation_fields.sql
```

Or manually run the SQL above.

### Step 2: Recompile Java Files
```bash
cd c:\xampp\tomcat\webapps\TalaqqiHub

# Compile model
javac -cp "WEB-INF/lib/*" src/com/talaqqihub/model/Evaluation.java

# Compile DAO
javac -cp "WEB-INF/lib/*" src/com/talaqqihub/dao/TeacherEvaluationDAO.java

# Compile Servlet
javac -cp "WEB-INF/lib/*" src/com/talaqqihub/servlet/TeacherEvaluationServlet.java
```

### Step 3: Restart Tomcat
```bash
# Windows
c:\xampp\tomcat\bin\shutdown.bat
c:\xampp\tomcat\bin\startup.bat

# Linux/Mac
./shutdown.sh
./startup.sh
```

### Step 4: Test the Form
1. Go to Teacher Portal → Evaluation
2. Click "Evaluate Now" on a pending evaluation
3. Fill all fields
4. Click "Create Evaluation"
5. Check if data saved in database

## Verification Query

Run this to verify data was saved:

```sql
SELECT * FROM evaluation 
WHERE teacher_id = 1 AND status = 'COMPLETED' 
LIMIT 1;
```

Should show all new columns with your data.

## Files Modified

```
✅ create_eval_table.sql
✅ add_evaluation_fields.sql  
✅ src/com/talaqqihub/model/Evaluation.java
✅ src/com/talaqqihub/servlet/TeacherEvaluationServlet.java
✅ src/com/talaqqihub/dao/TeacherEvaluationDAO.java
✅ WEB-INF/views/teacherEvaluation.jsp (card design)
```

## Troubleshooting

**Issue**: Form submits but data doesn't appear in database
- ✓ Check if database columns were added (see Verification Query above)
- ✓ Check Tomcat logs: `logs/catalina.out`
- ✓ Verify Java files were compiled

**Issue**: 500 Error after form submission
- ✓ Check database connection in `context.xml`
- ✓ Verify teacher_id is in session
- ✓ Check column names match in DAO

**Issue**: Form fields appear empty when editing
- ✓ Verify all columns are being selected in SELECT query
- ✓ Check ResultSet mapping in `mapResultSetToEvaluation()`

## Database Flow Diagram

```
Form (JSP)
    ↓ POST with all field values
Servlet (TeacherEvaluationServlet)
    ↓ Extract parameters + validate
DAO (TeacherEvaluationDAO)
    ↓ Execute INSERT/UPDATE query
Database (evaluation table)
    ↓ Record saved with all fields
Frontend
    ↓ Redirect & show success message
Evaluation List
```

---
Ready to deploy! 🚀
