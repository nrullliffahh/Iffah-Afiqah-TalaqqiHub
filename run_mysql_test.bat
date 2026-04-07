@echo off
echo Running MySQL test against talaqqihub...
"C:\xampp\mysql\bin\mysql.exe" -u root -padmin -e "USE talaqqihub; SHOW TABLES; SELECT COUNT(*) FROM teacher;"
echo Exit code: %ERRORLEVEL%