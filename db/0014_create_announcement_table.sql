-- Migration: Create announcement table for teacher/admin broadcast messages

CREATE TABLE IF NOT EXISTS announcement (
    announcementId   VARCHAR(10)  NOT NULL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    description      TEXT         NOT NULL,
    category         VARCHAR(50)  NOT NULL DEFAULT 'General',
    author           VARCHAR(100) NOT NULL,
    targetAudience   VARCHAR(255) NOT NULL,
    teacherId        VARCHAR(10)  DEFAULT NULL,
    studentId        VARCHAR(10)  DEFAULT NULL,
    status           ENUM('published','draft') NOT NULL DEFAULT 'published',
    createdAt        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    KEY idx_ann_teacher (teacherId),
    KEY idx_ann_author  (author),
    KEY idx_ann_created (createdAt),

    CONSTRAINT fk_ann_teacher FOREIGN KEY (teacherId) REFERENCES teacher(teacherId) ON DELETE CASCADE,
    CONSTRAINT fk_ann_student FOREIGN KEY (studentId) REFERENCES student(studentId) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample announcements (adjust teacherId to match your database)
INSERT INTO announcement (announcementId, title, description, category, author, targetAudience, teacherId, status)
SELECT 'ANN001', 'Class Cancelled - January 2nd',
       'Due to unforeseen weather conditions, tomorrow''s class scheduled for January 2nd has been cancelled. We will resume on January 5th. Please check your schedule for updates.',
       'Class Cancelled', t.teacherName, 'All My Students', t.teacherId, 'published'
FROM teacher t
WHERE t.teacherId = (SELECT teacherId FROM teacher ORDER BY teacherId LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM announcement WHERE announcementId = 'ANN001');

INSERT INTO announcement (announcementId, title, description, category, author, targetAudience, teacherId, status)
SELECT 'ANN002', 'Class Rescheduled to January 5th',
       'The class originally scheduled for January 2nd has been rescheduled to January 5th at the same time. Please update your calendar accordingly.',
       'Class Rescheduled', t.teacherName, 'Student: Ahmad Hassan', t.teacherId, 'published'
FROM teacher t
WHERE t.teacherId = (SELECT teacherId FROM teacher ORDER BY teacherId LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM announcement WHERE announcementId = 'ANN002');

INSERT INTO announcement (announcementId, title, description, category, author, targetAudience, teacherId, status)
SELECT 'ANN003', 'Holiday Announcement - Eid Al-Fitr',
       'TalaqqiHub will be closed during Eid Al-Fitr celebrations from April 10–14. All classes will resume on April 15. Wishing everyone a blessed Eid!',
       'Holiday', 'Talaqqi Admin', 'All Students & Teachers', NULL, 'published'
WHERE NOT EXISTS (SELECT 1 FROM announcement WHERE announcementId = 'ANN003');
