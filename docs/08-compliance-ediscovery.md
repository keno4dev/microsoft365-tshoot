# Compliance, eDiscovery & Retention

> **Category:** Compliance, Purview, Retention  
> **Applies to:** Microsoft Purview, Exchange Online, Microsoft 365

---

## 1. Delete Calendar Events Without Notifying Attendees

### Overview

This is a common request when an organizer wants to remove meeting items from recipient mailboxes without sending cancellation emails.

> **Required Roles:**
> - To create a Content Search: `eDiscovery Manager` or `Compliance Search` role
> - To delete messages: `Organization Management` or `Search And Purge` role

---

### Complete Step-by-Step Process

#### Step 1 — Load Exchange Online PowerShell Module

```powershell
Import-Module ExchangeOnlineManagement
```

#### Step 2 — Connect to Security & Compliance PowerShell

```powershell
Connect-IPPSSession -UserPrincipalName admin@contoso.com
```

#### Step 3 — Create a Compliance Content Search

```powershell
New-ComplianceSearch `
    -Name "DeleteCalEvent-JohnFrank" `
    -ExchangeLocation "John.Frank@contoso.com" `
    -ContentMatchQuery 'Subject:"John & Rachel 1 on 1 Check-In"' `
    -LogLevel Full
```

> Use `kind:meetings` in the query to specifically target calendar items:
> ```powershell
> -ContentMatchQuery 'kind:meetings AND Subject:"Weekly Standup"'
> ```

#### Step 4 — Run the Search

```powershell
Start-ComplianceSearch -SearchName "DeleteCalEvent-JohnFrank"

# Check search status
Get-ComplianceSearch -Identity "DeleteCalEvent-JohnFrank" | Format-List Status, Items, Size
```

#### Step 5 — Delete Matched Content (Hard Delete)

```powershell
New-ComplianceSearchAction `
    -SearchName "DeleteCalEvent-JohnFrank" `
    -Purge `
    -PurgeType HardDelete
```

#### Step 6 — Disconnect

```powershell
Disconnect-ExchangeOnline -Confirm:$false
```

---

### Legacy Method (Deprecated — for reference only)

> **Note:** `Search-Mailbox` is **deprecated** and may not work in all tenants.

```powershell
# Search only (no delete)
Search-Mailbox `
    -Identity "user@contoso.com" `
    -SearchQuery 'kind:meetings AND Subject:"meeting title"' `
    -TargetMailbox "admin@contoso.com" `
    -TargetFolder "search_result" `
    -LogLevel Full `
    -LogOnly `
    -SearchDumpster:$false

# Delete matched content
Search-Mailbox `
    -Identity "user@contoso.com" `
    -SearchQuery 'kind:meetings AND Subject:"meeting title"' `
    -DeleteContent
```

> **Reference:**
> - [Search-Mailbox cmdlet fails — Exchange Troubleshoot](https://learn.microsoft.com/en-us/exchange/troubleshoot/compliance/search-mailbox-cmdlet-fails)
> - [New-ComplianceSearch — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancesearch?view=exchange-ps)
> - [Search for and delete email messages — Microsoft Purview](https://learn.microsoft.com/en-us/purview/ediscovery-search-for-and-delete-email-messages)

---

## 2. Create a Retention Policy (7-Year Org-Wide Delete)

### Business Requirement
Automatically purge all mailbox data after **7 years (2,556 days)** across the entire organization.

### Step 1 — Create the Retention Tag

```powershell
New-RetentionPolicyTag `
    -Name "Corp-7years-Delete" `
    -Type All `
    -AgeLimitForRetention 2556 `
    -RetentionAction DeleteAndAllowRecovery
```

### Step 2 — Create the Retention Policy

```powershell
New-RetentionPolicy "RetentionPolicy-Corp" `
    -RetentionPolicyTagLinks "Corp-7years-Delete"
```

### Step 3 — Apply Policy to All Mailboxes

```powershell
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RetentionPolicy "RetentionPolicy-Corp"
```

### Step 4 — Force Immediate Processing (optional)

```powershell
# Trigger Managed Folder Assistant by UserPrincipalName
Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    Start-ManagedFolderAssistant -Identity $_.UserPrincipalName -FullCrawl
}

# Alternative: Trigger by ExchangeGuid
Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    Start-ManagedFolderAssistant -Identity $_.ExchangeGuid -FullCrawl
}
```

> **Note:** Without forcing the Managed Folder Assistant, the policy may take up to 7 days to apply to existing mailboxes.

---

## Reference Table

| Cmdlet | Purpose |
|--------|---------|
| `New-RetentionPolicyTag` | Define retention behavior (duration + action) |
| `New-RetentionPolicy` | Group tags into a named policy |
| `Set-Mailbox -RetentionPolicy` | Assign policy to a mailbox |
| `Start-ManagedFolderAssistant` | Force immediate processing of retention policies |
| `New-ComplianceSearch` | Create a Purview content search |
| `New-ComplianceSearchAction -Purge` | Hard/soft delete matched content |
| `Connect-IPPSSession` | Connect to Security & Compliance PowerShell |

---

## References

- [New-ComplianceSearch](https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancesearch?view=exchange-ps)
- [Search for and delete email — Purview](https://learn.microsoft.com/en-us/purview/ediscovery-search-for-and-delete-email-messages)
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps)
- [Retention Policies in Exchange Online](https://learn.microsoft.com/en-us/microsoft-365/compliance/retention-policies-exchange?view=o365-worldwide)
- [New-RetentionPolicyTag](https://learn.microsoft.com/en-us/powershell/module/exchange/new-retentionpolicytag?view=exchange-ps)
