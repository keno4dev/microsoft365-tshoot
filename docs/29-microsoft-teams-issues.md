# Microsoft Teams — Issues and Resolutions

> **Category:** Microsoft Teams, Enterprise Voice, Phone Numbers, Guest Access, File Upload, Cache, Channels, Diagnostics  
> **Applies to:** Microsoft Teams, Teams PowerShell Module, Microsoft 365 Business/Enterprise

---

## Table of Contents

1. [Enable Enterprise Voice for a User](#1-enable-enterprise-voice-for-a-user)
2. [Assign Phone Numbers (Calling Plan and Direct Routing)](#2-assign-phone-numbers-calling-plan-and-direct-routing)
3. [Unable to Add Guest User to a Private Channel](#3-unable-to-add-guest-user-to-a-private-channel)
4. [Unable to Send Attachments in Teams](#4-unable-to-send-attachments-in-teams)
5. [Clear the Teams Cache on Windows](#5-clear-the-teams-cache-on-windows)
6. [Unable to Open PowerPoint File from Teams](#6-unable-to-open-powerpoint-file-from-teams)
7. [Collect Teams Diagnostic Logs](#7-collect-teams-diagnostic-logs)
8. [Display Name Not Updated in Teams After Admin Center Change](#8-display-name-not-updated-in-teams-after-admin-center-change)
9. [Disable Channel Creation for All Teams](#9-disable-channel-creation-for-all-teams)
10. [Disable Channel Creation — Except for Owners](#10-disable-channel-creation--except-for-owners)
11. [Guest Users Unable to Join Townhall Meetings](#11-guest-users-unable-to-join-townhall-meetings)
12. [Microsoft Store Missing or Not Opening on Windows](#12-microsoft-store-missing-or-not-opening-on-windows)

---

## Prerequisites

```powershell
Set-ExecutionPolicy RemoteSigned
Install-Module MicrosoftTeams -Force -AllowClobber -Verbose
Import-Module MicrosoftTeams
Connect-MicrosoftTeams
```

---

## 1. Enable Enterprise Voice for a User

Enterprise Voice must be enabled before a user can make or receive PSTN calls through Teams Phone.

> **Note:** Enterprise Voice must be enabled for Call Queue membership to function correctly.

```powershell
# Enable Enterprise Voice for a single user
Set-CsPhoneNumberAssignment `
    -Identity "user@contoso.com" `
    -EnterpriseVoiceEnabled $true
```

**Reference:** [Enable users for Enterprise Voice — Microsoft Learn](https://www.itcapture.com/how-to/enable-users-for-enterprise-voice-online-and-phone-system-voicemail/)

---

## 2. Assign Phone Numbers (Calling Plan and Direct Routing)

### Assign a Calling Plan Number

```powershell
Set-CsPhoneNumberAssignment `
    -Identity "user@contoso.com" `
    -PhoneNumber "+12065551234" `
    -PhoneNumberType CallingPlan
```

### Assign a Direct Routing Number

```powershell
Set-CsPhoneNumberAssignment `
    -Identity "user@contoso.com" `
    -PhoneNumber "+12065559876" `
    -PhoneNumberType DirectRouting
```

### List Assigned Numbers

```powershell
Get-CsPhoneNumberAssignment | Select-Object TelephoneNumber, UserPrincipalName, NumberType
```

### Remove a Number Assignment

```powershell
Remove-CsPhoneNumberAssignment `
    -Identity "user@contoso.com" `
    -PhoneNumber "+12065551234" `
    -PhoneNumberType CallingPlan
```

**Reference:** [Set-CsPhoneNumberAssignment — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/teams/set-csphonenumberassignment)

---

## 3. Unable to Add Guest User to a Private Channel

### Root Cause

**By design** — external guest users must first be added to the **Team** before they can be explicitly added to a **Private Channel** within that team.

### Resolution

1. In the Teams client, go to the Team (not the channel) → **•••** (ellipsis) → **Add member**
2. Enter the guest's external email address and add them as a **member** of the Team
3. After they appear as a team member, go to the Private Channel → **•••** → **Add member** → find the guest

> If the guest still does not appear, ask them to sign out and back in to Teams, or wait up to 15 minutes for the membership cache to refresh.

**Reference:** [Unable to add guest user to private channel](https://answers.microsoft.com/en-us/msteams/forum/all/unable-to-add-guest-user-to-private-channel/86dcd615-67b2-4cf3-b01a-23c9006920c6)

---

## 4. Unable to Send Attachments in Teams

### Root Cause

If the organization uses **third-party content storage** (not OneDrive/SharePoint), the native Teams file upload option must be disabled via the Teams Files policy. When `NativeFileEntryPoints` is enabled (default), Teams shows OneDrive/SharePoint upload options which may be blocked.

### Resolution

```powershell
# Disable native file entry points for the Global policy
Set-CsTeamsFilesPolicy -Identity Global -NativeFileEntryPoints Disabled
```

### Check Current Policy

```powershell
Get-CsTeamsFilesPolicy | Select-Object Identity, NativeFileEntryPoints
```

**Reference:** [Turn off Teams native file upload policy — Microsoft Learn](https://learn.microsoft.com/en-us/microsoftteams/turn-off-teams-native-file-upload-policy)

---

## 5. Clear the Teams Cache on Windows

### When to Use

- Teams loads slowly or shows stale/incorrect data
- Profile pictures or names not refreshing
- Persistent UI glitches after updates

### Steps

1. Right-click the Teams icon in the taskbar → **Quit**
2. Press **Win + R** → type `%appdata%\Microsoft\Teams` → click **OK**
3. Select all files and folders in the directory → **Delete**
4. Reopen Microsoft Teams

> Teams will recreate all local cache files on the next launch. This is safe and has no impact on mailbox data or conversations.

### Via PowerShell

```powershell
# Quit Teams
Get-Process -Name "ms-teams", "Teams" -ErrorAction SilentlyContinue | Stop-Process -Force

# Clear cache
$TeamsCache = "$env:APPDATA\Microsoft\Teams"
Remove-Item -Path "$TeamsCache\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Teams cache cleared. Restart Teams to complete."
```

**Reference:** [Clear Teams cache — Microsoft Learn](https://learn.microsoft.com/en-us/microsoftteams/troubleshoot/teams-administration/clear-teams-cache)

---

## 6. Unable to Open PowerPoint File from Teams

### Root Cause

Office temp files in the local Application Data folder can prevent PowerPoint from opening files through Teams.

### Resolution

1. Close Teams and all Office applications
2. Open File Explorer and navigate to:
   ```
   C:\Users\<YourUserName>\AppData\Local\Microsoft\Office
   ```
3. Delete all files and subfolders inside the `Office` folder
4. Reopen Teams and retry opening the PowerPoint file

---

## 7. Collect Teams Diagnostic Logs

### Quick Method — Keyboard Shortcut

While the Teams desktop app is open and in focus:

```
Ctrl + Alt + Shift + 1
```

A diagnostic `.zip` log file is automatically saved to your **Downloads** folder. This log contains:
- Client version and build information
- How Teams modules load
- Recent activity and network events
- Error entries from current session

> Share this log file with Microsoft Support when reporting a client-side issue. It significantly speeds up diagnosis.

**Reference:** [Collect Teams logs — Microsoft Learn](https://learn.microsoft.com/en-us/microsoftteams/log-files)

---

## 8. Display Name Not Updated in Teams After Admin Center Change

### Symptom

A user's display name or phone number was updated in the Microsoft 365 Admin Center, but Teams still shows the old value.

### Root Cause — By Design

Teams uses an aggressive caching scheme for performance optimization:
- **User display name and telephone number:** cached up to **28 days** in the client
- **Profile photos:** cached up to **60 days**
- **Service-side cache:** up to **3 days**

### Workaround

- Clear the Teams client cache (see [Section 5](#5-clear-the-teams-cache-on-windows))
- Ask the affected user to sign out of Teams and sign back in
- Wait for the cache expiry period if no urgency

**Reference:** [User information not updated in Teams — Microsoft Learn](https://learn.microsoft.com/en-us/microsoftteams/troubleshoot/teams-administration/user-information-not-updated)

---

## 9. Disable Channel Creation for All Teams

### Check Current Channels Policy

```powershell
Get-CsTeamsChannelsPolicy | Format-Table Identity, AllowPrivateChannelCreation
```

### Set Global Policy to Block Private Channel Creation

```powershell
Set-CsTeamsChannelsPolicy -Identity Global -AllowPrivateChannelCreation $false
```

### Disable Channel Creation Across All Individual Teams

```powershell
$Teams = Get-Team

foreach ($Team in $Teams) {
    Set-Team -GroupId $Team.GroupId -AllowCreatePrivateChannels $false
    Set-Team -GroupId $Team.GroupId -AllowCreateUpdateChannels $false
    Write-Host "Disabled channel creation for: $($Team.DisplayName)"
}

Write-Host "Done — channel creation disabled for all Teams."
```

Save as `DisableChannelCreation.ps1` and run with:

```powershell
.\DisableChannelCreation.ps1
```

---

## 10. Disable Channel Creation — Except for Owners

This script selectively disables channel creation for **members** (non-owners) while leaving **owners** unaffected at the team level:

```powershell
Connect-MicrosoftTeams

Set-CsTeamsChannelsPolicy -Identity Global -AllowPrivateChannelCreation $false

$Teams = Get-Team

foreach ($Team in $Teams) {
    Write-Host "Processing: $($Team.DisplayName)"

    $Members = Get-TeamUser -GroupId $Team.GroupId

    foreach ($Member in $Members) {
        if ($Member.Role -ne "Owner") {
            Write-Host "  Limiting channels for member: $($Member.User)"
            Set-Team -GroupId $Team.GroupId -AllowCreatePrivateChannels $false
            Set-Team -GroupId $Team.GroupId -AllowCreateUpdateChannels $false
        } else {
            Write-Host "  Owner $($Member.User) — skipped"
        }
    }
}

Write-Host "Channel creation policy applied."
```

> **Note:** `Set-Team` flags like `AllowCreateUpdateChannels` apply at the **team level** — they do not differentiate per-user. Per-user granularity requires assigning a custom **TeamsChannelsPolicy** via `Grant-CsTeamsChannelsPolicy`.

---

## 11. Guest Users Unable to Join Townhall Meetings

### Root Cause

Teams **Townhall meetings** do not support cross-tenant joins for private meetings by design.

### Workarounds

1. Add the external user as an **attendee** directly in the Townhall meeting invite
2. Add the guest as a **member** to a Teams Group or Channel in the home tenant — this allows them to join via the Teams client

---

## 12. Microsoft Store Missing or Not Opening on Windows

### Fix 1 — Reset the Microsoft Store Cache

1. Press **Win + R**
2. Type `wsreset.exe` and click **OK**

A blank Command Prompt window will open (no visible output). After approximately 10 seconds it closes and the Microsoft Store opens automatically.

### Fix 2 — Reinstall the Microsoft Store App

1. Press **Win + X** → **Windows Terminal (Admin)**
2. Run:

```powershell
Get-AppXPackage *WindowsStore* -AllUsers |
    ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
```

3. Restart the computer

---

## Common Teams PowerShell Cmdlet Reference

| Cmdlet | Purpose |
|--------|---------|
| `Connect-MicrosoftTeams` | Authenticate to Teams PowerShell |
| `Get-Team` | List all teams in the tenant |
| `Get-TeamUser -GroupId` | List all members of a team |
| `Set-Team -GroupId` | Modify team-level settings |
| `Get-CsTeamsChannelsPolicy` | View channel creation policies |
| `Set-CsTeamsChannelsPolicy` | Modify channel creation policy |
| `Get-CsPhoneNumberAssignment` | List assigned phone numbers |
| `Set-CsPhoneNumberAssignment` | Assign a phone number to a user |
| `Get-CsAutoAttendant` | List Teams Auto Attendants |
| `Get-CsTenant` | Get tenant-level Teams settings |
