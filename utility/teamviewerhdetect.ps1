$key = 'HKLM:\SOFTWARE\WOW6432Node\TeamViewer'
try {
    $value = Get-ItemProperty -Path $key -Name 'Version' -ErrorAction Stop | Select-Object -ExpandProperty Version
} catch {
    exit 1
}
if ($value -like '*HC*') {
    Write-Output "TeamViewer Host Client detected: $value"
    exit 0
} else {
    Write-Output "TeamViewer Host Client not detected"
    exit 1
}
