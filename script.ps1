$vdotZipUrl = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$vdotZipFile = "$env:TEMP\VDOT.zip"
$vdotDir = "$env:TEMP\Virtual-Desktop-Optimization-Tool-main"

Invoke-WebRequest -Uri $vdotZipUrl -OutFile $vdotZipFile -ErrorAction Stop
Expand-Archive   -LiteralPath $vdotZipFile -DestinationPath $env:TEMP -Force -ErrorAction Stop
& "$vdotDir\Windows_VDOT.ps1" `
    -AcceptEULA `
    -Optimizations All `
    -AdvancedOptimizations RemoveOneDrive, Edge `
    -Verbose