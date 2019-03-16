# A standalone version of UploadToMattermost which you can run manually from the terminal
# does not generate public links, just uploads to the personal channel

# Fill these vars:
$apiUrl = "/api/v4";
$login = "";
$token = "";

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $cred.CredentialBlob)

# Enable support for TLS
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
    
#Get users private channel id
Write-Host "Fetching user data"
$userData = Invoke-RestMethod -Uri "$apiUrl/users/me" -Method Get -Headers $headers
$channelResult = Invoke-RestMethod -Uri "$apiUrl/channels/direct" -Method Post -Headers $headers -Body "[`"$($userData.id)`", `"$($userData.id)`"]"
$channelId = $channelResult.id

$fileIds = @()
foreach($path in $paths) {
    Write-Host "Sending " $path

    $channelIdEncoded = [System.Web.HttpUtility]::UrlEncode($channelId)
    $fileName = Split-Path $path -Leaf
    $fileNameEncoded = [System.Web.HttpUtility]::UrlEncode($fileName)

    [uri]$uri = "$apiUrl/files?channel_id=$channelIdEncoded&filename=$fileNameEncoded"

    $uploadResult = Invoke-RestMethod -Uri ([uri]$uri) -Method Post -Headers $headers -InFile $path -ContentType "application/octet-stream; charset=utf-8"

    #solve the most annoying powershell thing (force array even on single element)
    $uploadResult.file_infos | ForEach-Object { $fileIds += $_.id }
}

#Post a message with the file attached
Write-Host "Fetching user data"
$postData = @{
    "channel_id" = $channelId;
    "message" = "#Quickshare";
    "file_ids" = $fileIds;
}
$postDataJson = $postData | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/posts" -Method Post -Headers $headers -Body $postDataJson