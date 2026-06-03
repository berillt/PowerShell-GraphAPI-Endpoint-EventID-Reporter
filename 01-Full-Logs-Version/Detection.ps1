# ==============================================================================
# [TR] DETECTION SCRIPT: Intune'un her döngüde Remediation scriptini tetiklemesi için exit 1 ile çıkış yapar.
# [EN] DETECTION SCRIPT: Forces Intune to trigger the Remediation script in every cycle by exiting with code 1.
# ==============================================================================

Write-Output "Periyodik Event Log kontrolü baslatiliyor... | Starting periodic Event Log control..."
exit 1
