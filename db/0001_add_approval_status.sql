-- Add separate approvalStatus for teacher approval workflow
ALTER TABLE teacher
  ADD COLUMN approvalStatus ENUM('Approved','Pending','Rejected') NOT NULL DEFAULT 'Pending';

-- Initialize approvalStatus for existing rows: mark Active teachers as Approved
UPDATE teacher SET approvalStatus = 'Approved' WHERE teacherStatus = 'Active';
-- Leave others as 'Pending' by default; adjust as needed.
