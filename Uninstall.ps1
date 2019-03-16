
$sendToDir = "${env:AppData}\Microsoft\Windows\SendTo"

Remove-Item "$sendToDir\Mattermost (channel).lnk"
Remove-Item "$sendToDir\Mattermost (public link).lnk"

Write-Host "Uninstall complete. You can remove all files from this folder now."
Write-Host "Press any key to exit..."

Read-Host