-- Create notifications table to store user notifications (student/teacher)
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(64) NOT NULL,
  userType VARCHAR(32) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  bookingId VARCHAR(128),
  relatedScheduleId VARCHAR(128),
  isRead TINYINT(1) DEFAULT 0,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user (userType, userId),
  INDEX idx_booking (bookingId)
);
