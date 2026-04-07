-- Add 'popular' flag to packages table
-- For MySQL/MariaDB
ALTER TABLE packages
  ADD COLUMN popular TINYINT(1) DEFAULT 0;

-- Optional: If your schema uses 'isPopular' instead, run:
-- ALTER TABLE packages ADD COLUMN isPopular TINYINT(1) DEFAULT 0;

-- Verify:
-- SELECT packageId, packageName, popular FROM packages LIMIT 10;