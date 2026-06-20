DROP TABLE IF EXISTS evaluation;
CREATE TABLE evaluation (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    class_name VARCHAR(100),
    surah VARCHAR(100),
    ayah_range VARCHAR(50),
    session_date DATE,
    start_time TIME,
    end_time TIME,
    tajweed_score FLOAT DEFAULT 0,
    fluency_score FLOAT DEFAULT 0,
    accuracy_score FLOAT DEFAULT 0,
    overall_score FLOAT DEFAULT 0,
    rating INT DEFAULT 0,
    comments TEXT,
    areas_for_improvement TEXT,
    performance_tag VARCHAR(50),
    next_target VARCHAR(100),
    suggestions TEXT,
    teacher_comments TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    teacher_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_teacher_id (teacher_id),
    KEY idx_student_id (student_id),
    KEY idx_status (status),
    KEY idx_performance_tag (performance_tag),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO evaluation (student_id, student_name, class_name, surah, ayah_range, session_date, start_time, end_time, status, teacher_id)
VALUES 
(3, 'Zainab Hassan', 'Class A', 'An-Nisa', '1-10', '2024-04-22', '14:00:00', '14:30:00', 'PENDING', 1),
(4, 'Omar Ibrahim', 'Class B', 'Al-Imran', '15-25', '2024-04-23', '15:00:00', '15:30:00', 'PENDING', 1);

INSERT INTO evaluation (student_id, student_name, class_name, surah, ayah_range, session_date, start_time, end_time, tajweed_score, fluency_score, accuracy_score, overall_score, rating, comments, areas_for_improvement, performance_tag, next_target, suggestions, teacher_comments, status, teacher_id)
VALUES 
(1, 'Ahmed Ali', 'Class A', 'Al-Fatiha', '1-7', '2024-04-18', '10:00:00', '10:30:00', 88.5, 90.0, 87.0, 88.5, 4, 'Good recitation with clear pronunciation', 'Letter connections need practice', 'Good', 'Al-Baqarah 1-10', 'Work on tajweed rules for letter connections', 'Student shows good progress', 'COMPLETED', 1),
(2, 'Fatima Khan', 'Class B', 'Al-Baqarah', '1-20', '2024-04-19', '11:00:00', '11:45:00', 92.0, 89.5, 91.0, 90.8, 5, 'Excellent work! Very fluent and accurate', 'Minor pausing between verses', 'Excellent', 'Al-Baqarah 21-40', 'Continue practicing longer surahs', 'Excellent student performance', 'COMPLETED', 1);
