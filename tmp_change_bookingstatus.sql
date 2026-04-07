ALTER TABLE classbooking MODIFY COLUMN bookingStatus ENUM('Pending','Upcoming','Approved','Rejected') NOT NULL DEFAULT 'Pending';

UPDATE classbooking SET bookingStatus = 'Upcoming' WHERE bookingStatus = 'Approved';

SELECT bookingStatus, COUNT(*) AS cnt FROM classbooking GROUP BY bookingStatus;
SELECT * FROM classbooking ORDER BY bookingDate DESC, bookingTime DESC LIMIT 20;
