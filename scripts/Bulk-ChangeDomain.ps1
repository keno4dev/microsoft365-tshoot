# Bulk-ChangeDomain.ps1
#
# Description: Changes the UserPrincipalName (UPN) / domain for multiple users
#              by mapping old UPNs to new email addresses from a CSV file.
#
# CSV Format (C:\Users\admin\users.csv):
#   UserPrincipalName,EmailAddress
#   john.doe@contoso.onmicrosoft.com,john.doe@contoso.com
#   jane.smith@contoso.onmicrosoft.com,jane.smith@contoso.com
#
# Usage:
#   .\Bulk-ChangeDomain.ps1
#
# Prerequisites:
#   - MSOnline module: Install-Module MSOnline
#   - Run in PowerShell ISE (required for this script)
#   - Global Admin or User Management Admin role
#
# IMPORTANT: Run this script in PowerShell ISE, not standard PowerShell

$CsvPath = "C:\Users\admin\users.csv"

Install-Module MSOnline -ErrorAction SilentlyContinue
Import-Module MSOnline
Connect-MsolService

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at: $CsvPath"
    exit
}

$Usersdatabase = Import-Csv $CsvPath

foreach ($record in $Usersdatabase) {
    $upn   = $record.UserPrincipalName
    $email = $record.EmailAddress

    Write-Host "Updating: $upn → $email" -ForegroundColor Cyan
    Set-MsolUserPrincipalName -UserPrincipalName $upn -NewUserPrincipalName $email
    Write-Host "Done." -ForegroundColor Green
}

Write-Host "`nAll UPN changes completed." -ForegroundColor Yellow
