-- Migration: add optional fields for package details
-- Adds price, durationPerSession (minutes), description to packages table
ALTER TABLE `packages`
  ADD COLUMN `price` varchar(50) DEFAULT NULL,
  ADD COLUMN `durationPerSession` int(11) DEFAULT 15,
  ADD COLUMN `description` text DEFAULT NULL;

-- Note: Run this on your database before using the admin edit form.