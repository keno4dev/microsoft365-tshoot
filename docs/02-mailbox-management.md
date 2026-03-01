# Mailbox Management

> **Category:** Mailbox  
> **Applies to:** Exchange Online, Microsoft 365

---

## 1. Recover a Deleted Mailbox / User in M365

When a user is deleted in Microsoft 365, they enter a **soft-delete** (recycle bin) state for **30 days** before permanent deletion.

### Restore from Recycle Bin (Soft Delete)

```powershell
Connect-MsolService

# Option 1 — Restore to original state
Restore-MsolUser -UserPrincipalName "user@contoso.com"

# Option 2 — Hard restore (removes from recycle bin without restoring)
Remove-MsolUser -UserPrincipalName "user@contoso.com" -RemoveFromRecycleBin
```

> **Note:** `Remove-MsolUser -RemoveFromRecycleBin` is used to **purge** a user permanently, not restore them. To restore, use `Restore-MsolUser`.

---

## 2. Check & Update Mailbox Size / Message Limits

### Symptom

> "This message couldn't be delivered because it's too large. The limit is 0 KB."

This commonly occurs when a user is **migrated from on-premises Exchange** to Exchange Online and the `Get-RemoteMailbox` entry still reflects `0 B` for `MaxSendSize`.

### Diagnose the Issue

```powershell
# Check the cloud-side mailbox limits
Get-Mailbox user@contoso.com | Select Name, MaxSendSize, MaxReceiveSize

# Check the on-prem remote mailbox entry
Get-RemoteMailbox user@contoso.com | Select Name, MaxSendSize, MaxReceiveSize
```

### Resolution — Set Mailbox Size Limits

| Action | Command |
|--------|---------|
| Update a single mailbox | `Set-Mailbox -Identity user@contoso.com -MaxSendSize 75MB -MaxReceiveSize 75MB` |
| Update multiple mailboxes | `("alias1", "alias2", "alias3") \| % {Set-Mailbox -Identity $_ -MaxSendSize 75MB -MaxReceiveSize 75MB}` |
| Update **all** mailboxes | `Get-Mailbox \| Set-Mailbox -MaxSendSize 75MB -MaxReceiveSize 75MB` |
| Update default (future mailboxes) | `Get-MailboxPlan \| Set-MailboxPlan -MaxSendSize 75MB -MaxReceiveSize 75MB` |

> Exchange Online supports messages up to **150 MB**. See [Microsoft 365 Blog](https://www.microsoft.com/en-us/microsoft-365/blog/2015/04/15/office-365-now-supports-larger-email-messages-up-to-150-mb/).

---

## 3. Check Mailbox Quota

```powershell
# Check quota settings for a specific mailbox
Get-Mailbox help@contoso.com | Format-List IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota, UseDatabaseQuotaDefaults

# Check current usage statistics
Get-MailboxStatistics -Identity "user@contoso.com" | Select DisplayName, TotalItemSize, StorageLimitStatus, ItemCount

# Get quota for all mailboxes
Get-Mailbox | Get-MailboxStatistics | Format-Table DisplayName, TotalItemSize
```

### Set Custom Quotas

```powershell
Set-Mailbox -Identity help@contoso.com `
    -IssueWarningQuota 49GB `
    -ProhibitSendQuota 49.5GB `
    -ProhibitSendReceiveQuota 50GB `
    -UseDatabaseQuotaDefaults $false
```

### Force Managed Folder Assistant (apply retention / quota changes immediately)

```powershell
Start-ManagedFolderAssistant -Identity "user@contoso.com" -FullCrawl
```

> **Reference:** [Increase or Customize Mailbox Size](https://learn.microsoft.com/en-us/exchange/troubleshoot/user-and-shared-mailboxes/increase-or-customize-mailbox-size)

---

## 4. Adjust Mailbox Timezone and Regional Settings

### Check Available Timezones

```powershell
$TimeZone = Get-ChildItem "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Time zones" |
    ForEach-Object { Get-ItemProperty $_.PSPath }
$TimeZone | Sort-Object Display | Format-Table -AutoSize PSChildName, Display
```

### Set Timezone for a Single User

```powershell
Set-MailboxRegionalConfiguration -Identity user@contoso.com `
    -Language en-GB `
    -DateFormat "dd/MM/yyyy" `
    -TimeFormat "HH:mm" `
    -TimeZone "W. Europe Standard Time"
```

### Set Timezone for ALL Users (Org-wide)

```powershell
Get-Mailbox | Set-MailboxRegionalConfiguration `
    -Language en-GB `
    -DateFormat "dd/MM/yyyy" `
    -TimeFormat "HH:mm" `
    -TimeZone "W. Europe Standard Time"
```

> **Reference:** [Set-MailboxRegionalConfiguration — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxregionalconfiguration?view=exchange-ps)

---

## 5. Change a User's Display Name

### Via Exchange Admin Center (EAC) — Recommended

1. Log into the [Exchange Admin Center](https://admin.exchange.microsoft.com).
2. Navigate to **Recipients** → locate the user.
3. Click the user's name → **Account** tab → **Manage contact information**.
4. Update the **Display name** field.
5. Click **Save changes**.

> You must be a **Global Admin** or have the appropriate recipient management role.

### Via PowerShell

```powershell
Set-Mailbox -Identity user@contoso.com -DisplayName "New Display Name"
```

---

## 6. Get User's Last Logon and Logoff Time

```powershell
Get-MailboxStatistics -Identity "user@contoso.com" | Select LastLogonTime, LastLogoffTime
```

> **Note:** Sign-in logs (login time) can also be viewed via **Azure Active Directory Admin Center** → **Users** → **Sign-in logs**.  
> Logoff time specifically requires the `Get-MailboxStatistics` cmdlet.

---

## 7. Permanently Force Delete a Mailbox

> **Warning:** This action is irreversible.

```powershell
# Step 1: Install and connect Microsoft Graph
Install-Module -Name Microsoft.Graph
Install-Module -Name Microsoft.Graph.Beta
Connect-MgGraph

# Step 2: List soft-deleted mailboxes
Get-Mailbox -SoftDeletedMailbox

# Step 3: Hard delete the mailbox
Get-Mailbox -Identity "user@contoso.com" | Remove-Mailbox -PermanentlyDelete -Force -Confirm:$false

# Step 4: Verify it is removed
Get-Mailbox -SoftDeletedMailbox
```

---

## 8. Retrieve Recipient Details

Useful when encountering "matches multiple entries" errors:

```powershell
Get-Recipient -Identity user@contoso.com | Format-List
```

---

## References

- [Recover deleted mailbox — Microsoft Docs](https://learn.microsoft.com/en-us/exchange/recipients/disconnected-mailboxes/restore-deleted-mailbox?view=exchserver-2019)
- [Set-MailboxRegionalConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxregionalconfiguration?view=exchange-ps)
- [Increase or Customize Mailbox Size](https://learn.microsoft.com/en-us/exchange/troubleshoot/user-and-shared-mailboxes/increase-or-customize-mailbox-size)
- [Office 365 Larger Email Messages Blog](https://www.microsoft.com/en-us/microsoft-365/blog/2015/04/15/office-365-now-supports-larger-email-messages-up-to-150-mb/)
