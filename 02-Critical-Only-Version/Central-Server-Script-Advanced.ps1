# ==============================================================================
# [TR] CENTRAL SERVER SCRIPT (ADVANCED): Ortak klasördeki kritik CSV'leri birleştirir,
#      Graph API kullanarak yönetici ekibine özet e-posta raporu sunar.
# [EN] CENTRAL SERVER SCRIPT (ADVANCED): Merges critical CSVs from the shared folder,
#      and sends a summary email report to the admin team using Microsoft Graph API.
# ==============================================================================

# 1. BAĞLANTI VE GRAPH API AYARLARI | GRAPH API CONFIGURATION
# ==============================================================================
$TenantId     = "<YOUR_TENANT_ID>"
$ClientId     = "<YOUR_CLIENT_ID>"
$ClientSecret = "<YOUR_CLIENT_SECRET>"

# Klasör Yol Tanımlamaları | Directory Paths
$SharedFolder = "D:\PATH\GenericFolder"  # Cihazların CSV bıraktığı yer | Where devices drop CSVs
$ReportFolder = "C:\CentralEventReport"  # Analiz ve çıktı klasörü | Analysis and output folder
$OutputCsv    = "$ReportFolder\Merged_Critical_Events.csv"
$ZipFile      = "$ReportFolder\Generic_Event_Analysis.zip"

# E-Posta Bilgileri | Email Details
$SenderEmail    = "<REPORTS_SENDER_MAIL@YOUR_DOMAIN.com>"
$RecipientEmail = "<RECIPIENT_1@YOUR_DOMAIN.com>;<RECIPIENT_2@YOUR_DOMAIN.com>"

# 2. CSV DOSYALARINI BİRLEŞTİRME VE FİLTRELEME | MERGE & FILTER CSV FILES
# ==============================================================================
if (-not (Test-Path $ReportFolder)) { New-Item -ItemType Directory -Path $ReportFolder -Force }

$CsvFiles = Get-ChildItem -Path $SharedFolder -Filter "*.csv"
if ($CsvFiles.Count -eq 0) {
    Write-Output "BILGI: İşlenecek yeni log dosyası bulunamadı. | INFO: No new log files found to process."
    exit 0
}

$MasterReport = New-Object System.Collections.Generic.List[PSObject]
$DeviceCount = 0

foreach ($File in $CsvFiles) {
    try {
        $DeviceName = $File.BaseName.Replace("Events_", "")
        $Content = Import-Csv -Path $File.FullName -Delimiter ";"
        
        foreach ($Row in $Content) {
            # [TR] Sadece 'Critical' seviyedeki logları veya Security kanalından gelenleri rapora dahil et
            # [EN] Include only 'Critical' level logs or logs coming from the Security channel
            if ($Row.EntryType -eq "Critical" -or $Row.EntryType -eq "Security" -or $File.FullName -like "*Security*") {
                $LogEntry = [PSCustomObject]@{
                    "Device Name"         = $DeviceName
                    "Event ID"            = $Row.EventID
                    "Log Level / Type"    = $Row.EntryType
                    "Time Generated"      = $Row.TimeGenerated
                    "Critical Description"= $Row.Message
                }
                $MasterReport.Add($LogEntry)
            }
        }
        $DeviceCount++
        # İşlenen dosyayı arşivle veya sil | Delete or archive processed file
        Remove-Item $File.FullName -Force
    } catch {
        Write-Output "HATA ($($File.Name)): $($_.Exception.Message)"
    }
}

if ($MasterReport.Count -eq 0) {
    Write-Output "BILGI: Kritik aşamada bir loga rastlanmadı. | INFO: No critical logs found after filtering."
    exit 0
}

# Raporu Excel/CSV olarak kaydet ve ZIP'le | Save master report and ZIP it
$MasterReport | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8 -Delimiter ";"
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
Compress-Archive -Path $OutputCsv -DestinationPath $ZipFile

# 3. MICROSOFT GRAPH API İLE MAİL GÖNDERİMİ | SEND EMAIL VIA MICROSOFT GRAPH API
# ==============================================================================
# Token Alımı | OAuth2 Token Acquisition
$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientId
    Client_Secret = $ClientSecret
}
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method Post -Body $Body
$AccessToken   = $TokenResponse.access_token

# Dosyayı Base64 formatına çevirme (Mail eki için) | Convert ZIP to Base64 for attachment
$FileBytes = [System.IO.File]::ReadAllBytes($ZipFile)
$Base64File = [System.Convert]::ToBase64String($FileBytes)

# Graph API Mail JSON Gövdesi | Graph API Mail JSON Body
$MailJson = @"
{
    "message": {
        "subject": "Client Device Critical Event Report - $(Get-Date -Format 'dd.MM.yyyy')",
        "body": {
            "contentType": "HTML",
            "content": "<html><body>
                        <h2>Kurumsal Kritik Olay Analiz Raporu / Enterprise Critical Event Analysis Report</h2>
                        <p>Ağdaki cihazlardan toplanan ve <b>Kritik (Critical)</b> seviyede olan olay günlükleri ekteki dosyada sunulmuştur.</p>
                        <p><b>Raporlanan Toplam Cihaz Sayısı (Total Reported Devices):</b> $DeviceCount</p>
                        <p><i>Bu e-posta sistem tarafından otomatik üretilmiştir.</i></p>
                        </body></html>"
        },
        "toRecipients": [
            $(  # Birden fazla alıcıyı dinamik JSON formatına çevirir / Formats multiple recipients into JSON
                $Recipients = $RecipientEmail -split ";"
                ($Recipients | ForEach-Object { "{\"emailAddress\": {\"address\": \"$_\"}}" }) -join ","
            )
        ],
        "attachments": [
            {
                "@odata.type": "#microsoft.graph.fileAttachment",
                "name": "Generic_Event_Analysis.zip",
                "contentType": "application/zip",
                "contentBytes": "$Base64File"
            }
        ]
    }
}
"@

# Mail Gönderim İsteği | Send Mail Request
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$SenderEmail/sendMail" `
                  -Method Post `
                  -Headers @{ Authorization = "Bearer $AccessToken"; "Content-Type" = "application/json" } `
                  -Body (New-Object System.Net.Http.StringContent($MailJson, [System.Text.Encoding]::UTF8, "application/json"))

Write-Output "BASARILI: Kritik log raporu yonetici ekibine gonderildi. | SUCCESS: Critical log report sent to admins."

# Temizlik | Cleanup
Remove-Item $OutputCsv -Force
Remove-Item $ZipFile -Force
