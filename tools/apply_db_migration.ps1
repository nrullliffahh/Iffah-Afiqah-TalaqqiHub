<#
PowerShell helper to apply a SQL migration using the local MySQL client.
Usage examples:
  .\apply_db_migration.ps1                     # uses defaults from script
  .\apply_db_migration.ps1 -Database talaqqihub -User root -Password "" -File ..\db\0004_add_popular_column.sql

Defaults are set to match `util.DBConnection` in the project:
  Host: 127.0.0.1
  Port: 3306
  Database: talaqqihub
  User: root
  Password: admin

The script requires `mysql` to be available in PATH (MySQL client). If you use XAMPP, mysql.exe is usually in `C:\xampp\mysql\bin`.
#>
param(
    [string]$Host = "127.0.0.1",
    [int]$Port = 3306,
    [string]$Database = "talaqqihub",
    [string]$User = "root",
    [string]$Password = "admin",
    [string]$File = "..\db\0004_add_popular_column.sql"
)

$filePath = Resolve-Path $File -ErrorAction Stop
Write-Host "Applying migration: $filePath to $User@$Host:$Port/$Database"

# Build mysql command. Use --password= because -p with a space prompts interactively.
$mysqlCmd = "mysql -h $Host -P $Port -u $User --password=$Password $Database < `"$filePath`""
Write-Host "Running: $mysqlCmd"

$proc = Start-Process -FilePath cmd.exe -ArgumentList "/c", $mysqlCmd -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -eq 0) {
    Write-Host "Migration applied successfully." -ForegroundColor Green
} else {
    Write-Host "Migration failed. Exit code: $($proc.ExitCode)" -ForegroundColor Red
    Write-Host "If mysql is not in PATH, provide full path to mysql.exe or use phpMyAdmin to run the SQL." -ForegroundColor Yellow
}
