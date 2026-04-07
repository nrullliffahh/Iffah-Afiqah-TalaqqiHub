# Tomcat diagnostics script
# Saves output to %USERPROFILE%\tomcat_diagnostics.txt

$out = Join-Path $env:USERPROFILE 'tomcat_diagnostics.txt'
"Tomcat diagnostics - $(Get-Date -Format 'u')" | Out-File -FilePath $out

function Write-Log {
    param([string]$s)
    $s | Tee-Object -FilePath $out -Append
}

Write-Log "\n== Environment =="
Write-Log "User: $env:USERNAME"
Write-Log "Computer: $env:COMPUTERNAME"

Write-Log "\n== Logs folder listing (C:\xampp\tomcat\logs) =="
if (Test-Path 'C:\xampp\tomcat\logs') {
    Get-ChildItem 'C:\xampp\tomcat\logs' -File | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime, Length | Format-Table | Out-String | Write-Log
} else {
    Write-Log "Logs folder not found: C:\xampp\tomcat\logs"
}

Write-Log "\n== Last lines from newest log file =="
try {
    $f = Get-ChildItem 'C:\xampp\tomcat\logs' -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($f) {
        Write-Log "Newest log: $($f.FullName)"
        Write-Log "---- Last 500 lines ----"
        Get-Content $f.FullName -Tail 500 | ForEach-Object { Write-Log $_ }
    } else {
        Write-Log "No log files found in C:\xampp\tomcat\logs"
    }
} catch {
    Write-Log "Error reading logs: $_"
}

Write-Log "\n== Java information =="
try { java -version 2>&1 | ForEach-Object { Write-Log $_ } } catch { Write-Log "java not found or error: $_" }
try { where.exe java 2>&1 | ForEach-Object { Write-Log $_ } } catch {}
Write-Log "JAVA_HOME=$Env:JAVA_HOME"
Write-Log "JRE_HOME=$Env:JRE_HOME"

Write-Log "\n== Netstat (common Tomcat ports: 8080, 8005, 8009) =="
$ports = @('8080','8005','8009')
foreach ($p in $ports) {
    Write-Log "\n-- Checking port $p --"
    $lines = (netstat -aon | findstr ":$p") 2>&1
    if ($lines -and $lines -ne "") {
        $lines | ForEach-Object { Write-Log $_ }
        $pids = ($lines -split '\r?\n' | ForEach-Object { ($_ -split '\s+')[-1] } | Where-Object { $_ -match '^\d+$' } | Sort-Object -Unique)
        foreach ($pid in $pids) {
            try {
                $proc = Get-Process -Id $pid -ErrorAction Stop
                Write-Log "PID $pid -> $($proc.ProcessName)"
                try { Write-Log "Path: $($proc.Path)" } catch { }
            } catch {
                Write-Log "PID $pid -> process not found or access denied"
            }
        }
    } else {
        Write-Log "Port $p not in use."
    }
}

Write-Log "\n== server.xml connectors (C:\xampp\tomcat\conf\server.xml) =="
if (Test-Path 'C:\xampp\tomcat\conf\server.xml') {
    Select-String -Path 'C:\xampp\tomcat\conf\server.xml' -Pattern '<Connector' | ForEach-Object { Write-Log $_.Line }
} else {
    Write-Log "server.xml not found: C:\xampp\tomcat\conf\server.xml"
}

Write-Log "\n== End of diagnostics =="
Write-Log "Diagnostics saved to: $out"

"\nTo share results, open: $out"

# Open the file in notepad for convenience (comment out if undesired)
Start-Process notepad.exe $out
