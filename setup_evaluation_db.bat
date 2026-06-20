@echo off
REM Setup evaluation table in database
cd /d c:\xampp\tomcat\webapps\TalaqqiHub
c:\xampp\mysql\bin\mysql.exe -u root -p"admin" talaqqihub_db < evaluation_setup.sql
echo Database setup completed!
pause
