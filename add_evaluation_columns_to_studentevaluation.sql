-- Migration: Add missing columns to studentevaluation table
-- This consolidates evaluation data into the studentevaluation table

ALTER TABLE studentevaluation
ADD COLUMN IF NOT EXISTS student_name VARCHAR(255) AFTER studentId,
ADD COLUMN IF NOT EXISTS class_name VARCHAR(100) AFTER student_name,
ADD COLUMN IF NOT EXISTS surah VARCHAR(100) AFTER class_name,
ADD COLUMN IF NOT EXISTS ayah_range VARCHAR(50) AFTER surah,
ADD COLUMN IF NOT EXISTS session_date DATE AFTER ayah_range,
ADD COLUMN IF NOT EXISTS start_time TIME AFTER session_date,
ADD COLUMN IF NOT EXISTS end_time TIME AFTER start_time,
MODIFY COLUMN tajweedScore FLOAT DEFAULT 0,
MODIFY COLUMN fluencyScore FLOAT DEFAULT 0,
MODIFY COLUMN accuracyScore FLOAT DEFAULT 0,
ADD COLUMN IF NOT EXISTS overall_score FLOAT DEFAULT 0 AFTER accuracyScore,
ADD COLUMN IF NOT EXISTS rating INT DEFAULT 0 AFTER overall_score,
ADD COLUMN IF NOT EXISTS areas_for_improvement TEXT AFTER comments,
ADD COLUMN IF NOT EXISTS performance_tag VARCHAR(50) AFTER areas_for_improvement,
ADD COLUMN IF NOT EXISTS next_target_surah VARCHAR(100) AFTER performance_tag,
ADD COLUMN IF NOT EXISTS suggestions TEXT AFTER next_target_surah,
ADD COLUMN IF NOT EXISTS teacher_comments TEXT AFTER suggestions,
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'PENDING' AFTER teacher_comments,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Add indexes for better query performance
ALTER TABLE studentevaluation
ADD INDEX IF NOT EXISTS idx_status (status),
ADD INDEX IF NOT EXISTS idx_performance_tag (performance_tag),
ADD INDEX IF NOT EXISTS idx_session_date (session_date),
ADD INDEX IF NOT EXISTS idx_class_name (class_name);
