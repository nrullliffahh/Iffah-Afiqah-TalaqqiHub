@echo off
echo Running DBConnection test with DB_USER=root and DB_PASSWORD=admin...
set "DB_USER=root"
set "DB_PASSWORD=admin"
cd /d %~dp0
java -cp "WEB-INF\classes;WEB-INF\lib\*" util.DBConnection
echo Exit code: %ERRORLEVEL%