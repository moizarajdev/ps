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
$rimas = "C:\RIMAS_NTP"
$programFiles = "C:\Program Files (x86)"

New-Item -ItemType Directory -Path $rimas -Force | Out-Null
Copy-Item -Path "$source\PSBinaries\*" -Destination $rimas -Recurse -Force
Copy-Item -Path "$source\jpegger" -Destination $programFiles -Recurse -Force

reg.exe load HKU\DefaultUser 'C:\Users\Default\NTUSER.DAT'
reg.exe import "$source\jpegger.reg"
reg.exe unload HKU\DefaultUser

Copy-Item -Path "$source\vcredist64.exe" -Destination $env:TEMP -Force
Copy-Item -Path "$source\vcredist86.exe" -Destination $env:TEMP -Force
Copy-Item -Path "$source\TSScan_server.exe" -Destination $env:TEMP -Force

Start-Process -FilePath "$env:TEMP\vcredist64.exe" -ArgumentList "/install /quiet /norestart" -Wait
Start-Process -FilePath "$env:TEMP\vcredist86.exe" -ArgumentList "/install /quiet /norestart" -Wait
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All
Start-Process -FilePath "$env:TEMP\TSScan_server.exe" -ArgumentList "/VERYSILENT" -Wait

$fontPath    = "$source\MICRE13B.ttf"
$fontsFolder = "$env:WINDIR\Fonts"
$fileName    = Split-Path $FontPath -Leaf
$dest        = Join-Path $fontsFolder $fileName
Copy-Item -Path $fontPath -Destination $dest -Force

$shell          = New-Object -ComObject Shell.Application
$fontsFolderObj = $shell.Namespace($fontsFolder)
$fontsFolderObj.CopyHere($FontPath)

$regPath   = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$valueName = $fileName
Set-ItemProperty -Path $regPath -Name $valueName -Value $fileName -Type String
