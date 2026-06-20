-- Migration: add price, rangeAge, and description to packages
ALTER TABLE `packages`
  ADD COLUMN `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN `rangeAge` varchar(50) DEFAULT NULL,
  ADD COLUMN `description` text DEFAULT NULL;

-- Note: This matches the live talaqqihub_db package schema used by the app.