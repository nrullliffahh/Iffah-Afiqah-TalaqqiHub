-- Migration: Add certificationPath column to teacher and create notifications table
-- Run this on talaqqihub_db

-- Add certificationPath column if missing
ALTER TABLE teacher
ADD COLUMN IF NOT EXISTS certificationPath VARCHAR(255) DEFAULT NULL;

-- Create notifications table used by NotificationsServlet
CREATE TABLE IF NOT EXISTS notifications (
  id VARCHAR(36) NOT NULL,
  userType VARCHAR(20) NOT NULL,
  userId VARCHAR(10) NOT NULL,
  title VARCHAR(255),
  message TEXT,
  bookingId VARCHAR(10),
  relatedScheduleId VARCHAR(10),
  isRead TINYINT(1) DEFAULT 0,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user (userType, userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
