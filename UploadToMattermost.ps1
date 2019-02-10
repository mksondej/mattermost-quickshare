param(
    [switch]$public,
    [switch]$channelPicker,
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$paths
)

. "$PSScriptRoot\CredMan.ps1"
. "$PSScriptRoot\Utils.ps1"
. "$PSScriptRoot\Config.ps1"

$credentialKey = "MM-Quickshare";

Write-Host "Ogarniam dane logowania"
$cred = Read-Creds -Target $credentialKey

if($null -eq $cred) {
    Show-Error "Brak zapisanych danych logowania do MM. Obczaj instrukcję."
    exit 1
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $cred.CredentialBlob)

# Enable support for TLS
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'

function Upload-Channel($channelId) {
    #Upload all files
    Write-Host "Wysyłam pliki"
    $fileIds = @()
    foreach($path in $paths) {
        Write-Host "Wysyłam " + $path
        $fileContent = [IO.File]::ReadAllBytes($path);
        $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileContent);
        $fileName = Split-Path $path -Leaf
        $boundary = [System.Guid]::NewGuid().ToString(); 
        $LF = "`r`n";
        
        $bodyLines = ( 
            "--$boundary",
            "Content-Disposition: form-data; name=`"files`"; filename=`"$fileName`"",
            "Content-Type: application/octet-stream$LF",
            $fileEnc,
            "--$boundary",
            "Content-Disposition: form-data; name=`"channel_id`"$LF",
            $channelId,
            "--$boundary--$LF" 
        ) -join $LF
            
        $uploadResult = Invoke-RestMethod -Uri "$apiUrl/files" -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Headers $headers
        
        #solve the most annoying powershell thing (force array even on single element)
        $uploadResult.file_infos | ForEach-Object { $fileIds += $_.id }
    }
    
    #Post a message with the file attached
    Write-Host "Robię posta"
    $postData = @{
        "channel_id" = $channelId;
        "message" = "#Quickshare";
        "file_ids" = $fileIds;
    }
    $postDataJson = $postData | ConvertTo-Json
    Invoke-RestMethod -Uri "$apiUrl/posts" -Method Post -Headers $headers -Body $postDataJson
    
    #Handle public links
    if($public -eq $true) {
        if($paths.Count -gt 1) {
            Show-Error "Link publiczny da się pobrać jak wysyłasz tylko 1 plik."
            exit 1
        } else {
            $linkResult = Invoke-RestMethod -Uri "$apiUrl/files/$($fileIds[0])/link" -Method Get -Headers $headers
            Set-Clipboard -Value $linkResult.link
        }
    }
    
    #Notify success
    $notificationText = 'Wysłano plików: ' + $fileIds.Count
    if($public -eq $true) {
        $notificationText += "`nLink masz w schowku."
    }

    Show-Notification "Mattermost Quickshare" $notificationText

    return $fileIds
}

#Get users private channel id
Write-Host "Pobieram dane użytkownika"
$userData = Invoke-RestMethod -Uri "$apiUrl/users/me" -Method Get -Headers $headers

if($channelPicker -eq $true) {
    $teamData = Invoke-RestMethod -Uri "$apiUrl/teams/name/$team" -Method Get -Headers $headers
    $channels = Invoke-RestMethod -Uri "$apiUrl/users/$($userData.id)/teams/$($teamData.id)/channels" -Method Get -Headers $headers
    $channelsForPicker = $channels | Where-Object { ($_.type -ne "D") -and ($_.type -ne "G") } | Sort-Object -Property type | Sort-Object -Property display_name
    Show-Picker "Wybierz kanał" $channelsForPicker "id" "display_name" { 
        param($channel) Upload-Channel $channel.id 
    }
} else {
    $directChannel = Invoke-RestMethod -Uri "$apiUrl/channels/direct" -Method Post -Headers $headers -Body "[`"$($userData.id)`", `"$($userData.id)`"]"
    $directChannelId = $directChannel.id
    Upload-Channel $directChannelId
}