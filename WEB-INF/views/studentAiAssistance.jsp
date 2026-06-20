<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="model.AiAssistance" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Assistance - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .chat-page { padding: 0; display: flex; flex-direction: column; min-height: calc(100vh - 73px); }
        .chat-container { flex: 1; display: flex; flex-direction: column; padding: 24px 30px 0; max-height: none; }
        .assistant-header {
            display: flex; justify-content: space-between; align-items: flex-start;
            margin-bottom: 16px;
        }
        .assistant-title-row { display: flex; align-items: center; gap: 12px; }
        .assistant-icon {
            width: 44px; height: 44px; border-radius: 50%;
            background: var(--student-gradient);
            display: flex; align-items: center; justify-content: center; color: white; font-size: 18px;
        }
        .assistant-title { font-size: 20px; font-weight: 700; color: #1E293B; }
        .assistant-subtitle { font-size: 14px; color: #64748B; margin-top: 2px; }
        .history-btn {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 16px; border-radius: 10px; border: 1px solid #E2E8F0;
            background: white; color: #475569; font-size: 14px; font-weight: 500;
            cursor: pointer; transition: all 0.2s;
        }
        .history-btn:hover { background: #F8FAFC; border-color: #CBD5E1; }
        .history-badge {
            background: var(--student-green); color: white; border-radius: 50%;
            width: 20px; height: 20px; font-size: 11px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
        }
        .disclaimer {
            background: #EFF6FF; border: 1px solid #BFDBFE; border-radius: 12px;
            padding: 12px 16px; display: flex; align-items: flex-start; gap: 10px;
            margin-bottom: 20px; font-size: 13px; color: #1E40AF;
        }
        .disclaimer i { margin-top: 2px; color: #3B82F6; }
        .chat-messages {
            flex: 1; overflow-y: auto; padding-bottom: 16px;
            display: flex; flex-direction: column; gap: 16px;
        }
        .welcome-state {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; justify-content: center; text-align: center;
            padding: 40px 20px;
        }
        .welcome-icon {
            width: 72px; height: 72px; border-radius: 50%;
            background: var(--student-gradient);
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 32px; margin-bottom: 20px;
        }
        .welcome-title { font-size: 22px; font-weight: 700; color: #1E293B; margin-bottom: 8px; }
        .welcome-text { font-size: 14px; color: #64748B; max-width: 480px; margin-bottom: 28px; line-height: 1.6; }
        .suggested-prompts { display: flex; flex-direction: column; gap: 10px; width: 100%; max-width: 520px; }
        .prompt-btn {
            display: flex; align-items: center; gap: 10px;
            padding: 14px 18px; border-radius: 12px; border: 1px solid #E2E8F0;
            background: white; color: #334155; font-size: 14px; text-align: left;
            cursor: pointer; transition: all 0.2s;
        }
        .prompt-btn:hover { border-color: var(--student-green); background: var(--student-green-light); }
        .prompt-btn i { color: #94A3B8; font-size: 13px; }
        .message { max-width: 85%; padding: 14px 18px; border-radius: 16px; font-size: 14px; line-height: 1.6; }
        .message.user {
            align-self: flex-end; background: var(--student-green); color: white;
            border-bottom-right-radius: 4px;
        }
        .message.assistant {
            align-self: flex-start; background: white; color: #1E293B;
            border: 1px solid #E2E8F0; border-bottom-left-radius: 4px;
        }
        .message.assistant .ai-label {
            font-size: 11px; font-weight: 600; color: var(--student-green);
            margin-bottom: 6px; display: flex; align-items: center; gap: 6px;
        }
        .typing-indicator {
            align-self: flex-start; background: white; border: 1px solid #E2E8F0;
            border-radius: 16px; padding: 14px 18px; display: none;
        }
        .typing-dots { display: flex; gap: 4px; }
        .typing-dots span {
            width: 8px; height: 8px; border-radius: 50%; background: #94A3B8;
            animation: bounce 1.4s infinite ease-in-out both;
        }
        .typing-dots span:nth-child(1) { animation-delay: -0.32s; }
        .typing-dots span:nth-child(2) { animation-delay: -0.16s; }
        @keyframes bounce {
            0%, 80%, 100% { transform: scale(0); }
            40% { transform: scale(1); }
        }
        .input-area {
            background: white; border-top: 1px solid #E2E8F0;
            padding: 16px 30px 20px; margin: 0;
        }
        .input-row { display: flex; gap: 12px; align-items: flex-end; }
        .chat-input {
            flex: 1; border: 1px solid #E2E8F0; border-radius: 14px;
            padding: 14px 18px; font-size: 14px; resize: none;
            min-height: 48px; max-height: 120px; outline: none;
            font-family: inherit; line-height: 1.5;
        }
        .chat-input:focus { border-color: var(--student-green); box-shadow: 0 0 0 3px rgba(4,120,87,0.15); }
        .ask-btn {
            display: flex; align-items: center; gap: 8px;
            padding: 14px 24px; border-radius: 14px; border: none;
            background: var(--student-gradient);
            color: white; font-size: 14px; font-weight: 600; cursor: pointer;
            transition: all 0.2s; white-space: nowrap;
        }
        .ask-btn:hover { opacity: 0.9; transform: translateY(-1px); }
        .ask-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
        .input-hint { font-size: 12px; color: #94A3B8; margin-top: 8px; }
        .history-panel {
            position: fixed; top: 0; right: -400px; width: 400px; height: 100vh;
            background: white; box-shadow: -4px 0 24px rgba(0,0,0,0.1);
            z-index: 1000; transition: right 0.3s ease; overflow-y: auto;
        }
        .history-panel.open { right: 0; }
        .history-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.3);
            z-index: 999; display: none;
        }
        .history-overlay.open { display: block; }
        .history-panel-header {
            padding: 20px 24px; border-bottom: 1px solid #E2E8F0;
            display: flex; justify-content: space-between; align-items: center;
        }
        .history-panel-title { font-size: 18px; font-weight: 700; color: #1E293B; }
        .history-close { background: none; border: none; font-size: 20px; color: #64748B; cursor: pointer; }
        .history-item {
            padding: 16px 24px; border-bottom: 1px solid #F1F5F9; cursor: pointer;
            transition: background 0.2s;
        }
        .history-item:hover { background: #F8FAFC; }
        .history-question { font-size: 14px; font-weight: 600; color: #1E293B; margin-bottom: 4px; }
        .history-response { font-size: 13px; color: #64748B; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .history-empty { padding: 40px 24px; text-align: center; color: #94A3B8; font-size: 14px; }
        .error-toast {
            background: #FEF2F2; border: 1px solid #FECACA; color: #B91C1C;
            border-radius: 10px; padding: 12px 16px; font-size: 13px;
            margin-bottom: 12px; display: none;
        }
        .info-toast {
            background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E;
            border-radius: 10px; padding: 12px 16px; font-size: 13px;
            margin-bottom: 12px; display: none;
        }
    </style>
</head>
<body>
<%
    int historyCount = 0;
    Object hc = request.getAttribute("historyCount");
    if (hc instanceof Integer) historyCount = (Integer) hc;
%>

    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="ai-assistance"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="AI Assistance"/>
            <jsp:param name="notifPrefix" value="aiNotif"/>
        </jsp:include>

    <div class="page-content chat-page">
    <div class="chat-container">
        <div class="assistant-header">
            <div>
                <div class="assistant-title-row">
                    <div class="assistant-icon"><i class="fas fa-bolt"></i></div>
                    <div>
                        <div class="assistant-title">AI Learning Assistant</div>
                        <div class="assistant-subtitle">Ask questions about Quran recitation and Tajweed rules</div>
                    </div>
                </div>
            </div>
            <button type="button" class="history-btn" id="historyBtn" onclick="toggleHistory()">
                <i class="fas fa-clock"></i> History
                <span class="history-badge" id="historyBadge"><%= historyCount %></span>
            </button>
        </div>

        <div class="disclaimer">
            <i class="fas fa-info-circle"></i>
            <span>AI responses are for learning support only. Always verify important matters with qualified teachers.</span>
        </div>

        <div class="error-toast" id="errorToast"></div>
        <div class="info-toast" id="infoToast"></div>

        <div class="chat-messages" id="chatMessages">
            <div class="welcome-state" id="welcomeState">
                <div class="welcome-icon"><i class="fas fa-bolt"></i></div>
                <div class="welcome-title">Welcome to AI Learning Assistant</div>
                <div class="welcome-text">
                    Ask questions about Quran recitation, Tajweed rules, pronunciation, or any aspect of your learning journey.
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
                    Ask AI <i class="fas fa-arrow-right"></i>
                </button>
            </div>
            <div class="input-hint">Press Enter to send, Shift + Enter for new line</div>
        </div>
    </div>
    </div>
    </div>

<!-- History panel -->
<div class="history-overlay" id="historyOverlay" onclick="toggleHistory()"></div>
<div class="history-panel" id="historyPanel">
    <div class="history-panel-header">
        <span class="history-panel-title">Chat History</span>
        <button type="button" class="history-close" onclick="toggleHistory()"><i class="fas fa-times"></i></button>
    </div>
    <div id="historyList">
        <c:choose>
            <c:when test="${not empty historyList}">
                <c:forEach var="item" items="${historyList}">
                    <div class="history-item"
                         data-question="${fn:escapeXml(item.aiQuestion)}"
                         data-response="${fn:escapeXml(item.aiResponse)}">
                        <div class="history-question"><c:out value="${item.aiQuestion}"/></div>
                        <div class="history-response">
                            <c:out value="${fn:length(item.aiResponse) > 100 ? fn:substring(item.aiResponse, 0, 100).concat('...') : item.aiResponse}"/>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="history-empty">No chat history yet. Ask your first question!</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    const contextPath = '<%= request.getContextPath() %>';
    let isLoading = false;

    function handleKeydown(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendQuestion();
        }
    }

    function usePrompt(btn) {
        const text = btn.textContent.trim();
        document.getElementById('chatInput').value = text;
        sendQuestion();
    }

    function hideWelcome() {
        const welcome = document.getElementById('welcomeState');
        if (welcome) welcome.style.display = 'none';
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
        return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br>');
    }

    function showError(msg) {
        document.getElementById('infoToast').style.display = 'none';
        const toast = document.getElementById('errorToast');
        toast.textContent = msg;
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 6000);
    }

    function showInfo(msg) {
        document.getElementById('errorToast').style.display = 'none';
        const toast = document.getElementById('infoToast');
        toast.textContent = msg;
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 8000);
    }

    function setLoading(loading) {
        isLoading = loading;
        document.getElementById('askBtn').disabled = loading;
        document.getElementById('typingIndicator').style.display = loading ? 'block' : 'none';
        if (loading) {
            const container = document.getElementById('chatMessages');
            container.scrollTop = container.scrollHeight;
        }
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

            const res = await fetch(contextPath + '/student/ai-assistance', {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                body: formData
            });

            const data = await res.json();
            setLoading(false);

            if (data.success) {
                let reply = data.response;
                if (data.fallback) {
                    reply = reply.replace(/\n\n_Note:.*$/s, '');
                }
                appendMessage(reply, 'assistant');
                if (data.fallback) {
                    showInfo('Live AI unavailable. Showing offline Tajweed guide instead.');
                }
                if (data.historyCount !== undefined) {
                    document.getElementById('historyBadge').textContent = data.historyCount;
                }
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
        item.addEventListener('click', () => {
            loadHistoryItem(item.dataset.question, item.dataset.response);
        });
    });

    document.getElementById('chatInput').addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
</script>
</body>
</html>
