-- Optional: adds timestamp to AI interaction history for admin analytics
ALTER TABLE aiassistance
    ADD COLUMN createdAt TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP;
