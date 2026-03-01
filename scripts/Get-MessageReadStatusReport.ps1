# Get-MessageReadStatusReport.ps1
# 
# Description: Generates a per-recipient email read status report for a given
#              message and exports the results to CSV.
#
# Usage:
#   .\Get-MessageReadStatusReport.ps1 -Mailbox "sender@contoso.com" -MessageId "<message-id@domain>"
#
# Prerequisites:
#   - Exchange Online PowerShell module (ExchangeOnlineManagement)
#   - Connected session: Connect-ExchangeOnline
#   - Organization-level read tracking enabled:
#       Set-OrganizationConfig -ReadTrackingEnabled $true
#
# Reference: https://github.com/maxbakhub/winposh/blob/main/Exchange/Get-MessageReadStatusReport.ps1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Mailbox,

    [Parameter(Mandatory = $true)]
    [string]$MessageId
)

$output = @()

# Check org-wide read tracking state
if (!(Get-OrganizationConfig).ReadTrackingEnabled) {
    throw "Email read tracking is disabled for this organization. Enable it with: Set-OrganizationConfig -ReadTrackingEnabled `$true"
}

# Locate the message by ID
$msg = Search-MessageTrackingReport `
    -Identity $Mailbox `
    -BypassDelegateChecking `
    -MessageId $MessageId

# Validate exactly one message was found
if ($msg.count -ne 1) {
    throw "$($msg.count) message(s) found with this MessageId. Expected exactly 1."
}

# Get the full tracking report
$report = Get-MessageTrackingReport `
    -Identity $msg.MessageTrackingReportId `
    -BypassDelegateChecking

# Extract recipient events
$recipientTrackingEvents = @($report | Select-Object -ExpandProperty RecipientTrackingEvents)
$recipients = $recipientTrackingEvents | Select-Object RecipientAddress

# Build report per recipient
foreach ($recipient in $recipients) {
    $events = Get-MessageTrackingReport `
        -Identity $msg.MessageTrackingReportId `
        -BypassDelegateChecking `
        -RecipientPathFilter $recipient.RecipientAddress `
        -ReportTemplate RecipientPath

    $outputLine = $events.RecipientTrackingEvents[-1] |
        Select-Object RecipientAddress, Status, EventDescription

    $output += $outputLine
}

# Display results
$output | Format-Table -AutoSize

# Export to CSV
$directory = "C:\PS\ExchangeReports"
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}

$file = "$directory\ReadStatusReport.csv"
$output | Export-Csv -NoTypeInformation -Append -Path $file

Write-Host "Report saved to: $file" -ForegroundColor Green
