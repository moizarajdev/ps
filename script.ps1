$URI = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$zip = "$env:TEMP\VDOT.zip"
$dir = "$env:TEMP\Virtual-Desktop-Optimization-Tool-main"

Invoke-WebRequest -Uri $URI -OutFile $zip -ErrorAction Stop
Expand-Archive   -LiteralPath $zip -DestinationPath $env:TEMP -Force -ErrorAction Stop
& "$dir\Windows_VDOT.ps1" `
    -AcceptEULA `
    -Optimizations All `
    -AdvancedOptimizations RemoveOneDrive, Edge `
    -Verbose

$source = "\\usmfs01\Office2\moiz\"
$dest = "C:\RIMAS_NTP"
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item -Path "$source\PSBinaries\*" -Destination $dest -Recurse -Force
Copy-Item -Path "$source\vcredist64.exe" -Destination $env:TEMP -Force
Copy-Item -Path "$source\vcredist86.exe" -Destination $env:TEMP -Force
Copy-Item -Path "$source\TSScan_server.exe" -Destination $env:TEMP -Force

Start-Process -FilePath "$env:TEMP\vcredist64.exe" -ArgumentList "/install /quiet /norestart" -Wait
Start-Process -FilePath "$env:TEMP\vcredist86.exe" -ArgumentList "/install /quiet /norestart" -Wait
Start-Process -FilePath "$env:TEMP\TSScan_server.exe" -ArgumentList "/VERYSILENT" -Wait