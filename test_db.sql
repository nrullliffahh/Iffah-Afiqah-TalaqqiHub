-- Check evaluation table
SELECT 'Total Records:' as info, COUNT(*) as count FROM evaluation;

-- Show first 3 evaluations
SELECT evaluation_id, student_id, student_name, surah, tajweed_score, fluency_score, accuracy_score, overall_score, status, teacher_id FROM evaluation LIMIT 3;

-- Check how many with teacher_id = 1
SELECT 'Teacher 1 Records:' as info, COUNT(*) as count FROM evaluation WHERE teacher_id = 1;

-- Check how many completed
SELECT 'Completed Records:' as info, COUNT(*) as count FROM evaluation WHERE status = 'COMPLETED';

-- Check completed for teacher 1
SELECT 'Completed for Teacher 1:' as info, COUNT(*) as count FROM evaluation WHERE teacher_id = 1 AND status = 'COMPLETED';
