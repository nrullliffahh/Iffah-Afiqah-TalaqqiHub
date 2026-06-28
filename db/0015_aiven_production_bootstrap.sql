-- Optional bootstrap for Aiven/production when only the base dump was imported.
-- Run once: mysql -h HOST -P PORT -u avnadmin -p talaqqihub_db < db/0015_aiven_production_bootstrap.sql
-- Safe to re-run: duplicate column errors can be ignored.

ALTER TABLE teacher
  ADD COLUMN approvalStatus ENUM('Approved','Pending','Rejected') NOT NULL DEFAULT 'Pending';

UPDATE teacher SET approvalStatus = 'Approved' WHERE teacherStatus = 'Active' AND approvalStatus = 'Pending';

ALTER TABLE teacher
  ADD COLUMN certificationPath VARCHAR(255) DEFAULT NULL;

CREATE TABLE IF NOT EXISTS studentcancellation (
  bookingId VARCHAR(10) NOT NULL PRIMARY KEY,
  cancellationReason TEXT,
  cancelledAt DATETIME DEFAULT NULL,
  cancelledBy VARCHAR(50) DEFAULT NULL,
  CONSTRAINT fk_studentcancellation_booking FOREIGN KEY (bookingId) REFERENCES classbooking (bookingId) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Modern talaqqisession links via bookingId; legacy dumps use scheduleId only.
ALTER TABLE talaqqisession
  ADD COLUMN bookingId VARCHAR(10) DEFAULT NULL;

-- Ayah range end for teacher Quran Apply (see db/0007_add_classAyahEnd.sql)
ALTER TABLE classschedule
  ADD COLUMN IF NOT EXISTS classAyahEnd INT DEFAULT NULL
    COMMENT 'Last ayah of the range set by the teacher (inclusive). NULL = single ayah only.'
  AFTER classAyah;

-- Announcements (see db/0014_create_announcement_table.sql for full schema + samples)
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
    KEY idx_ann_created (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;