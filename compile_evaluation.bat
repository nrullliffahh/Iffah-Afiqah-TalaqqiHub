@echo off
cd /d C:\xampp\tomcat\webapps\TalaqqiHub
javac -cp "WEB-INF/classes;WEB-INF/lib/*" -d WEB-INF/classes src\dao\EvaluationDAO.java
exit /b %ERRORLEVEL%
