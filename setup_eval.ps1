$sqlFile = "c:\xampp\tomcat\webapps\TalaqqiHub\create_eval_table.sql"
$mysqlExe = "c:\xampp\mysql\bin\mysql.exe"
$db = "talaqqihub_db"

# Read SQL file and prepare command
$sqlContent = Get-Content -Path $sqlFile -Raw

# Execute each statement
$statements = $sqlContent -split "(?<=[;])" | Where-Object { $_.Trim() -ne "" }

foreach ($statement in $statements) {
    if ($statement.Trim() -ne "") {
        Write-Host "Executing: $($statement.Trim().Substring(0, [Math]::Min(50, $statement.Length)))"
        $result = & $mysqlExe -u root $db -e $statement
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error executing statement"
        }
    }
}

Write-Host "Table setup completed!"
