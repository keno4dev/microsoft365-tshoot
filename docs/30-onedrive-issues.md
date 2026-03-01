# OneDrive — Issues and Resolutions

> **Category:** OneDrive, Sync Client, Windows, Storage, Logs  
> **Applies to:** OneDrive on Windows 10/11, Microsoft 365 Business/Personal/Enterprise

---

## Table of Contents

1. [Unable to Set Up OneDrive on Windows Desktop](#1-unable-to-set-up-onedrive-on-windows-desktop)
2. [Full OneDrive Reinstall Procedure](#2-full-onedrive-reinstall-procedure)
3. [How to Collect OneDrive Sync Logs](#3-how-to-collect-onedrive-sync-logs)
4. [OneDrive Sync — Common Errors and Fixes](#4-onedrive-sync--common-errors-and-fixes)
5. [OneDrive Storage — View and Manage Quota](#5-onedrive-storage--view-and-manage-quota)
6. [OneDrive Known Folder Move (Desktop, Documents, Pictures)](#6-onedrive-known-folder-move-desktop-documents-pictures)

---

## 1. Unable to Set Up OneDrive on Windows Desktop

### Quick Reset (Try First)

1. Press **Win + R**
2. Paste the command below and press **Enter**:

```
%localappdata%\Microsoft\OneDrive\onedrive.exe /reset
```

3. Wait 1–2 minutes, then launch OneDrive from the Start menu

> If the OneDrive icon does not reappear after 2 minutes, run OneDrive manually:
> ```
> Win + R → %localappdata%\Microsoft\OneDrive\onedrive.exe → Enter
> ```

---

## 2. Full OneDrive Reinstall Procedure

If the reset does not resolve the issue, perform a **clean uninstall and reinstall**:

### Step 1 — Terminate OneDrive

Open **Command Prompt as Administrator** (Start → CMD → Right-click → Run as administrator):

```cmd
taskkill /f /im OneDrive.exe
```

### Step 2 — Uninstall OneDrive

For **64-bit Windows 10/11:**

```cmd
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
```

For **32-bit Windows 10:**

```cmd
%SystemRoot%\System32\OneDriveSetup.exe /uninstall
```

### Step 3 — Remove OneDrive Registry Key

1. Open **Registry Editor** (`Win + R → regedit`)
2. Navigate to:
   ```
   HKEY_CURRENT_USER\Software\Microsoft\OneDrive
   ```
3. Right-click the `OneDrive` key → **Delete**

### Step 4 — Delete OneDrive Folders

Open **File Explorer** and navigate to the user's profile directory:

```
C:\Users\<WindowsUsername>
```

Delete the following folders if present:
- `OneDrive` (or `OneDrive - CompanyName`)
- `SharePoint` (or `CompanyName`) — SharePoint-sync folder

> Move any files you want to keep out of these folders **before** deleting them. This does not delete files from the cloud — only the local sync copy.

### Step 5 — Reinstall OneDrive

Download the latest OneDrive installer:

**Official installer:** [https://go.microsoft.com/fwlink/?linkid=860984](https://go.microsoft.com/fwlink/?linkid=860984)

Run the installer and sign in. When prompted to choose the OneDrive sync folder:

> **⚠ Do not click "Use this folder" on the default path.**  
> Click **Change location** and select a different folder (e.g., `C:\OneDrive_Sync`). Using the original folder path after a reinstall can cause sync conflicts.

### Step 6 — Run Disk Check

After reinstalling, run a file system integrity check:

Open **Command Prompt as Administrator**:

```cmd
chkdsk C: /f
```

Restart the PC when prompted. After restart, use the **Sync** option from OneDrive in the browser to trigger a fresh sync.

**Reference:** [OneDrive reset and reinstall — Microsoft Learn](https://support.microsoft.com/en-us/office/fix-onedrive-sync-problems-0899b115-05f7-45ec-95b2-e4cc8c4670b2)

---

## 3. How to Collect OneDrive Sync Logs

OneDrive logs are essential for diagnosing sync failures, authentication errors, and performance issues.

### Method — Run CollectSyncLogs.bat

**If OneDrive was installed for all users (machine-wide):**

```
C:\Program Files (x86)\Microsoft OneDrive\<VersionNumber>\CollectSyncLogs.bat
```

**If OneDrive was installed for the current user only:**

```
%localappdata%\Microsoft\OneDrive\<VersionNumber>\CollectSyncLogs.bat
```

> Replace `<VersionNumber>` with the highest version number folder found in that path.

### Run from PowerShell

```powershell
# Machine-wide installation
$Path = "C:\Program Files (x86)\Microsoft OneDrive"
$LatestVersion = Get-ChildItem $Path -Directory | Sort-Object Name -Descending | Select-Object -First 1
& "$($LatestVersion.FullName)\CollectSyncLogs.bat"
```

### Log Output Location

```
%localappdata%\Microsoft\OneDrive\logs
```

> Share the contents of this folder with Microsoft Support when logging a OneDrive sync issue.

---

## 4. OneDrive Sync — Common Errors and Fixes

| Error / Symptom | Likely Cause | Fix |
|-----------------|-------------|-----|
| OneDrive won't start after Windows update | Corrupted sync state | Run `onedrive.exe /reset` |
| "Can't sync this folder" / red X | File path too long (>260 chars) or invalid characters | Rename files/folders to remove special chars; enable Long Path Support in Group Policy |
| Sync paused — storage full | OneDrive quota exceeded | Free up space or upgrade storage at [onedrive.live.com](https://onedrive.live.com) |
| Files stuck uploading (spinning icon) | Locked files (open in Office) | Close Office apps; let sync complete |
| "You don't have permission to access this folder" | SharePoint permission issue | Check site permissions in SharePoint Admin Center |
| OneDrive keeps asking for sign-in | Conditional Access or MFA blocking the sync client | Add OneDrive to the trusted apps list in Conditional Access or exclude the sync client |
| Files on local machine not appearing online | Sync not running | Right-click OneDrive tray icon → Settings → ensure sync is not paused |

### Enable Long Path Support (Windows 10/11)

```powershell
# Enable NTFS long paths (requires reboot)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" -Value 1 -Type DWord
```

**Reference:** [Fix OneDrive sync problems — Microsoft Support](https://support.microsoft.com/en-us/office/fix-onedrive-sync-problems-0899b115-05f7-45ec-95b2-e4cc8c4670b2)

---

## 5. OneDrive Storage — View and Manage Quota

### Check Storage Usage from Browser

1. Sign in to [https://onedrive.live.com](https://onedrive.live.com) or [https://office.com](https://office.com)
2. Click the **Settings** gear (top-right) → **OneDrive settings** → **More settings** → **Storage metrics**

### PowerShell — Bulk OneDrive Storage Report (Admin)

```powershell
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

# Get all personal OneDrive sites with storage usage
$Sites = Get-SPOSite -IncludePersonalSite $true -Limit All `
    -Filter "Url -like '-my.sharepoint.com/personal/'"

$Report = foreach ($Site in $Sites) {
    Get-SPOSite -Identity $Site.Url |
        Select-Object URL, Owner, StorageQuota, StorageUsageCurrent, LastContentModifiedDate
}

$Report | Export-Csv -Path "C:\Reports\OneDriveStorage.csv" -NoTypeInformation
Write-Host "Report exported: C:\Reports\OneDriveStorage.csv"
```

**Reference:** [Get-SPOSite — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/get-sposite)

---

## 6. OneDrive Known Folder Move (Desktop, Documents, Pictures)

**Known Folder Move (KFM)** redirects Windows known folders (Desktop, Documents, Pictures) to OneDrive — effectively backing them up to the cloud automatically.

### Enable via Group Policy

`Computer Configuration → Administrative Templates → OneDrive`  
→ **Silently move Windows known folders to OneDrive**  
→ Set to **Enabled** and enter your Tenant ID

### Enable via Registry

```powershell
$TenantId = "your-tenant-id-here"

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }

Set-ItemProperty -Path $RegPath -Name "KFMSilentOptIn" -Value $TenantId -Type String
```

### Check KFM Status for a User

```powershell
Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1" |
    Select-Object UserFolder, UserName, ServiceEndpointUri
```

**Reference:** [Redirect and move Windows known folders to OneDrive](https://learn.microsoft.com/en-us/sharepoint/redirect-known-folders)
