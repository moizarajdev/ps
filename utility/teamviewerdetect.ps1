$package = Get-Package -Name '*TeamViewer*' -ErrorAction SilentlyContinue | Where-Object Name -notlike '*Host*'

if ($package) {
    Write-Output "TeamViewer is installed."
    exit 0
}
else {
    Write-Output "TeamViewer is not installed."
    exit 1
}
