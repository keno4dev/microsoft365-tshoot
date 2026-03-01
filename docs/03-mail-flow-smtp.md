# Mail Flow & SMTP

> **Category:** Mail Flow, SMTP, Transport  
> **Applies to:** Exchange Online, Microsoft 365

---

## 1. SMTP — Overview of Options for Exchange Online

When a device, application, or service needs to send email through Microsoft 365, there are **five options** available:

| Option | Auth Required | Requires Static IP | Internal Only | Notes |
|--------|:---:|:---:|:---:|-------|
| **1. Third-party SMTP provider** (e.g. SMTP2GO) | No | No | No | ✅ Recommended. DMARC-compliant, secure, minimal M365 config |
| **2. Turn off Security Defaults** | No | No | No | ❌ Not recommended — exposes tenant to attack |
| **3. Conditional Access + Exception Account** | Legacy | No | No | Requires Entra ID P1/P2 licensing |
| **4. Direct Send** | No | Preferred | Yes | Works for internal mail only; no auth required |
| **5. SMTP Relay** | No | Yes | Both | Complex setup; requires a static IP |

> **Reference:** [How to set up a multifunction device or application to send email using Microsoft 365](https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-microsoft-365-or-office-365)

---

## 2. Enable / Disable Legacy TLS SMTP AUTH

### Symptom
Older client applications using SMTP AUTH fail after Microsoft enforced TLS 1.2+.

### Via Exchange Admin Center (EAC)

```
Exchange Admin Center → Settings → Mail Flow → Turn on use of legacy TLS clients
```

### Via PowerShell

#### When Execution Policy is Already RemoteSigned

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-Module MSOnline
Install-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Check current state (returns True/False)
Get-TransportConfig | Format-List AllowLegacyTLSClients

# Enable Legacy TLS
Set-TransportConfig -AllowLegacyTLSClients $true

# Verify
Get-TransportConfig | Format-List AllowLegacyTLSClients
```

#### When Execution Policy is NOT RemoteSigned

```powershell
Set-ExecutionPolicy RemoteSigned

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-Module MSOnline
Install-Module ExchangeOnlineManagement
Connect-ExchangeOnline

Get-TransportConfig | Format-List AllowLegacyTLSClients
Set-TransportConfig -AllowLegacyTLSClients $true
Get-TransportConfig | Format-List AllowLegacyTLSClients
```

> **Reference:** [Opt-in Exchange Online endpoint for legacy TLS using SMTP AUTH](https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/opt-in-exchange-online-endpoint-for-legacy-tls-using-smtp-auth)

---

## 3. Add Email Addresses to the Allow List (Anti-Spam)

### Symptom
Emails from a known, trusted sender are being delivered to the Junk/Spam folder.

### Resolution

```
Exchange Admin Center (EAC)
  → Security
  → Policies & Rules
  → Anti-Spam Inbound Policy (Default)
  → Edit Allow and Blocked Senders and Domains
  → Allow Senders → Add the address
```

---

## 4. Bypass ATP (Safe Attachments) Scanning via Mail Flow Rule

Use this when you need to whitelist a third-party phishing simulation vendor (e.g., KnowBe4, Proofpoint, Phishing Tackle) so their test emails bypass Microsoft Defender for Office 365 attachment scanning.

### Steps

1. Navigate to: `Exchange Admin Center → Mail flow → Rules → Add a rule → Create a new rule`
2. Name the rule: `Bypass ATP Attachment Processing - Trusted IP`
3. **Condition:** `The Sender... → IP address is in any of these ranges or exactly matches` → Enter the trusted IP(s)
4. **Action:** `Modify the message properties... → Set a message header`
   - Header name: `X-MS-Exchange-Organization-SkipSafeAttachmentProcessing`
   - Header value: `1`
5. Set rule priority and save.

> **Reference:** [Bypassing Microsoft 365 ATP by IP Address — Phishing Tackle](https://support.phishingtackle.com/hc/en-gb/articles/360035515271-Bypassing-Microsoft-365-formerly-Office-365-Advanced-Threat-Protection-ATP-Defender-for-Office-By-IP-Address)

---

## 5. Automatically Block / Delete Emails from a Sub-domain

### Symptom
End users receive spam or unwanted emails from `*.onmicrosoft.com` sub-domains and want these deleted automatically.

### Single User — Via Outlook Inbox Rule

Create an inbox rule with:
- **Condition:** `Sender address includes` → `onmicrosoft.com`
- **Action:** `Delete the message`

### Bulk — Apply to All User Mailboxes via PowerShell

```powershell
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

foreach ($mailbox in $mailboxes) {
    New-InboxRule `
        -Mailbox $mailbox.UserPrincipalName `
        -Name "Block onmicrosoft.com" `
        -FromAddressContainsWords "onmicrosoft.com" `
        -DeleteMessage $true
}
```

---

## 6. Delete Mail Contacts via PowerShell and CSV

### Step 1 — Prepare CSV File

Create `C:\CSV\deletecontact.csv` with a column `ExternalEmailAddress`:

```csv
ExternalEmailAddress
contact1@external.com
contact2@external.com
```

### Step 2 — Run the Script

```powershell
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

$users = Import-Csv "C:\CSV\deletecontact.csv"

foreach ($user in $users) {
    $ExternalEmailAddress = $user.ExternalEmailAddress
    Remove-MailContact $ExternalEmailAddress
}

Write-Host "DONE RUNNING SCRIPT, CHECK FOR ERRORS"
Read-Host -Prompt "Press Enter to exit"
```

> **Reference:** [O365: How to Delete Contacts Using PowerShell and CSV](https://social.technet.microsoft.com/wiki/contents/articles/54248.o365-how-to-delete-contacts-using-powershell-and-csv-file.aspx)

---

## References

- [Set up SMTP relay — Microsoft Docs](https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-microsoft-365-or-office-365)
- [Legacy TLS SMTP AUTH opt-in endpoint](https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/opt-in-exchange-online-endpoint-for-legacy-tls-using-smtp-auth)
- [Anti-spam protection in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-spam-protection-about)
