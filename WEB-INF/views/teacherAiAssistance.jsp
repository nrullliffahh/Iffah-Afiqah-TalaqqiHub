<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Assistance - TalaqqiHub Teacher Portal</title>
    <%@ include file="/WEB-INF/views/includes/teacherLayoutStyles.jsp" %>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { overflow-x: hidden; }
        .main-content { display: flex; flex-direction: column; }
        .chat-container {
            flex: 1; display: flex; flex-direction: column;
            padding: 24px 32px 0; max-height: calc(100vh - 73px);
        }
        .assistant-icon {
            width: 44px; height: 44px; border-radius: 50%;
            background: linear-gradient(135deg, #7c3aed 0%, #be185d 100%);
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 18px;
        }
        .assistant-title { font-size: 20px; font-weight: 700; color: #111827; }
        .assistant-subtitle { font-size: 14px; color: #6B7280; margin-top: 2px; }
        .history-btn {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 16px; border-radius: 10px; border: 1px solid #E5E7EB;
            background: white; color: #4B5563; font-size: 14px; font-weight: 500; cursor: pointer;
        }
        .history-badge {
            background: #7c3aed; color: white; border-radius: 50%;
            width: 20px; height: 20px; font-size: 11px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
        }
        .disclaimer {
            background: #F5F3FF; border: 1px solid #DDD6FE; border-radius: 12px;
            padding: 12px 16px; display: flex; align-items: flex-start; gap: 10px;
            margin-bottom: 20px; font-size: 13px; color: #5B21B6;
        }
        .disclaimer i { color: #7c3aed; margin-top: 2px; }
        .chat-messages {
            flex: 1; overflow-y: auto; padding-bottom: 16px;
            display: flex; flex-direction: column; gap: 16px;
        }
        .welcome-state {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; justify-content: center; text-align: center; padding: 40px 20px;
        }
        .welcome-icon {
            width: 80px; height: 80px; border-radius: 50%;
            background: linear-gradient(135deg, #7c3aed 0%, #be185d 100%);
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 36px; margin-bottom: 20px;
        }
        .welcome-title { font-size: 22px; font-weight: 700; color: #111827; margin-bottom: 8px; }
        .welcome-text { font-size: 14px; color: #6B7280; max-width: 520px; margin-bottom: 28px; line-height: 1.6; }
        .suggested-prompts { display: flex; flex-direction: column; gap: 10px; width: 100%; max-width: 520px; }
        .prompt-btn {
            display: flex; align-items: center; gap: 10px;
            padding: 14px 18px; border-radius: 12px; border: 1px solid #E5E7EB;
            background: white; color: #374151; font-size: 14px; text-align: left; cursor: pointer;
        }
        .prompt-btn:hover { border-color: #a855f7; background: #FAF5FF; }
        .prompt-btn i { color: #FBBF24; }
        .message { max-width: 85%; padding: 14px 18px; border-radius: 16px; font-size: 14px; line-height: 1.6; }
        .message.user {
            align-self: flex-end;
            background: linear-gradient(135deg, #7c3aed 0%, #be185d 100%);
            color: white; border-bottom-right-radius: 4px;
        }
        .message.assistant {
            align-self: flex-start; background: white; color: #111827;
            border: 1px solid #E5E7EB; border-bottom-left-radius: 4px;
        }
        .message.assistant .ai-label {
            font-size: 11px; font-weight: 600; color: #7c3aed;
            margin-bottom: 6px; display: flex; align-items: center; gap: 6px;
        }
        .typing-indicator {
            align-self: flex-start; background: white; border: 1px solid #E5E7EB;
            border-radius: 16px; padding: 14px 18px; display: none;
        }
        .typing-dots { display: flex; gap: 4px; }
        .typing-dots span {
            width: 8px; height: 8px; border-radius: 50%; background: #a855f7;
            animation: bounce 1.4s infinite ease-in-out both;
        }
        .typing-dots span:nth-child(1) { animation-delay: -0.32s; }
        .typing-dots span:nth-child(2) { animation-delay: -0.16s; }
        @keyframes bounce {
            0%, 80%, 100% { transform: scale(0); }
            40% { transform: scale(1); }
        }
        .input-area {
            background: white; border-top: 1px solid #E5E7EB;
            padding: 16px 32px 20px; margin: 0 -32px;
        }
        .input-row { display: flex; gap: 12px; align-items: flex-end; }
        .chat-input {
            flex: 1; border: 1px solid #E5E7EB; border-radius: 14px;
            padding: 14px 18px; font-size: 14px; resize: none;
            min-height: 48px; max-height: 120px; outline: none; font-family: inherit;
        }
        .chat-input:focus { border-color: #a855f7; box-shadow: 0 0 0 3px rgba(168,85,247,0.15); }
        .ask-btn {
            display: flex; align-items: center; gap: 8px;
            padding: 14px 24px; border-radius: 14px; border: none;
            background: linear-gradient(135deg, #7c3aed 0%, #be185d 100%);
            color: white; font-size: 14px; font-weight: 600; cursor: pointer; white-space: nowrap;
        }
        .ask-btn:hover { opacity: 0.92; }
        .ask-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .input-hint { font-size: 12px; color: #9CA3AF; margin-top: 8px; }
        .history-panel {
            position: fixed; top: 0; right: -400px; width: 400px; height: 100vh;
            background: white; box-shadow: -4px 0 24px rgba(0,0,0,0.1);
            z-index: 1000; transition: right 0.3s ease; overflow-y: auto;
        }
        .history-panel.open { right: 0; }
        .history-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.3); z-index: 999; display: none; }
        .history-overlay.open { display: block; }
        .history-panel-header {
            padding: 20px 24px; border-bottom: 1px solid #E5E7EB;
            display: flex; justify-content: space-between; align-items: center;
        }
        .history-item { padding: 16px 24px; border-bottom: 1px solid #F3F4F6; cursor: pointer; }
        .history-item:hover { background: #FAF5FF; }
        .error-toast {
            background: #FEF2F2; border: 1px solid #FECACA; color: #B91C1C;
            border-radius: 10px; padding: 12px 16px; font-size: 13px; margin-bottom: 12px; display: none;
        }
        .info-toast {
            background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E;
            border-radius: 10px; padding: 12px 16px; font-size: 13px; margin-bottom: 12px; display: none;
        }
    </style>
</head>
<body>
<%
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }
    int historyCount = 0;
    Object hc = request.getAttribute("historyCount");
    if (hc instanceof Integer) historyCount = (Integer) hc;
%>

<jsp:include page="/WEB-INF/views/includes/teacherSidebar.jsp">
    <jsp:param name="activePage" value="ai-assistance"/>
</jsp:include>

<div class="main-content">
    <jsp:include page="/WEB-INF/views/includes/teacherTopNavbar.jsp">
        <jsp:param name="pageTitle" value="AI Assistance"/>
        <jsp:param name="notifPrefix" value="aiNotif"/>
    </jsp:include>

    <div class="chat-container">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;">
            <div style="display:flex;align-items:center;gap:12px;">
                <div class="assistant-icon"><i class="fas fa-bolt"></i></div>
                <div>
                    <div class="assistant-title">AI Learning Assistant</div>
                    <div class="assistant-subtitle">Ask questions about Quran recitation and Tajweed rules</div>
                </div>
            </div>
            <button type="button" class="history-btn" onclick="toggleHistory()">
                <i class="fas fa-clock"></i> History
                <span class="history-badge" id="historyBadge"><%= historyCount %></span>
            </button>
        </div>

        <div class="disclaimer">
            <i class="fas fa-info-circle"></i>
            <span>AI responses are for teaching reference only. Always verify important matters with qualified scholars.</span>
        </div>

        <div class="error-toast" id="errorToast"></div>
        <div class="info-toast" id="infoToast"></div>

        <div class="chat-messages" id="chatMessages">
            <div class="welcome-state" id="welcomeState">
                <div class="welcome-icon"><i class="fas fa-bolt"></i></div>
                <div class="welcome-title">Welcome to AI Learning Assistant</div>
                <div class="welcome-text">
                    Ask questions about Quran recitation, Tajweed rules, pronunciation, or use as teaching preparation support.
                </div>
                <div class="suggested-prompts">
                    <button type="button" class="prompt-btn" onclick="usePrompt(this)">
                        <i class="fas fa-lightbulb"></i>
                        How do I pronounce the letter ض correctly?
                    </button>
                    <button type="button" class="prompt-btn" onclick="usePrompt(this)">
                        <i class="fas fa-lightbulb"></i>
                        What are the different types of Madd?
                    </button>
                    <button type="button" class="prompt-btn" onclick="usePrompt(this)">
                        <i class="fas fa-lightbulb"></i>
                        Explain Noon Sakinah rules with examples
                    </button>
                </div>
            </div>
            <div class="typing-indicator" id="typingIndicator">
                <div class="typing-dots"><span></span><span></span><span></span></div>
            </div>
        </div>

        <div class="input-area">
            <div class="input-row">
                <textarea id="chatInput" class="chat-input" rows="1"
                    placeholder="Ask about Quran recitation or Tajweed rules..."
                    onkeydown="handleKeydown(event)"></textarea>
                <button type="button" class="ask-btn" id="askBtn" onclick="sendQuestion()">
                    <i class="fas fa-arrow-right"></i> Ask AI
                </button>
            </div>
            <div class="input-hint">Press Enter to send, Shift + Enter for new line</div>
        </div>
    </div>
</div>

<div class="history-overlay" id="historyOverlay" onclick="toggleHistory()"></div>
<div class="history-panel" id="historyPanel">
    <div class="history-panel-header">
        <span style="font-size:18px;font-weight:700;color:#111827;">Chat History</span>
        <button type="button" onclick="toggleHistory()" style="background:none;border:none;color:#6B7280;font-size:20px;cursor:pointer;">
            <i class="fas fa-times"></i>
        </button>
    </div>
    <div id="historyList">
        <c:choose>
            <c:when test="${not empty historyList}">
                <c:forEach var="item" items="${historyList}">
                    <div class="history-item"
                         data-question="${fn:escapeXml(item.aiQuestion)}"
                         data-response="${fn:escapeXml(item.aiResponse)}">
                        <div style="font-size:14px;font-weight:600;color:#111827;margin-bottom:4px;"><c:out value="${item.aiQuestion}"/></div>
                        <div style="font-size:13px;color:#6B7280;">
                            <c:out value="${fn:length(item.aiResponse) > 100 ? fn:substring(item.aiResponse, 0, 100).concat('...') : item.aiResponse}"/>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div style="padding:40px 24px;text-align:center;color:#9CA3AF;font-size:14px;">No chat history yet. Ask your first question!</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    const contextPath = '<%= request.getContextPath() %>';
    let isLoading = false;

    function handleKeydown(e) {
        if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendQuestion(); }
    }
    function usePrompt(btn) {
        document.getElementById('chatInput').value = btn.textContent.trim();
        sendQuestion();
    }
    function hideWelcome() {
        const w = document.getElementById('welcomeState');
        if (w) w.style.display = 'none';
    }
    function appendMessage(text, role) {
        hideWelcome();
        const container = document.getElementById('chatMessages');
        const typing = document.getElementById('typingIndicator');
        const div = document.createElement('div');
        div.className = 'message ' + role;
        if (role === 'assistant') {
            div.innerHTML = '<div class="ai-label"><i class="fas fa-bolt"></i> AI Assistant</div>' + formatText(text);
        } else {
            div.textContent = text;
        }
        container.insertBefore(div, typing);
        container.scrollTop = container.scrollHeight;
    }
    function formatText(text) {
        return text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\n/g,'<br>');
    }
    function showError(msg) {
        document.getElementById('infoToast').style.display = 'none';
        const t = document.getElementById('errorToast');
        t.textContent = msg; t.style.display = 'block';
        setTimeout(() => { t.style.display = 'none'; }, 6000);
    }
    function showInfo(msg) {
        document.getElementById('errorToast').style.display = 'none';
        const t = document.getElementById('infoToast');
        t.textContent = msg; t.style.display = 'block';
        setTimeout(() => { t.style.display = 'none'; }, 8000);
    }
    function setLoading(loading) {
        isLoading = loading;
        document.getElementById('askBtn').disabled = loading;
        document.getElementById('typingIndicator').style.display = loading ? 'block' : 'none';
        if (loading) document.getElementById('chatMessages').scrollTop = document.getElementById('chatMessages').scrollHeight;
    }
    async function sendQuestion() {
        const input = document.getElementById('chatInput');
        const question = input.value.trim();
        if (!question || isLoading) return;
        input.value = '';
        appendMessage(question, 'user');
        setLoading(true);
        try {
            const formData = new URLSearchParams();
            formData.append('action', 'ask');
            formData.append('question', question);
            const res = await fetch(contextPath + '/teacher/ai-assistance', {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                body: formData
            });
            const data = await res.json();
            setLoading(false);
            if (data.success) {
                let reply = data.response;
                if (data.fallback) reply = reply.replace(/\n\n_Note:.*$/s, '');
                appendMessage(reply, 'assistant');
                if (data.fallback) showInfo('Live AI unavailable. Showing offline Tajweed guide instead.');
                if (data.historyCount !== undefined) document.getElementById('historyBadge').textContent = data.historyCount;
            } else {
                showError(data.error || 'Failed to get AI response.');
            }
        } catch (err) {
            setLoading(false);
            showError('Network error. Please check your connection and try again.');
        }
    }
    function toggleHistory() {
        document.getElementById('historyPanel').classList.toggle('open');
        document.getElementById('historyOverlay').classList.toggle('open');
    }
    function loadHistoryItem(question, response) {
        hideWelcome();
        const container = document.getElementById('chatMessages');
        container.querySelectorAll('.message').forEach(m => m.remove());
        appendMessage(question, 'user');
        appendMessage(response, 'assistant');
        toggleHistory();
    }
    document.querySelectorAll('.history-item[data-question]').forEach(item => {
        item.addEventListener('click', () => loadHistoryItem(item.dataset.question, item.dataset.response));
    });
    document.getElementById('chatInput').addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
</script>
</body>
</html>
