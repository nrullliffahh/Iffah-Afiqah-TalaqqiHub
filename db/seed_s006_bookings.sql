-- Seed bookings for student S006 (3 completed bookings)
-- Run with: mysql -u root -p talaqqihub < db/seed_s006_bookings.sql

SET FOREIGN_KEY_CHECKS=0;

-- Insert into the application's `booking` table using readable booking IDs
INSERT INTO classbooking (bookingId, studentId, scheduleId, classId, bookingDate, bookingTime, bookingStatus, createdAt)
VALUES
('BKG-S006-20260103-090000', 'S006', 'C152', NULL, '2026-01-03', '09:00:00', 'Completed', '2026-01-03'),
('BKG-S006-20260107-101500', 'S006', 'C153', NULL, '2026-01-07', '10:15:00', 'Completed', '2026-01-07'),
('BKG-S006-20260112-113000', 'S006', 'C154', NULL, '2026-01-12', '11:30:00', 'Completed', '2026-01-12');

SET FOREIGN_KEY_CHECKS=1;

-- Notes:
-- - These rows mark 3 completed sessions in the current month for student S006.
-- - The application counts "usedSessions" by selecting bookings with bookingStatus = 'Completed' in the current month.
-- - After running this, `StudentBookingDAO.getBookingSummary("S006")` should return usedSessions = 3 (totalSessions remains 16).
-- - If your schema enforces NOT NULL or foreign keys for scheduleId/classId, adjust the inserted values to match existing ids.
