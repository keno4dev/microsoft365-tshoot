# Enterprise Best Practices for Azure AD (Entra ID)

> **Category:** Azure Active Directory, Entra ID, AD Connect, Hybrid Identity, FSMO, ADSI Edit, Synchronization  
> **Applies to:** Azure AD / Microsoft Entra ID, Active Directory on-premises, Azure AD Connect (Entra Connect), Microsoft 365

---

## Table of Contents

1. [User Account Design Considerations](#1-user-account-design-considerations)
2. [Required Ports for Active Directory Communication](#2-required-ports-for-active-directory-communication)
3. [AD DNS Diagnostics](#3-ad-dns-diagnostics)
4. [Convert ObjectGuid ↔ ImmutableId](#4-convert-objectguid--immutableid)
5. [Soft-Match and Hard-Match — Hybrid Identity Sync](#5-soft-match-and-hard-match--hybrid-identity-sync)
   - [Clearing ImmutableId for Soft-Match](#clearing-immutableid-for-soft-match)
   - [Method 1 — Hard Match via ldifde + GUID Export](#method-1--hard-match-via-ldifde--guid-export)
   - [Method 2 — Hard Match via PowerShell (AD + MSOnline)](#method-2--hard-match-via-powershell-ad--msonline)
   - [Method 3 — Interactive Hard Match (Grid UI)](#method-3--interactive-hard-match-grid-ui)
6. [AD Connect — Uninstalling and Reinstalling](#6-ad-connect--uninstalling-and-reinstalling)
7. [Distribution Groups Not Syncing to Microsoft 365](#7-distribution-groups-not-syncing-to-microsoft-365)
8. [FSMO Role Management](#8-fsmo-role-management)
9. [Attribute Editor Missing in ADUC](#9-attribute-editor-missing-in-aduc)
10. [ADSI Edit — Editing AD Object Attributes](#10-adsi-edit--editing-ad-object-attributes)
11. [AD Connect Auto-Upgrade](#11-ad-connect-auto-upgrade)
12. [AD Connect TLS 1.2 Sync Errors](#12-ad-connect-tls-12-sync-errors)
13. [Unable to Connect to MSOL Service / Get-MsolUserRole Error](#13-unable-to-connect-to-msol-service--get-msoluserrole-error)

---

## 1. User Account Design Considerations

Before provisioning users in Azure AD at scale, establish consistent conventions and processes.

| Design Area | Recommendation |
|-------------|---------------|
| **Naming convention** | Use a consistent format (e.g., `LastName.FirstName@contoso.com`). This simplifies bulk creation by reducing unique values in the CSV. |
| **Initial passwords** | Generate random passwords and deliver them securely (e.g., via manager, secure channel). |
| **Error handling** | After a bulk create, download the **Bulk operation results** file from the Azure portal — it identifies duplicates and conflicts. Upload smaller batches to simplify troubleshooting. |
| **Licensing** | Assign licenses at creation time using group-based licensing or PowerShell bulk assignment. |
| **MFA registration** | Ensure SSPR + MFA registration prompts are configured so users self-enroll on first sign-in. |

**Reference:** [Create bulk users in Azure AD](https://learn.microsoft.com/en-us/entra/identity/users/users-bulk-add)

---

## 2. Required Ports for Active Directory Communication

Ensure these ports are open between domain controllers, AD Connect servers, and clients:

| Port | Protocol | Purpose |
|------|----------|---------|
| 53 | TCP/UDP | DNS |
| 88 | TCP/UDP | Kerberos authentication |
| 135 | TCP/UDP | RPC endpoint mapper |
| 137–138 | UDP | NetBIOS name service / datagram |
| 389 | TCP/UDP | LDAP |
| 445 | TCP | SMB (for replication, sysvol) |
| 464 | TCP/UDP | Kerberos password change |
| 636 | TCP | LDAP over SSL (LDAPS) |
| 3268 | TCP | Global Catalog |
| 3269 | TCP | Global Catalog over SSL |
| 49152–65535 | TCP | RPC dynamic ports |

**Reference:** [Active Directory and Active Directory Domain Services port requirements](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements)

---

## 3. AD DNS Diagnostics

Run a comprehensive DNS diagnostic from a domain controller:

```cmd
DCDiag /Test:DNS /e /v
```

| Flag | Meaning |
|------|---------|
| `/Test:DNS` | Run only DNS-related tests |
| `/e` | Test all domain controllers in the forest |
| `/v` | Verbose output |

---

## 4. Convert ObjectGuid ↔ ImmutableId

A user's on-premises **ObjectGuid** maps to the Azure AD **ImmutableId** (Base64-encoded). Converting between them is essential for hard-matching during hybrid identity migrations.

### Convert ObjectGuid → ImmutableId (Base64)

```powershell
# Using a known GUID string
[Convert]::ToBase64String(
    [guid]::New("f7cc07d7-7c15-447d-876d-c01b0e5a9e38").ToByteArray()
)
# Output example: 18fM9xV8fUSHbcAbDlqeOA==
```

### Convert ImmutableId (Base64) → ObjectGuid

```powershell
[Guid]([Convert]::FromBase64String("1wfM9xV8fUSHbcAbDlqeOA=="))
# Output: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

## 5. Soft-Match and Hard-Match — Hybrid Identity Sync

When migrating from cloud-only identities to hybrid (AD Connect sync), you need to **link** (match) the on-premises AD user to the existing cloud Azure AD user.

- **Soft-Match:** Azure AD automatically links accounts that share the same UPN or primary SMTP address
- **Hard-Match:** You manually set the on-premises user's ObjectGuid as the cloud user's ImmutableId

### Clearing ImmutableId for Soft-Match

If an incorrect ImmutableId is set (blocking soft-match), clear it first:

```powershell
Connect-MsolService

# Check current ImmutableId
Get-MsolUser -UserPrincipalName user@contoso.com | Select ImmutableID

# Clear the ImmutableId to allow soft-match
Set-MsolUser -UserPrincipalName user@contoso.com -ImmutableID "$null"

# Remove any stale duplicates left in Azure AD
Remove-MsolUser -RemoveFromRecycleBin -UserPrincipalName user@contoso.com
Remove-MsolUser -UserPrincipalName user@contoso.com -RemoveFromRecycleBin -Force

# Trigger a delta sync
Start-ADSyncSyncCycle -PolicyType Delta
```

---

### Method 1 — Hard Match via ldifde + GUID Export

**Use when:** You need to match many users or don't have PowerShell AD module on the DC.

```cmd
# Export ObjectGuid and UPN for all AD users to a file
ldifde -f objectguid.txt -r "(Userprincipalname=*)" -l "objectGuid, userPrincipalName"
```

1. Open `objectguid.txt` and locate the user by `userPrincipalName`
2. Copy the `objectGUID` value
3. Set that value as the ImmutableId in Azure AD:

```powershell
Connect-MsolService

# Replace the GUID-like value with the one from ldifde output
Set-MsolUser `
    -UserPrincipalName user@contoso.com `
    -ImmutableID "De7ppAsUlkup05KZVqXtUATd=="

# Trigger sync
Start-ADSyncSyncCycle -PolicyType Delta
```

> Allow **10 minutes** for the sync to complete.

---

### Method 2 — Hard Match via PowerShell (AD + MSOnline)

**Use when:** PowerShell AD module is available on the server.

```powershell
Connect-MsolService

# Variables — set these
$ADUser    = "samaccountname"          # On-prem SAM account name
$365User   = "user@contoso.com"        # Azure AD UPN

# Get the on-premises ObjectGuid and convert to ImmutableId
$Guid        = (Get-ADUser $ADUser).ObjectGuid
$ImmutableID = [System.Convert]::ToBase64String($Guid.ToByteArray())

# Set the ImmutableId on the cloud user
Set-MsolUser -UserPrincipalName $365User -ImmutableId $ImmutableID

# Trigger sync
Start-ADSyncSyncCycle -PolicyType Delta
```

---

### Method 3 — Interactive Hard Match (Grid UI)

**Use when:** Matching a set of users interactively with visual selection.

```powershell
Set-ExecutionPolicy RemoteSigned
$credential = Get-Credential

Import-Module MsOnline
Connect-MsolService -Credential $credential

# Step 1: Select the on-premises user from a grid
$ADGuidUser = Get-ADUser -Filter * |
    Select-Object Name,ObjectGUID |
    Sort-Object Name |
    Out-GridView -Title "Select On-Premises AD User" -PassThru

# Step 2: Convert GUID to ImmutableId
$UserImmutableID = [System.Convert]::ToBase64String(
    $ADGuidUser.ObjectGUID.ToByteArray()
)

# Step 3: Select the matching cloud user from a grid
$OnlineUser = Get-MsolUser |
    Select-Object UserPrincipalName,DisplayName,ProxyAddresses,ImmutableID |
    Sort-Object DisplayName |
    Out-GridView -Title "Select The Office 365 User To Link" -PassThru

# Step 4: Set the ImmutableId
Set-MsolUser `
    -UserPrincipalName $OnlineUser.UserPrincipalName `
    -ImmutableID $UserImmutableID

# Step 5: Verify the IDs match
$Office365UserQuery = Get-MsolUser -UserPrincipalName $OnlineUser.UserPrincipalName
Write-Host "AD Immutable ID Used:" $UserImmutableID
Write-Host "Office 365 User Linked:" $Office365UserQuery.ImmutableId

# Step 6: Trigger sync
Start-ADSyncSyncCycle -PolicyType Delta
Start-ADSyncSyncCycle -PolicyType Initial  # Use if delta doesn't resolve it
```

> **Last resort:** If hard-match still does not work after all methods above — **uninstall and reinstall Azure AD Connect** on the domain controller.

---

## 6. AD Connect — Uninstalling and Reinstalling

If the Azure AD Connect (Entra Connect) tool fails to uninstall or reinstall correctly, follow this full manual cleanup procedure.

### Step 1 — Uninstall in Programs and Features

Remove ALL of the following from **Control Panel → Programs and Features**:

**For Azure AD Connect:**
- Microsoft Azure Active Directory Connect Tool
- Microsoft Azure AD Sync
- Forefront Identity Manager Windows Azure Active Directory Connector
- Microsoft SQL Server 2012 Express LocalDB
- Microsoft SQL Server 2012 Native Client
- Microsoft SQL Server 2012 Command Line Utilities
- Microsoft Online Services Sign-in Assistant *(restart required)*
- Windows Azure Active Directory Module for Windows PowerShell

### Step 2 — Delete Leftover Folders

```
C:\Program Files\Microsoft Azure Active Directory Connect
C:\Program Files\Microsoft Azure AD Sync
```

### Step 3 — Delete the Scheduled Task

1. Open **Task Scheduler**
2. In **Task Scheduler Library**, right-click **Azure AD Sync Scheduler** → **Delete**

### Step 4 — Clean the Registry

Open **Registry Editor** (`regedit`) as Administrator and delete these keys (if they exist):

**For Azure AD Connect:**
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AD Sync
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Azure AD Connect
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Local DB
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSOLCoExistence
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MicrosoftAzureADConnectionTool
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ADSync
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Application\AzureActiveDirectoryDirectorySyncTool
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Tracing\AzureADConnect_RASAPI32
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Tracing\AzureADConnect_RASMANCS
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Tracing\DirectorySyncTool_RASAPI32
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Tracing\DirectorySyncTool_RASMANCS
```

### Step 5 — Reinstall

Download the latest Azure AD Connect (Entra Connect) installer from:  
**https://www.microsoft.com/en-us/download/details.aspx?id=47594**

**Reference:** [Azure AD Sync: Unable to install the Synchronization Service](https://itshi-tech.blogspot.com/2019/11/azure-ad-sync-unable-to-install.html)

---

## 7. Distribution Groups Not Syncing to Microsoft 365

### Symptom

On-premises distribution groups are not appearing in Exchange Online / Microsoft 365 after AD Connect sync.

### Root Cause

The distribution group is missing required attributes: **`mail`** and **`displayName`**.

### Resolution

1. Open **Active Directory Users and Computers**
2. Click **View → Advanced Features** to show the Attribute Editor
3. Right-click the distribution group → **Properties → Attribute Editor**
4. Set values for `mail` (e.g., `grp-marketing@contoso.com`) and `displayName` (if empty)
5. Click **Apply → OK**
6. Re-run the sync:

```powershell
# Option 1: via Azure AD Connect wizard
# Open Azure AD Connect → Customize synchronization options → re-select the OU

# Option 2: via PowerShell
Start-ADSyncSyncCycle -PolicyType Initial
```

**Reference:** [Azure AD sync — distribution groups not syncing](https://answers.microsoft.com/en-us/msoffice/forum/all/azure-active-directory-sync-does-not-sync/c31df7dd-9308-4d04-819e-3e5e63d3d00a)

---

## 8. FSMO Role Management

### Query FSMO Role Holders

```cmd
NetDom Query FSMO
```

### Check and Summarize AD Replication

```cmd
RepAdmin /ShowRepl          # Show replication status per DC
RepAdmin /ReplSummary       # Show replication summary
```

### Register Schema MMC Snap-in

```cmd
RegSvr32 Schmmgmt.dll
```

This registers the Active Directory Schema MMC snap-in, which is required to view and edit the AD schema.

### Transfer FSMO Roles (GUI)

1. Open **Active Directory Users and Computers** (or **AD Domains and Trusts** / **AD Schema** depending on the role)
2. Right-click the domain or forest root → **Operations Masters**
3. Select the role tab and click **Change**

### Transfer FSMO Roles (PowerShell)

```powershell
# Import the AD module
Import-Module ActiveDirectory

# Transfer all FSMO roles to a target DC
Move-ADDirectoryServerOperationMasterRole `
    -Identity "NewDCName" `
    -OperationMasterRole PDCEmulator,RIDMaster,InfrastructureMaster,SchemaMaster,DomainNamingMaster
```

**Reference:** [Transfer or seize FSMO roles — Windows Server](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/transfer-or-seize-fsmo-roles-in-ad-ds)

---

## 9. Attribute Editor Missing in ADUC

### Symptom

The **Attribute Editor** tab is missing in the Properties window of a user or object in **Active Directory Users and Computers (ADUC)**.

### Root Cause

The **Advanced Features** view is not enabled.

### Fix 1 — Enable Advanced Features

1. Open ADUC
2. Click **View → Advanced Features**
3. Reopen the user's Properties — the **Attribute Editor** tab will now appear

### Fix 2 — Search Context Workaround

When viewing a **search result** in ADUC, the Attribute Editor may still be hidden:
1. Search for the user
2. Click the user's **Member Of** tab → open one of the groups
3. In the group's **Members** tab, double-click the user
4. The Attribute Editor tab will now be visible

### Fix 3 — Use LDAP Custom Query

In ADUC, right-click **Saved Queries → New Query**:
1. Click **Define Query**
2. Select **Custom Search** and click the **Advanced** tab
3. Enter a query like:
   ```
   (objectcategory=person)(samaccountname=johndoe)
   ```

### Fix 4 — Use Active Directory Administrative Center

In ADAC (unlike ADUC), the **Attribute Editor is accessible after a search** without needing Advanced Features enabled.

**Reference:** [Attribute Editor tab missing in ADUC](https://learn.microsoft.com/en-us/answers/questions/562406/why-we-are-not-able-to-see-attibute-editor-in-user)

---

## 10. ADSI Edit — Editing AD Object Attributes

**ADSI Edit** (`adsiedit.msc`) is a low-level editor for Active Directory that allows direct access to object attributes, directory partitions, and service objects not exposed in standard MMC snap-ins.

### When to Use ADSI Edit

- Editing attributes not visible in ADUC
- Fixing corrupted or non-standard AD attributes
- Editing configuration and schema partitions
- Clearing stale or incorrect ImmutableId / SourceAnchor values

### How to Open

```
Win + R → adsiedit.msc → Enter
```

On first launch: **Actions → Connect to** → select **Default naming context** for user/computer objects.

### Navigation

Navigate the tree to find the user container → right-click the object → **Properties** → use the Attribute Editor.

> **⚠ Warning:** ADSI Edit writes directly to the AD database and bypasses the safety checks of standard MMC tools. **Always back up Active Directory before making changes.** Incorrect edits can corrupt AD objects or cause sync failures.

**Reference:** [Editing AD attributes with ADSI Edit](https://woshub.com/active-directory-attribute-editor/)

---

## 11. AD Connect Auto-Upgrade

Ensure Azure AD Connect stays current by enabling the **auto-upgrade** feature:

```powershell
# Enable auto-upgrade
Set-ADSyncAutoUpgrade -AutoUpgradeState Enabled

# Check current auto-upgrade state
Get-ADSyncAutoUpgrade
```

> Auto-upgrade is supported only for **express installation** configurations. Custom installations require manual upgrades.

**Reference:** [Azure AD Connect: Automatic upgrade](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-automatic-upgrade)

---

## 12. AD Connect TLS 1.2 Sync Errors

### Symptom

Azure AD Connect (Entra Connect) shows sync errors such as:
- `no-start-ma` on Delta Import
- `stopped-extension-dll-exception` on export

New users in on-premises AD are **not syncing to Microsoft 365**.

### Root Cause

TLS 1.2 is not enforced on the AD Connect server. Microsoft requires TLS 1.2 for all connections to Azure AD.

### Resolution — Verify and Enforce TLS 1.2

Use the Microsoft-provided PowerShell script to check and configure TLS 1.2:

**Reference:** [PowerShell script to check TLS 1.2 — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-tls-enforcement#powershell-script-to-check-tls-12)

Manual enforcement via registry:

```powershell
# Enable TLS 1.2 for .NET Framework (required for AD Connect)
# Set for .NET 4.x
$RegPath = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
Set-ItemProperty -Path $RegPath -Name "SchUseStrongCrypto" -Value 1 -Type DWord
Set-ItemProperty -Path $RegPath -Name "SystemDefaultTlsVersions" -Value 1 -Type DWord

# Set for .NET 4.x (WOW64)
$RegPath32 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319"
Set-ItemProperty -Path $RegPath32 -Name "SchUseStrongCrypto" -Value 1 -Type DWord
Set-ItemProperty -Path $RegPath32 -Name "SystemDefaultTlsVersions" -Value 1 -Type DWord
```

> Restart the **Microsoft Azure AD Sync** service after making these changes.

---

## 13. Unable to Connect to MSOL Service / Get-MsolUserRole Error

### Symptom

Running `Get-MsolUserRole` or other MSOnline cmdlets returns errors related to the MSOL module or PowerShell access.

### Context

Some Microsoft 365 Education tenants have **PowerShell blocked** at the policy level (School Data Sync).

**References:**
- [Blocking PowerShell for Edu — Microsoft Learn](https://learn.microsoft.com/en-us/schooldatasync/blocking-powershell-for-edu)
- [Blocking the MSOnline module](https://learn.microsoft.com/en-us/schooldatasync/blocking-powershell-for-edu#blocking-the-msol-module)

### General Fix — Reinstall the MSOnline / AzureAD Module

```powershell
# Remove and reinstall MSOnline
Uninstall-Module MSOnline -AllVersions
Install-Module MSOnline -Force
Import-Module MSOnline
Connect-MsolService
```

> **Migration note:** The MSOnline module is **deprecated**. Migrate to [Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview) for all new scripts.

---

## Key Cmdlets Reference

| Cmdlet | Purpose |
|--------|---------|
| `Start-ADSyncSyncCycle -PolicyType Delta` | Trigger an incremental sync |
| `Start-ADSyncSyncCycle -PolicyType Initial` | Trigger a full sync |
| `Set-ADSyncAutoUpgrade -AutoUpgradeState Enabled` | Enable auto-upgrade for AD Connect |
| `Get-MsolUser -UserPrincipalName` | Get a cloud user's details including ImmutableId |
| `Set-MsolUser -ImmutableID "$null"` | Clear ImmutableId to allow soft-match |
| `Set-MsolUser -ImmutableId <value>` | Set ImmutableId for hard-match |
| `Remove-MsolUser -RemoveFromRecycleBin` | Permanently delete a user from the AAD recycle bin |
| `NetDom Query FSMO` | Show FSMO role holders |
| `RepAdmin /ReplSummary` | Show AD replication summary |

**References:**
- [Azure AD Connect (Entra Connect) overview](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect)
- [Hybrid identity — hard match and soft match](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-existing-tenant)
- [Enterprise best practices for Azure AD — Netwrix Summit Part 1](https://www.netwrix.com/azure_ad_summit.html)
- [Enterprise best practices for Azure AD — Netwrix Summit Part 2](https://www.netwrix.com/azure_ad_summit_pt2.html)
- [Enterprise best practices for Azure AD — Netwrix Summit Part 3](https://www.netwrix.com/azure_ad_summit_pt3.html)
