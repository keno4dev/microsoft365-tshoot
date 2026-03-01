# Microsoft 365 Licensing — Issues & Resolutions

> **Category:** Licensing, License Assignment, MSOnline PowerShell, Bulk Operations  
> **Applies to:** Microsoft 365, Office 365, Exchange Online, Azure AD / Entra ID

---

## Table of Contents

1. [Office 5-Device Limit vs Mailbox Access Limit](#1-office-5-device-limit-vs-mailbox-access-limit)
2. [Bulk Remove License from Users (CSV)](#2-bulk-remove-license-from-users-csv)
3. [Bulk Assign License to Users (CSV)](#3-bulk-assign-license-to-users-csv)
4. [Remove License from All Users with a Specific SKU](#4-remove-license-from-all-users-with-a-specific-sku)
5. [Add License to All Unlicensed Users](#5-add-license-to-all-unlicensed-users)
6. [Add Specific Licensed Users to a Distribution Group](#6-add-specific-licensed-users-to-a-distribution-group)
7. [Get All Users with Their License Details](#7-get-all-users-with-their-license-details)

---

## 1. Office 5-Device Limit vs Mailbox Access Limit

### Question

> "We have an on-premises account accessed by 7–8 users simultaneously from different machines. If we move this mailbox to Office 365, will those users hit the 5-device limit? Can we assign Microsoft 365 Apps for Business to 5 users and use Office 2016 OEM for the remaining 2–3?"

### Clarification

The **5-device limit** applies to **Office app activations** (Word, Excel, Outlook desktop, etc.) — not to mailbox or email access.

| Limit Type | What It Controls | Impact |
|------------|-----------------|--------|
| Office 5-device activation limit | How many devices a single user can run Office apps on | Per-user license |
| Mailbox access | How many users/devices can connect to and read a mailbox | **No hard limit** |

### Resolution

Moving a shared mailbox to Exchange Online does **not** impose a limit on how many users can simultaneously access it via Outlook. More than 5 different users on different devices can connect to and use the mailbox in question.

```
Users can access the shared mailbox via:
  - Outlook Desktop (add shared mailbox as secondary/delegate)
  - Outlook on the Web (OWA)
  - Outlook Mobile
```

> **Note:** The 5-device limit is about *Office installation activations*, not mailbox connection counts.

**Reference:** [Microsoft 365 Apps for Business FAQ](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/microsoft-365-apps-for-business-faq)

---

## 2. Bulk Remove License from Users (CSV)

Use this when you need to remove a specific license SKU from a list of users in a CSV file.

### CSV Format

```
UserPrincipalName
user1@contoso.com
user2@contoso.com
user3@contoso.com
```

### Script

```powershell
# Step 1: Connect to MSOnline
Connect-MsolService

# Step 2: Import CSV and strip the license from each user
# Replace TENANT:SKUID with your actual AccountSkuId (e.g., cityofsunnyvale:ENTERPRISEPACK_GOV)
Import-Csv C:\temp\users.csv | ForEach-Object {
    Set-MsolUserLicense `
        -UserPrincipalName $_.UserPrincipalName `
        -RemoveLicenses "TENANT:SKUID"
}
```

> **Tip:** To find your AccountSkuId values, run `Get-MsolAccountSku`.

---

## 3. Bulk Assign License to Users (CSV)

Use this when you need to assign a specific license SKU to a list of users in a CSV file.

```powershell
# Step 1: Connect to MSOnline
Connect-MsolService

# Step 2: Import CSV and assign the license to each user
Import-Csv C:\temp\users.csv | ForEach-Object {
    Set-MsolUserLicense `
        -UserPrincipalName $_.UserPrincipalName `
        -AddLicenses "TENANT:SKUID"
}
```

---

## 4. Remove License from All Users with a Specific SKU

Use this to strip a specific license from **every user** in the tenant who currently holds that SKU.

```powershell
Connect-MsolService

# Replace TENANT:SKUID with your AccountSkuId
Get-MsolUser -All |
    Where-Object {
        $_.isLicensed -eq $true -AND
        $_.Licenses.AccountSkuId -eq "TENANT:SKUID"
    } |
    ForEach-Object {
        Set-MsolUserLicense `
            -UserPrincipalName $_.UserPrincipalName `
            -RemoveLicenses "TENANT:SKUID"
    }
```

---

## 5. Add License to All Unlicensed Users

Use this to assign a license to all users in the tenant who currently have **no license**.

```powershell
Connect-MsolService

# Replace TENANT:SKUID with your AccountSkuId
Get-MsolUser -All |
    Where-Object { $_.isLicensed -eq $false } |
    ForEach-Object {
        Set-MsolUserLicense `
            -UserPrincipalName $_.UserPrincipalName `
            -AddLicenses "TENANT:SKUID"
    }
```

---

## 6. Add Specific Licensed Users to a Distribution Group

Use this to add all users who hold a particular license to an Azure AD security or M365 group.

```powershell
Connect-MsolService
Connect-AzureAD  # or: Connect-MgGraph

# Get all users holding the target license SKU
$Users = (Get-MsolUser |
    Where-Object { ($_.Licenses).AccountSkuId -match "DEVELOPERPACK_E5" }) |
    Select-Object -ExpandProperty ObjectId

# Add each user to the group (replace the ObjectId with your group's ID)
foreach ($User in $Users) {
    Add-AzureADGroupMember `
        -ObjectId 'a41f7689-ded3-4d33-a0d4-532a077d86fd' `
        -RefObjectId $User
}
```

---

## 7. Get All Users with Their License Details

Use this to export a full list of licensed users and their license assignments for review or auditing.

```powershell
Connect-MsolService

# List all licensed users and their license objects
Get-MsolUser -All |
    Where-Object { $_.isLicensed -eq $true } |
    ForEach-Object { Get-MsolUserLicense }

# Alternatively — export to CSV
Get-MsolUser -All |
    Where-Object { $_.isLicensed -eq $true } |
    Select-Object DisplayName, UserPrincipalName, @{Name='Licenses';Expression={($_.Licenses.AccountSkuId) -join '; '}} |
    Export-Csv C:\temp\licensed-users.csv -NoTypeInformation
```

---

## Key Cmdlets Reference

| Cmdlet | Purpose |
|--------|---------|
| `Get-MsolAccountSku` | List all available license SKUs in the tenant |
| `Get-MsolUser -All` | Get all users (licensed and unlicensed) |
| `Set-MsolUserLicense -AddLicenses` | Assign a license SKU to a user |
| `Set-MsolUserLicense -RemoveLicenses` | Remove a license SKU from a user |
| `Get-MsolUserLicense` | Get license details for a user |
| `Add-AzureADGroupMember` | Add a user to an Azure AD group |

> **Note:** The MSOnline (`Connect-MsolService`) module is deprecated in favour of [Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview). For new scripts, prefer `Connect-MgGraph` and the `Microsoft.Graph` module.

**Reference:** [Assign licenses to users using PowerShell](https://learn.microsoft.com/en-us/microsoft-365/enterprise/assign-licenses-to-user-accounts-with-microsoft-365-powershell)
