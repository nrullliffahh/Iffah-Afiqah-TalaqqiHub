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
