# Bulk-Add-UsersToM365Group.ps1
#
# Description: Adds multiple users from a CSV file to a specified
#              Microsoft 365 Unified Group (M365 Group).
#
# CSV Format (C:\Temp\GroupMembers.csv):
#   Member
#   john.doe@contoso.com
#   jane.smith@contoso.com
#
# Usage:
#   .\Bulk-Add-UsersToM365Group.ps1
#
# Prerequisites:
#   - ExchangeOnlineManagement module
#   - Exchange Admin or Groups Admin role

$CsvPath    = "C:\Temp\GroupMembers.csv"
$GroupName  = "All Company"  # Change this to your target group name

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at: $CsvPath"
    exit
}

Import-CSV $CsvPath | ForEach-Object {
    Add-UnifiedGroupLinks `
        -Identity $GroupName `
        -LinkType Members `
        -Links $_.Member

    Write-Host -ForegroundColor Green "Added '$($_.Member)' to M365 Group: '$GroupName'"
}

Write-Host "`nAll users processed." -ForegroundColor Cyan
Disconnect-ExchangeOnline -Confirm:$false
