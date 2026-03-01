# SharePoint Online — Administration and Troubleshooting

> **Category:** SharePoint Online, SPO PowerShell, Site Management, Storage, Root Site Swap  
> **Applies to:** SharePoint Online, Microsoft 365 Business/Enterprise, SharePoint Online Management Shell

---

## Table of Contents

1. [Essential Reference — SharePointDiary.com](#1-essential-reference--sharepointdiarycom)
2. [Connect to SharePoint Online via PowerShell](#2-connect-to-sharepoint-online-via-powershell)
3. [Change the SharePoint Tenant Domain (Rename)](#3-change-the-sharepoint-tenant-domain-rename)
4. [Change a SharePoint Site URL](#4-change-a-sharepoint-site-url)
5. [Swap (Replace) the SharePoint Root Site](#5-swap-replace-the-sharepoint-root-site)
6. [OneDrive Storage Usage Report for All Users](#6-onedrive-storage-usage-report-for-all-users)
7. [SharePoint Storage Management — Common Tasks](#7-sharepoint-storage-management--common-tasks)
8. [Common Errors and Fixes](#8-common-errors-and-fixes)

---

## 1. Essential Reference — SharePointDiary.com

[https://www.sharepointdiary.com/](https://www.sharepointdiary.com/)

This is a highly comprehensive community resource covering SharePoint Online and on-premises topics — particularly strong on PowerShell scripting for SPO administration. Bookmark it before diving into any SharePoint PowerShell work.

---

## 2. Connect to SharePoint Online via PowerShell

### Install the SharePoint Online Management Shell

**Option 1 — PowerShell Gallery (recommended):**

```powershell
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force
```

**Option 2 — MSI installer:**  
[https://www.microsoft.com/en-us/download/details.aspx?id=35588](https://www.microsoft.com/en-us/download/details.aspx?id=35588)

### Connect

```powershell
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

# Replace 'contoso' with your tenant name
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"
```

> **Note:** Use the **admin** URL (`-admin.sharepoint.com`), not the standard URL.

### Verify Connection

```powershell
Get-SPOTenant | Select-Object SharingCapability, StorageQuota, StorageQuotaAllocated
```

**Reference:** [Connect-SPOService — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/connect-sposervice)

---

## 3. Change the SharePoint Tenant Domain (Rename)

When an organization rebrands or changes its Microsoft 365 tenant name, the SharePoint and OneDrive URLs change accordingly.

> **⚠ Warning — High Impact Operation:**  
> Tenant rename changes all SharePoint site URLs and all OneDrive URLs across the organization. Users with bookmarks, embedded links, synced OneDrive folders, and Teams file links will be affected. Plan carefully, communicate to all users, and schedule a maintenance window.

### Check Eligibility

```powershell
Get-SPOTenant | Select-Object TenantId, InitialDomain
```

Renames are not available for:
- Tenants with **active eDiscovery holds**
- Tenants enrolled in **multi-geo**
- Tenants that have renamed within the past **90 days**

### Perform the Rename

```powershell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

Start-SPOTenantRename `
    -DomainName "newcontoso" `
    -ScheduledDateTime "2026-04-01T02:00:00"
```

| Parameter | Description |
|-----------|-------------|
| `-DomainName` | New tenant name (just the prefix, without `.onmicrosoft.com`) |
| `-ScheduledDateTime` | UTC datetime for when the rename should execute (minimum 24 hours from now) |

### Check Rename Status

```powershell
Get-SPOTenantRenameStatus
```

**Reference:** [Rename a SharePoint domain — Microsoft Learn](https://learn.microsoft.com/en-us/sharepoint/tenant-rename)

---

## 4. Change a SharePoint Site URL

To rename an individual site collection (not the whole tenant):

```powershell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

# Get the current site
Get-SPOSite -Identity "https://contoso.sharepoint.com/sites/OldSiteName"

# Rename the site URL
Start-SPOSiteRename `
    -Identity "https://contoso.sharepoint.com/sites/OldSiteName" `
    -NewSiteUrl "https://contoso.sharepoint.com/sites/NewSiteName"
```

> Changes to site URLs break existing bookmarks, direct links, and embedded references. Notify affected users before making changes.

**Reference:** [Change a site address — Microsoft Learn](https://learn.microsoft.com/en-us/sharepoint/change-site-address)

---

## 5. Swap (Replace) the SharePoint Root Site

Organizations may need to replace the **root SharePoint site** (`https://contoso.sharepoint.com`) with a modern communication site (e.g., a new intranet). Use `Invoke-SPOSiteSwap` to archive the current root and promote the new site.

```powershell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

# Define URLs
$AdminCenter = "https://contoso-admin.sharepoint.com"
$NewIntranet  = "https://contoso.sharepoint.com/sites/NewIntranet"  # New site to promote to root
$CurrentRoot  = "https://contoso.sharepoint.com/"                    # Existing root (will be archived)
$ArchiveUrl   = "https://contoso.sharepoint.com/sites/OldRoot-archive"  # Where the old root goes

Invoke-SPOSiteSwap `
    -SourceUrl  $NewIntranet `
    -TargetUrl  $CurrentRoot `
    -ArchiveUrl $ArchiveUrl
```

| Parameter | Role |
|-----------|------|
| `-SourceUrl` | The new site you want to become the root |
| `-TargetUrl` | The current root site (will be archived) |
| `-ArchiveUrl` | A new URL where the old root is moved to |

> The swap is **not instantaneous** — it can take several hours for large sites. The archive site retains all content and permissions.

**References:**
- [Invoke-SPOSiteSwap — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/invoke-spositeswap)
- [SharePoint root site change to modern — SharePointDiary.com](https://www.sharepointdiary.com/2019/08/sharepoint-online-change-root-site-to-modern.html)

---

## 6. OneDrive Storage Usage Report for All Users

Use the SharePoint Online PowerShell module to report on all personal OneDrive sites:

### Method 1 — Basic Report

```powershell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

$Sites = Get-SPOSite `
    -IncludePersonalSite $true `
    -Limit All `
    -Filter "Url -like '-my.sharepoint.com/personal/'"

$SiteInfoArray = @()

foreach ($Site in $Sites) {
    $Details = Get-SPOSite -Identity $Site.Url |
        Select-Object URL, Owner, StorageQuota, StorageUsageCurrent, LastContentModifiedDate
    $SiteInfoArray += $Details
}

$SiteInfoArray | Export-Csv -Path "C:\Reports\OneDriveStorage.csv" -NoTypeInformation
Write-Host "Report exported to C:\Reports\OneDriveStorage.csv"
```

### Method 2 — Streamlined with Pipeline

```powershell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

$Report = Get-SPOSite `
    -IncludePersonalSite $true `
    -Limit All `
    -Filter "Url -like '-my.sharepoint.com/personal/'" |
    ForEach-Object { Get-SPOSite -Identity $_.Url } |
    Select-Object URL, Owner, StorageQuota, StorageUsageCurrent, LastContentModifiedDate

$Report | Export-Csv -Path "C:\Reports\OneDriveStorage.csv" -NoTypeInformation
Write-Host "Site information exported to C:\Reports\OneDriveStorage.csv"
```

> **StorageQuota** is in MB. **StorageUsageCurrent** is the current usage in MB.

**Reference:** [Get-SPOSite — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/get-sposite)

---

## 7. SharePoint Storage Management — Common Tasks

### View Tenant Storage Quota

```powershell
Get-SPOTenant | Select-Object StorageQuota, StorageQuotaAllocated
# StorageQuota = total pooled storage in MB
# StorageQuotaAllocated = storage explicitly assigned to sites
```

### Set Storage Quota for a Specific Site

```powershell
Set-SPOSite -Identity "https://contoso.sharepoint.com/sites/MySite" `
    -StorageQuota 10240 `        # 10 GB in MB
    -StorageQuotaWarningLevel 9216  # Warn at 9 GB
```

### List All Sites Over a Storage Threshold

```powershell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

$ThresholdGB = 5
$ThresholdMB = $ThresholdGB * 1024

Get-SPOSite -Limit All |
    Where-Object { $_.StorageUsageCurrent -gt $ThresholdMB } |
    Select-Object Title, Url, StorageUsageCurrent |
    Sort-Object StorageUsageCurrent -Descending
```

---

## 8. Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Connect-SPOService: Access denied` | Account is not a SharePoint Administrator | Assign the **SharePoint Administrator** role in M365 Admin Center → Active users → Roles |
| `Get-SPOSite: The site is locked` | Site is read-only or locked by admin | `Set-SPOSite -LockState Unlock -Identity <url>` |
| `Invoke-SPOSiteSwap: Source and target sites must both be modern` | Classic site in the swap path | Modernize the classic site first using the SharePoint modernization scanner |
| `Start-SPOTenantRename: DomainName already exists` | Requested domain is taken | Choose a different tenant name |
| `You do not have permission to run this cmdlet` | Missing admin roles | Ensure Global Admin or SharePoint Admin role is assigned |
| Site not appearing in `Get-SPOSite` | New site provisioning in progress | Wait 5–10 minutes and retry; new sites take time to appear in the admin API |

---

## Common SPO Cmdlet Reference

| Cmdlet | Purpose |
|--------|---------|
| `Connect-SPOService` | Connect to the SPO Admin Center |
| `Get-SPOTenant` | View tenant-wide SPO settings |
| `Get-SPOSite` | List and inspect site collections |
| `Set-SPOSite` | Modify site settings (storage, permissions, lock state) |
| `New-SPOSite` | Create a classic site collection |
| `Remove-SPOSite` | Delete a site (moves to recycle bin) |
| `Restore-SPODeletedSite` | Recover a deleted site from recycle bin |
| `Start-SPOSiteRename` | Rename a site's URL |
| `Start-SPOTenantRename` | Rename the entire SPO tenant domain |
| `Invoke-SPOSiteSwap` | Swap a site into the root URL |
| `Get-SPOUser` | List users with access to a site |
| `Set-SPOUser` | Modify user properties on a site |
