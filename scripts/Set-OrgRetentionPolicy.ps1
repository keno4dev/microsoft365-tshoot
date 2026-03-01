# Set-OrgRetentionPolicy.ps1
#
# Description: Creates a 7-year org-wide retention policy for Exchange Online
#              and applies it to all mailboxes. Forces immediate processing
#              via the Managed Folder Assistant.
#
# Usage:
#   .\Set-OrgRetentionPolicy.ps1
#
# Prerequisites:
#   - ExchangeOnlineManagement module
#   - Organization Management or Compliance Management role

$TagName    = "Corp-7years-DeleteAndRecover"
$PolicyName = "RetentionPolicy-Corp-7Years"
$AgeDays    = 2556  # 7 years in days

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true

Write-Host "Creating retention tag: $TagName" -ForegroundColor Cyan
New-RetentionPolicyTag `
    -Name $TagName `
    -Type All `
    -AgeLimitForRetention $AgeDays `
    -RetentionAction DeleteAndAllowRecovery

Write-Host "Creating retention policy: $PolicyName" -ForegroundColor Cyan
New-RetentionPolicy $PolicyName `
    -RetentionPolicyTagLinks $TagName

Write-Host "Applying retention policy to all mailboxes..." -ForegroundColor Yellow
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RetentionPolicy $PolicyName

Write-Host "Triggering Managed Folder Assistant on all mailboxes..." -ForegroundColor Yellow
Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    Start-ManagedFolderAssistant -Identity $_.UserPrincipalName -FullCrawl
    Write-Host "  Processed: $($_.UserPrincipalName)"
}

Write-Host "`nRetention policy applied successfully to all mailboxes." -ForegroundColor Green
Disconnect-ExchangeOnline -Confirm:$false
