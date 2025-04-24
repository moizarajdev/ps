# 2. Write the copy logic into its own script (still all in one file)
$taskScriptPath = "$env:ProgramData\CopyRimasNTPData.ps1"
$taskScriptContent = @'
if (-not (Test-Path 'C:\RIMAS_NTP')) {
    New-Item -Path 'C:\RIMAS_NTP' -ItemType Directory | Out-Null
}
robocopy '\\usmrimas\Rimas_NTP\PSBinaries' 'C:\RIMAS_NTP' /MIR /R:2 /W:5
'@

# Ensure the folder exists and write the .ps1
$taskScriptDir = Split-Path $taskScriptPath
if (-not (Test-Path $taskScriptDir)) {
    New-Item -Path $taskScriptDir -ItemType Directory | Out-Null
}
Set-Content -Path $taskScriptPath -Value $taskScriptContent -Force -Encoding UTF8

# 3. Create & register the scheduled task
$taskName = 'CopyRimasNTPData'

# Use -LogonType ServiceAccount so NT AUTHORITY\SYSTEM is valid
$action = New-ScheduledTaskAction `
    -Execute 'PowerShell.exe' `
    -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$taskScriptPath`""

# On startup, with a 15-second delay
$trigger = New-ScheduledTaskTrigger -AtStartup -Delay '00:00:15'

$principal = New-ScheduledTaskPrincipal `
    -UserId 'NT AUTHORITY\SYSTEM' `
    -LogonType ServiceAccount `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName  $taskName `
    -Action    $action `
    -Trigger   $trigger `
    -Principal $principal `
    -Force

# 4. Reboot so the task fires at next boot
Restart-Computer -Force