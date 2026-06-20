-- =====================================================
-- INSERT SAMPLE DATA INTO EVALUATION TABLE
-- Run this script to populate the teacher evaluation database
-- =====================================================

-- 1. INSERT SAMPLE EVALUATIONS FOR TEACHER ID = 1 (Status: COMPLETED)
INSERT INTO evaluation (
    student_id, student_name, class_name, surah, ayah_range,
    session_date, start_time, end_time,
    tajweed_score, fluency_score, accuracy_score, overall_score,
    rating, comments, areas_for_improvement, performance_tag, next_target, suggestions, teacher_comments,
    status, teacher_id, created_at, updated_at
) VALUES 
(1, 'Ahmed Ali', 'Class A', 'Al-Fatiha', '1-7', '2024-05-01', '10:00:00', '10:30:00',
 88.5, 90.0, 87.0, 88.5, 4,
 'Excellent pronunciation of heavy letters', 'Work on letter connections', 'Good', 'Al-Baqarah 1-10',
 'Continue practicing Tajweed rules daily', 'Student shows great dedication',
 'COMPLETED', 1, NOW(), NOW()),

(2, 'Fatima Khan', 'Class B', 'Al-Baqarah', '1-20', '2024-05-02', '11:00:00', '11:45:00',
 92.0, 89.5, 91.0, 90.8, 5,
 'Very fluent and accurate recitation', 'Minor pausing between verses', 'Excellent', 'Al-Baqarah 21-40',
 'Continue with longer surahs, focus on Makharij', 'Excellent performance',
 'COMPLETED', 1, NOW(), NOW()),

(3, 'Zainab Hassan', 'Class A', 'An-Nisa', '1-10', '2024-05-03', '14:00:00', '14:30:00',
 75.5, 78.0, 76.5, 76.7, 3,
 'Good effort and participation', 'Tajweed rules need more practice', 'Fair', 'An-Nisa 11-30',
 'Study Assimilation rules with focus', 'Needs more dedication',
 'COMPLETED', 1, NOW(), NOW()),

(4, 'Omar Ibrahim', 'Class C', 'Ar-Rahman', '1-20', '2024-04-28', '15:30:00', '16:00:00',
 85.0, 87.5, 86.0, 86.2, 4,
 'Good Makharij pronunciation', 'Work on Noon Saakinah rules', 'Good', 'Ar-Rahman 21-40',
 'Practice the Ghunnah technique more', 'Making steady progress',
 'COMPLETED', 1, NOW(), NOW()),

(5, 'Aisha Mohammed', 'Class B', 'Al-Imran', '1-30', '2024-04-29', '09:00:00', '09:45:00',
 94.5, 93.0, 95.0, 94.2, 5,
 'Outstanding fluency and accuracy', 'Continue maintaining excellence', 'Excellent', 'Al-Imran 31-50',
 'Move to longer surahs, explore advanced Tajweed', 'Top performer in class',
 'COMPLETED', 1, NOW(), NOW());

-- 2. INSERT PENDING EVALUATIONS FOR TEACHER ID = 1 (Status: PENDING)
INSERT INTO evaluation (
    student_id, student_name, class_name, surah, ayah_range,
    session_date, start_time, end_time,
    tajweed_score, fluency_score, accuracy_score, overall_score,
    rating, comments, areas_for_improvement, performance_tag, next_target, suggestions, teacher_comments,
    status, teacher_id, created_at, updated_at
) VALUES 
(6, 'Muhammad Hassan', 'Class A', 'Al-A''raf', '1-20', '2024-05-10', '10:30:00', '11:00:00',
 NULL, NULL, NULL, NULL, 0,
 '', '', '', '', '', '',
 'PENDING', 1, NOW(), NOW()),

(7, 'Sara Abdullah', 'Class C', 'At-Tawbah', '1-15', '2024-05-11', '13:00:00', '13:30:00',
 NULL, NULL, NULL, NULL, 0,
 '', '', '', '', '', '',
 'PENDING', 1, NOW(), NOW()),

(8, 'Hassan Ali', 'Class B', 'Yunus', '1-20', '2024-05-12', '15:00:00', '15:30:00',
 NULL, NULL, NULL, NULL, 0,
 '', '', '', '', '', '',
 'PENDING', 1, NOW(), NOW());

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check total evaluations inserted
SELECT 'Total Evaluations Created' as Status, COUNT(*) as Count FROM evaluation;

-- Show completed evaluations for teacher 1
SELECT 'Completed Evaluations:' as Status;
SELECT evaluation_id, student_name, surah, tajweed_score, fluency_score, accuracy_score, overall_score, status 
FROM evaluation 
WHERE teacher_id = 1 AND status = 'COMPLETED' 
ORDER BY created_at DESC;

-- Show pending evaluations for teacher 1
SELECT '' as Separator;
SELECT 'Pending Evaluations:' as Status;
SELECT evaluation_id, student_name, surah, session_date, status 
FROM evaluation 
WHERE teacher_id = 1 AND status = 'PENDING' 
ORDER BY session_date DESC;

-- Show dashboard summary statistics
SELECT '' as Separator;
SELECT 'Dashboard Summary for Teacher 1:' as Status;
SELECT 
    COUNT(DISTINCT student_id) as Total_Students_Evaluated,
    COUNT(*) as Total_Sessions_Evaluated,
    ROUND(AVG(overall_score), 2) as Avg_Overall_Score,
    ROUND(AVG(tajweed_score), 2) as Avg_Tajweed_Score,
    ROUND(AVG(fluency_score), 2) as Avg_Fluency_Score,
    ROUND(AVG(accuracy_score), 2) as Avg_Accuracy_Score
FROM evaluation 
WHERE teacher_id = 1 AND status = 'COMPLETED';
