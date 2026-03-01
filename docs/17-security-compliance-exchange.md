# Security & Compliance in Exchange — Issues & Resolutions

> **Category:** Email Security, Anti-Spam, DKIM, SPF, DMARC, EOP, Quarantine, Compromised Accounts, Retention Compliance, SMTP Security  
> **Applies to:** Exchange Online, Exchange Online Protection (EOP), Microsoft Defender for Office 365, Microsoft Purview

---

## Table of Contents

1. [Compromised Account — Tenant Blocked from Sending External Email](#1-compromised-account--tenant-blocked-from-sending-external-email)
2. [Configure DKIM for a Custom Domain](#2-configure-dkim-for-a-custom-domain)
3. [Skip Spam Filtering for Selective Domains from the Same IP](#3-skip-spam-filtering-for-selective-domains-from-the-same-ip)
4. [Skip Spam Filtering for a CIDR IP Outside /24–/32 Range](#4-skip-spam-filtering-for-a-cidr-ip-outside-24-32-range)
5. [Quarantined Email Stuck as "Needs Review"](#5-quarantined-email-stuck-as-needs-review)
6. [Send Email Securely Using PowerShell (SMTP Client Submission)](#6-send-email-securely-using-powershell-smtp-client-submission)
7. [EOP Connection Filter — IP Allow / Block List Behaviour](#7-eop-connection-filter--ip-allow--block-list-behaviour)
8. [Secure by Default in Microsoft 365 / EOP](#8-secure-by-default-in-microsoft-365--eop)
9. [SMTP Authentication for Legacy Devices/Apps — Alternatives](#9-smtp-authentication-for-legacy-devicesapps--alternatives)
10. [Unable to Delete a Retention Policy in Microsoft Purview Portal](#10-unable-to-delete-a-retention-policy-in-microsoft-purview-portal)
11. [Block Emails from a Sub-domain in Bulk (Inbox Rules)](#11-block-emails-from-a-sub-domain-in-bulk-inbox-rules)

---

## 1. Compromised Account — Tenant Blocked from Sending External Email

### Symptom

After an admin account was compromised and used to send bulk spam, the tenant's ability to send **external emails** was blocked by Microsoft. Deleting the inbound connector for AD Connect synchronization was proposed but risks breaking on-premises sync.

### Key Points

- The **compromised account** created malicious inbound/outbound mail connectors
- Microsoft blocked external email because the tenant's outbound spam threshold was exceeded
- **Do NOT delete the AD Connect inbound connector** — this will break on-premises user synchronization

### Resolution Steps

1. **Enable MFA on ALL Global Admin accounts** immediately
2. **Review and delete any connectors created by the compromised account:**
   ```
   Exchange Admin Center → Mail flow → Connectors
   ```
   Identify and remove connectors not matching legitimate on-premises configurations.

3. **Run the Microsoft diagnostic to release the tenant's blocked threshold:**
   ```
   Run diagnostic: "Release Tenant Threshold Exceeded Preview & Validate EOP domain"
   ```
   This can be accessed via the Microsoft 365 Admin Center → **Support → Run Diagnostics**.

4. **Review and audit recent admin activities** in Microsoft Purview Audit Logs:
   ```
   Microsoft Purview → Audit → Audit Search
   Search for: Removed connector, Added connector, Modified connector
   ```

> **Security hygiene:** All Global Admin accounts should have **MFA enforced** and **Conditional Access policies** applied. Review sign-in logs for the compromised account immediately.

---

## 2. Configure DKIM for a Custom Domain

**DKIM (DomainKeys Identified Mail)** adds a cryptographic signature to outbound messages, allowing receiving servers to verify the message was sent by your domain and has not been tampered with.

### Why DKIM Matters

| Authentication | Protects Against |
|----------------|-----------------|
| SPF | Unauthorized senders using your domain's IP |
| **DKIM** | Message tampering; spoofed messages that pass SPF |
| DMARC | Combined enforcement of SPF + DKIM with reporting |

> DKIM is enabled by default for `<tenant>.onmicrosoft.com` domains. It **must be manually enabled** for all custom domains added to your tenant.

### Step 1 — Add CNAME Records to Your DNS Provider

For the domain `contoso.com`, add two CNAME records:

| Host Name | Record Type | Value |
|-----------|-------------|-------|
| `selector1._domainkey.contoso.com` | CNAME | `selector1-contoso-com._domainkey.contoso.onmicrosoft.com.` |
| `selector2._domainkey.contoso.com` | CNAME | `selector2-contoso-com._domainkey.contoso.onmicrosoft.com.` |

> **TTL:** 3600

### Step 2 — Enable DKIM in the Microsoft 365 Defender Portal

1. Go to **Microsoft 365 Defender** (`https://security.microsoft.com`)
2. Navigate to **Email & collaboration → Policies & rules → Threat policies**
3. Under **Rules**, select **DKIM**
4. Select your custom domain
5. Click **Create DKIM keys**
6. Copy the CNAME values shown in the pop-up and add them to your DNS provider
7. Return to the portal → toggle **Sign messages for this domain with DKIM signatures** to **Enabled**

### Verify DKIM is Working

After DNS propagation (up to 48 hours), send a test email to an external mailbox and check the message headers for:
```
DKIM-Signature: v=1; a=rsa-sha256; d=contoso.com; ...
Authentication-Results: dkim=pass
```

**Reference:** [Use DKIM to validate outbound email sent from your custom domain](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email)

---

## 3. Skip Spam Filtering for Selective Domains from the Same IP

### Scenario

Source email server `192.168.1.25` sends email from `contoso.com`, `fabrikam.com`, and `tailspintoys.com`. You want to skip spam filtering **only for fabrikam.com** (not the other domains).

### Solution — IP Allow List + Mail Flow Rule with Exception

**Step 1:** Add `192.168.1.25` to the **IP Allow List** in the Connection Filter Policy:
```
Microsoft 365 Defender → Policies & rules → Threat policies
  → Anti-spam → Connection filter policy
  → IP Allow List → Add 192.168.1.25
```

**Step 2:** Create a Mail Flow (Transport) Rule:

| Field | Setting |
|-------|---------|
| **Condition** | The sender IP address is in: `192.168.1.25` |
| **Action** | Set the spam confidence level (SCL) to `0` |
| **Exception** | The sender domain is: `fabrikam.com` *(only skip filtering for this domain)* |

> With the IP in the Allow List AND the SCL=0 rule applied (except for fabrikam.com), fabrikam.com messages are still spam-filtered while the others bypass filtering.

**Reference:** [Connection filter policy — IP Allow List scenarios](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/configure-the-connection-filter-policy)

---

## 4. Skip Spam Filtering for a CIDR IP Outside /24–/32 Range

### Limitation

The **IP Allow List** only accepts CIDR ranges of **/24 to /32**. If your source IP is in a broader range (e.g., `/16`), you cannot add it directly to the IP Allow List.

> **Warning:** Messages from IP ranges in a Microsoft-flagged block list will still be blocked even if added to the IP Allow List.

### Solution — Mail Flow Rule

Create a mail flow rule with **at minimum** these settings:

| Field | Setting |
|-------|---------|
| **Condition** | Sender IP address is in: `<your CIDR IP with /1 to /23 mask>` |
| **Action** | Set the SCL to **Bypass spam filtering** |

> Optionally: set the rule to **audit**, **test**, or run during a **specific time period** before enforcing it.

**Reference:** [Configure the connection filter policy in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/configure-the-connection-filter-policy)

---

## 5. Quarantined Email Stuck as "Needs Review"

### Symptom

Attempting to release an email from the Microsoft Defender Quarantine portal shows the status **"Needs review"** and the release action does nothing.

### Resolution — Release via PowerShell

```powershell
Connect-ExchangeOnline  # Or Connect-IPPSSession

# List all quarantined messages
Get-QuarantineMessage

# Get details about a specific quarantined message by sender
Get-QuarantineMessage -SenderAddress "sender@example.com" | FL

# Release a specific message to all original recipients
Get-QuarantineMessage -SenderAddress "sender@example.com" |
    Release-QuarantineMessage -ReleaseToAll

# Release a specific message by Message-ID with force (allow sender)
Get-QuarantineMessage -MessageID "<5c695d7e-6642-4681-a4b0-9e7a86613cb7@contoso.com>" |
    Release-QuarantineMessage -User julia@contoso.com -Force -AllowSender

# Release by quarantine identity (GUID pair)
Release-QuarantineMessage `
    -Identity "c14401cf-aa9a-465b-cfd5-08d0f0ca37c5\4c2ca98e-94ea-db3a-7eb8-3b63657d4db7" `
    -ReleaseToAll

# Release ALL quarantined messages (use with caution — includes spam and transport rule)
Get-QuarantineMessage | Release-QuarantineMessage -ReleaseToAll

# Release only spam-quarantined messages
Get-QuarantineMessage -Type Spam | Release-QuarantineMessage -ReleaseToAll
```

### Resolution — Check Quarantine Policy in the Defender Portal

1. Go to **Microsoft 365 Defender → Email & collaboration → Policies & rules → Threat policies**
2. Under **Policies**, select **Anti-spam** → review the inbound anti-spam rule
3. Note the **quarantine policy** applied on the rule
4. Navigate back to **Threat policies → Quarantine policies**
5. Review the policy's permitted actions — the "Needs review" state may mean the policy requires admin approval before release

**Reference:** [Manage quarantined messages and files as an admin in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-admin-manage-messages-files)

---

## 6. Send Email Securely Using PowerShell (SMTP Client Submission)

Use the snippet below to send email via **SMTP Client Submission** (`smtp.office365.com:587`) with TLS and credential-based authentication.

```powershell
# Enforce TLS 1.2
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

# Collect credentials interactively (or use a stored credential)
$Credential = Get-Credential

# Build the parameters hashtable
$MailParams = @{
    SmtpServer                 = 'smtp.office365.com'
    Port                       = 587
    UseSSL                     = $true
    Credential                 = $Credential
    From                       = 'sender@yourdomain.com'
    To                         = 'recipient@example.com', 'other@example.com'
    Subject                    = "SMTP Client Submission - $(Get-Date -Format g)"
    Body                       = 'This is a test email using SMTP Client Submission'
    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
}

# Send the message
Send-MailMessage @MailParams
```

> **Note:** SMTP Client Submission requires **SMTP AUTH to be enabled both at the organization level and on the sender's mailbox**. Verify with:
> ```powershell
> Get-TransportConfig | FL SmtpClientAuthenticationDisabled
> Get-CasMailbox user@contoso.com | FL SmtpClientAuthenticationDisabled
> ```

---

## 7. EOP Connection Filter — IP Allow / Block List Behaviour

### Overview

Exchange Online Protection (EOP) provides connection filtering through the **default connection filter policy**.

| List Type | Behaviour |
|-----------|-----------|
| **IP Allow List** | Skip spam filtering for messages from listed IPs |
| **IP Block List** | Reject all messages from listed IPs (no spam filter — outright reject) |
| **Safe list** | Microsoft-managed dynamic allow list — no customer configuration needed; skips spam filtering |

### Scenarios Where IP Allow List Messages Are Still Filtered

Despite being in the IP Allow List, a message may still be spam-filtered when:

1. The source IP is also configured in **an on-premises IP-based inbound connector in another tenant** (Tenant A), and the EOP server that first encounters the message is in the **same Active Directory forest** as Tenant A — `IPV:CAL` is added but spam filtering still runs.

2. Your tenant's IP Allow List and the EOP server that first encounters the message are in **different Microsoft Active Directory forests** — `IPV:CAL` is not added, spam filtering runs.

### Workaround for Either Scenario

Create a mail flow rule:

| Field | Setting |
|-------|---------|
| **Condition** | Sender IP address is in the problematic IP range |
| **Action** | Set SCL to **Bypass spam filtering** |

**Reference:** [Configure the connection filter policy in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/configure-the-connection-filter-policy)

---

## 8. Secure by Default in Microsoft 365 / EOP

> "**Secure by default**" means Microsoft applies the most secure settings possible out of the box, with the goal of protecting customers even when they haven't explicitly configured security policies.

### What Secure by Default Means in Practice

- Email with **suspected malware** → automatically **quarantined** (controlled by quarantine policy + anti-malware policy)
- Email identified as **high confidence phishing** → handled per the anti-spam policy action

### What Secure by Default Overrides (i.e., what it ignores)

The following customer-configured overrides are **bypassed** by secure-by-default for malware and high confidence phishing:

- Allowed sender lists / allowed domain lists (anti-spam policies)
- Outlook Safe Senders
- IP Allow List (connection filtering)
- Exchange mail flow rules (transport rules)

> **Secure by default is not a setting — it is the way filtering works**. It cannot be turned on or off. Only admins can manage quarantined malware/phishing messages.

**Reference:** [Secure by default in Office 365](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/secure-by-default)

---

## 9. SMTP Authentication for Legacy Devices/Apps — Alternatives

### Problem

Security Defaults enforce MFA for all user accounts, which breaks legacy apps, printers, and multi-function devices that use **Basic Auth / SMTP AUTH**. These devices cannot support modern authentication.

### Alternatives

| Option | Description | Notes |
|--------|-------------|-------|
| **App Password** | Generate an app-specific password from the user account and use it in the device | Works in some configurations; not compatible with Security Defaults in all scenarios |
| **Third-party SMTP relay (e.g., SMTP2GO)** | Use a DMARC-compliant third-party provider for SMTP relay | Low cost (~$10/month); does not touch Microsoft 365 config; recommended |
| **Conditional Access + exclusion** | Turn off Security Defaults, enable Conditional Access, exclude the legacy app account | Requires Entra ID Premium P1; not recommended unless CA is already in use |
| **Direct Send** | Send directly to Exchange Online without auth; for internal recipients only | Requires static IP; cannot use dynamic/DHCP IP |
| **SMTP Relay** | Full SMTP relay via Exchange Online | Requires static IP; can send internally and externally |

> **Do NOT simply turn off Security Defaults** — this exposes the tenant to attack without proper replacement controls.

> **Note:** App passwords are **not compatible** with Security Defaults in some tenants. If Security Defaults are on, turn them off and enforce MFA using **Per-User MFA** in the M365 Admin Center — then app passwords work.

**Reference:** [SMTP AUTH in Exchange Online](https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/authenticated-client-smtp-submission)

---

## 10. Unable to Delete a Retention Policy in Microsoft Purview Portal

### Symptom

When attempting to delete a retention policy in the Microsoft Purview Compliance Portal, the policy **reappears** after deletion.

### Resolution — Via PowerShell

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName admin@contoso.com

# Remove the retention compliance policy
Remove-RetentionCompliancePolicy -Identity "Regulation 123 Compliance"

# Force deletion if standard removal fails
Remove-RetentionCompliancePolicy -Identity "Regulation 123 Compliance" -ForceDeletion

# If Identity name doesn't work, use the policy GUID instead
# Get the GUID:
Get-RetentionCompliancePolicy "Regulation 123 Compliance" | FL Guid
# Then:
Remove-RetentionCompliancePolicy -Identity "<GUID>" -ForceDeletion
```

### Cause: Policy Created via Desired State Configuration (DSC)

> If the policy keeps reappearing — the IT team's initial configuration used **Desired State Configuration (DSC)** and the file was uploaded to Microsoft Defender. Until the DSC file is **removed from Defender**, the policy will be automatically recreated.

**Fix:** Remove the DSC configuration file from Defender/Purview, then delete the policy.

**References:**
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell)
- [Remove-RetentionCompliancePolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/remove-retentioncompliancepolicy)

---

## 11. Block Emails from a Sub-domain in Bulk (Inbox Rules)

### Scenario

An organization wants to automatically block emails from senders at `*.onmicrosoft.com` (or any sub-domain pattern) for **all users' mailboxes**.

### Resolution — Create an Inbox Rule in Bulk via PowerShell

```powershell
Connect-ExchangeOnline

# Create an inbox rule on every user mailbox to auto-delete from the target domain
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

foreach ($mailbox in $mailboxes) {
    New-InboxRule `
        -Mailbox $mailbox.UserPrincipalName `
        -Name "BlockOnMicrosoft" `
        -FromAddressContainsWords "onmicrosoft.com" `
        -DeleteMessage $true
}
```

> **Alternative (for a single user):** Create the rule manually in Outlook:
> 1. Go to **Home → Rules → Manage Rules & Alerts → New Rule**
> 2. Condition: *from address contains* `onmicrosoft.com`
> 3. Action: *delete it / permanently delete*

> **Note:** This is a workaround. A more robust approach is to create an **Anti-spam policy** or **mail flow rule** at the organizational level in Exchange Admin Center → Mail flow → Rules — to block/quarantine messages based on sender domain patterns.

---

## Key Cmdlets Reference

| Cmdlet | Purpose |
|--------|---------|
| `Get-QuarantineMessage` | List quarantined messages |
| `Release-QuarantineMessage` | Release quarantined messages to recipients |
| `Get-TransportConfig` | Check org-level SMTP AUTH settings |
| `Get-CasMailbox` | Check per-user SMTP AUTH and CAS settings |
| `New-InboxRule` | Create inbox rules programmatically |
| `Remove-RetentionCompliancePolicy` | Delete a compliance retention policy |
| `Connect-IPPSSession` | Connect to Security & Compliance PowerShell |
| `New-TransportRule` | Create mail flow (transport) rules |
| `Set-HostedContentFilterPolicy` | Configure anti-spam policies |

**References:**
- [Exchange Online Protection overview](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/exchange-online-protection-overview)
- [Anti-spam protection in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-spam-protection)
- [Create safe sender lists in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/create-safe-sender-lists-in-office-365)
- [DKIM setup for Exchange Online](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email)
