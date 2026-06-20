# Attempts to apply db/000X_add_certpath_and_notifications.sql to local talaqqihub_db
# Tries credentials from environment or common local defaults used by the project.

$script = Join-Path $PSScriptRoot "000X_add_certpath_and_notifications.sql"
if (-not (Test-Path $script)) {
    Write-Error "Migration file not found: $script"
    exit 1
}

# Helper to run mysql with given user/password
function Run-MySql($user, $password) {
    $exe = "mysql"
    $args = "-u $user -p$($password) talaqqihub_db < `"$script`""
    Write-Output "Trying mysql with user=$user (password length=$(if ($password) { $password.Length } else {0}))"
    $cmd = "$exe $args"
    Write-Output "Running: $cmd"
    try {
        cmd.exe /c $cmd
        return $LASTEXITCODE
    } catch {
        Write-Error "Failed to run mysql: $_"
        return 1
    }
}

# Try credentials from env
$dbUser = $env:DB_USER
$dbPass = $env:DB_PASSWORD
if ($dbUser -and $dbPass) {
    $rc = Run-MySql $dbUser $dbPass
    if ($rc -eq 0) { Write-Output "Migration applied using env credentials"; exit 0 }
}

# Try project default: root/admin
$rc = Run-MySql "root" "admin"
if ($rc -eq 0) { Write-Output "Migration applied using root/admin"; exit 0 }

# Try root with empty password
$rc = Run-MySql "root" ""
if ($rc -eq 0) { Write-Output "Migration applied using root (empty password)"; exit 0 }

Write-Error "All automatic attempts failed. Please run the following command manually with correct credentials:`n
mysql -u <user> -p < database_name < $script" 
exit 1
