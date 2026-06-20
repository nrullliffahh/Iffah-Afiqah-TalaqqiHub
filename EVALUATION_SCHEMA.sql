-- Complete Evaluation Database Schema
-- For Both Student and Teacher Evaluation Systems

-- =====================================================
-- 1. STUDENT EVALUATION TABLE (Existing)
-- =====================================================
-- Stores teacher evaluations of students + student feedback
-- Used by: Student Portal and Teacher Dashboard

CREATE TABLE IF NOT EXISTS studentevaluation (
    studentEvaluationId INT AUTO_INCREMENT PRIMARY KEY,
    studentId VARCHAR(50) NOT NULL,
    teacherId VARCHAR(50) NOT NULL,
    sessionId VARCHAR(50),
    scheduleId INT,
    
    -- Teacher's Evaluation Scores (0-100)
    tajweedScore INT DEFAULT NULL,
    fluencyScore INT DEFAULT NULL,
    accuracyScore INT DEFAULT NULL,
    
    -- Teacher's Feedback (can be from teacherevaluation table via JOIN)
    strength TEXT,
    weakness TEXT,
    studentImprovements TEXT,
    nextTarget VARCHAR(255),
    comments TEXT,
    
    -- Student's Feedback About Teacher
    starRating INT DEFAULT 0,
    
    -- Metadata
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    KEY idx_studentId (studentId),
    KEY idx_teacherId (teacherId),
    KEY idx_sessionId (sessionId),
    KEY idx_scheduleId (scheduleId),
    
    FOREIGN KEY (studentId) REFERENCES student(studentId),
    FOREIGN KEY (teacherId) REFERENCES teacher(teacherId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 2. TEACHER EVALUATION TABLE (Enhanced)
-- =====================================================
-- Stores detailed teacher evaluations of students
-- Used by: Teacher Portal and Admin Dashboard

CREATE TABLE IF NOT EXISTS evaluation (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Student Information
    student_id INT NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    class_name VARCHAR(100),
    
    -- Session Information
    surah VARCHAR(100),
    ayah_range VARCHAR(50),
    session_date DATE,
    start_time TIME,
    end_time TIME,
    
    -- Performance Scores (0-100 float)
    tajweed_score FLOAT DEFAULT 0,
    fluency_score FLOAT DEFAULT 0,
    accuracy_score FLOAT DEFAULT 0,
    overall_score FLOAT DEFAULT 0,
    
    -- Feedback Fields
    rating INT DEFAULT 0,
    comments TEXT,                          -- Strengths
    areas_for_improvement TEXT,             -- NEW: Areas needing work
    performance_tag VARCHAR(50),            -- NEW: Excellent/Good/Fair/Needs Improvement
    next_target VARCHAR(100),               -- NEW: Next Surah & Ayah
    suggestions TEXT,                       -- Improvement Suggestions
    teacher_comments TEXT,                  -- NEW: Additional teacher notes
    
    -- Metadata
    status VARCHAR(20) DEFAULT 'PENDING',   -- PENDING or COMPLETED
    teacher_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    KEY idx_teacher_id (teacher_id),
    KEY idx_student_id (student_id),
    KEY idx_status (status),
    KEY idx_performance_tag (performance_tag),
    KEY idx_created_at (created_at),
    
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacherId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. TEACHER EVALUATION TABLE (For Student Feedback)
-- =====================================================
-- Stores student's feedback/evaluation about teachers
-- Used by: Student Portal (Evaluate Teacher section)

CREATE TABLE IF NOT EXISTS teacherevaluation (
    teacherEvaluationId VARCHAR(50) PRIMARY KEY,
    evaluationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    teacherComments TEXT,
    teacherImprovements TEXT,
    studentId VARCHAR(50) NOT NULL,
    teacherId VARCHAR(50) NOT NULL,
    scheduleId INT,
    
    KEY idx_studentId (studentId),
    KEY idx_teacherId (teacherId),
    
    FOREIGN KEY (studentId) REFERENCES student(studentId),
    FOREIGN KEY (teacherId) REFERENCES teacher(teacherId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERT SAMPLE DATA (For Testing)
-- =====================================================

-- Sample Student Evaluations (from teacher)
INSERT INTO studentevaluation 
(studentId, teacherId, sessionId, tajweedScore, fluencyScore, accuracyScore, strength, weakness, studentImprovements, nextTarget, comments)
VALUES 
('S001', 'T001', 'SES001', 85, 88, 82, 'Good pronunciation', 'Needs work on Makharij', 'Practice heavy letters', 'Al-Baqarah 1-20', 'Overall good progress'),
('S002', 'T002', 'SES002', 92, 90, 95, 'Excellent fluency', 'Minor pause issues', 'Work on continuous reading', 'Al-Imran 1-10', 'Excellent student'),
('S003', 'T001', 'SES003', 78, 75, 80, 'Clear voice', 'Tajweed rules need review', 'Study Noon Saakinah', 'Al-Fatiha repeat', 'Need more practice');

-- Sample Teacher Evaluations (to students)
INSERT INTO evaluation 
(student_id, student_name, class_name, surah, ayah_range, session_date, start_time, end_time, 
 tajweed_score, fluency_score, accuracy_score, overall_score, rating,
 comments, areas_for_improvement, performance_tag, next_target, suggestions, teacher_comments, status, teacher_id)
VALUES 
(1, 'Ahmed Ali', 'Class A', 'Al-Fatiha', '1-7', '2024-05-08', '10:00:00', '10:30:00',
 88.5, 90.0, 87.0, 88.5, 4,
 'Excellent pronunciation of heavy letters', 'Work on letter connections', 'Good', 'Al-Baqarah 1-10',
 'Continue practicing Tajweed rules daily', 'Student shows great dedication', 'COMPLETED', 1),
 
(2, 'Fatima Khan', 'Class B', 'Al-Baqarah', '1-20', '2024-05-07', '11:00:00', '11:45:00',
 92.0, 89.5, 91.0, 90.8, 5,
 'Very fluent and accurate recitation', 'Minor pausing between verses', 'Excellent', 'Al-Baqarah 21-40',
 'Continue with longer surahs, focus on Makharij', 'Excellent performance', 'COMPLETED', 1),

(3, 'Zainab Hassan', 'Class A', 'An-Nisa', '1-10', '2024-05-06', '14:00:00', '14:30:00',
 75.5, 78.0, 76.5, 76.7, 3,
 'Good effort and participation', 'Tajweed rules need more practice', 'Fair', 'An-Nisa 11-30',
 'Study Assimilation rules with focus', 'Needs more dedication', 'COMPLETED', 1);

-- =====================================================
-- USEFUL QUERIES
-- =====================================================

-- Get latest evaluation for a student
-- SELECT * FROM studentevaluation 
-- WHERE studentId = 'S001' 
-- ORDER BY studentEvaluationId DESC LIMIT 1;

-- Get all evaluations by a teacher
-- SELECT * FROM evaluation 
-- WHERE teacher_id = 1 AND status = 'COMPLETED' 
-- ORDER BY created_at DESC;

-- Get pending evaluations for a teacher
-- SELECT * FROM evaluation 
-- WHERE teacher_id = 1 AND status = 'PENDING' 
-- ORDER BY session_date DESC;

-- Get teacher's statistics
-- SELECT 
--   COUNT(DISTINCT student_id) as total_students,
--   COUNT(*) as total_evaluations,
--   AVG(overall_score) as avg_score,
--   AVG(tajweed_score) as avg_tajweed,
--   AVG(fluency_score) as avg_fluency,
--   AVG(accuracy_score) as avg_accuracy
-- FROM evaluation 
-- WHERE teacher_id = 1 AND status = 'COMPLETED';

-- Search evaluations
-- SELECT * FROM evaluation 
-- WHERE teacher_id = 1 
-- AND (student_name LIKE '%Ahmed%' OR surah LIKE '%Baqarah%')
-- ORDER BY created_at DESC;

-- Filter by performance tag
-- SELECT * FROM evaluation 
-- WHERE teacher_id = 1 AND performance_tag = 'Excellent'
-- ORDER BY created_at DESC;

-- Get student feedback about teacher
-- SELECT se.*, t.teacherName 
-- FROM studentevaluation se
-- LEFT JOIN teacher t ON se.teacherId = t.teacherId
-- WHERE se.studentId = 'S001' 
-- ORDER BY se.studentEvaluationId DESC;

-- =====================================================
-- INDEXES
-- =====================================================
-- These are already created in the table definitions above
-- But here's a summary of indexes for reference:

-- studentevaluation indexes:
-- - idx_studentId: For finding all evaluations of a student
-- - idx_teacherId: For finding all evaluations by a teacher
-- - idx_sessionId: For linking with talaqqi sessions
-- - idx_scheduleId: For linking with class schedule

-- evaluation indexes:
-- - idx_teacher_id: For teacher dashboard queries
-- - idx_student_id: For student filtering
-- - idx_status: For finding pending vs completed
-- - idx_performance_tag: For performance-based filtering
-- - idx_created_at: For sorting by date

-- =====================================================
-- VIEW DEFINITIONS (Optional - for complex queries)
-- =====================================================

-- Teacher's Dashboard Summary
-- CREATE VIEW teacher_evaluation_summary AS
-- SELECT 
--   teacher_id,
--   COUNT(DISTINCT student_id) as total_students_evaluated,
--   COUNT(*) as total_evaluations,
--   SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_count,
--   SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) as pending_count,
--   AVG(overall_score) as avg_overall_score,
--   AVG(tajweed_score) as avg_tajweed_score,
--   AVG(fluency_score) as avg_fluency_score,
--   AVG(accuracy_score) as avg_accuracy_score
-- FROM evaluation
-- GROUP BY teacher_id;

-- Student's Evaluation History
-- CREATE VIEW student_evaluation_history AS
-- SELECT 
--   se.studentId,
--   t.teacherName,
--   se.tajweedScore,
--   se.fluencyScore,
--   se.accuracyScore,
--   ((COALESCE(se.tajweedScore,0) + COALESCE(se.fluencyScore,0) + COALESCE(se.accuracyScore,0))/3) as overall_score,
--   se.strength,
--   se.weakness,
--   se.createdAt
-- FROM studentevaluation se
-- LEFT JOIN teacher t ON se.teacherId = t.teacherId
-- ORDER BY se.createdAt DESC;
