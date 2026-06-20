-- ========================================
-- Teacher Evaluation Module - Database Setup
-- ========================================

-- Create the evaluation table
CREATE TABLE IF NOT EXISTS evaluation (
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
    KEY idx_status (status),
    KEY idx_session_date (session_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Sample Data (Optional - For Testing)
-- ========================================

-- Insert sample PENDING evaluations
INSERT INTO evaluation (student_id, student_name, class_name, surah, ayah_range, session_date, start_time, end_time, status, teacher_id)
VALUES 
(3, 'Zainab Hassan', 'Class A', 'An-Nisa', '1-10', '2024-04-22', '14:00:00', '14:30:00', 'PENDING', 1),
(4, 'Omar Ibrahim', 'Class B', 'Al-Imran', '15-25', '2024-04-23', '15:00:00', '15:30:00', 'PENDING', 1),
(5, 'Ayesha Muhammad', 'Class C', 'Yusuf', '1-20', '2024-04-24', '16:00:00', '16:45:00', 'PENDING', 1);

-- Insert sample COMPLETED evaluations
INSERT INTO evaluation (student_id, student_name, class_name, surah, ayah_range, session_date, start_time, end_time, tajweed_score, fluency_score, accuracy_score, overall_score, rating, comments, suggestions, status, teacher_id)
VALUES 
(1, 'Ahmed Ali', 'Class A', 'Al-Fatiha', '1-7', '2024-04-18', '10:00:00', '10:30:00', 88.5, 90.0, 87.0, 88.5, 4, 'Good recitation with clear pronunciation', 'Work on tajweed rules for letter connections', 'COMPLETED', 1),
(2, 'Fatima Khan', 'Class B', 'Al-Baqarah', '1-20', '2024-04-19', '11:00:00', '11:45:00', 92.0, 89.5, 91.0, 90.8, 5, 'Excellent work! Very fluent and accurate', 'Continue practicing longer surahs', 'COMPLETED', 1),
(6, 'Hassan Ali', 'Class A', 'At-Tariq', '1-17', '2024-04-20', '09:30:00', '10:00:00', 75.5, 78.0, 76.5, 76.7, 3, 'Decent effort but needs improvement', 'Practice more at home, improve pronunciation', 'COMPLETED', 1),
(7, 'Layla Mohsin', 'Class C', 'Ad-Duha', '1-11', '2024-04-21', '13:00:00', '13:20:00', 85.0, 84.5, 86.0, 85.2, 4, 'Good pacing and fluency', 'Work on articulation of certain letters', 'COMPLETED', 1),
(8, 'Karim Hassan', 'Class B', 'An-Nas', '1-6', '2024-04-21', '14:30:00', '14:45:00', 94.0, 93.5, 95.0, 94.2, 5, 'Outstanding recitation!', 'Consider advanced level material', 'COMPLETED', 1);

-- ========================================
-- Verification Query
-- ========================================
-- Run this to verify your data:
-- SELECT COUNT(*) as total_evaluations FROM evaluation;
-- SELECT status, COUNT(*) as count FROM evaluation GROUP BY status;
-- SELECT teacher_id, COUNT(*) as evaluations FROM evaluation GROUP BY teacher_id;

-- ========================================
-- Dashboard Summary Query (Example)
-- ========================================
-- This is the query used by getDashboardSummary():
/*
SELECT 
    COUNT(DISTINCT student_id) as total_students_evaluated,
    COUNT(*) as total_sessions_evaluated,
    AVG(overall_score) as avg_overall_score,
    AVG(tajweed_score) as avg_tajweed_score,
    AVG(fluency_score) as avg_fluency_score,
    AVG(accuracy_score) as avg_accuracy_score
FROM evaluation
WHERE teacher_id = 1 AND status = 'COMPLETED';
*/

-- ========================================
-- Index for Performance
-- ========================================
-- These indexes are already created in the table definition
-- They help with fast queries on:
-- - teacher_id (for filtering by teacher)
-- - student_id (for filtering by student)
-- - status (for separating pending/completed)
-- - session_date (for sorting by date)
