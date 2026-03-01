# Email Tracking & Read Status

> **Category:** Message Tracking, Compliance  
> **Applies to:** Exchange Online, Exchange Server, Microsoft 365

---

## 1. Overview

Microsoft Exchange supports email **read tracking** — the ability to determine whether a recipient has opened or read a given email. This is useful for compliance, support escalations, or SLA verification.

> **Important:** Read tracking must be **enabled** at the organization level before any data is collected.

---

## 2. Check if Read Tracking is Enabled

```powershell
# Check org-wide read tracking status (True = Enabled)
Get-OrganizationConfig | Select ReadTrackingEnabled
```

### Enable Read Tracking Org-Wide

```powershell
Set-OrganizationConfig -ReadTrackingEnabled $true
```

> Only **after** running this command will read tracking data appear in Exchange logs.

---

## 3. Disable Read Tracking for Specific Mailboxes

Useful for service accounts, shared mailboxes, or privacy-sensitive mailboxes:

```powershell
Set-Mailbox support@contoso.com -MessageTrackingReadStatusEnabled $false
Set-Mailbox helpdesk@contoso.com -MessageTrackingReadStatusEnabled $false
```

---

## 4. Check Per-Mailbox Read Tracking Setting

```powershell
Get-EXOMailbox -Properties messageTrackingReadStatusEnabled |
    Select UserPrincipalName, messageTrackingReadStatusEnabled
```

---

## 5. Trace a Message via Message Trace

```powershell
# Get message trace details by recipient
Get-MessageTrace -RecipientAddress user@contoso.com | Format-List

# Get detailed trace using the MessageTraceId
Get-MessageTraceDetail `
    -RecipientAddress user@contoso.com `
    -MessageTraceId "293cd6db-b280-4440-c49a-08da8b6beecf" | Format-List
```

---

## 6. Get Message Tracking Log (On-Prem / Hybrid)

```powershell
Get-MessageTrackingLog `
    -Sender sender@contoso.com `
    -MessageSubject "This is a test" `
    -Start (Get-Date).AddHours(-48) `
    -EventId RECEIVE |
    Select MessageID
```

> Exchange transport logs location (on-premises):
> `%ExchangeInstallPath%TransportRoles\Logs\MessageTracking`

---

## 7. Full Read Status Report Script

The script below generates a per-recipient read status report for a given email and exports it to CSV.

```powershell
# Get-MessageReadStatusReport.ps1
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
    throw "Email tracking status is disabled. Run: Set-OrganizationConfig -ReadTrackingEnabled `$true"
}

# Locate the message
$msg = Search-MessageTrackingReport -Identity $Mailbox -BypassDelegateChecking -MessageId $MessageId

if ($msg.count -ne 1) {
    throw "$($msg.count) emails found with this MessageId — expected exactly 1."
}

# Get full tracking report
$report = Get-MessageTrackingReport -Identity $msg.MessageTrackingReportId -BypassDelegateChecking

# Extract recipient tracking events
$recipientTrackingEvents = @($report | Select-Object -ExpandProperty RecipientTrackingEvents)
$recipients = $recipientTrackingEvents | Select-Object RecipientAddress

# Build status report per recipient
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

$output

# Export to CSV
$directory = "C:\PS\ExchangeReports"
if (-not (Test-Path $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }

$output | Export-Csv -NoTypeInformation -Append -Path "$directory\ReadStatusReport.csv"
Write-Host "Report saved to $directory\ReadStatusReport.csv"
```

**Usage:**

```powershell
.\Get-MessageReadStatusReport.ps1 -Mailbox "sender@contoso.com" -MessageId "<message-id@domain>"
```

> **Original script reference:** https://github.com/maxbakhub/winposh/blob/main/Exchange/Get-MessageReadStatusReport.ps1

---

## 8. Add a Shared Calendar (Windows & Mac)

### On Windows (Outlook)

1. Open **Outlook** → Select the **Calendar** icon
2. Click **Add Calendar** / **Open Calendar**
3. Choose the type: **User**, **Room**, or **Internet**
4. Select the user or room from the list

### On Mac (Outlook)

1. Open **Outlook** → Select the **Calendar** icon
2. Click **File** → **Open & Export** → **Other User's Folder**
3. Search for and select the desired user

---

## References

- [Tracking Read Status of Email in Exchange — woshub.com](https://woshub.com/tracking-read-status-email-exchange/)
- [Get-MessageTrackingReport — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/get-messagetrackingreport?view=exchange-ps)
- [Get-MessageTrace — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/get-messagetrace?view=exchange-ps)
