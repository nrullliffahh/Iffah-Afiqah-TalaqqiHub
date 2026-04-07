-- Add certificationPath column to teacher table
ALTER TABLE teacher
ADD COLUMN certificationPath VARCHAR(255) DEFAULT NULL;
