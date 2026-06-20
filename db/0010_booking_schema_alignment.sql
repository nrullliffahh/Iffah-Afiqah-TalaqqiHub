-- Migration: align booking schema with the current application
-- Safe to run on the live database; keeps legacy status values usable.

START TRANSACTION;

ALTER TABLE classbooking
  MODIFY COLUMN bookingStatus ENUM('Pending','Confirmed','Cancelled','Completed','Approved','Rejected') NOT NULL DEFAULT 'Pending';

UPDATE classbooking
SET bookingStatus = 'Pending'
WHERE bookingStatus IN ('Approved', 'Upcoming');

UPDATE classbooking
SET bookingStatus = 'Cancelled'
WHERE bookingStatus = 'Rejected';

SELECT bookingStatus, COUNT(*) AS cnt
FROM classbooking
GROUP BY bookingStatus
ORDER BY bookingStatus;

COMMIT;