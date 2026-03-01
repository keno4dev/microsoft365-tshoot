# Exchange Online Mailbox Auditing

> **Category:** Mailbox Audit Logging, Compliance Auditing, Non-Owner Access, Exchange Admin Center  
> **Applies to:** Exchange Online, Microsoft Purview, Microsoft 365 Compliance

---

## Table of Contents

1. [Overview — Mailbox Audit Logging in Exchange Online](#1-overview--mailbox-audit-logging-in-exchange-online)
2. [Enable or Disable Mailbox Audit Logging](#2-enable-or-disable-mailbox-audit-logging)
3. [Manage Mailbox Auditing via PowerShell](#3-manage-mailbox-auditing-via-powershell)
4. [Manage Mailbox Auditing via Exchange Admin Center (EAC)](#4-manage-mailbox-auditing-via-exchange-admin-center-eac)
5. [Default Audit Actions by Logon Type](#5-default-audit-actions-by-logon-type)
6. [Search Unified Audit Log via PowerShell](#6-search-unified-audit-log-via-powershell)
7. [Audit Logon Types Explained](#7-audit-logon-types-explained)
8. [Export and Report Mailbox Audit Logs](#8-export-and-report-mailbox-audit-logs)
9. [Audit Best Practices](#9-audit-best-practices)

---

## 1. Overview — Mailbox Audit Logging in Exchange Online

**Mailbox audit logging** records all mailbox access by:
- Exchange Online administrators
- Delegates (users with delegated access)
- The mailbox owner themselves (configurable)

> In **Microsoft 365**, mailbox auditing is enabled by default for all user mailboxes since January 2019. However, verifying per-mailbox enablement is still recommended — especially for older tenants or migrated mailboxes.

### What Gets Logged

Every access event that is logged includes:
- The **identity** of the user who accessed the mailbox
- The **action** performed (e.g., read, moved, deleted)
- The **time and date** of the access
- Whether access was by the **owner, delegate, or admin**
- The **items** accessed (folder path, subject if applicable)

---

## 2. Enable or Disable Mailbox Audit Logging

### Connect to Exchange Online

**Legacy method (Basic Auth — deprecated):**

```powershell
$UserCredential = Get-Credential
$Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -Credential $UserCredential `
    -Authentication Basic `
    -AllowRedirection
Import-PSSession $Session
```

**Modern method (recommended):**

```powershell
Install-Module ExchangeOnlineManagement -Force
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
```

### Enable / Disable Audit on a Specific Mailbox

```powershell
# Enable audit logging for a specific user
Set-Mailbox -Identity user@contoso.com -AuditEnabled $true

# Disable audit logging for a specific user
Set-Mailbox -Identity user@contoso.com -AuditEnabled $false
```

### Enable Audit Logging for All User Mailboxes

```powershell
$UserMailboxes = Get-Mailbox -Filter { RecipientTypeDetails -eq 'UserMailbox' }
$UserMailboxes | ForEach-Object {
    Set-Mailbox $_.Identity -AuditEnabled $true
}
```

---

## 3. Manage Mailbox Auditing via PowerShell

### Check Whether Audit Is Enabled

```powershell
# Check all mailboxes — AuditEnabled = True means active
Get-Mailbox | FL Name,AuditEnabled

# Check a specific mailbox
Get-Mailbox -Identity user@contoso.com | FL Name,AuditEnabled,AuditAdmin,AuditDelegate,AuditOwner
```

### Retrieve Audit Log Entries for a Mailbox

```powershell
# Show all Admin and Delegate logon entries with details
Search-MailboxAuditLog user@contoso.com `
    -LogonTypes Admin,Delegate `
    -ShowDetails

# Narrow by date range
Search-MailboxAuditLog user@contoso.com `
    -StartDate "01/01/2024" `
    -EndDate "12/31/2024" `
    -LogonTypes Admin,Delegate,Owner `
    -ShowDetails

# Show audit log entries for an admin accessing multiple mailboxes
Search-MailboxAuditLog `
    -LogonTypes Admin `
    -ShowDetails `
    -StartDate "06/01/2024" `
    -EndDate "06/30/2024"
```

### Send All Audit Log Entries to an Email Address

```powershell
# Creates an asynchronous audit log search — results are emailed to the StatusMailRecipients address
New-MailboxAuditLogSearch `
    -StatusMailRecipients auditor@contoso.com `
    -StartDate "01/01/2024" `
    -EndDate "12/31/2024"
```

> **Note:** `New-MailboxAuditLogSearch` is an asynchronous operation. The audit log report is sent to the specified email address when complete (typically within a few minutes to hours depending on data volume).

---

## 4. Manage Mailbox Auditing via Exchange Admin Center (EAC)

### Review Non-Owner Access to Mailboxes (Audit-Enabled)

1. Open **Exchange Admin Center (EAC)**
2. Go to **Compliance management → Auditing**
3. Click **Run a non-owner mailbox access report**
4. Specify the date range and click **Search**
5. The report lists all non-owner access events for audit-enabled mailboxes

### View Details About Non-Owner Access to a Specific Mailbox

In the non-owner access report results, click a **mailbox** to expand detailed access records for that mailbox.

### Export Mailbox Audit Logs

1. Open **EAC → Compliance management → Auditing**
2. Click **Export mailbox audit logs**
3. Specify the export parameters (date range, mailbox, recipient email)
4. The export file is sent to the specified recipient as an XML attachment

---

## 5. Default Audit Actions by Logon Type

Exchange Online logs the following actions by default per logon type:

| Action | Owner | Delegate | Admin |
|--------|:-----:|:--------:|:-----:|
| Copy (message copied to another folder) | ❌ | ✅ | ✅ |
| Create (item created in Calendar, Contacts, Notes, Tasks) | ❌ | ✅ | ✅ |
| FolderBind (folder accessed) | ❌ | ✅ | ✅ |
| HardDelete (item permanently deleted) | ✅ | ✅ | ✅ |
| MessageBind (message opened in reading pane) | ❌ | ❌ | ✅ |
| Move (item moved to another folder) | ✅ | ✅ | ✅ |
| MoveToDeletedItems (item moved to Deleted Items) | ✅ | ✅ | ✅ |
| SendAs (message sent as mailbox) | ❌ | ✅ | ✅ |
| SendOnBehalf (message sent on behalf of mailbox) | ❌ | ✅ | ✅ |
| SoftDelete (item deleted from Deleted Items) | ✅ | ✅ | ✅ |
| Update (message properties changed) | ✅ | ✅ | ✅ |

### Add Custom Actions to Audit

To extend what gets audited for each logon type, use the `-AuditAdmin`, `-AuditDelegate`, and `-AuditOwner` parameters:

```powershell
# Enable additional admin audit actions
Set-Mailbox user@contoso.com `
    -AuditAdmin HardDelete,Move,MoveToDeletedItems,SoftDelete,Update,Create,FolderBind,MessageBind

# Enable additional delegate audit actions
Set-Mailbox user@contoso.com `
    -AuditDelegate HardDelete,Move,MoveToDeletedItems,SoftDelete,Update,Create,FolderBind,SendAs,SendOnBehalf

# Enable owner audit actions
Set-Mailbox user@contoso.com `
    -AuditOwner HardDelete,Move,MoveToDeletedItems,SoftDelete,Update,Create
```

---

## 6. Search Unified Audit Log via PowerShell

The **Unified Audit Log** covers events across Microsoft 365 services — not just mailbox operations.

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName admin@contoso.com

# Search for mailbox login events for a specific user
Search-UnifiedAuditLog `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31" `
    -UserIds "user@contoso.com" `
    -Operations "MailboxLogin,MailItemsAccessed" `
    -ResultSize 1000 |
    Select-Object CreationDate,UserIds,Operations,AuditData

# Search for admin access to another mailbox
Search-UnifiedAuditLog `
    -StartDate "2024-06-01" `
    -EndDate "2024-06-30" `
    -Operations "FolderBind,HardDelete" `
    -UserIds "admin@contoso.com" |
    Select-Object CreationDate,UserIds,Operations,AuditData

# Export audit log results to CSV
Search-UnifiedAuditLog `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31" `
    -Operations "Send,SendAs,SendOnBehalf" |
    Export-Csv C:\temp\unified-audit-send-events.csv -NoTypeInformation
```

> **Note:** `Search-UnifiedAuditLog` can return a maximum of 5,000 results per cmdlet call. For large exports, use the **Microsoft Purview Audit** portal or break searches into smaller date ranges.

**Reference:** [Search the audit log in Microsoft Purview](https://learn.microsoft.com/en-us/purview/audit-search)

---

## 7. Audit Logon Types Explained

| Logon Type | Who It Covers |
|------------|--------------|
| **Owner** | The mailbox owner accessing their own mailbox |
| **Delegate** | A user who has been explicitly granted access (e.g., Full Access, Send As) |
| **Admin** | Exchange Online administrator who accessed the mailbox without explicit permission grant (e.g., using EAC or management tools) |
| **ExternalUser** | Federated or guest users accessing the mailbox |

```powershell
# Retrieve entries for all logon types
Search-MailboxAuditLog user@contoso.com `
    -LogonTypes Admin,Delegate,Owner `
    -ShowDetails `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31"
```

---

## 8. Export and Report Mailbox Audit Logs

### Export Audit Log via Exchange Admin Center

1. Go to **EAC → Compliance management → Auditing**
2. Click **Export mailbox audit logs**
3. Specify:
   - **Start date / End date**
   - **Mailboxes to export** (or leave blank for all)
   - **Send the audit data to** — enter an email address for the report
4. Click **Export** — the report arrives as an XML attachment

### Export via PowerShell to CSV

```powershell
# Export audit log for a specific mailbox to CSV
Search-MailboxAuditLog user@contoso.com `
    -LogonTypes Admin,Delegate,Owner `
    -ShowDetails `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31" |
    Export-Csv C:\temp\mailbox-audit-log.csv -NoTypeInformation

# Generate an audit report and send by email
New-MailboxAuditLogSearch `
    -Mailboxes "user@contoso.com" `
    -LogonTypes Admin,Delegate `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31" `
    -StatusMailRecipients auditor@contoso.com `
    -Name "Q1 2024 Mailbox Audit Report"
```

---

## 9. Audit Best Practices

```
☐ 1.  Verify mailbox audit logging is enabled for all user mailboxes
        Get-Mailbox -ResultSize Unlimited | Where {$_.AuditEnabled -eq $false} | FL Name,UserPrincipalName

☐ 2.  Enable audit for any mailbox where it is disabled
        Set-Mailbox user@contoso.com -AuditEnabled $true

☐ 3.  Ensure the Unified Audit Log is enabled for the organization
        Microsoft Purview → Audit → Check "Auditing is turned on"
        (or: Get-AdminAuditLogConfig | FL UnifiedAuditLogIngestionEnabled)

☐ 4.  Configure appropriate audit actions per logon type using AuditAdmin/AuditDelegate/AuditOwner

☐ 5.  Set up regular audit log export to a secure location or SIEM for long-term retention
        (Audit logs in Exchange Online are retained for 90 days by default; 
         Microsoft 365 E5 plan: up to 1 year with optional 10-year add-on)

☐ 6.  Review non-owner access reports regularly for shared mailboxes and executive mailboxes

☐ 7.  Protect audit log data from tampering — enable litigation hold on the compliance mailbox

☐ 8.  Use Search-UnifiedAuditLog for cross-service investigation (SharePoint, Teams, Exchange)
```

### Audit Log Retention Periods

| Plan | Retention Period |
|------|:---------------:|
| Microsoft 365 Business plans | 90 days |
| Office 365 E1 / Business Premium | 90 days |
| Office 365 E3 / Microsoft 365 E3 | 180 days |
| Office 365 E5 / Microsoft 365 E5 | 1 year |
| Microsoft Purview Audit (Premium) | Up to 10 years (add-on) |

**References:**
- [Mailbox auditing in Exchange Online](https://learn.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing)
- [Search-MailboxAuditLog](https://learn.microsoft.com/en-us/powershell/module/exchange/search-mailboxauditlog)
- [New-MailboxAuditLogSearch](https://learn.microsoft.com/en-us/powershell/module/exchange/new-mailboxauditlogsearch)
- [Search the audit log in Microsoft Purview](https://learn.microsoft.com/en-us/purview/audit-search)
- [Manage auditing in Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/compliance/auditing-solutions-overview)
