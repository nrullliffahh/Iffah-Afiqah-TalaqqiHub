$ini='C:\xampp\mysql\data\my.ini'
$bak='C:\backups\mysql-data-backup\my.ini.bak'
Copy-Item -Path $ini -Destination $bak -Force
$add = "`r`n[mysqld]`r`ninnodb_force_recovery=2`
"
Add-Content -Path $ini -Value $add
Write-Host "my.ini backed up to $bak and updated"
