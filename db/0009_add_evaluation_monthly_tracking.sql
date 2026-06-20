-- Migration: Add monthly evaluation tracking
-- Purpose: Track last evaluation month to reset evaluations at the start of each month

-- Add fields to studentevaluation table
ALTER TABLE studentevaluation 
ADD COLUMN IF NOT EXISTS evaluationMonth VARCHAR(7) DEFAULT NULL COMMENT 'Format: YYYY-MM, tracks when evaluation was last submitted in current month',
ADD COLUMN IF NOT EXISTS isMonthlyEvaluationSubmitted BOOLEAN DEFAULT FALSE COMMENT 'Whether monthly evaluation has been submitted this month',
ADD COLUMN IF NOT EXISTS monthlyEvaluationResetDate TIMESTAMP NULL COMMENT 'When the monthly evaluation was reset';

-- Add fields to evaluation table (teacher evaluations)
ALTER TABLE evaluation 
ADD COLUMN IF NOT EXISTS evaluationMonth VARCHAR(7) DEFAULT NULL COMMENT 'Format: YYYY-MM, tracks when evaluation was last submitted in current month',
ADD COLUMN IF NOT EXISTS isMonthlyEvaluationSubmitted BOOLEAN DEFAULT FALSE COMMENT 'Whether monthly evaluation has been submitted this month',
ADD COLUMN IF NOT EXISTS monthlyEvaluationResetDate TIMESTAMP NULL COMMENT 'When the monthly evaluation was reset';

-- Create evaluation_session_feedback table for post-session evaluations
CREATE TABLE IF NOT EXISTS evaluation_session_feedback (
    feedbackId INT AUTO_INCREMENT PRIMARY KEY,
    sessionId VARCHAR(50) NOT NULL,
    studentId VARCHAR(10) NOT NULL,
    teacherId VARCHAR(10) NOT NULL,
    
    -- Student feedback about teacher (after session)
    studentRating INT DEFAULT 0 COMMENT 'Student rating of teacher (1-5 stars)',
    studentComments TEXT COMMENT 'Student feedback about session',
    studentFeedbackTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Teacher feedback about student (after session)  
    teacherRating INT DEFAULT 0 COMMENT 'Teacher rating of student (1-5 stars)',
    teacherComments TEXT COMMENT 'Teacher feedback about student performance',
    teacherFeedbackTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Monthly consolidation
    isIncludedInMonthlyEvaluation BOOLEAN DEFAULT FALSE COMMENT 'Whether feedback included in monthly evaluation',
    monthlyEvaluationId INT,
    
    UNIQUE KEY unique_session_student_teacher (sessionId, studentId, teacherId),
    KEY idx_sessionId (sessionId),
    KEY idx_studentId (studentId),
    KEY idx_teacherId (teacherId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create monthly_evaluation_summary table
CREATE TABLE IF NOT EXISTS monthly_evaluation_summary (
    monthlyEvalId INT AUTO_INCREMENT PRIMARY KEY,
    studentId VARCHAR(10) NOT NULL,
    teacherId VARCHAR(10) NOT NULL,
    evaluationMonth VARCHAR(7) NOT NULL COMMENT 'Format: YYYY-MM',
    
    -- Aggregated scores from session feedback
    avgSessionRating FLOAT DEFAULT 0,
    totalSessionFeedback INT DEFAULT 0,
    
    -- Monthly consolidation scores
    tajweedScore FLOAT DEFAULT 0,
    fluencyScore FLOAT DEFAULT 0,
    accuracyScore FLOAT DEFAULT 0,
    overallScore FLOAT DEFAULT 0,
    
    -- Consolidated feedback
    strengths TEXT,
    areasForImprovement TEXT,
    nextTarget VARCHAR(100),
    
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_student_month (studentId, evaluationMonth),
    KEY idx_studentId (studentId),
    KEY idx_teacherId (teacherId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_evaluation_month ON studentevaluation(evaluationMonth);
CREATE INDEX IF NOT EXISTS idx_evaluation_teacher_month ON evaluation(evaluationMonth);
CREATE INDEX IF NOT EXISTS idx_session_feedback_month ON evaluation_session_feedback(sessionId);
