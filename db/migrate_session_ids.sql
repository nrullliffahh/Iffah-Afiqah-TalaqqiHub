-- Migration: rename TSB... session IDs to sequential S### and fix sessionType
SET FOREIGN_KEY_CHECKS = 0;

UPDATE talaqqisession SET sessionId = 'S005' WHERE sessionId = 'TSB011';
UPDATE talaqqisession SET sessionId = 'S006' WHERE sessionId = 'TSB012';
UPDATE talaqqisession SET sessionId = 'S007' WHERE sessionId = 'TSB010';
UPDATE talaqqisession SET sessionId = 'S008' WHERE sessionId = 'TSB013';
UPDATE talaqqisession SET sessionId = 'S009' WHERE sessionId = 'TSB003';

UPDATE talaqqisession SET sessionType = 'Live Talaqqi';

SET FOREIGN_KEY_CHECKS = 1;

SELECT sessionId, sessionType, bookingId
FROM talaqqisession
ORDER BY CAST(SUBSTRING(sessionId, 2) AS UNSIGNED);
