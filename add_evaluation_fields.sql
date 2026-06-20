-- Add new columns to evaluation table for enhanced evaluation features
-- Run this script if the columns don't exist

-- Add areas_for_improvement column
ALTER TABLE evaluation ADD COLUMN areas_for_improvement TEXT NULL AFTER comments;

-- Add performance_tag column
ALTER TABLE evaluation ADD COLUMN performance_tag VARCHAR(50) NULL AFTER areas_for_improvement;

-- Add next_target column (next Surah & Ayah for the student)
ALTER TABLE evaluation ADD COLUMN next_target VARCHAR(100) NULL AFTER performance_tag;

-- Add teacher_comments column
ALTER TABLE evaluation ADD COLUMN teacher_comments TEXT NULL AFTER next_target;

-- Add created_at timestamp
ALTER TABLE evaluation ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER teacher_comments;

-- Add updated_at timestamp
ALTER TABLE evaluation ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Create an index for better query performance
ALTER TABLE evaluation ADD INDEX idx_performance_tag (performance_tag);
ALTER TABLE evaluation ADD INDEX idx_created_at (created_at);
