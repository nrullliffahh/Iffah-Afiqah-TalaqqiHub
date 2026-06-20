-- Migration: move legacy studentPackage data into packageId
-- This is safe to run on a live database that still uses `studentPackage`.
-- Step 1: add packageId if it does not already exist.
ALTER TABLE `student`
  ADD COLUMN `packageId` varchar(10) DEFAULT NULL;

-- Step 2: copy existing values from studentPackage into packageId.
UPDATE `student`
SET `packageId` = `studentPackage`
WHERE `packageId` IS NULL AND `studentPackage` IS NOT NULL;

-- Step 3: make packageId required once the data is copied.
ALTER TABLE `student`
  MODIFY COLUMN `packageId` varchar(10) NOT NULL;

-- Step 4: drop the legacy column after verification.
ALTER TABLE `student`
  DROP COLUMN `studentPackage`;

-- Optional: add a foreign key if your packages table uses packageId.
-- ALTER TABLE `student`
--   ADD CONSTRAINT `fk_student_package` FOREIGN KEY (`packageId`) REFERENCES `packages` (`packageId`) ON UPDATE CASCADE;
