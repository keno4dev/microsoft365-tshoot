# Microsoft 365 Groups & Teams

> **Category:** M365 Groups, Microsoft Teams, Collaboration  
> **Applies to:** Microsoft 365, Teams, Exchange Online

---

## 1. Add All Users from a CSV to a Microsoft 365 Group

```powershell
Connect-MsolService

# Import members from CSV and add to a M365 Group
Import-Csv "C:\Document\users.csv" | ForEach-Object {
    Add-UnifiedGroupLinks `
        -Identity "All Company" `
        -LinkType Members `
        -Links $_.UserPrincipalName
}
```

---

## 2. Add Members from a CSV to a Specific M365 Group

```csv
# C:\Temp\GroupMembers.csv format:
Member
john.doe@contoso.com
jane.smith@contoso.com
```

```powershell
Import-CSV "C:\Temp\GroupMembers.csv" | ForEach-Object {
    Add-UnifiedGroupLinks `
        -Identity "M365 Group" `
        -LinkType Members `
        -Links $_.Member

    Write-Host -ForegroundColor Green "Added Member '$($_.Member)' to Office 365 Group"
}
```

---

## 3. Create a Teams Team from an Existing M365 Group

Once a Microsoft 365 Group is created and populated with members, you can create a **Microsoft Teams team** directly from it:

### Via Microsoft Teams Admin Center

1. Navigate to [Teams Admin Center](https://admin.teams.microsoft.com)
2. Go to **Teams → Manage Teams → Add**
3. Choose **Create from an existing Microsoft 365 group**
4. Select the group and click **Apply**

### Via PowerShell (using Microsoft Teams Module)

```powershell
Install-Module MicrosoftTeams
Connect-MicrosoftTeams

# Create a team linked to an existing M365 Group
New-Team -GroupId (Get-UnifiedGroup -Identity "All Company").ExternalDirectoryObjectId
```

---

## 4. M365 Group Not Visible in Outlook Web / Desktop

### Symptom
A Microsoft 365 Group exists but doesn't appear in the Outlook navigation pane for users.

### Diagnose

```powershell
Get-UnifiedGroup -Identity "Marketing Department" | Format-List HiddenFromAddressListsEnabled, HiddenFromExchangeClientsEnabled
```

### Resolution

```powershell
# Make group visible in address lists
Set-UnifiedGroup -Identity "Marketing Department" -HiddenFromAddressListsEnabled $false

# Make group visible in Exchange/Outlook clients
Set-UnifiedGroup -Identity "Marketing Department" -HiddenFromExchangeClientsEnabled:$false
```

> After applying changes, users may need to restart Outlook or wait up to 1 hour for the change to propagate.

---

## 5. Block / Delete Spammy Emails Org-Wide (Inbox Rules for All Users)

### Use Case
Create an inbox rule across all user mailboxes to automatically delete emails from unwanted sub-domains (e.g., `*.onmicrosoft.com` phishing attempts).

```powershell
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

foreach ($mailbox in $mailboxes) {
    New-InboxRule `
        -Mailbox $mailbox.UserPrincipalName `
        -Name "Block onmicrosoft spam" `
        -FromAddressContainsWords "onmicrosoft.com" `
        -DeleteMessage $true
}
```

> **Note:** This creates a per-user inbox rule — it is not a transport rule. Transport-level blocking should be done via Anti-Spam policies in the EAC.

---

## 6. Key PowerShell Cmdlets Summary

| Cmdlet | Purpose |
|--------|---------|
| `Add-UnifiedGroupLinks` | Add members/owners to an M365 Group |
| `Get-UnifiedGroup` | Get properties of an M365 Group |
| `Set-UnifiedGroup` | Modify properties (visibility, etc.) |
| `New-Team` | Create a Microsoft Teams team |
| `New-InboxRule` | Create inbox rules per mailbox |
| `Connect-MicrosoftTeams` | Connect to Teams PowerShell |

---

## References

- [Add-UnifiedGroupLinks — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/add-unifiedgrouplinks?view=exchange-ps)
- [Set-UnifiedGroup](https://learn.microsoft.com/en-us/powershell/module/exchange/set-unifiedgroup?view=exchange-ps)
- [Microsoft Teams PowerShell Module](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-overview)
- [Manage Microsoft 365 Groups](https://learn.microsoft.com/en-us/microsoft-365/admin/create-groups/manage-groups?view=o365-worldwide)
