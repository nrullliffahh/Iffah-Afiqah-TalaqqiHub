-- Add sessionDuration and sessionStartTime columns to talaqqisession table
-- sessionDuration: stores the actual duration in minutes
-- sessionStartTime: stores when the live session started (TIMESTAMP)

ALTER TABLE talaqqisession 
ADD COLUMN sessionStartTime TIMESTAMP NULL DEFAULT NULL AFTER sessionDate,
ADD COLUMN sessionDuration INT DEFAULT 0 AFTER sessionStartTime;

-- Add index for faster queries
CREATE INDEX idx_sessionStartTime ON talaqqisession(sessionStartTime);
