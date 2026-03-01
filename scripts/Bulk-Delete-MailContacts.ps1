# Bulk-Delete-MailContacts.ps1
#
# Description: Deletes multiple Exchange Online mail contacts using a CSV file.
#
# CSV Format (C:\CSV\deletecontact.csv):
#   ExternalEmailAddress
#   contact1@external.com
#   contact2@external.com
#
# Usage:
#   .\Bulk-Delete-MailContacts.ps1
#
# Prerequisites:
#   - ExchangeOnlineManagement module installed
#   - Exchange Admin or Recipient Management role
#
# Reference:
#   https://social.technet.microsoft.com/wiki/contents/articles/54248.o365-how-to-delete-contacts-using-powershell-and-csv-file.aspx

$CsvPath = "C:\CSV\deletecontact.csv"

Import-Module ExchangeOnlineManagement

$UserCredential = Get-Credential
Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at: $CsvPath"
    exit
}

$users = Import-Csv $CsvPath

foreach ($user in $users) {
    $ExternalEmailAddress = $user.ExternalEmailAddress
    Write-Host "Removing contact: $ExternalEmailAddress" -ForegroundColor Yellow
    Remove-MailContact $ExternalEmailAddress -Confirm:$false
}

Write-Host "`nDONE RUNNING SCRIPT — CHECK FOR ERRORS ABOVE" -ForegroundColor Green
Read-Host -Prompt "Press Enter to exit"

Disconnect-ExchangeOnline -Confirm:$false
