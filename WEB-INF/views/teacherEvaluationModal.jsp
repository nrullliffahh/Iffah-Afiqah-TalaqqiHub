<%-- Teacher Evaluation Modal Component --%>
<%-- Shows after a Talaqqi session ends for teacher to provide feedback --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
.teacher-evaluation-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    z-index: 9999;
    align-items: center;
    justify-content: center;
}

.teacher-evaluation-modal.show {
    display: flex;
}

.teacher-evaluation-modal-content {
    background: white;
    border-radius: 12px;
    padding: 32px;
    max-width: 500px;
    width: 90%;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
    animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
    from {
        transform: translateY(20px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}

.teacher-evaluation-header {
    text-align: center;
    margin-bottom: 24px;
}

.teacher-evaluation-header h2 {
    font-size: 24px;
    font-weight: 700;
    color: #7c3aed;
    margin-bottom: 8px;
}

.teacher-evaluation-header p {
    font-size: 14px;
    color: #64748B;
}

.teacher-evaluation-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.teacher-evaluation-form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.teacher-evaluation-form-group label {
    font-size: 14px;
    font-weight: 600;
    color: #7c3aed;
}

.teacher-star-rating {
    display: flex;
    gap: 12px;
    font-size: 28px;
}

.teacher-star {
    cursor: pointer;
    color: #CBD5E1;
    transition: all 0.2s ease;
}

.teacher-star:hover,
.teacher-star.active {
    color: #6d28d9;
    transform: scale(1.2);
}

.student-name {
    font-size: 16px;
    font-weight: 600;
    color: #0F172A;
    margin-bottom: 4px;
}

.teacher-session-details {
    font-size: 13px;
    color: #64748B;
    margin-top: 4px;
}

textarea.teacher-evaluation-comments {
    width: 100%;
    padding: 12px;
    border: 1px solid #E2E8F0;
    border-radius: 8px;
    font-family: inherit;
    font-size: 14px;
    resize: vertical;
    min-height: 80px;
    transition: border-color 0.2s;
}

textarea.teacher-evaluation-comments:focus {
    outline: none;
    border-color: #7c3aed;
    box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.teacher-evaluation-actions {
    display: flex;
    gap: 12px;
    margin-top: 24px;
}

.btn-teacher-evaluation {
    flex: 1;
    padding: 12px 16px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-teacher-submit {
    background: #7c3aed;
    color: white;
}

.btn-teacher-submit:hover {
    background: #6d28d9;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(124, 58, 237, 0.2);
}

.btn-teacher-skip {
    background: #E2E8F0;
    color: #475569;
}

.btn-teacher-skip:hover {
    background: #CBD5E1;
}

.teacher-loading-spinner {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 3px solid rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 0.8s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

.teacher-success-message {
    background: #F3E8FF;
    color: #6B21A8;
    padding: 16px;
    border-radius: 8px;
    text-align: center;
    margin-bottom: 16px;
}

.evaluation-criteria {
    background: #f9fafb;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 12px;
}

.evaluation-criteria h4 {
    font-size: 12px;
    font-weight: 700;
    color: #7c3aed;
    margin-bottom: 8px;
    text-transform: uppercase;
}

.evaluation-criteria-description {
    font-size: 12px;
    color: #64748B;
    line-height: 1.5;
}
</style>

<div id="teacherEvaluationModal" class="teacher-evaluation-modal">
    <div class="teacher-evaluation-modal-content">
        <div class="teacher-evaluation-header">
            <h2>Session Complete! ✅</h2>
            <p>Please rate your student's performance and share your feedback</p>
        </div>

        <div id="teacherSuccessMessage" class="teacher-success-message" style="display: none;">
            ✓ Thank you for your feedback!
        </div>

        <form id="teacherEvaluationForm" class="teacher-evaluation-form" onsubmit="submitTeacherEvaluation(event)">
            <!-- Student Info -->
            <div class="teacher-evaluation-form-group">
                <label>Student</label>
                <div class="student-name" id="studentName">-</div>
                <div class="teacher-session-details" id="teacherSessionDetails">-</div>
            </div>

            <!-- Evaluation Criteria Info -->
            <div class="evaluation-criteria">
                <h4>📝 Rating Guidelines</h4>
                <div class="evaluation-criteria-description">
                    <strong>5 ⭐:</strong> Excellent - Outstanding performance<br>
                    <strong>4 ⭐:</strong> Good - Solid performance with minor improvements<br>
                    <strong>3 ⭐:</strong> Average - Satisfactory, room for improvement<br>
                    <strong>2 ⭐:</strong> Fair - Needs significant improvement<br>
                    <strong>1 ⭐:</strong> Poor - Major areas need attention
                </div>
            </div>

            <!-- Rating Stars -->
            <div class="teacher-evaluation-form-group">
                <label>How would you rate this student's session? ⭐</label>
                <div class="teacher-star-rating" id="teacherStarRating">
                    <span class="teacher-star" data-rating="1">★</span>
                    <span class="teacher-star" data-rating="2">★</span>
                    <span class="teacher-star" data-rating="3">★</span>
                    <span class="teacher-star" data-rating="4">★</span>
                    <span class="teacher-star" data-rating="5">★</span>
                </div>
                <input type="hidden" id="teacherRatingInput" name="rating" value="0" required>
            </div>

            <!-- Comments -->
            <div class="teacher-evaluation-form-group">
                <label>Your Feedback (Optional)</label>
                <textarea id="teacherCommentsInput" name="comments" class="teacher-evaluation-comments"
                          placeholder="Share specific feedback about the student's Quran recitation, tajweed, fluency, and areas for improvement..."></textarea>
            </div>

            <!-- Actions -->
            <div class="teacher-evaluation-actions">
                <button type="button" class="btn-teacher-evaluation btn-teacher-skip" onclick="skipTeacherEvaluation()">Skip for Now</button>
                <button type="submit" class="btn-teacher-evaluation btn-teacher-submit" id="teacherSubmitBtn">Submit Feedback</button>
            </div>
        </form>
    </div>
</div>

<script>
// Teacher Evaluation Modal Management
let currentTeacherEvaluationData = {
    sessionId: null,
    studentId: null,
    rating: 0
};

// Teacher Star Rating Click Handler
document.querySelectorAll('.teacher-star-rating .teacher-star').forEach(star => {
    star.addEventListener('click', function() {
        const rating = parseInt(this.dataset.rating);
        currentTeacherEvaluationData.rating = rating;
        document.getElementById('teacherRatingInput').value = rating;
        
        // Update star display
        document.querySelectorAll('.teacher-star-rating .teacher-star').forEach(s => {
            const starRating = parseInt(s.dataset.rating);
            if (starRating <= rating) {
                s.classList.add('active');
            } else {
                s.classList.remove('active');
            }
        });
    });
    
    // Hover effect
    star.addEventListener('mouseover', function() {
        const rating = parseInt(this.dataset.rating);
        document.querySelectorAll('.teacher-star-rating .teacher-star').forEach(s => {
            const starRating = parseInt(s.dataset.rating);
            if (starRating <= rating) {
                s.style.color = '#6d28d9';
            } else {
                s.style.color = '#CBD5E1';
            }
        });
    });
});

document.getElementById('teacherStarRating').addEventListener('mouseout', function() {
    document.querySelectorAll('.teacher-star-rating .teacher-star').forEach((s, i) => {
        if (i < currentTeacherEvaluationData.rating) {
            s.classList.add('active');
        } else {
            s.classList.remove('active');
        }
    });
});

/**
 * Show teacher evaluation modal after session ends
 */
function showTeacherEvaluationModal(sessionId, studentId, studentName, surah, ayah) {
    currentTeacherEvaluationData.sessionId = sessionId;
    currentTeacherEvaluationData.studentId = studentId;
    currentTeacherEvaluationData.rating = 0;
    
    // Reset form
    document.getElementById('teacherEvaluationForm').reset();
    document.getElementById('teacherRatingInput').value = 0;
    document.getElementById('teacherSuccessMessage').style.display = 'none';
    document.querySelectorAll('.teacher-star').forEach(s => s.classList.remove('active'));
    
    // Update student info
    document.getElementById('studentName').textContent = studentName || 'Student';
    document.getElementById('teacherSessionDetails').textContent = `Surah: ${surah}, Ayah: ${ayah}`;
    
    // Show modal
    document.getElementById('teacherEvaluationModal').classList.add('show');
}

/**
 * Hide teacher evaluation modal
 */
function hideTeacherEvaluationModal() {
    document.getElementById('teacherEvaluationModal').classList.remove('show');
}

/**
 * Submit teacher evaluation feedback
 */
function submitTeacherEvaluation(event) {
    event.preventDefault();
    
    const rating = parseInt(document.getElementById('teacherRatingInput').value);
    const comments = document.getElementById('teacherCommentsInput').value;
    
    if (rating === 0) {
        alert('Please select a rating');
        return;
    }
    
    const submitBtn = document.getElementById('teacherSubmitBtn');
    submitBtn.innerHTML = '<span class="teacher-loading-spinner"></span>';
    submitBtn.disabled = true;
    
    fetch('<%= request.getContextPath() %>/api/evaluation/session-feedback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            action: 'submitTeacherFeedback',
            sessionId: currentTeacherEvaluationData.sessionId,
            studentId: currentTeacherEvaluationData.studentId,
            rating: rating,
            comments: comments
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('teacherSuccessMessage').style.display = 'block';
            document.getElementById('teacherEvaluationForm').style.display = 'none';
            
            setTimeout(() => {
                hideTeacherEvaluationModal();
            }, 2000);
        } else {
            alert('Error: ' + (data.error || 'Failed to submit feedback'));
            submitBtn.innerHTML = 'Submit Feedback';
            submitBtn.disabled = false;
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error submitting feedback');
        submitBtn.innerHTML = 'Submit Feedback';
        submitBtn.disabled = false;
    });
}

/**
 * Skip teacher evaluation for now
 */
function skipTeacherEvaluation() {
    hideTeacherEvaluationModal();
}
</script>
