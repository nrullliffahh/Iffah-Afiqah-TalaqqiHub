$mysqlPath = "c:\xampp\mysql\bin\mysql.exe"
$sqlFile = "c:\xampp\tomcat\webapps\TalaqqiHub\evaluation_setup.sql"
$dbName = "talaqqihub_db"
$username = "root"
$password = "admin"

# Read the SQL file content
$sqlContent = Get-Content -Path $sqlFile -Raw

# Execute MySQL command
$process = Start-Process -FilePath $mysqlPath -ArgumentList "-u $username -p`"$password`" $dbName" -NoNewWindow -RedirectStandardInput $sqlFile -Wait

Write-Host "Database setup completed!"
