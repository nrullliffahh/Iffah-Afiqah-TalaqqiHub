-- Migration: Create studentfeedback table
-- Stores student evaluations / ratings of teachers after completed sessions

CREATE TABLE IF NOT EXISTS studentfeedback (
    feedbackId      VARCHAR(50)  NOT NULL PRIMARY KEY,
    studentId       VARCHAR(50)  NOT NULL,
    teacherId       VARCHAR(50)  NOT NULL,
    sessionId       VARCHAR(50)  DEFAULT NULL,
    scheduleId      INT          DEFAULT NULL,
    rating          INT          NOT NULL DEFAULT 0,
    comments        TEXT,
    suggestions     TEXT,
    createdAt       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    KEY idx_sf_student  (studentId),
    KEY idx_sf_teacher  (teacherId),
    KEY idx_sf_session  (sessionId),

    FOREIGN KEY (studentId) REFERENCES student(studentId)  ON DELETE CASCADE,
    FOREIGN KEY (teacherId) REFERENCES teacher(teacherId)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
