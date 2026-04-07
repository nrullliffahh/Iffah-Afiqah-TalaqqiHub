@echo off
cd /d %~dp0
echo Compiling DAO classes...
javac -cp "WEB-INF\classes;WEB-INF\lib\*" -d "WEB-INF\classes" src\dao\EvaluationDAO.java src\dao\TeacherDAO.java
echo Exit code: %ERRORLEVEL%