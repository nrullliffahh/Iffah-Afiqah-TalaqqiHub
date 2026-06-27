-- Production Aiven: upgrade legacy studentevaluation + talaqqisession for teacher portal.
-- Safe to re-run: ignore "Duplicate column" errors.

ALTER TABLE studentevaluation ADD COLUMN sessionId VARCHAR(50) DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN scheduleId INT DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN class_name VARCHAR(100) DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN surah VARCHAR(100) DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN ayah_range VARCHAR(50) DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN session_date DATE DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN start_time TIME DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN end_time TIME DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN overall_score FLOAT DEFAULT 0;
ALTER TABLE studentevaluation ADD COLUMN rating INT DEFAULT 0;
ALTER TABLE studentevaluation ADD COLUMN areas_for_improvement TEXT;
ALTER TABLE studentevaluation ADD COLUMN performance_tag VARCHAR(50) DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN next_target_surah VARCHAR(100) DEFAULT NULL;
ALTER TABLE studentevaluation ADD COLUMN suggestions TEXT;
ALTER TABLE studentevaluation ADD COLUMN teacher_comments TEXT;
ALTER TABLE studentevaluation ADD COLUMN status VARCHAR(20) DEFAULT 'PENDING';
ALTER TABLE studentevaluation ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE talaqqisession ADD COLUMN bookingId VARCHAR(10) DEFAULT NULL;
