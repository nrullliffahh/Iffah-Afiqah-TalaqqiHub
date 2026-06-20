@echo off
setlocal enabledelayedexpansion
cd /d c:\xampp\tomcat\webapps\TalaqqiHub
c:\xampp\mysql\bin\mysql.exe -u root talaqqihub_db < create_eval_table.sql
echo Table creation completed
