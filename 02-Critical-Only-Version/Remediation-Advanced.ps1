
# ==============================================================================
# [TR] REMEDIATION SCRIPT (GELİŞMİŞ SÜRÜM): Çoklu olay günlüğü kanallarını tarar ve merkezi paylaşıma aktarır.
# [EN] REMEDIATION SCRIPT (ADVANCED VERSION): Scans multi-channel event logs and copies to central share.
# ==============================================================================

# Ayarlar | Settings
$NetworkPath = "\\<YOUR_SERVER_IP_OR_NAME>\<SHARE_NAME>$"
$Computer    = $env:COMPUTERNAME
$LocalPath   = "C:\Windows\Temp\Events_$Computer.csv"

# Takip edilecek genişletilmiş kritik Event ID listesi
# Extended list of critical Event IDs to monitor
$EventIDs = @(7, 11, 153, 18, 19, 46, 47, 4101, 14, 4625, 4624, 4771, 4778, 1058, 1030, 1000, 1002, 1001, 51, 55, 1014, 4201, 1123, 1124, 5007, 20, 25, 31, 7031, 7034, 41)

Write-Output "Islem basladi | Process started: $Computer"

# Sunucu erisilebilirlik kontrolü | Server connectivity check
if (-not (Test-Connection -ComputerName "<YOUR_SERVER_IP_OR_NAME>" -Count 1 -Quiet)) {
    Write-Output "HATA: Sunucuya ulasilamiyor (Ping Fail). | ERROR: Server unreachable (Ping Fail)."
    exit 1
}

# =====================================================
# LOG TOPLAMA | LOG COLLECTION
# =====================================================
try {
    # Son 2 günlük verileri tara | Scan logs from the last 2 days
    $StartTime = (Get-Date).AddDays(-2)
    $FilteredEvents = New-Object System.Collections.Generic.List[PSObject]
    $Channels = @('System', 'Application', 'Security')

    foreach ($Log in $Channels) {
        $Events = Get-WinEvent -FilterHashtable @{
            LogName   = $Log
            Id        = $EventIDs
            StartTime = $StartTime
        } -ErrorAction SilentlyContinue | Where-Object { $_.LevelDisplayName -eq "Critical" -or $_.LogName -eq 'Security' } 
        
        # [TR] Security logunda 'Critical' aranmaz, ID filtrelemesi yeterlidir.
        # [EN] Level mapping is not applicable for Security channel, ID filtering is sufficient.
        
        if ($Events) { $FilteredEvents.AddRange($Events) }
    }

    if ($FilteredEvents.Count -gt 0) {
        $FilteredEvents | Select-Object @{N='TimeGenerated';E={$_.TimeCreated}}, 
                                        @{N='EventID';E={$_.Id}}, 
                                        @{N='EntryType';E={$_.LevelDisplayName}}, 
                                        Message | 
        Export-Csv -Path $LocalPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
        Write-Output "BILGI: $(($FilteredEvents).Count) adet kritik log yerel dosyaya yazildi. | INFO: $(($FilteredEvents).Count) critical logs written to local file."
    } else {
        Write-Output "BILGI: Son 2 gunde kritik log bulunmadi. | INFO: No critical logs found in the last 2 days."
        exit 0
    }
} catch {
    Write-Output "HATA (Log Toplama): $($_.Exception.Message) | ERROR (Log Collection): $($_.Exception.Message)"
    exit 1
}

# =====================================================
# KOPYALAMA | COPY TO SHARE
# =====================================================
if (Test-Path $LocalPath) {
    try {
        # Dosyayı merkezi paylaşıma kopyalar | Copies the file to central share
        Copy-Item -Path $LocalPath -Destination "$NetworkPath\" -Force -ErrorAction Stop
        Write-Output "BASARILI: $Computer dosyasi sunucuya kopyalandi. | SUCCESS: $Computer file copied to server."
        Remove-Item $LocalPath -Force 
    } catch {
        Write-Output "HATA (Kopyalama): $($_.Exception.Message) | ERROR (Copying): $($_.Exception.Message)"
    }
}
