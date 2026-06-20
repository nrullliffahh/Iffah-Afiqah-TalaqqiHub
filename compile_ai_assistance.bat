@echo off
cd /d %~dp0
echo Compiling AI Assistance classes...

set CLASSPATH=WEB-INF\classes;WEB-INF\lib\*;C:\xampp\tomcat\lib\servlet-api.jar

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\model\AiAssistance.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\util\AiConfig.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\util\OpenAIService.java src\util\GeminiService.java src\util\TajweedKnowledgeBase.java src\util\AiChatService.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\dao\AiAssistanceDAO.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\controller\StudentAiAssistanceServlet.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\controller\TeacherAiAssistanceServlet.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\model\AiInteraction.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

javac -encoding UTF-8 -cp "%CLASSPATH%" -d WEB-INF\classes src\controller\AdminAiAssistanceServlet.java
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo AI Assistance compilation complete.
exit /b 0
