# Audit Log Configuration in Exchange Online

> **Category:** Mailbox Audit Logging, Admin Audit Log, Permissions, OWA Policy, Microsoft Purview  
> **Applies to:** Exchange Online, Microsoft 365, Outlook on the Web (OWA), Microsoft Purview Compliance

---

## Table of Contents

1. [Overview — Default Audit Logging Behaviour](#1-overview--default-audit-logging-behaviour)
2. [Granting Users Access to Audit Reports](#2-granting-users-access-to-audit-reports)
3. [Allow XML Audit Log Attachments in OWA](#3-allow-xml-audit-log-attachments-in-owa)
4. [Admin Audit Log Configuration](#4-admin-audit-log-configuration)
5. [Enable / Verify Unified Audit Log for the Organization](#5-enable--verify-unified-audit-log-for-the-organization)
6. [Audit Log Retention by Plan](#6-audit-log-retention-by-plan)

---

## 1. Overview — Default Audit Logging Behaviour

> **Mailbox audit logging is enabled by default for all Exchange Online organizations.** As an admin, you can access and run any report on the Auditing page in the Exchange Admin Center (EAC) or Microsoft Purview Compliance portal.

However, **other users** (such as a records manager, compliance officer, or legal staff) must be explicitly assigned permissions before they can access audit reports.

### What Gets Audited by Default

When mailbox auditing is on, Exchange Online logs actions performed by:
- **Administrators** — Exchange Online admins accessing mailboxes via management tools
- **Delegates** — Users with delegated access (Full Access, Send As, Send on Behalf)
- **Owners** — Selected owner actions (HardDelete, Move, SoftDelete, Update)

---

## 2. Granting Users Access to Audit Reports

### Simplest Method — Add to the Records Management Role Group

> *"The easiest way to give users access is to add them to the **Microsoft Purview Records Management** role group."*

```powershell
Connect-ExchangeOnline

# Add a user to the Records Management role group
Add-RoleGroupMember -Identity "Records Management" -Member user@contoso.com

# Verify membership
Get-RoleGroupMember -Identity "Records Management"
```

### Alternative — Assign the Audit Logs Role via PowerShell

For more granular control, assign just the **Audit Logs** management role:

```powershell
# Create a new role assignment
New-ManagementRoleAssignment `
    -Role "Audit Logs" `
    -User user@contoso.com

# Verify the assignment
Get-ManagementRoleAssignment -RoleAssignee user@contoso.com | FL Role,RoleAssignee
```

### Available Audit-Related Role Groups

| Role Group | Access Granted |
|------------|---------------|
| Records Management | Run compliance and audit reports |
| Compliance Management | Full compliance and eDiscovery capabilities |
| View-Only Audit Logs | View-only access to audit log data |
| Organization Management | Full admin access (includes audit) |

**Reference:** [Manage role groups in Exchange Online](https://learn.microsoft.com/en-us/exchange/permissions-exo/role-groups)

---

## 3. Allow XML Audit Log Attachments in OWA

When you **export mailbox audit logs** or **administrator audit logs**, Exchange Online delivers the log as an **XML file attached to an email message**.

> **Problem:** Outlook on the Web (OWA) **blocks XML attachments by default**. You must explicitly allow `.xml` as a permitted file type in the OWA Mailbox Policy.

### Resolution

```powershell
Connect-ExchangeOnline

# Add .xml to the allowed file types in the Default OWA policy
Set-OwaMailboxPolicy `
    -Identity Default `
    -AllowedFileTypes @{Add=".xml"}

# Verify the change
Get-OwaMailboxPolicy -Identity Default | FL AllowedFileTypes
```

### Verify Per-User Policy (if not using Default)

Some users may be assigned a non-default OWA policy. Find and update it:

```powershell
# Check which OWA policy a user has
Get-CasMailbox user@contoso.com | FL OwaMailboxPolicy

# Update the correct policy
Set-OwaMailboxPolicy `
    -Identity "CustomPolicyName" `
    -AllowedFileTypes @{Add=".xml"}
```

> **Note:** Changes to OWA policies may take **up to 60 minutes** to take effect for active user sessions.

**Reference:** [Set-OwaMailboxPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-owamailboxpolicy)

---

## 4. Admin Audit Log Configuration

The **Administrator Audit Log** records changes made by administrators to Exchange Online organization settings — separate from per-mailbox audit logs.

```powershell
Connect-ExchangeOnline

# Check current admin audit log configuration
Get-AdminAuditLogConfig | FL AdminAuditLogEnabled,AdminAuditLogAgeLimit,LogLevel

# Enable admin audit logging (enabled by default; run if somehow disabled)
Set-AdminAuditLogConfig -AdminAuditLogEnabled $true

# Set retention period (default is 90 days; max is 1 year)
Set-AdminAuditLogConfig -AdminAuditLogAgeLimit 180

# Search admin audit log for configuration changes by a specific admin
Search-AdminAuditLog `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31" `
    -UserIds admin@contoso.com |
    Select-Object RunDate,Caller,CmdletName,CmdletParameters |
    Format-Table -AutoSize

# Export admin audit log results to CSV
Search-AdminAuditLog `
    -StartDate "2024-01-01" `
    -EndDate "2024-12-31" |
    Export-Csv C:\temp\admin-audit-log.csv -NoTypeInformation
```

**Reference:** [Admin audit logging in Exchange Online](https://learn.microsoft.com/en-us/exchange/security-and-compliance/exchange-auditing-reports/view-administrator-audit-log)

---

## 5. Enable / Verify Unified Audit Log for the Organization

The **Unified Audit Log** captures events across all Microsoft 365 services — Exchange Online, SharePoint, Teams, Azure AD, OneDrive, and more.

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName admin@contoso.com

# Check if Unified Audit Log ingestion is enabled
Get-AdminAuditLogConfig | FL UnifiedAuditLogIngestionEnabled

# Enable Unified Audit Log ingestion if disabled
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
```

You can also enable it in the Microsoft Purview Compliance Portal:
1. Go to **https://compliance.microsoft.com**
2. Navigate to **Audit → Start recording user and admin activity**

> **Note:** After enabling, it may take **up to 24 hours** before audit data begins appearing in search results.

**Reference:** [Turn on auditing in Microsoft 365](https://learn.microsoft.com/en-us/purview/audit-log-enable-disable)

---

## 6. Audit Log Retention by Plan

| Plan | Audit Log Retention |
|------|:------------------:|
| Microsoft 365 Business plans | 90 days |
| Office 365 E1 | 90 days |
| Office 365 E3 / Microsoft 365 E3 | 180 days |
| Office 365 E5 / Microsoft 365 E5 | 1 year |
| Microsoft Purview Audit (Premium) | Up to 10 years (add-on license) |

> Audit (Premium) provides **intelligent insights** and **longer retention** — required for investigations that span periods longer than 1 year.

**References:**
- [Mailbox auditing in Exchange Online](https://learn.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing)
- [Microsoft Purview Audit (Premium) overview](https://learn.microsoft.com/en-us/purview/audit-premium)
- [Set-OwaMailboxPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-owamailboxpolicy)
- [Search-AdminAuditLog](https://learn.microsoft.com/en-us/powershell/module/exchange/search-adminauditlog)
