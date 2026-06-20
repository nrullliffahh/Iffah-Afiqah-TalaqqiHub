# Teacher Evaluation Module - Setup Guide

## 📋 Overview
This is a complete Teacher Evaluation Module for the TalaqqiHub application using JSP + Servlet + DAO with MVC architecture.

## 📁 File Structure

```
TalaqqiHub/
├── src/com/talaqqihub/
│   ├── model/
│   │   └── Evaluation.java          (Model Class)
│   ├── dao/
│   │   └── TeacherEvaluationDAO.java (Data Access Object)
│   └── servlet/
│       └── TeacherEvaluationServlet.java (Controller)
└── teacherEvaluation.jsp            (View - JSP)
```

## 🗄️ Database Setup

### Create Evaluation Table

```sql
CREATE TABLE evaluation (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    class_name VARCHAR(100),
    surah VARCHAR(100),
    ayah_range VARCHAR(50),
    session_date DATE,
    start_time TIME,
    end_time TIME,
    tajweed_score FLOAT DEFAULT 0,
    fluency_score FLOAT DEFAULT 0,
    accuracy_score FLOAT DEFAULT 0,
    overall_score FLOAT DEFAULT 0,
    rating INT DEFAULT 0,
    comments TEXT,
    suggestions TEXT,
    status ENUM('PENDING', 'COMPLETED') DEFAULT 'PENDING',
    teacher_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_teacher_id (teacher_id),
    KEY idx_student_id (student_id),
    KEY idx_status (status)
);
```

### Insert Sample Data (Optional)

```sql
INSERT INTO evaluation (student_id, student_name, class_name, surah, ayah_range, session_date, start_time, end_time, tajweed_score, fluency_score, accuracy_score, overall_score, rating, comments, suggestions, status, teacher_id)
VALUES 
(1, 'Ahmed Ali', 'Class A', 'Al-Fatiha', '1-7', '2024-04-20', '10:00:00', '10:30:00', 88.5, 90.0, 87.0, 88.5, 4, 'Good recitation', 'Work on pronunciation', 'COMPLETED', 1),
(2, 'Fatima Khan', 'Class B', 'Al-Baqarah', '1-20', '2024-04-21', '11:00:00', '11:45:00', 92.0, 89.5, 91.0, 90.8, 5, 'Excellent work', 'Keep it up', 'COMPLETED', 1),
(3, 'Zainab Hassan', 'Class A', 'An-Nisa', '1-10', '2024-04-22', '14:00:00', '14:30:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, 'PENDING', 1);
```

## 🔧 Installation Steps

### Step 1: Create Java Source Directories
```bash
mkdir -p src/com/talaqqihub/model
mkdir -p src/com/talaqqihub/dao
mkdir -p src/com/talaqqihub/servlet
```

### Step 2: Copy Java Files
- Copy `Evaluation.java` to `src/com/talaqqihub/model/`
- Copy `TeacherEvaluationDAO.java` to `src/com/talaqqihub/dao/`
- Copy `TeacherEvaluationServlet.java` to `src/com/talaqqihub/servlet/`

### Step 3: Copy JSP File
- Copy `teacherEvaluation.jsp` to the root of webapps/TalaqqiHub/

### Step 4: Configure web.xml (Servlet Mapping)

Add the following to your `WEB-INF/web.xml`:

```xml
<!-- Servlet Definition -->
<servlet>
    <servlet-name>TeacherEvaluationServlet</servlet-name>
    <servlet-class>com.talaqqihub.servlet.TeacherEvaluationServlet</servlet-class>
</servlet>

<!-- Servlet Mapping -->
<servlet-mapping>
    <servlet-name>TeacherEvaluationServlet</servlet-name>
    <url-pattern>/TeacherEvaluationServlet</url-pattern>
</servlet-mapping>
```

### Step 5: Compile Java Files

From the TalaqqiHub directory:

```bash
javac -cp "lib/*" -d build/classes src/com/talaqqihub/model/Evaluation.java
javac -cp "lib/*:build/classes" -d build/classes src/com/talaqqihub/dao/TeacherEvaluationDAO.java
javac -cp "lib/*:build/classes" -d build/classes src/com/talaqqihub/servlet/TeacherEvaluationServlet.java
```

Or use a build script (compile_evaluation.bat):

```batch
@echo off
set CLASSPATH=lib\*;build\classes
javac -cp %CLASSPATH% -d build/classes src/com/talaqqihub/model/Evaluation.java
javac -cp %CLASSPATH% -d build/classes src/com/talaqqihub/dao/TeacherEvaluationDAO.java
javac -cp %CLASSPATH% -d build/classes src/com/talaqqihub/servlet/TeacherEvaluationServlet.java
echo Compilation complete!
```

### Step 6: Deploy to Tomcat

Copy the compiled classes to:
```
webapps/TalaqqiHub/WEB-INF/classes/com/talaqqihub/model/
webapps/TalaqqiHub/WEB-INF/classes/com/talaqqihub/dao/
webapps/TalaqqiHub/WEB-INF/classes/com/talaqqihub/servlet/
```

Or use Tomcat's build process in your IDE (Maven, Gradle, Ant, etc.)

### Step 7: Restart Tomcat

## 🚀 Usage

### Accessing the Teacher Evaluation Module

1. **Login** as a teacher in TalaqqiHub
2. **Navigate** to: `http://localhost:8080/TalaqqiHub/TeacherEvaluationServlet`

### Features

#### Dashboard Summary
- Total students evaluated
- Total sessions evaluated
- Average scores (Overall, Tajweed, Fluency, Accuracy)

#### Pending Evaluations
- Lists students awaiting evaluation
- Click "Evaluate Now" to open the evaluation form
- Fill in scores, rating, comments, and suggestions

#### Completed Evaluations
- Search by student name or surah
- Filter by class name
- Sort by: Newest, Oldest, Best Score, Lowest Score
- View/Edit buttons for each evaluation
- Color-coded performance indicators

#### Student Feedback
- Display comments and suggestions from evaluations
- Star ratings for each evaluation
- Organized feedback cards

## 📝 Key Classes

### Evaluation.java (Model)
- 18 fields for evaluation data
- Getter/Setter methods
- Helper methods: `getPerformanceLabel()`, `getPerformanceColor()`

### TeacherEvaluationDAO.java
Methods:
- `getDashboardSummary(teacherId)` - Get statistics
- `getPendingEvaluations(teacherId)` - Pending list
- `getCompletedEvaluations(teacherId, search, filter, sort)` - Completed with filters
- `getEvaluationById(evaluationId)` - Single evaluation
- `insertEvaluation(evaluation)` - Create new
- `updateEvaluation(evaluation)` - Update existing
- `deleteEvaluation(evaluationId, teacherId)` - Delete
- `getClassNames(teacherId)` - For filter dropdown

### TeacherEvaluationServlet.java
Methods:
- `doGet()` - Load dashboard and forward to JSP
- `doPost()` - Handle insert/update operations
- `extractEvaluationFromRequest()` - Parse form data

### teacherEvaluation.jsp
Sections:
1. **Navigation Bar** - TalaqqiHub branding
2. **Dashboard Cards** - 6 summary statistics
3. **Pending Evaluations** - Grid of cards with "Evaluate Now" button
4. **Completed Evaluations** - Table with search, filter, sort
5. **Student Feedback** - Comments and suggestions display
6. **Modals** - For evaluation entry and viewing

## 🎨 UI Features

- **Tailwind CSS** - Responsive design
- **Gradient Buttons** - Purple to Pink theme
- **Card Layouts** - Modern rounded corners (rounded-xl)
- **Shadow Effects** - Depth and hierarchy
- **Responsive Grid** - Works on mobile, tablet, desktop
- **Modal Dialogs** - Smooth popups for forms
- **Color Coding** - Performance indicators by score

## 🔐 Security Notes

1. **Session Check** - Verifies teacher is logged in
2. **Teacher ID** - All queries scoped to current teacher
3. **Authorization** - Teachers can only see/edit their own evaluations
4. **Input Validation** - Server-side validation in servlet

## ⚙️ Database Connection

The servlet uses JNDI DataSource:
```
java:comp/env/jdbc/TalaqqiHub
```

Ensure your `context.xml` includes:
```xml
<Resource name="jdbc/TalaqqiHub"
          auth="Container"
          type="javax.sql.DataSource"
          maxActive="100"
          maxIdle="30"
          maxWait="10000"
          username="root"
          password="your_password"
          driverClassName="com.mysql.jdbc.Driver"
          url="jdbc:mysql://localhost:3306/talaqqihub_db" />
```

## 🛠️ Troubleshooting

### Database Connection Error
- Check DataSource configuration in context.xml
- Verify MySQL is running
- Check database credentials

### JSP Not Found
- Ensure teacherEvaluation.jsp is in webapps/TalaqqiHub/
- Clear Tomcat cache and restart

### Servlet Not Found (404)
- Verify servlet mapping in web.xml
- Check Java classes compiled to correct location
- Restart Tomcat

### No Data Displayed
- Verify evaluation table has sample data
- Check if teacher_id in session matches database records
- Look at Tomcat logs for SQL errors

## 📊 Example Score Calculation

Overall Score = (Tajweed + Fluency + Accuracy) / 3

**Performance Labels:**
- 90-100% → Excellent (Green)
- 80-89% → Good (Blue)
- 70-79% → Satisfactory (Yellow)
- 60-69% → Fair (Orange)
- Below 60% → Poor (Red)

## 🔄 Future Enhancements

- Export evaluations to PDF/Excel
- Email notifications
- Bulk evaluation import
- Charts and analytics
- Peer evaluation comparison
- Attendance integration
- Achievement badges/certificates

## 📞 Support

For issues or questions:
1. Check Tomcat logs: `logs/catalina.out`
2. Verify database table structure
3. Review servlet console output
4. Check browser console for JavaScript errors

---

**Version:** 1.0  
**Last Updated:** April 2024  
**Framework:** JSP + Servlet + DAO (MVC)  
**Database:** MySQL  
**UI:** Tailwind CSS
