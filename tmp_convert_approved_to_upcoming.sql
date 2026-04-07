SELECT 'Before' AS phase, bookingStatus, COUNT(*) AS cnt FROM classbooking GROUP BY bookingStatus;

UPDATE classbooking SET bookingStatus='Upcoming' WHERE bookingStatus='Approved';

SELECT 'After' AS phase, bookingStatus, COUNT(*) AS cnt FROM classbooking GROUP BY bookingStatus;

SELECT bookingId, bookingDate, bookingTime, bookingStatus, studentId, scheduleId FROM classbooking ORDER BY bookingDate DESC, bookingTime DESC LIMIT 20;
