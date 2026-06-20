<%-- Evaluation Modal Component --%>
<%-- Shows after a Talaqqi session ends for student to provide feedback --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
.evaluation-modal {
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

.evaluation-modal.show {
    display: flex;
}

.evaluation-modal-content {
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

.evaluation-header {
    text-align: center;
    margin-bottom: 24px;
}

.evaluation-header h2 {
    font-size: 24px;
    font-weight: 700;
    color: #1F4D36;
    margin-bottom: 8px;
}

.evaluation-header p {
    font-size: 14px;
    color: #64748B;
}

.evaluation-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.form-group label {
    font-size: 14px;
    font-weight: 600;
    color: #1F4D36;
}

.star-rating {
    display: flex;
    gap: 12px;
    font-size: 28px;
}

.star {
    cursor: pointer;
    color: #CBD5E1;
    transition: all 0.2s ease;
}

.star:hover,
.star.active {
    color: #F59E0B;
    transform: scale(1.2);
}

.teacher-name {
    font-size: 16px;
    font-weight: 600;
    color: #0F172A;
    margin-bottom: 4px;
}

.session-details {
    font-size: 13px;
    color: #64748B;
    margin-top: 4px;
}

textarea.evaluation-comments {
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

textarea.evaluation-comments:focus {
    outline: none;
    border-color: #1F4D36;
    box-shadow: 0 0 0 3px rgba(31, 77, 54, 0.1);
}

.evaluation-actions {
    display: flex;
    gap: 12px;
    margin-top: 24px;
}

.btn-evaluation {
    flex: 1;
    padding: 12px 16px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-submit {
    background: #1F4D36;
    color: white;
}

.btn-submit:hover {
    background: #1a3e2c;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(31, 77, 54, 0.2);
}

.btn-skip {
    background: #E2E8F0;
    color: #475569;
}

.btn-skip:hover {
    background: #CBD5E1;
}

.loading-spinner {
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

.success-message {
    background: #D1FAE5;
    color: #065F46;
    padding: 16px;
    border-radius: 8px;
    text-align: center;
    margin-bottom: 16px;
}

.monthly-renewal-banner {
    background: linear-gradient(135deg, #1F4D36 0%, #355E3B 100%);
    color: white;
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    text-align: center;
}

.monthly-renewal-banner .badge {
    display: inline-block;
    background: rgba(255, 255, 255, 0.2);
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 12px;
    margin-bottom: 8px;
}

.monthly-renewal-banner h3 {
    font-size: 16px;
    margin-bottom: 4px;
}

.monthly-renewal-banner p {
    font-size: 13px;
    opacity: 0.9;
}
</style>

<div id="evaluationModal" class="evaluation-modal">
    <div class="evaluation-modal-content">
        <!-- Monthly Renewal Banner -->
        <div id="monthlyRenewalBanner" class="monthly-renewal-banner" style="display: none;">
            <div class="badge">📅 Monthly Reset</div>
            <h3>New Evaluation Month!</h3>
            <p>Start your fresh evaluation journey for <%= new java.text.SimpleDateFormat("MMMM yyyy").format(new java.util.Date()) %></p>
        </div>

        <div class="evaluation-header">
            <h2>Session Complete! 🎉</h2>
            <p>Please rate your teacher and share your feedback</p>
        </div>

        <div id="successMessage" class="success-message" style="display: none;">
            ✓ Thank you for your feedback!
        </div>

        <form id="evaluationForm" class="evaluation-form" onsubmit="submitEvaluation(event)">
            <!-- Teacher Info -->
            <div class="form-group">
                <label>Your Teacher</label>
                <div class="teacher-name" id="teacherName">-</div>
                <div class="session-details" id="sessionDetails">-</div>
            </div>

            <!-- Rating Stars -->
            <div class="form-group">
                <label>How would you rate this session? ⭐</label>
                <div class="star-rating" id="starRating">
                    <span class="star" data-rating="1">★</span>
                    <span class="star" data-rating="2">★</span>
                    <span class="star" data-rating="3">★</span>
                    <span class="star" data-rating="4">★</span>
                    <span class="star" data-rating="5">★</span>
                </div>
                <input type="hidden" id="ratingInput" name="rating" value="0" required>
            </div>

            <!-- Comments -->
            <div class="form-group">
                <label>Your Feedback (Optional)</label>
                <textarea id="commentsInput" name="comments" class="evaluation-comments"
                          placeholder="Share your thoughts about the session, what you learned, and what could be improved..."></textarea>
            </div>

            <!-- Actions -->
            <div class="evaluation-actions">
                <button type="button" class="btn-evaluation btn-skip" onclick="skipEvaluation()">Skip for Now</button>
                <button type="submit" class="btn-evaluation btn-submit" id="submitBtn">Submit Feedback</button>
            </div>
        </form>
    </div>
</div>

<script>
// Evaluation Modal Management
let currentEvaluationData = {
    sessionId: null,
    teacherId: null,
    rating: 0
};

// Star Rating Click Handler
document.querySelectorAll('.star-rating .star').forEach(star => {
    star.addEventListener('click', function() {
        const rating = parseInt(this.dataset.rating);
        currentEvaluationData.rating = rating;
        document.getElementById('ratingInput').value = rating;
        
        // Update star display
        document.querySelectorAll('.star-rating .star').forEach(s => {
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
        document.querySelectorAll('.star-rating .star').forEach(s => {
            const starRating = parseInt(s.dataset.rating);
            if (starRating <= rating) {
                s.style.color = '#F59E0B';
            } else {
                s.style.color = '#CBD5E1';
            }
        });
    });
});

document.getElementById('starRating').addEventListener('mouseout', function() {
    document.querySelectorAll('.star-rating .star').forEach((s, i) => {
        if (i < currentEvaluationData.rating) {
            s.classList.add('active');
        } else {
            s.classList.remove('active');
        }
    });
});

/**
 * Show evaluation modal after session ends
 */
function showEvaluationModal(sessionId, teacherId, teacherName, surah, ayah) {
    currentEvaluationData.sessionId = sessionId;
    currentEvaluationData.teacherId = teacherId;
    currentEvaluationData.rating = 0;
    
    // Reset form
    document.getElementById('evaluationForm').reset();
    document.getElementById('ratingInput').value = 0;
    document.getElementById('successMessage').style.display = 'none';
    document.querySelectorAll('.star').forEach(s => s.classList.remove('active'));
    
    // Update teacher info
    document.getElementById('teacherName').textContent = teacherName || 'Your Teacher';
    document.getElementById('sessionDetails').textContent = `Surah: ${surah}, Ayah: ${ayah}`;
    
    // Check if monthly renewal
    checkMonthlyRenewal();
    
    // Show modal
    document.getElementById('evaluationModal').classList.add('show');
}

/**
 * Hide evaluation modal
 */
function hideEvaluationModal() {
    document.getElementById('evaluationModal').classList.remove('show');
}

/**
 * Submit evaluation feedback
 */
function submitEvaluation(event) {
    event.preventDefault();
    
    const rating = parseInt(document.getElementById('ratingInput').value);
    const comments = document.getElementById('commentsInput').value;
    
    if (rating === 0) {
        alert('Please select a rating');
        return;
    }
    
    const submitBtn = document.getElementById('submitBtn');
    submitBtn.innerHTML = '<span class="loading-spinner"></span>';
    submitBtn.disabled = true;
    
    fetch('<%= request.getContextPath() %>/api/evaluation/session-feedback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            action: 'submitStudentFeedback',
            sessionId: currentEvaluationData.sessionId,
            teacherId: currentEvaluationData.teacherId,
            rating: rating,
            comments: comments
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('successMessage').style.display = 'block';
            document.getElementById('evaluationForm').style.display = 'none';
            
            setTimeout(() => {
                hideEvaluationModal();
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
 * Skip evaluation for now
 */
function skipEvaluation() {
    hideEvaluationModal();
}

/**
 * Check and show monthly renewal banner
 */
function checkMonthlyRenewal() {
    fetch('<%= request.getContextPath() %>/api/evaluation/session-feedback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            action: 'getMonthlyStatus'
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success && data.status.isNewMonth) {
            document.getElementById('monthlyRenewalBanner').style.display = 'block';
        } else {
            document.getElementById('monthlyRenewalBanner').style.display = 'none';
        }
    })
    .catch(error => console.log('Monthly check:', error));
}

/**
 * Auto-show evaluation modal for pending sessions
 */
document.addEventListener('DOMContentLoaded', function() {
    // This will be called after session ends
    // Can be triggered from StudentTalaqqiSessionServlet
});
</script>
