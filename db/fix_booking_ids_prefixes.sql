-- Usage: mysql -u root -p talaqqihub < db/fix_booking_ids_prefixes.sql

START TRANSACTION;

-- Create temporary mapping table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_booking_map (
  old_id VARCHAR(255) PRIMARY KEY,
  new_id VARCHAR(255)
) ENGINE=MEMORY;

TRUNCATE TABLE temp_booking_map;

-- Insert mapping for bookings matching the provided prefixes
INSERT INTO temp_booking_map (old_id, new_id)
SELECT b.bookingId,
       CONCAT('BKG-', b.studentId, '-', DATE_FORMAT(b.bookingDate, '%Y%m%d'), '-', DATE_FORMAT(b.bookingTime, '%H%i%S')) AS new_id
FROM booking b
WHERE b.bookingId LIKE '0d7d0cba-f%'
   OR b.bookingId LIKE '0d81b6a2-f%'
   OR b.bookingId LIKE '0d81ba17-f%';

-- Check: list mappings (for review) -- comment out when running non-interactively
SELECT * FROM temp_booking_map;

-- Update booking table using mapping, only when new_id does not already exist
UPDATE booking AS tgt
JOIN temp_booking_map m ON tgt.bookingId = m.old_id
LEFT JOIN booking AS existing ON existing.bookingId = m.new_id
SET tgt.bookingId = m.new_id
WHERE existing.bookingId IS NULL;

-- Update student_cancellation references
UPDATE student_cancellation sc
JOIN temp_booking_map m ON sc.bookingId = m.old_id
SET sc.bookingId = m.new_id;

-- If you also have other tables that reference booking.bookingId, add similar UPDATE statements here.

DROP TEMPORARY TABLE IF EXISTS temp_booking_map;

COMMIT;

-- Notes:
-- 1) Script only updates bookings whose computed new_id does not collide with an existing bookingId.
-- 2) Review the SELECT output above before applying in a production environment.
-- 3) If prefixes provided match multiple rows, all matching rows will be converted.
