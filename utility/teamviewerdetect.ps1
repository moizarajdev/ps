$package = Get-Package -Name '*teamviewer*' -ErrorAction SilentlyContinue
if ($package -and ($package | Where-Object Name -like '*Host*')) {
    Write-Output "TeamViewer Host is installed."
    exit 0
}
else {
    Write-Output "TeamViewer Host is not installed."
    exit 1
}
