
$sendToDir = "${env:AppData}\Microsoft\Windows\SendTo"

Remove-Item "$sendToDir\Mattermost (kanał).lnk"
Remove-Item "$sendToDir\Mattermost (publiczny link).lnk"

Write-Host "Odinstalowano aplikację. Możesz usunąć pliki z tego folderu."
Write-Host "Wciśnij dowolny klawisz by zamknąć okno..."

Read-Host