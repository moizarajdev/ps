$vdotZipUrl = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$vdotZipFile = "$env:TEMP\VDOT.zip"
$vdotDir = "$env:TEMP\Virtual-Desktop-Optimization-Tool-main"

Invoke-WebRequest -Uri $vdotZipUrl -OutFile $vdotZipFile -ErrorAction Stop
Expand-Archive -LiteralPath $vdotZipFile -DestinationPath $env:TEMP -Force -ErrorAction Stop

& "$vdotDir\Windows_VDOT.ps1" -AcceptEULA -Optimizations All -AdvancedOptimizations RemoveOneDrive, Edge -Verbose

$taskName = 'CopyRimasNTPData'
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "if(-not(Test-Path ''C:\RIMAS_NTP'')){New-Item -Path ''C:\RIMAS_NTP'' -ItemType Directory|Out-Null};robocopy ''\\usmrimas\Rimas_NTP\PSBinaries\Data'' ''C:\RIMAS_NTP'' /MIR /R:2 /W:5"'
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay = New-TimeSpan -Seconds 30
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force

Restart-Computer -Force
