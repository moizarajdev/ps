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

$source = "\\usmfs01\Office2\moiz\PSBinaries"
$destination = "C:\RIMAS_NTP"

if (-Not (Test-Path -Path $source)) {
    exit 1
}

if (-Not (Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
}

Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force

Copy-Item -Path "\\usmfs01\Office2\moiz\TSScan_server.exe" -Destination $env:TEMP -Force
.$env:TEMP\TSScan_server.exe /VERYSILENT