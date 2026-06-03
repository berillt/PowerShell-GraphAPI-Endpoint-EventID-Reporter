
# ==============================================================================
# [TR] SCCM DISCOVERY SCRIPT: Cihazlarda belirtilen kritik olayların varlığını denetler ve SCCM uyumluluk durumunu döndürür.
# [EN] SCCM DISCOVERY SCRIPT: Checks for specified critical events on devices and returns SCCM compliance state.
# ==============================================================================

$StartTime = (Get-Date).AddDays(-2)
$EventIDs = @(7, 11, 153, 18, 19, 46, 47, 4101, 14, 4625, 4624, 4771, 4778, 1058, 1030, 1000, 1002, 1001, 51, 55, 1014, 4201, 1123, 1124, 5007, 20, 25, 31, 7031, 7034, 41)
$Channels = @('System', 'Application', 'Security')

$CriticalEventsCount = 0

foreach ($Log in $Channels) {
    $Events = Get-WinEvent -FilterHashtable @{
        LogName   = $Log
        Id        = $EventIDs
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue | Where-Object { $_.LevelDisplayName -eq "Critical" -or $_.LogName -eq 'Security' }
    
    if ($Events) { $CriticalEventsCount += $Events.Count }
}

# [TR] SCCM Uyum kuralı çıktısı (Çıktı "Temiz" ise cihaz uyumlu sayılır)
# [EN] SCCM Compliance rule output (If output is "Temiz", device is marked as compliant)
if ($CriticalEventsCount -gt 0) {
    Write-Output "Hata Bulundu ($CriticalEventsCount Kritik Log) | Issues Found"
} else {
    Write-Output "Temiz"
}
