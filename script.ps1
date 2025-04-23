$vdotZipUrl = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$vdotZipFile = "$env:TEMP\VDOT.zip"
$vdotDir = "$env:TEMP\Virtual-Desktop-Optimization-Tool-main"

Invoke-WebRequest -Uri $vdotZipUrl -OutFile $vdotZipFile -ErrorAction Stop
Expand-Archive -LiteralPath $vdotZipFile -DestinationPath $env:TEMP -Force -ErrorAction Stop

& "$vdotDir\Windows_VDOT.ps1" -AcceptEULA -Optimizations All -AdvancedOptimizations All -Verbose

$taskName = 'CopyRimasNTPData'
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "if(-not(Test-Path ''C:\RIMAS_NTP'')){New-Item -Path ''C:\RIMAS_NTP'' -ItemType Directory|Out-Null};robocopy ''\\usmrimas\Rimas_NTP\PSBinaries\Data'' ''C:\RIMAS_NTP'' /MIR /R:2 /W:5"'
$trigger = New-ScheduledTaskTrigger -AtStartup -Delay '00:00:10'
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -RunLevel Highest -User 'SYSTEM' -Force

Restart-Computer -Force
