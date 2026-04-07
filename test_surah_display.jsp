<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Test if current session has teacher access
    String teacherId = (String) session.getAttribute("teacherId");
    if (teacherId == null) {
        // You can log in if needed, for now show a test message
        out.println("Not logged in as teacher. Access denied.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Test Surah Display API</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { margin-bottom: 30px; padding: 15px; border: 1px solid #ccc; }
        pre { background: #f5f5f5; padding: 10px; overflow-x: auto; }
        button { padding: 8px 15px; margin: 5px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Test Surah Display API</h1>
    <p>Testing the quran-api endpoints to debug surah display issue.</p>

    <div class="test-section">
        <h2>Test 1: Surah List API</h2>
        <button onclick="testSurahList()">Test /teacher/quran-api?action=surahList</button>
        <div id="result1"></div>
    </div>

    <div class="test-section">
        <h2>Test 2: Surah Info API (Surah 2 - Al-Baqarah)</h2>
        <button onclick="testSurahInfo(2)">Test /teacher/quran-api?action=surahInfo&surah=2</button>
        <div id="result2"></div>
    </div>

    <div class="test-section">
        <h2>Test 3: Surah Info API (Surah 1 - Al-Fatiha)</h2>
        <button onclick="testSurahInfo(1)">Test /teacher/quran-api?action=surahInfo&surah=1</button>
        <div id="result3"></div>
    </div>

    <div class="test-section">
        <h2>Test 4: Single Ayah API</h2>
        <button onclick="testAyah(2, 1)">Test /teacher/quran-api?action=ayah&surah=2&ayah=1</button>
        <div id="result4"></div>
    </div>

    <script>
        var CTX = "<%= request.getContextPath() %>";

        function testSurahList() {
            var resultDiv = document.getElementById("result1");
            resultDiv.innerHTML = "<p>Loading...</p>";
            
            fetch(CTX + "/teacher/quran-api?action=surahList")
                .then(r => r.json())
                .then(json => {
                    resultDiv.innerHTML = "<pre class='success'>" + JSON.stringify(json, null, 2) + "</pre>";
                    if (json && json.data && json.data.length > 0) {
                        var first = json.data[0];
                        resultDiv.innerHTML += "<p><strong>First item keys:</strong> " + Object.keys(first).join(", ") + "</p>";
                    }
                })
                .catch(err => {
                    resultDiv.innerHTML = "<pre class='error'>" + err.message + "</pre>";
                });
        }

        function testSurahInfo(surahNum) {
            var resultDiv = document.getElementById("result" + (surahNum === 1 ? "3" : "2"));
            resultDiv.innerHTML = "<p>Loading...</p>";
            
            fetch(CTX + "/teacher/quran-api?action=surahInfo&surah=" + surahNum)
                .then(r => r.json())
                .then(json => {
                    resultDiv.innerHTML = "<pre class='success'>" + JSON.stringify(json, null, 2) + "</pre>";
                    if (json && json.data) {
                        resultDiv.innerHTML += "<p><strong>Data keys:</strong> " + Object.keys(json.data).join(", ") + "</p>";
                        resultDiv.innerHTML += "<p><strong>englishName:</strong> " + json.data.englishName + "</p>";
                        resultDiv.innerHTML += "<p><strong>englishNameTranslation:</strong> " + json.data.englishNameTranslation + "</p>";
                    }
                })
                .catch(err => {
                    resultDiv.innerHTML = "<pre class='error'>" + err.message + "</pre>";
                });
        }

        function testAyah(surah, ayah) {
            var resultDiv = document.getElementById("result4");
            resultDiv.innerHTML = "<p>Loading...</p>";
            
            fetch(CTX + "/teacher/quran-api?action=ayah&surah=" + surah + "&ayah=" + ayah)
                .then(r => r.json())
                .then(json => {
                    resultDiv.innerHTML = "<pre class='success'>" + JSON.stringify(json, null, 2) + "</pre>";
                    if (json && json.data) {
                        resultDiv.innerHTML += "<p><strong>Data is array:</strong> " + (Array.isArray(json.data) ? "Yes" : "No") + "</p>";
                        if (Array.isArray(json.data)) {
                            resultDiv.innerHTML += "<p><strong>Array length:</strong> " + json.data.length + "</p>";
                        }
                    }
                })
                .catch(err => {
                    resultDiv.innerHTML = "<pre class='error'>" + err.message + "</pre>";
                });
        }
    </script>
</body>
</html>
