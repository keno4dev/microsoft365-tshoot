# Mailbox Archive — Issues & Resolutions

> **Category:** Mailbox Archive, Litigation Hold, Recoverable Items, Managed Folder Assistant, Retention Policies, MRM  
> **Applies to:** Exchange Online, Microsoft Purview, Microsoft 365 Compliance

---

## Table of Contents

1. [Org-Wide Best Practice — Litigation Hold + Archive for All Users](#1-org-wide-best-practice--litigation-hold--archive-for-all-users)
2. [Error: 554 5.2.0 — QuotaExceededException / Recoverable Items Full](#2-error-554-520--quotaexceededexception--recoverable-items-full)
3. [Step-by-Step: Increase Recoverable Items Quota (Mailboxes on Hold)](#3-step-by-step-increase-recoverable-items-quota-mailboxes-on-hold)
   - [Step 1 — Create a Custom Retention Tag for Recoverable Items](#step-1--create-a-custom-retention-tag-for-recoverable-items)
   - [Step 2 — Create a New Exchange Retention Policy](#step-2--create-a-new-exchange-retention-policy)
   - [Step 3 — Apply the Retention Policy to Mailboxes on Hold](#step-3--apply-the-retention-policy-to-mailboxes-on-hold)
   - [Step 4 — Run Managed Folder Assistant to Apply Changes](#step-4--run-managed-folder-assistant-to-apply-changes)
4. [ElcProcessingDisabled — Behaviour & Management](#4-elcprocessingdisabled--behaviour--management)
5. [Start-ManagedFolderAssistant RPC Error — Fix with GUID](#5-start-managedfolderassistant-rpc-error--fix-with-guid)
6. [Auto-Expanding Archive](#6-auto-expanding-archive)
7. [Single Item Recovery](#7-single-item-recovery)
8. [Enable Archive Mailboxes in Bulk](#8-enable-archive-mailboxes-in-bulk)
9. [Litigation Hold — Enable, Report, Bulk Operations](#9-litigation-hold--enable-report-bulk-operations)
10. [Unable to Delete Emails from Online Archive (Search-Mailbox)](#10-unable-to-delete-emails-from-online-archive-search-mailbox)
11. [ImmutableId / SourceAnchor Issues with Deleted Users](#11-immutableid--sourceanchor-issues-with-deleted-users)
12. [Mailbox Archive — Case-by-Case Resolution Checklist](#12-mailbox-archive--case-by-case-resolution-checklist)

---

## 1. Org-Wide Best Practice — Litigation Hold + Archive for All Users

For robust data protection and compliance, it is recommended to enable both **Litigation Hold** and **Archive** for all user mailboxes across the organization.

```powershell
# Enable Litigation Hold for all user mailboxes (with optional duration in days)
Get-Mailbox -ResultSize Unlimited -Filter "RecipientTypeDetails -eq 'UserMailbox'" |
    Set-Mailbox -LitigationHoldEnabled $true  # -LitigationHoldDuration 456

# Enable archive for a specific user
Enable-Mailbox -Identity user@contoso.com -Archive

# Disable Litigation Hold for all users (when rolling back)
Get-Mailbox -ResultSize Unlimited -Filter "RecipientTypeDetails -eq 'UserMailbox'" |
    Set-Mailbox -LitigationHoldEnabled $false
```

**Reference:** [Enable archive mailboxes in Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing)

---

## 2. Error: 554 5.2.0 — QuotaExceededException / Recoverable Items Full

### Symptom

```
554 5.2.0 STOREDRV.Deliver.Exception:QuotaExceededException.MapiExceptionShutoffQuotaExceeded;
Failed to process message due to a permanent exception with message
```

### Root Cause

The Recoverable Items folder has reached its quota. This can happen when:
- The mailbox is on **Litigation Hold** or **In-Place Hold** (prevents permanent deletion)
- The **Managed Folder Assistant (MFA)** has not processed the mailbox recently
- Items in the Recoverable Items folder are not being moved to the Archive

### Diagnostic Commands

```powershell
Connect-ExchangeOnline

# Check Recoverable Items folder state
Get-Mailbox -Identity user@contoso.com | FL recoverableitems*

# Check total mailbox statistics and deleted item counts
Get-MailboxStatistics user@contoso.com |
    Format-List StorageLimitStatus,TotalItemSize,TotalDeletedItemSize,ItemCount,DeletedItemCount

# Check per-folder sizes in Recoverable Items
Get-MailboxFolderStatistics -Identity user@contoso.com -FolderScope RecoverableItems |
    Format-Table Identity,FolderAndSubfolderSize

# Check hold configuration
Get-Mailbox -Identity user@contoso.com | Select LitigationHoldEnabled,InPlaceholds
Get-Mailbox -Identity user@contoso.com | Select ArchiveName,ArchiveStatus,ArchiveState

# Check all retention-related properties
Get-Mailbox -Identity user@contoso.com | FL *Retention*
```

---

## 3. Step-by-Step: Increase Recoverable Items Quota (Mailboxes on Hold)

**Reference:** [Increase the Recoverable Items quota for mailboxes on hold](https://learn.microsoft.com/en-us/microsoft-365/compliance/increase-the-recoverable-quota-for-mailboxes-on-hold)

### Step 1 — Create a Custom Retention Tag for Recoverable Items

```powershell
Connect-ExchangeOnline

# Optional: adjust how long deleted items are kept before being eligible for archiving
Set-Mailbox user@contoso.com -RetainDeletedItemsFor 30

# Set deleted item retention for all user mailboxes (max 30 days in Exchange Online)
Get-Mailbox -ResultSize unlimited -Filter "RecipientTypeDetails -eq 'UserMailbox'" |
    Set-Mailbox -RetainDeletedItemsFor 30

# Create the Recoverable Items retention tag (MoveToArchive after 30 days)
New-RetentionPolicyTag `
    -Name "Recoverable Items 30 days for mailboxes on hold" `
    -Type RecoverableItems `
    -AgeLimitForRetention 30 `
    -RetentionAction MoveToArchive

# Alternative tag for general archive mailboxes
New-RetentionPolicyTag `
    -Name "MRM Policy Tag for Archive Mailboxes" `
    -Type RecoverableItems `
    -AgeLimitForRetention 30 `
    -RetentionAction MoveToArchive
```

> **Recommendation:** Set the `AgeLimitForRetention` to match the `RetainDeletedItemsFor` value on the mailbox — this ensures items get the full deleted item retention window before being moved to archive.

### Step 2 — Create a New Exchange Retention Policy

**Using Exchange Admin Center (EAC):**
1. Go to **Compliance management > Retention policies** → click **Add**
2. Name the policy (e.g., `MRM Policy for Mailboxes on Hold`)
3. Under **Retention tags**, click **Add** and select the tag created in Step 1
4. Click **Save**

**Using PowerShell:**

```powershell
# Policy for mailboxes on hold — includes standard tags
New-RetentionPolicy "MRM Policy for Mailboxes on Hold" `
    -RetentionPolicyTagLinks "Recoverable Items 30 days for mailboxes on hold",
        "1 Month Delete","1 Week Delete","1 Year Delete","5 Year Delete",
        "6 Month Delete","Default 2 year move to archive","Junk Email",
        "Never Delete","Personal 1 year move to archive","Personal 5 year move to archive"

# Minimal version — only the Recoverable Items tag
New-RetentionPolicy "MRM Policy for Mailboxes on Hold" `
    -RetentionPolicyTagLinks "Recoverable Items 30 days for mailboxes on hold"

# Policy for general archive mailboxes
New-RetentionPolicy "General MRM Policy for Archive Mailboxes" `
    -RetentionPolicyTagLinks "Default 2 year move to archive","Junk Email",
        "Never Delete","Personal 1 year move to archive","Personal 5 year move to archive"
```

### Step 3 — Apply the Retention Policy to Mailboxes on Hold

**Apply to a specific user:**

```powershell
Set-Mailbox "User DisplayName" -RetentionPolicy "MRM Policy for Mailboxes on Hold"
```

**Apply to all mailboxes on Litigation Hold:**

```powershell
$LitigationHolds = Get-Mailbox -ResultSize unlimited |
    Where-Object { $_.LitigationHoldEnabled -eq 'True' }
$LitigationHolds.DistinguishedName |
    Set-Mailbox -RetentionPolicy "MRM Policy for Mailboxes on Hold"
```

**Apply to all mailboxes on In-Place Hold:**

```powershell
$InPlaceHolds = Get-Mailbox -ResultSize unlimited |
    Where-Object { $_.InPlaceHolds -ne $null }
$InPlaceHolds.DistinguishedName |
    Set-Mailbox -RetentionPolicy "MRM Policy for Mailboxes on Hold"
```

**Verify the policy was applied:**

```powershell
Get-Mailbox user@contoso.com | Select RetentionPolicy

# Verify for all Litigation Hold mailboxes
Get-Mailbox -ResultSize unlimited |
    Where-Object { $_.LitigationHoldEnabled -eq 'True' } |
    Format-Table DisplayName,RetentionPolicy -Auto

# Verify for all In-Place Hold mailboxes
Get-Mailbox -ResultSize unlimited |
    Where-Object { $_.InPlaceHolds -ne $null } |
    Format-Table DisplayName,RetentionPolicy -Auto
```

### Step 4 — Run Managed Folder Assistant to Apply Changes

Instead of waiting for the assistant to run on its scheduled cycle, trigger it manually:

```powershell
# Process a single mailbox
Start-ManagedFolderAssistant -Identity user@contoso.com

# Full crawl of a single mailbox
Start-ManagedFolderAssistant -Identity user@contoso.com -FullCrawl

# Clean up hold items specifically
Start-ManagedFolderAssistant -Identity user@contoso.com -HoldCleanup

# Run in a loop (poll every 90 seconds) — useful during active remediation
while ($true) {
    Start-ManagedFolderAssistant user@contoso.com
    Write-Host "Waiting..."
    Start-Sleep -Seconds 90
}

# Process all mailboxes in the organization
Get-Mailbox -ResultSize Unlimited |
    ForEach-Object { Start-ManagedFolderAssistant -Identity $_.UserPrincipalName -FullCrawl }

# Process all mailboxes on hold
$MailboxesOnHold = Get-Mailbox -ResultSize unlimited |
    Where-Object { ($_.InPlaceHolds -ne $null) -or ($_.LitigationHoldEnabled -eq "True") }
$MailboxesOnHold.DistinguishedName | Set-Mailbox -ElcProcessingDisabled $false
$MailboxesOnHold.DistinguishedName | Start-ManagedFolderAssistant -FullCrawl
```

> **Important:** If the mailbox's primary mailbox is **more than 85–95% full**, archiving may not start even after triggering the assistant. Reduce the primary mailbox size first, then trigger `Start-ManagedFolderAssistant`.

> **Note:** After running the scripts, the email movement may not start until the **user logs into OWA at least once**. This is known behaviour.

---

## 4. ElcProcessingDisabled — Behaviour & Management

`ElcProcessingDisabled` controls whether the **Managed Folder Assistant (MFA)** processes a specific mailbox.

### Behaviour Table

| ElcProcessingDisabled | Org-Wide Setting | MFA Processes Mailbox? |
|:---------------------:|:----------------:|:----------------------:|
| `$false` | `$false` | ✅ Yes |
| `$true` | `$false` | ❌ No |
| `$false` | `$true` | ❌ No (org overrides mailbox) |
| `$true` | `$true` | ❌ No |

> **Key difference from RetentionHoldEnabled:** `ElcProcessingDisabled` prevents ALL MFA processing, including purging expired items from Recoverable Items. `RetentionHoldEnabled` only pauses MRM policy enforcement.

```powershell
# Confirm ElcProcessingDisabled and SingleItemRecoveryEnabled status
Get-Mailbox user@contoso.com | FL ElcProcessingDisabled, SingleItemRecoveryEnabled

# Re-enable MFA processing for a specific mailbox
Set-Mailbox -Identity user@contoso.com -ElcProcessingDisabled $false

# Re-enable MFA processing for the entire organization
Set-OrganizationConfig -ElcProcessingDisabled $false
```

---

## 5. Start-ManagedFolderAssistant RPC Error — Fix with GUID

### Error

```
The call to Mailbox Assistants Service on server: 'whatever.prod.outlook.com' failed.
Error from RPC is -2147220992.
```

### Root Cause

Using the UPN or display name as the identity can trigger RPC failures in some tenancies due to initialization timing. The fix is to use the **mailbox GUID** as the identity.

### Resolution

```powershell
# Step 1: Get the mailbox GUIDs
Get-MailboxLocation -User user@contoso.com | FL mailboxGuid,mailboxLocationType

# This returns two GUIDs if archiving is enabled:
#   PrimaryMailbox GUID
#   MainArchive GUID

# Step 2: Use the Primary mailbox GUID with Start-ManagedFolderAssistant
Start-ManagedFolderAssistant aace1f4e-feed-ace0-babe-466f1deed1d1 -FullCrawl
```

**Reference:** [Start-ManagedFolderAssistant in Office 365 — Tim McMichael TechNet](https://learn.microsoft.com/en-gb/archive/blogs/timmcmic/office-365-start-managedfolderassistant-in-office-365)

---

## 6. Auto-Expanding Archive

Auto-expanding archiving removes the 100 GB cap on archive mailboxes by provisioning additional storage automatically.

```powershell
# Enable for a specific user
Enable-Mailbox user@contoso.com -AutoExpandingArchive

# Verify for a specific user
Get-Mailbox user@contoso.com | FL AutoExpandingArchiveEnabled

# Enable org-wide
Set-OrganizationConfig -AutoExpandingArchive

# Verify org-wide setting
Get-OrganizationConfig | FL AutoExpandingArchiveEnabled

# Check auto-expanding archive on inactive mailboxes
Get-Mailbox -InactiveMailboxOnly | FL UserPrincipalName,AutoExpandingArchiveEnabled
```

### What Happens When Auto-Expanding Archive Is Enabled (Mailbox on Hold)

| Component | Before | After |
|-----------|--------|-------|
| Primary archive storage quota | 100 GB | 110 GB |
| Archive warning quota | 90 GB | 100 GB |
| Recoverable Items quota in primary | 100 GB | 110 GB |
| Recoverable Items warning quota | 90 GB | 100 GB |

> **Note:** These quota increases apply only if the mailbox is on hold or assigned to a retention policy.

> **Run a diagnostic:** Use [https://aka.ms/PillarArchiveMailbox](https://aka.ms/PillarArchiveMailbox) to run an automated diagnostic check on a user's archive mailbox.

**Reference:** [Enable auto-expanding archiving](https://learn.microsoft.com/en-us/microsoft-365/compliance/enable-autoexpanding-archiving)

---

## 7. Single Item Recovery

Single Item Recovery prevents users from permanently purging items from the Recoverable Items folder.

```powershell
# Disable per-user Single Item Recovery (required before permanent deletion of faulty items)
$ExchangeGUID = Get-Mailbox user@contoso.com | Select-Object -ExpandProperty ExchangeGUID
Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $false

# Enable org-wide Single Item Recovery
Set-OrganizationConfig -SingleItemRecoveryEnabled $true
```

### Single Item Recovery State Comparison

| Property | State: Enabled | State: Disabled |
|----------|:--------------:|:---------------:|
| Soft-deleted items in Recoverable Items | ✅ Yes | ✅ Yes |
| Hard-deleted items in Recoverable Items | ✅ Yes | ❌ No |
| Users can purge from Recoverable Items | ❌ No | ✅ Yes |
| MFA auto-purges after 14 days | ✅ Yes | ✅ Yes |
| Calendar items purged after 120 days | ✅ Yes | ✅ Yes |

> **Hold Priority:** If a mailbox is on both In-Place Hold and Litigation Hold, **Litigation Hold takes precedence**. Note that In-Place Hold does NOT prevent MFA from running, but Litigation Hold does.

**Reference:** [Recoverable Items folder in Exchange Online](https://learn.microsoft.com/en-us/exchange/security-and-compliance/recoverable-items-folder/recoverable-items-folder)

---

## 8. Enable Archive Mailboxes in Bulk

```powershell
# Enable archive for a specific user
Enable-Mailbox -Identity user@contoso.com -Archive

# Enable archive for all users whose archive isn't yet enabled (method 1)
Get-Mailbox -Filter {ArchiveStatus -Eq "None" -AND RecipientTypeDetails -eq "UserMailbox"} |
    Enable-Mailbox -Archive

# Enable archive for all users whose archive isn't yet enabled (method 2 — GUID-based)
Get-Mailbox -Filter {ArchiveGuid -Eq "00000000-0000-0000-0000-000000000000" -AND RecipientTypeDetails -Eq "UserMailbox"} |
    Enable-Mailbox -Archive
```

> **Disabling and Re-enabling Archives:** After disabling an archive mailbox, you can reconnect it to the user's primary mailbox within **30 days**. Content is restored. After 30 days, a new (empty) archive is created. The default archive policy moves items to archive **after 2 years**.

---

## 9. Litigation Hold — Enable, Report, Bulk Operations

```powershell
# Place all user mailboxes on Litigation Hold with 7-year duration
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} |
    Set-Mailbox -LitigationHoldEnabled $true -LitigationHoldDuration 2555

# Enable Litigation Hold for all user mailboxes (no duration)
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} |
    Set-Mailbox -LitigationHoldEnabled $True

# Enable for users in a specific department
Get-Recipient -RecipientTypeDetails UserMailbox -ResultSize unlimited `
    -Filter '(Department -eq "Marketing")' |
    Set-Mailbox -LitigationHoldEnabled $True

# Report all mailboxes and Litigation Hold status
Get-Mailbox -ResultSize Unlimited | FL LitigationHold*

# Display user mailboxes WITHOUT Litigation Hold
Get-Mailbox | Where-Object { $_.LitigationHoldEnabled -match "False" } |
    FL Name,LitigationHold*

# Report Recoverable Items size for mailboxes on Litigation Hold
Get-Mailbox -ResultSize Unlimited -Filter {LitigationHoldEnabled -eq $true} |
    Get-MailboxFolderStatistics -FolderScope RecoverableItems |
    Format-Table Identity,FolderAndSubfolderSize -Auto

# Export to CSV — all mailboxes with hold status
Get-Mailbox -ResultSize unlimited |
    Format-Table DisplayName, LitigationHoldEnabled -Auto > c:\litigation-hold-report.csv
```

---

## 10. Unable to Delete Emails from Online Archive (Search-Mailbox)

### Symptom

Users cannot delete emails from the online archive — commonly related to holds preventing item removal.

### Resolution

Use `Search-Mailbox` to find and optionally delete targeted items:

```powershell
# Search and move emails within a date range to a target mailbox (with full logging)
Search-Mailbox <SourceMailbox> `
    -SearchQuery {Received:mm/dd/yyyy..mm/dd/yyyy} `
    -TargetMailbox <TargetMailbox> `
    -TargetFolder <TargetFolder> `
    -DeleteContent `
    -Force `
    -LogLevel Full

# Search by subject — log only (no deletion)
Search-Mailbox -Identity "April Stewart" `
    -SearchQuery 'Subject:"Your bank statement"' `
    -TargetMailbox "administrator" `
    -TargetFolder "SearchAndDeleteLog" `
    -LogOnly `
    -LogLevel Full

# Search and archive specific subject — move to discovery mailbox
Search-Mailbox -Identity "Joe Healy" `
    -SearchQuery "Subject:Project Hamilton" `
    -TargetMailbox "DiscoveryMailbox" `
    -TargetFolder "JoeHealy-ProjectHamilton" `
    -LogLevel Full
```

---

## 11. ImmutableId / SourceAnchor Issues with Deleted Users

### Scenario

A user was deleted in Active Directory but their Azure AD cloud object remains (or vice versa), causing sync conflicts.

### Option A — Delete the Azure AD object permanently

```powershell
Connect-MsolService  # Or Connect-MgGraph

# Permanently delete the object from Azure AD (not just soft-delete)
Remove-MsolUser -ObjectId "<user's object ID>" -RemoveFromRecycleBin

# Trigger a delta sync to resolve the conflict
Start-ADSyncSyncCycle -PolicyType Delta
```

### Option B — Clear the ImmutableId to retain the cloud object

If the object was deleted in AD but you want to keep the cloud-only Azure AD object:

```powershell
Connect-MsolService

# Clear the SourceAnchor (ImmutableId) from the AAD object
Set-MsolUser -ObjectId '<user object ID>' -ImmutableId "$null"

# Trigger a delta sync
Start-ADSyncSyncCycle -PolicyType Delta
```

---

## 12. Mailbox Archive — Case-by-Case Resolution Checklist

```
☐ 1.  Enable archive mailbox
        Enable-Mailbox -Identity user@contoso.com -Archive

☐ 2.  Optionally enable Litigation Hold to preserve all mailbox items
        Set-Mailbox -Identity user@contoso.com -LitigationHoldEnabled $true

☐ 3.  Validate Recoverable Items state
        Get-Mailbox -Identity user@contoso.com | FL recoverableitems*
        Get-MailboxStatistics user@contoso.com | Format-List StorageLimitStatus,TotalItemSize,...
        Get-MailboxFolderStatistics user@contoso.com -FolderScope RecoverableItems | Ft Identity,FolderAndSubfolderSize
        Get-MailboxFolderStatistics user@contoso.com | sort itemsinfolder -descending | ft folderpath,itemsinfolder

☐ 4.  Check quota settings
        Get-Mailbox user@contoso.com | Select DisplayName, *Quota*

☐ 5.  Create a retention tag
        New-RetentionPolicyTag -Name "..." -Type RecoverableItems -AgeLimitForRetention 30 -RetentionAction MoveToArchive

☐ 6.  Create a retention policy (link to the tag)
        New-RetentionPolicy "..." -RetentionPolicyTagLinks "..."

☐ 7.  Apply the retention policy to the mailbox
        Set-Mailbox user@contoso.com -RetentionPolicy "..."

☐ 8.  Ensure ElcProcessingDisabled is $false
        Set-Mailbox user@contoso.com -ElcProcessingDisabled $false
        Set-OrganizationConfig -ElcProcessingDisabled $false

☐ 9.  Run the Managed Folder Assistant
        Start-ManagedFolderAssistant -Identity user@contoso.com -FullCrawl
        (If RPC error: use Get-MailboxLocation -User user@contoso.com | FL mailboxGuid,mailboxLocationType
                       then: Start-ManagedFolderAssistant <GUID> -FullCrawl)

☐ 10. Have the user log into OWA once to trigger archive movement
```

**References:**
- [Increase the Recoverable Items quota for mailboxes on hold](https://learn.microsoft.com/en-us/microsoft-365/compliance/increase-the-recoverable-quota-for-mailboxes-on-hold)
- [New-RetentionPolicyTag](https://learn.microsoft.com/en-us/powershell/module/exchange/new-retentionpolicytag?view=exchange-ps)
- [Enable archive mailboxes in Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing)
- [Start-ManagedFolderAssistant in Office 365](https://learn.microsoft.com/en-gb/archive/blogs/timmcmic/office-365-start-managedfolderassistant-in-office-365)
