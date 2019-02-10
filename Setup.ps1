﻿. "$PSScriptRoot\CredMan.ps1"
. "$PSScriptRoot\Utils.ps1"

$MMUrl = Read-Host "1. Podaj pełny adres MM"
$Team = Read-Host "2. Podaj nazwę teamu"
$User = Read-Host "3. Podaj swój login MM/Gitlab"
Write-Host "4. Otwórz mattermosta, kliknij na menu przy swoim profilu i wybierz `"Account settings`" (pierwszy link)"
Write-Host "5. Wejdź w zakładkę Security"
Write-Host "6. Kliknij Personal Access Tokens"
Write-Host "7. Dodaj nowy token nadając mu dowolną nazwę"
Write-Host "8. Skopiuj do schowka wartość z `"Access Token`""
$Token = Read-Host "9. Teraz podaj ten token"

Write-Host
Write-Host "Mam wszystko. Działam..."

Write-Host "Tworzę plik konfiguracyjny..."
@(
    "# Generated by Setup.ps1",
    "`$apiUrl = `"$MMURL/api/v4`";",
    "`$team = `"$Team`";"
) | Out-File "Config.ps1" -Force

Write-Host "Wpisuję dane do menedżera poświadczeń..."
Write-Creds "MM-Quickshare" $User $Token

$psPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$sendToDir = "${env:AppData}\Microsoft\Windows\SendTo"
$mainScriptPath = "$PSScriptRoot\UploadToMattermost.ps1"

Write-Host "Tworzę skróty w `"Wyślij do`"..."
Write-Shortcut $sendToDir $psPath "$mainScriptPath -channelPicker" "Mattermost (kanał)"
Write-Shortcut $sendToDir $psPath "$mainScriptPath -public" "Mattermost (publiczny link)"

Write-Host "Instalacja zakończona. Wciśnij dowolny klawisz by zamknąć okno..."
Read-Host