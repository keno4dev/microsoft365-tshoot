# Sending Email via PowerShell

> **Category:** PowerShell, Exchange Online, SMTP, Email Automation, Send-MailMessage, Send-MailKitMessage  
> **Applies to:** Microsoft 365, Exchange Online, Windows PowerShell 5.1+, PowerShell 7+

---

## Table of Contents

1. [Overview](#1-overview)
2. [Method 1 — Send-MailMessage via SMTP (Obsolete)](#2-method-1--send-mailmessage-via-smtp-obsolete)
3. [App Password Requirements (for Method 1)](#3-app-password-requirements-for-method-1)
4. [Method 2 — Send-MailKitMessage (Modern)](#4-method-2--send-mailkitmessage-modern)
5. [Method 3 — Full Send-MailKitMessage Template](#5-method-3--full-send-mailkitmessage-template)
6. [Method 4 — Microsoft Graph API (Recommended for Non-Interactive)](#6-method-4--microsoft-graph-api-recommended-for-non-interactive)
7. [Choosing the Right Method](#7-choosing-the-right-method)

---

## 1. Overview

There are several methods to send email from PowerShell in a Microsoft 365 environment:

| Method | Module / Cmdlet | Status | Auth Method |
|--------|----------------|--------|-------------|
| SMTP Client Submission | `Send-MailMessage` | ⚠ Obsolete | Username + Password (or App Password) |
| Send-MailKitMessage (SMTP) | `Send-MailKitMessage` | ✅ Supported | Username + Password (or App Password) |
| Microsoft Graph | `Send-MgUserMail` | ✅ Recommended | OAuth 2.0 / App Registration |

> **`Send-MailMessage` is officially deprecated** ([Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/send-mailmessage)) because it does not support modern authentication. It remains functional for scenarios where only basic SMTP client submission is available.

---

## 2. Method 1 — Send-MailMessage via SMTP (Obsolete)

Despite its deprecated status, `Send-MailMessage` is still commonly used for quick scripts in environments where OAuth is not yet set up.

### Prerequisites

- An Exchange Online (or Office 365) user account
- MFA registered; optionally an **App Password** if Basic Auth is blocked
- TLS 1.2 enforced on the sending machine

### Script

```powershell
# Enforce TLS 1.2 for .NET SMTP client
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Prompt for credentials (or supply securely from a secret store)
$credential = Get-Credential

# Define mail parameters
$mailParams = @{
    SmtpServer                 = "smtp.office365.com"
    Port                       = 587
    UseSSL                     = $true
    Credential                 = $credential
    From                       = "sender@contoso.com"
    To                         = "recipient@contoso.com"
    Subject                    = "Automated Report — $(Get-Date -Format 'yyyy-MM-dd')"
    Body                       = "Please find the attached report."
    Attachments                = "C:\Reports\Report.csv"
    DeliveryNotificationOption = "OnFailure"
    BodyAsHtml                 = $false
}

Send-MailMessage @mailParams
Write-Host "Email sent successfully."
```

**Reference:** [Send-MailMessage — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/send-mailmessage)

---

## 3. App Password Requirements (for Method 1)

Basic Auth (username + password) over SMTP requires that **per-app passwords** are used when MFA is enabled.

### Requirements

- **MFA must be enforced** for the sending account
- **Security Defaults must be disabled** in Azure AD (Security Defaults block app passwords)
- **App Password** generated from: My Account → Security Info → Add Sign-in Method → App Password

### Steps to Generate

1. Sign in at [https://mysignins.microsoft.com/security-info](https://mysignins.microsoft.com/security-info)
2. Click **+ Add method → App password**
3. Name it (`PowerShell_Script`), copy the generated password
4. Use this password (not the regular account password) in `Get-Credential`

> **After generating an app password:** Sign out and back in to Outlook (or restart Outlook) to ensure the new app password is registered properly.

---

## 4. Method 2 — Send-MailKitMessage (Modern)

`Send-MailKitMessage` is a modern SMTP wrapper built on the **MimeKit** and **MailKit** libraries, which fully support TLS and modern authentication flows.

### Install

```powershell
# Ensure PowerShellGet is up to date first
Install-Module PowershellGet -Force
Install-Module -Name Send-MailKitMessage -Force
Import-Module Send-MailKitMessage
```

### Quick One-Liner

```powershell
$credential = Get-Credential

Send-MailKitMessage `
    -From       "sender@contoso.com" `
    -RecipientList "recipient@contoso.com" `
    -Subject    "Test Email from PowerShell" `
    -TextBody   "This is a test message sent via Send-MailKitMessage." `
    -SmtpServer "smtp.office365.com" `
    -Port        587 `
    -Credential  $credential
```

**Reference:** [Send-MailKitMessage on PowerShell Gallery](https://www.powershellgallery.com/packages/Send-MailKitMessage)

---

## 5. Method 3 — Full Send-MailKitMessage Template

Use this template when you need **CC, BCC, HTML body, or attachments**:

```powershell
Import-Module Send-MailKitMessage
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$credential = Get-Credential

# --- Build Recipient List ---
$RecipientList = [MimeKit.InternetAddressList]::new()
$RecipientList.Add([MimeKit.InternetAddress]"recipient1@contoso.com")
$RecipientList.Add([MimeKit.InternetAddress]"recipient2@contoso.com")

# --- Build CC List ---
$CCList = [MimeKit.InternetAddressList]::new()
$CCList.Add([MimeKit.InternetAddress]"cc.user@contoso.com")

# --- Build BCC List ---
$BCCList = [MimeKit.InternetAddressList]::new()
$BCCList.Add([MimeKit.InternetAddress]"bcc.user@contoso.com")

# --- Build Attachment List ---
$AttachmentList = [System.Collections.Generic.List[string]]::new()
$AttachmentList.Add("C:\Reports\Report.csv")
$AttachmentList.Add("C:\Reports\Summary.pdf")

# --- Compose Message Parameters ---
$Parameters = @{
    # Connection
    UseSecureConnectionIfAvailable = $true
    SmtpServer                     = "smtp.office365.com"
    Port                           = 587
    Credential                     = $credential

    # Addressing
    From                           = [MimeKit.MailboxAddress]::new("Sender Name", "sender@contoso.com")
    RecipientList                  = $RecipientList
    CCList                         = $CCList
    BCCList                        = $BCCList

    # Content
    Subject                        = "Weekly Report — $(Get-Date -Format 'MMMM dd, yyyy')"
    TextBody                       = "Please see the attached report. If you cannot view HTML, this plain text version is provided."
    HTMLBody                       = @"
<html>
<body>
<h2>Weekly Report</h2>
<p>Please find the attached report for the week ending <strong>$(Get-Date -Format 'MMMM dd, yyyy')</strong>.</p>
<p>For questions, reply to this email.</p>
</body>
</html>
"@
    # Attachments
    AttachmentList                 = $AttachmentList
}

Send-MailKitMessage @Parameters
Write-Host "Email sent with HTML body and attachments."
```

### Parameter Reference

| Parameter | Type | Description |
|-----------|------|-------------|
| `UseSecureConnectionIfAvailable` | `bool` | Use TLS/STARTTLS if the server supports it |
| `SmtpServer` | `string` | SMTP relay host |
| `Port` | `int` | SMTP port (typically 587 for STARTTLS) |
| `Credential` | `PSCredential` | Sending account credentials |
| `From` | `MimeKit.MailboxAddress` | Sender name and address |
| `RecipientList` | `MimeKit.InternetAddressList` | TO recipients |
| `CCList` | `MimeKit.InternetAddressList` | CC recipients |
| `BCCList` | `MimeKit.InternetAddressList` | BCC recipients |
| `Subject` | `string` | Email subject line |
| `TextBody` | `string` | Plain text email body |
| `HTMLBody` | `string` | HTML email body |
| `AttachmentList` | `List[string]` | Full paths to attachment files |

---

## 6. Method 4 — Microsoft Graph API (Recommended for Non-Interactive)

For **unattended/service account** scenarios, use Microsoft Graph with an **App Registration** (no user password required).

### Prerequisites

1. Create an **App Registration** in Entra ID
2. Grant **Mail.Send** application permission
3. Grant admin consent
4. Note the **Tenant ID**, **Client ID**, and **Client Secret**

### Install Graph Module

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
```

### Send Email via Graph (App Auth)

```powershell
# App registration credentials
$TenantId     = "your-tenant-id"
$ClientId     = "your-client-id"
$ClientSecret = "your-client-secret" | ConvertTo-SecureString -AsPlainText -Force

$TokenCredential = New-Object System.Management.Automation.PSCredential ($ClientId, $ClientSecret)
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $TokenCredential

# Define message
$Message = @{
    Subject = "Automated Notification"
    Body = @{
        ContentType = "HTML"
        Content = "<h2>Hello</h2><p>This is an automated notification.</p>"
    }
    ToRecipients = @(
        @{ EmailAddress = @{ Address = "recipient@contoso.com" } }
    )
}

# Send from a mailbox (the app must have Mail.Send permission scoped to that mailbox)
Send-MgUserMail -UserId "sender@contoso.com" -Message $Message
```

**Reference:** [Send mail using the Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/user-sendmail)

---

## 7. Choosing the Right Method

| Scenario | Recommended Method |
|----------|-------------------|
| Quick one-off test — no OAuth setup | Method 2 (Send-MailKitMessage) |
| Automated pipelines with attachments | Method 3 (Full Send-MailKitMessage template) |
| Service-to-service / unattended daemon | Method 4 (Microsoft Graph with app registration) |
| Legacy script compatibility | Method 1 (Send-MailMessage — acknowledged deprecated) |

> **For production automation:** Always prefer **Microsoft Graph** (Method 4) with an app registration and scoped `Mail.Send` permission. This avoids storing user passwords and supports modern zero-trust authentication patterns.

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `5.7.57 SMTP — Client not authenticated` | Basic Auth disabled at tenant level | Use OAuth / App Password / Graph |
| `5.7.139 Authentication unsuccessful` | Security Defaults blocking basic auth | Disable Security Defaults or use app password |
| `Unable to connect to smtp.office365.com:587` | Port 587 blocked by firewall | Open outbound TCP 587 on firewall/proxy |
| `TLS handshake failed` | TLS 1.0/1.1 used instead of 1.2 | Add `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12` |
| `The server does not support secure connections` | Port mismatch | Use port 587 (STARTTLS) not 465 for Office 365 |
