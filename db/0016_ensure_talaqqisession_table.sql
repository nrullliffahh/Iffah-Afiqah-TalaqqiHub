-- Fix missing/typo Talaqqi session table on Aiven production.
-- Run in MySQL Workbench with schema talaqqihub_db selected.

-- 1) Check which name exists:
SHOW TABLES LIKE 'talaqqi%';

-- 2) If you see talaqisession (one "q") but NOT talaqqisession, run:
-- RENAME TABLE talaqisession TO talaqqisession;

-- 3) If neither exists, create the correct table:
CREATE TABLE IF NOT EXISTS talaqqisession (
  sessionId    VARCHAR(10)  NOT NULL PRIMARY KEY,
  sessionType  VARCHAR(50)  DEFAULT 'Live Talaqqi',
  sessionDate  DATE         NOT NULL,
  scheduleId   VARCHAR(10)  DEFAULT NULL,
  bookingId    VARCHAR(10)  DEFAULT NULL,
  KEY idx_scheduleId (scheduleId),
  KEY idx_sessionDate (sessionDate),
  CONSTRAINT fk_talaqqisession_scheduleId
    FOREIGN KEY (scheduleId) REFERENCES classschedule (scheduleId)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4) Optional: add bookingId if bootstrap was not run yet (ignore duplicate-column error):
-- ALTER TABLE talaqqisession ADD COLUMN bookingId VARCHAR(10) DEFAULT NULL;

-- 5) Verify:
SELECT COUNT(*) AS session_rows FROM talaqqisession;
SELECT bookingId, scheduleId, studentId, bookingStatus
FROM classbooking
ORDER BY bookingDate DESC
LIMIT 5;
