-- Add Rescheduled to classbooking.bookingStatus where missing (safe to re-run).
-- Production Aiven schema from 0010 may not include this value.

ALTER TABLE classbooking
  MODIFY COLUMN bookingStatus
  ENUM('Pending','Confirmed','Cancelled','Completed','Approved','Rejected','Rescheduled','Upcoming')
  NOT NULL DEFAULT 'Pending';
