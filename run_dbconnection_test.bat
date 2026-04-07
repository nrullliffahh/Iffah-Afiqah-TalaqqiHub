@echo off
echo Running DBConnection test with DB_USER=root and empty password...
set "DB_USER=root"
set "DB_PASSWORD="
cd /d %~dp0
java -cp "WEB-INF\classes;WEB-INF\lib\*" util.DBConnection
echo Exit code: %ERRORLEVEL%