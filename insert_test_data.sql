DELETE FROM studentevaluation WHERE teacherId = 'T001';

INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES 
('SE101', 'S001', 'T001', 'Class A', 'Al-Fatiha', '1-7', '2024-05-01', '10:00:00', '10:30:00', 88.5, 90.0, 87.0, 88.5, 4, 'Excellent pronunciation', 'Work on connections', 'Good', 'Al-Baqarah 1-10', 'Continue practice', 'Great dedication', 'COMPLETED', 'S001'),
('SE102', 'S002', 'T001', 'Class B', 'Al-Baqarah', '1-20', '2024-05-02', '11:00:00', '11:45:00', 92.0, 89.5, 91.0, 90.8, 5, 'Very fluent', 'Minor pausing', 'Excellent', 'Al-Baqarah 21-40', 'Move to longer surahs', 'Excellent', 'COMPLETED', 'S002'),
('SE103', 'S003', 'T001', 'Class A', 'An-Nisa', '1-10', '2024-05-03', '14:00:00', '14:30:00', 75.5, 78.0, 76.5, 76.7, 3, 'Good effort', 'Tajweed review needed', 'Fair', 'An-Nisa 11-30', 'Study Assimilation', 'Needs dedication', 'COMPLETED', 'S003'),
('SE104', 'S004', 'T001', 'Class A', 'Al-Araf', '1-20', '2024-05-10', '10:30:00', '11:00:00', 0, 0, 0, 0, 0, '', '', '', '', '', '', 'PENDING', 'S004'),
('SE105', 'S005', 'T001', 'Class C', 'At-Tawbah', '1-15', '2024-05-11', '13:00:00', '13:30:00', 0, 0, 0, 0, 0, '', '', '', '', '', '', 'PENDING', 'S005');
