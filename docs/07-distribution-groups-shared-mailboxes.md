# Distribution Groups & Shared Mailboxes

> **Category:** Recipients, Permissions  
> **Applies to:** Exchange Online, Microsoft 365

---

## 1. Add a Security Group as Delegate to a User Mailbox

```powershell
Add-MailboxPermission `
    -Identity user@contoso.com `
    -User "<SecurityGroupName>" `
    -AccessRights FullAccess
```

---

## 2. Add Multiple Users to a Shared Mailbox (from a Distribution Group)

```powershell
# Get all members of the distribution group
$DL = Get-DistributionGroupMember "GROUPNAME" | Select-Object -ExpandProperty Name

foreach ($D in $DL) {
    Add-MailboxPermission `
        -Identity "SHARED_MAILBOX_NAME" `
        -User $D `
        -AccessRights FullAccess

    Write-Host -ForegroundColor Yellow `
        "$D has been granted FullAccess to SHARED_MAILBOX_NAME"
}
```

> Replace `GROUPNAME` with the distribution group name and `SHARED_MAILBOX_NAME` with the shared mailbox alias or email address.

---

## 3. Audit Distribution Group Changes

Use the Admin Audit Log or Unified Audit Log to identify who added/removed members, or who created a group.

### Classic Admin Audit Log

```powershell
# Who removed a member?
Search-AdminAuditLog -Cmdlets Remove-DistributionGroupMember -StartDate 01/24/2024 -EndDate 02/12/2024

# Who added a member?
Search-AdminAuditLog -Cmdlets Add-DistributionGroupMember -StartDate 01/24/2024 -EndDate 03/06/2024

# Who created a new group?
Search-AdminAuditLog -Cmdlets New-DistributionGroup -StartDate 01/24/2024 -EndDate 03/06/2024
```

### Unified Audit Log (Recommended — supports more scenarios)

```powershell
# Members added in the last 30 days
Search-UnifiedAuditLog `
    -RecordType ExchangeAdmin `
    -Operations Add-DistributionGroupMember `
    -StartDate (Get-Date).AddDays(-30) `
    -EndDate (Get-Date)

# New groups created in the last 30 days
Search-UnifiedAuditLog `
    -RecordType ExchangeAdmin `
    -Operations New-DistributionGroup `
    -StartDate (Get-Date).AddDays(-30) `
    -EndDate (Get-Date)
```

---

## 4. Shared Mailbox Hidden from the Global Address List (GAL)

### Symptom
Users cannot send from a shared mailbox that has been hidden from the GAL — they receive an NDR.

### Root Cause
When a shared mailbox is hidden from the GAL, **auto-mapping** may not work correctly. Exchange auto-mapping relies on the GAL to resolve mailbox identity when users try to send on behalf of it.

### Resolution Options

| Option | Details |
|--------|---------|
| **Assign a basic license** | Assign an Exchange Online Plan 1 license to the shared mailbox. This allows it to work independently of auto-mapping behavior. |
| **Convert to user mailbox** | Convert the shared mailbox to a regular user mailbox so it behaves as a standard sending identity. |
| **Unhide from GAL** | If business rules allow, remove the hidden setting from the mailbox. |

```powershell
# Unhide the shared mailbox from the GAL
Set-Mailbox -Identity sharedmailbox@contoso.com -HiddenFromAddressListsEnabled $false
```

> **Reference:** [Cannot access shared calendar for hidden mailbox](https://learn.microsoft.com/en-us/exchange/troubleshoot/calendars/cannot-access-shared-calendar-for-hidden-mailbox)

---

## 5. Microsoft 365 Group Not Showing in Outlook Web / Desktop

### Symptom
An M365 group exists but does not appear in Outlook (web or desktop) for users.

### Diagnosis

```powershell
Get-UnifiedGroup -Identity "Marketing Department" | Format-List
```

### Resolution

```powershell
# Unhide the group from address lists
Set-UnifiedGroup -Identity "Legal Department" -HiddenFromAddressListsEnabled $false

# Show in Exchange clients (Outlook)
Set-UnifiedGroup -Identity "Legal Department" -HiddenFromExchangeClientsEnabled:$false
```

---

## References

- [Add-MailboxPermission — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/add-mailboxpermission?view=exchange-ps)
- [Search-AdminAuditLog](https://learn.microsoft.com/en-us/powershell/module/exchange/search-adminauditlog?view=exchange-ps)
- [Search-UnifiedAuditLog](https://learn.microsoft.com/en-us/powershell/module/exchange/search-unifiedauditlog?view=exchange-ps)
- [Shared mailboxes in Exchange Online](https://learn.microsoft.com/en-us/exchange/collaboration-exo/shared-mailboxes)
