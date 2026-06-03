
-- ==============================================================================
-- [TR] SCCM SQL VERİ TABANI SORGUSU: Power BI Dashboard'una uyumluluk durumlarını aktarmak için kullanılır.
-- [EN] SCCM SQL DATABASE QUERY: Used to feed compliance status logs into the Power BI Dashboard.
-- ==============================================================================

SELECT 
    sys.Netbios_Name0 AS [Device Name],
    loc.DisplayName AS [Configuration Item Name],
    det.CurrentValue AS [Current Value / Error Detail],
    CASE 
        WHEN det.ComplianceState = 1 THEN 'Compliant (No Errors)'
        WHEN det.ComplianceState = 2 THEN 'Non-Compliant (Critical Events Detected)'
        ELSE 'Unknown / Error State'
    END AS [Compliance Status],
    det.LastComplianceMessageTime AS [Last Evaluation Date]
FROM v_R_System sys
JOIN v_CIComplianceStatusDetail det ON sys.ResourceID = det.ResourceID
JOIN v_LocalizedCIProperties loc ON det.CI_ID = loc.CI_ID
WHERE loc.DisplayName = 'EventID' -- SCCM tarafında oluşturduğunuz CI adı ile eşleşmelidir / Must match your SCCM CI Name
ORDER BY det.LastComplianceMessageTime DESC;
