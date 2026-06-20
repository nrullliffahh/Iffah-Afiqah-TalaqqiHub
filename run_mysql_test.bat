@echo off
echo Running MySQL test against talaqqihub_db...
"C:\xampp\mysql\bin\mysql.exe" -u root -padmin -e "USE talaqqihub_db; SHOW TABLES; SELECT COUNT(*) FROM teacher;"
echo Exit code: %ERRORLEVEL%