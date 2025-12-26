<!-- Feedback Modal -->
<div id="feedbackModal" class="feedback-modal">
    <div class="feedback-content">
        <button class="close-btn" onclick="closeFeedback()">&times;</button>
        <div class="feedback-header">
            <h2>üìù Send Feedback</h2>
            <p>We value your feedback! Please share your thoughts about the East Gojjam VIMS system.</p>
        </div>
        
        <form class="feedback-form" onsubmit="submitFeedback(event)">
            <div class="form-group">
                <label for="feedback-name">ü Your Name</label>
                <input type="text" id="feedback-name" name="name" placeholder="Enter your full name" required>
            </div>
            
            <div class="form-group">
                <label for="feedback-email"> Email Address</label>
                <input type="email" id="feedback-email" name="email" placeholder="Enter your email address" required>
            </div>
            
            <div class="form-group">
                <label for="feedback-subject">üìù Subject</label>
                <input type="text" id="feedback-subject" name="subject" placeholder="Brief description of your feedback" required>
            </div>
            
            <div class="form-group">
                <label for="feedback-message"> Your Message</label>
                <textarea id="feedback-message" name="message" placeholder="Please share your detailed feedback, suggestions, or report any issues you've encountered..." required></textarea>
            </div>
            
            <div class="feedback-buttons">
                <button type="button" class="btn-cancel" onclick="closeFeedback()">‚ùå Cancel</button>
                <button type="submit" class="btn-submit">üöÄ Send Feedback</button>
            </div>
        </form>
    </div>
</div>

<style>
.feedback-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
    z-index: 2000;
    backdrop-filter: blur(5px);
}
.feedback-content {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: white;
    padding: 1.5rem;
    border-radius: 15px;
    width: 90%;
    max-width: 450px;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 15px 35px rgba(0,0,0,0.2);
}
.feedback-header {
    text-align: center;
    margin-bottom: 1rem;
}
.feedback-header h2 {
    color: #2c3e50;
    font-size: 1.5rem;
    margin-bottom: 0.5rem;
}
.feedback-header p {
    color: #666;
    font-size: 0.9rem;
}
.feedback-form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}
.form-group {
    display: flex;
    flex-direction: column;
}
.form-group label {
    color: #2c3e50;
    font-weight: 600;
    margin-bottom: 0.3rem;
    font-size: 0.85rem;
}
.feedback-form input, .feedback-form textarea {
    padding: 0.75rem;
    border: 2px solid #e0e6ed;
    border-radius: 8px;
    font-size: 0.9rem;
    transition: all 0.3s ease;
}
.feedback-form input:focus, .feedback-form textarea:focus {
    outline: none;
    border-color: #4facfe;
    box-shadow: 0 0 0 2px rgba(79, 172, 254, 0.1);
}
.feedback-form textarea {
    min-height: 80px;
    resize: vertical;
}
.feedback-buttons {
    display: flex;
    gap: 0.5rem;
    justify-content: center;
    margin-top: 1rem;
}
.btn-submit {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 20px;
    cursor: pointer;
    font-weight: bold;
    font-size: 0.9rem;
    transition: all 0.3s ease;
}
.btn-submit:hover {
    transform: translateY(-2px);
}
.btn-cancel {
    background: #6c757d;
    color: white;
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 20px;
    cursor: pointer;
    font-weight: bold;
    font-size: 0.9rem;
    transition: all 0.3s ease;
}
.btn-cancel:hover {
    background: #495057;
    transform: translateY(-2px);
}
.close-btn {
    position: absolute;
    top: 10px;
    right: 15px;
    background: none;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
    color: #666;
    width: 30px;
    height: 30px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}
.close-btn:hover {
    background: #f0f0f0;
}
</style>

<script>
function openFeedback() {
    document.getElementById('feedbackModal').style.display = 'block';
}

function closeFeedback() {
    document.getElementById('feedbackModal').style.display = 'none';
}

function submitFeedback(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    // Send to server without client validation
    fetch('feedback-handler.jsp', {
        method: 'POST',
        body: formData
    })
    .then(response => response.text())
    .then(text => {
        try {
            const data = JSON.parse(text);
            if (data.success) {
                alert('Thank you for your feedback! We appreciate your input.');
                form.reset();
                closeFeedback();
            } else {
                alert('Error: ' + data.message);
            }
        } catch (e) {
            alert('Thank you for your feedback! We appreciate your input.');
            form.reset();
            closeFeedback();
        }
    })
    .catch(error => {
        alert('Thank you for your feedback! We appreciate your input.');
        form.reset();
        closeFeedback();
    });
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('feedbackModal');
    if (event.target === modal) {
        closeFeedback();
    }
}
</script>