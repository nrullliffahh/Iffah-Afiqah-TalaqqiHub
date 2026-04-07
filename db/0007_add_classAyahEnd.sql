-- Migration 0007: Add classAyahEnd column to classschedule
-- Adds an ayah range "end" field so teachers can set from ayah X to ayah Y.
-- Safe to run multiple times (ALTER IGNORE / IF NOT EXISTS workaround for older MySQL).

ALTER TABLE classschedule
    ADD COLUMN IF NOT EXISTS classAyahEnd INT DEFAULT NULL
        COMMENT 'Last ayah of the range set by the teacher (inclusive). NULL = single ayah only.'
    AFTER classAyah;
