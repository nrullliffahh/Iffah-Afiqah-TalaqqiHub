-- Migration: add ageRange column to packages
ALTER TABLE `packages`
  ADD COLUMN `ageRange` varchar(50) DEFAULT NULL;

-- Note: Run this after db/0002_add_package_fields.sql