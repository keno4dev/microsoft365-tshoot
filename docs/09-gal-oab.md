# Global Address List (GAL) & Offline Address Book (OAB)

> **Category:** Address Lists, Directory  
> **Applies to:** Exchange Online, Exchange Server, Microsoft 365

---

## 1. Overview

The **Global Address List (GAL)** is the master directory of all email-enabled recipients in your organization. The **Offline Address Book (OAB)** is a downloaded snapshot of the GAL used by Outlook clients when they are working offline.

When new users are created, or attributes (like display names) are changed, you may need to trigger a manual update to ensure the changes reflect for all users promptly.

---

## 2. Update the Global Address List

```powershell
Get-GlobalAddressList | Update-GlobalAddressList
```

---

## 3. Update the Offline Address Book (OAB)

After updating the GAL, the OAB must also be refreshed so offline Outlook clients receive the latest data:

```powershell
Get-OfflineAddressBook | Update-OfflineAddressBook
```

---

## 4. Distribute OAB to Client Access Servers

After updating the OAB, notify the Client Access Server layer so the updated OAB is made available for client downloads:

```powershell
Get-ClientAccessServer | Update-FileDistributionService
```

---

## 5. Verify GAL Properties

```powershell
Get-GlobalAddressList -Identity "<GAL Name>" | `
    Format-List Name, RecipientFilterType, RecipientFilter, IncludedRecipients, Conditional*
```

---

## 6. Change the Display Name of a User

When a mailbox's display name needs to be updated (e.g., after a name change or onboarding correction), the change must be made and then propagated to the GAL.

### Via Exchange Admin Center (EAC)

1. Log into the [Exchange Admin Center](https://admin.exchange.microsoft.com)
2. Navigate to **Recipients** → locate the user
3. Click the user → **Account** tab → **Manage contact information**
4. Update the **Display name** field
5. Click **Save changes**

> You must be assigned the **Recipient Management** or **Global Admin** role.

### Via PowerShell

```powershell
Set-Mailbox -Identity user@contoso.com -DisplayName "New Display Name"
```

After changing the display name, force a GAL update:

```powershell
Get-GlobalAddressList | Update-GlobalAddressList
Get-OfflineAddressBook | Update-OfflineAddressBook
```

---

## 7. Show / Hide a Recipient from the GAL

```powershell
# Hide a mailbox from the GAL
Set-Mailbox -Identity user@contoso.com -HiddenFromAddressListsEnabled $true

# Show a mailbox in the GAL
Set-Mailbox -Identity user@contoso.com -HiddenFromAddressListsEnabled $false

# Hide a distribution group
Set-DistributionGroup -Identity "Finance Team" -HiddenFromAddressListsEnabled $true

# Show an M365 Unified Group
Set-UnifiedGroup -Identity "Marketing Department" -HiddenFromAddressListsEnabled $false
```

---

## 8. Force Rebuild / Resync Address Book (Exchange Online)

In Exchange Online, the GAL update process is largely automated. However, if changes are not reflecting:

```powershell
# For a specific mailbox — trigger the Managed Folder Assistant which also catalogs changes
Start-ManagedFolderAssistant -Identity "user@contoso.com"
```

For OAB-related Outlook issues, instruct the user to:

1. In Outlook: `Send/Receive → Send/Receive Groups → Download Address Book`
2. Check `Download changes since last Send/Receive`
3. Click **OK**

---

## References

- [Update-GlobalAddressList — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/update-globaladdresslist?view=exchange-ps)
- [Update-OfflineAddressBook](https://learn.microsoft.com/en-us/powershell/module/exchange/update-offlineaddressbook?view=exchange-ps)
- [Address Lists in Exchange Online](https://learn.microsoft.com/en-us/exchange/address-books/address-lists/address-lists)
