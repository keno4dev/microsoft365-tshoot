# Outlook Issues & Resolutions

> **Category:** Outlook Desktop, OWA, Outlook Mobile, Outlook on Mac, Authentication, Profile Issues  
> **Applies to:** Outlook for Windows, Outlook for Mac, Outlook on the Web (OWA), Microsoft 365

---

## Table of Contents

1. [Emails Are Very Slow to Open / Outlook Hangs](#1-emails-are-very-slow-to-open--outlook-hangs)
2. [Unable to Delete Emails — Recoverable Items Full](#2-unable-to-delete-emails--recoverable-items-full)
3. [EAC / OWA Shows 500 Unexpected Error](#3-eac--owa-shows-500-unexpected-error)
4. [Encryption Button Missing in OWA](#4-encryption-button-missing-in-owa)
5. [Outlook Not Showing New Emails (Desktop Only)](#5-outlook-not-showing-new-emails-desktop-only)
6. [Outlook Connectivity Test Failing — ADAL / WAM Registry Fix](#6-outlook-connectivity-test-failing--adal--wam-registry-fix)
7. [Common Outlook Repair Commands](#7-common-outlook-repair-commands)
8. [Unable to Manage Delegates in Outlook Desktop](#8-unable-to-manage-delegates-in-outlook-desktop)
9. [Outlook Azure Token Errors — Event ID 1098](#9-outlook-azure-token-errors--event-id-1098)
10. [Outlook Auto-Creates Contacts (100,000+)](#10-outlook-auto-creates-contacts-100000)
11. [Adding a Shared Mailbox in Outlook on Mac](#11-adding-a-shared-mailbox-in-outlook-on-mac)
12. [Room Mailbox Delay in Sending Booking Confirmations](#12-room-mailbox-delay-in-sending-booking-confirmations)
13. [Save Emails as .EML via Registry](#13-save-emails-as-eml-via-registry)
14. [Outlook Prompting for Password / Auth Errors](#14-outlook-prompting-for-password--auth-errors)
15. [Outlook Disconnected — Registry Profile Reset](#15-outlook-disconnected--registry-profile-reset)
16. [Sent Emails Save to Shared Mailbox Sent Items (Not User's)](#16-sent-emails-save-to-shared-mailbox-sent-items-not-users)
17. [Desktop Outlook Cannot Encrypt — OWA Works Fine](#17-desktop-outlook-cannot-encrypt--owa-works-fine)
18. [Email Recall Shows as Pending](#18-email-recall-shows-as-pending)
19. [Encrypted Emails Not Opening (Outlook 2019)](#19-encrypted-emails-not-opening-outlook-2019)
20. [Outlook "No Network Connection" (Error 2603)](#20-outlook-no-network-connection-error-2603)
21. [Outlook Cannot Print Emails](#21-outlook-cannot-print-emails)
22. [Outlook Bookings App Not Working](#22-outlook-bookings-app-not-working)

---

## 1. Emails Are Very Slow to Open / Outlook Hangs

### Symptom

Specific emails cause Outlook to hang for a long time when opening them. This occurs company-wide, suggesting cache corruption.

### Resolution — Clear the Outlook Cache

1. Save any open work and **close Outlook**
2. Press **Windows key + R**
3. Enter `%localappdata%\Microsoft\Outlook` and press **Enter**
4. Double-click the **RoamCache** folder
5. Press **Ctrl+A** to select all files, then press **Delete**
6. Reopen Outlook

Also try running Outlook in Safe Mode:
```
outlook.exe /safe
```

**Reference:** [How to Clear the Outlook Cache — lifewire.com](https://www.lifewire.com/how-to-clear-cache-in-outlook-4767454)

---

## 2. Unable to Delete Emails — Recoverable Items Full

### Symptom

A user is unable to delete emails. The Recoverable Items folder size is abnormally large (e.g., 30 GB).

### Resolution

```powershell
Connect-ExchangeOnline

# Re-enable ELC processing at org and user level
Set-OrganizationConfig -ElcProcessingDisabled $false
Set-Mailbox -Identity user@contoso.com -ElcProcessingDisabled $false

# Run Managed Folder Assistant to process hold cleanup and full crawl
Start-ManagedFolderAssistant -Identity user@contoso.com -HoldCleanup
Start-ManagedFolderAssistant -Identity user@contoso.com -FullCrawl
```

See also: [docs/15-mailbox-archive-issues.md](15-mailbox-archive-issues.md) for full Recoverable Items resolution steps.

---

## 3. EAC / OWA Shows 500 Unexpected Error

### Symptom

```
Outlook 500 Unexpected Error :(
An error occurred and your request couldn't be completed. Please try again.
```

### Common Cause

A **Microsoft 365 Service Incident** (SI) affecting Exchange Online for some tenants.

### Steps to Confirm

1. Navigate to **Microsoft 365 Admin Center → Health → Service health**
2. Look for any active incidents on **Exchange Online**
3. If a service incident is confirmed, the resolution is handled by Microsoft — monitor the SI for updates

> If no SI is active, try creating a new Global Admin test account and confirming whether the issue persists.

---

## 4. Encryption Button Missing in OWA

### Symptom

The **Encrypt** button or **Protect** option is missing in Outlook on the Web (OWA).

### Resolution

The tenant may be on **Targeted Release**, which causes feature rollout inconsistency.

1. Go to **Microsoft 365 Admin Center → Settings → Org Settings → Organization Profile → Release Preferences**
2. Switch to **Standard release**
3. Allow **1–2 hours** for the change to take effect

**Direct link:**
```
https://admin.microsoft.com/AdminPortal/Home#/Settings/OrganizationProfile/:/Settings/L1/ReleasePreferences
```

Also ensure IRM is configured. See [docs/13-email-encryption.md](13-email-encryption.md) for full IRM setup.

---

## 5. Outlook Not Showing New Emails (Desktop Only)

### Symptom

A user's Outlook desktop does not show new incoming emails unless the account is manually taken offline and brought back online. Mobile and OWA work fine.

### Resolution — Disable Cached Exchange Mode

1. Go to **File → Account Settings → Account Settings**
2. Double-click the affected mailbox
3. **Uncheck:** `Use Cached Exchange Mode to download email to an Outlook data file`
4. Click **Next → Finish**
5. Restart Outlook

Outlook should now show the connection status as: **Online with: Microsoft Exchange**

---

## 6. Outlook Connectivity Test Failing — ADAL / WAM Registry Fix

### Symptom

- Connectivity test fails
- Outlook fails to open or authenticate
- Profile creation fails

### Resolution — Add Registry Keys

Open **Registry Editor** (`regedit`) and create the following DWORD (32-bit) values under:

```
HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Identity
```

| Value Name | Type | Data |
|------------|------|------|
| `DisableAADWAM` | DWORD (32-bit) | `1` |
| `DisableADALatopWAMOverride` | DWORD (32-bit) | `1` |
| `EnableADAL` | DWORD (32-bit) | `1` |

Restart the machine after setting the values.

**Registry file format (for import):**

```
[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Identity]
"DisableADALatopWAMOverride"=dword:00000001
"DisableAADWAM"=dword:00000001
"EnableADAL"=dword:00000001
```

---

## 7. Common Outlook Repair Commands

Run these from the **Run** dialog (`Windows + R`) or a command prompt:

| Command | Purpose |
|---------|---------|
| `outlook.exe /safe` | Launch Outlook in Safe Mode (no add-ins) |
| `outlook.exe /resetnavpane` | Reset the Navigation Pane layout |
| `outlook.exe /cleanviews` | Reset custom views to defaults |
| `outlook.exe /cleanrules` | Delete all Outlook rules (client and server) |
| `outlook.exe /manageprofile` | Open the Outlook profile manager |
| `outlook.exe /cleanreminders` | Clear all reminders and recreate |
| `outlook.exe /ResetFolders` | Re-create missing default folders |

**Open Outlook AppData folder:**
```
%USERPROFILE%\AppData\Roaming
```

**Reference:** [Top ways to fix Outlook not opening on Windows 11](https://www.guidingtech.com/top-ways-to-fix-outlook-not-opening-on-windows-11/)

---

## 8. Unable to Manage Delegates in Outlook Desktop

### Symptom

Opening **File → Account Settings → Delegate Access** in Outlook Desktop returns:

> "The Delegates page is not available. Cannot access Outlook folder."

`Remove-MailboxFolderPermission -ResetDelegateUserCollection` and OWA delegate removal have already been attempted without success.

### Root Cause

The user's own mailbox has `FullAccess` permission granted to themselves — causing the Delegates page to fail.

### Resolution

```powershell
# Remove the incorrect self-permission
Remove-MailboxPermission -Identity user@contoso.com `
    -User user@contoso.com `
    -AccessRights FullAccess `
    -Confirm:$false

# Then run Outlook in Safe Mode and clear rules
# Windows+R → outlook.exe /safe
# Windows+R → outlook.exe /CleanRules
```

---

## 9. Outlook Azure Token Errors — Event ID 1098

### Symptom

- Users repeatedly prompted to sign in
- Event ID **1098** in Windows Event Viewer
- Cannot create new Outlook profiles

### References

- [Event 1098 and can't create new profiles — Outlook | Microsoft Docs](https://learn.microsoft.com/en-us/outlook/troubleshoot/authentication/event-1098-azure-token-errors)
- [Error 0xCAA5001C Token broker operation failed — Windows Client | Microsoft Docs](https://learn.microsoft.com/en-us/windows/client-management/mdm/certificate-authentication-device-enrollment)

---

## 10. Outlook Auto-Creates Contacts (100,000+)

### Symptom

A freshly created account has 100,000+ contacts in both desktop Outlook and OWA. Deleting the contacts or the folder does not help — they are automatically recreated.

### Root Cause

A corrupted Azure AD sync object linked to the account is re-creating contacts on every synchronization cycle.

### Temporary Fix — AD Object Remediation

1. Move the affected user to a **non-syncing OU** in Active Directory
2. Run a **Delta Sync**: `Start-ADSyncSyncCycle -PolicyType Delta`
3. Permanently delete the user from Azure AD
4. Run another Delta Sync — the user reappears fresh in Azure AD

### Permanent Fix — MFCMAPI Tool

Use **MFCMAPI** to permanently delete the contacts and folder:

1. Download from GitHub: [MFCMAPI Releases](https://github.com/stephenegriffin/mfcmapi/releases/tag/22.0.22216.01) (use x64 version)
2. **Open Outlook first**, then launch MFCMAPI
3. Go to **Session → Logon** → select the Outlook profile → click **OK**
4. Navigate: **Root - Mailbox → IPM_SUBTREE → Contacts**
5. Press **Ctrl+A** to select all contacts
6. Right-click → **Permanent delete** → click **OK**

> To list MFCMAPI public folders contacts, navigate to **MFCMAPIFolders → Contacts**.

---

## 11. Adding a Shared Mailbox in Outlook on Mac

### Method 1 — Delegation UI

1. Launch Outlook → click **Tools** → **Accounts**
2. Select your account → click **Delegation and Sharing**
3. Click the **Shared with Me** tab
4. Click the **+** (plus) button
5. Search for the shared mailbox name → click **Add**
6. Close the Accounts window

### Method 2 — Delegates Advanced

1. Open Outlook → **Tools** → **Accounts**
2. Click **Advanced** at the bottom
3. Click **Delegates** → click **+**
4. Type the shared mailbox name → click **Add**
5. Click **OK** → close Accounts

> The shared mailbox appears in the Outlook navigation pane after a short sync delay (may take several minutes).

---

## 12. Room Mailbox Delay in Sending Booking Confirmations

### Symptom

A room mailbox does not automatically accept or send confirmations for booking requests, particularly when the invitation comes through a third-party mail service (inbound connector).

### Root Cause

The room mailbox treats the invitation as an **external message** (because it's relayed through a third-party) and doesn't auto-process it.

### Resolution — Method 1: Allow External Meeting Requests

```powershell
Set-CalendarProcessing -Identity "RoomMailboxName" `
    -ProcessExternalMeetingMessages $True
```

> **Risk:** Minimal — external users would need to know the room's email address to send invitations.

### Resolution — Method 2: Treat Connector Messages as Internal

```powershell
Set-InboundConnector `
    -Identity "InboundConnectorName" `
    -TreatMessagesAsInternal $True
```

> **Risk:** Higher — internal messages bypass antispam filtering. Only use this if the inbound connector exclusively routes internal messages. The connector's `ConnectorType` must be `OnPremises`.

---

## 13. Save Emails as .EML via Registry

By default, Outlook saves emails in `.msg` format. To change this to `.eml`:

1. Press **Windows + R** → type `regedit` → press **Enter**
2. Navigate to:
   ```
   HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Options\Mail
   ```
   *(Replace `16.0` with your Outlook version if different)*
3. Right-click the right pane → **New → DWORD (32-bit) Value**
4. Name it `SaveAsEML`
5. Double-click it → set the value to `1`
6. Click **OK** → close Registry Editor

> **Warning:** Always back up the registry before making changes.

---

## 14. Outlook Prompting for Password / Auth Errors

### Resolution

1. Open **Control Panel → Credential Manager**
2. Under **Windows Credentials**, remove all Microsoft or Office 365 entries
3. Navigate to `C:\Users\<username>\AppData\Local\Microsoft`
4. Cut (move) the **OneAuth** and **IdentityCache** folders out to another location (e.g., Desktop as backup)
5. Optionally create a new Outlook profile:
   `File → Account Settings → Manage Profile` or run `outlook.exe /manageprofiles`
6. Reopen Outlook and sign in fresh

---

## 15. Outlook Disconnected — Registry Profile Reset

### Symptom

Outlook shows **Disconnected** and creating a new profile doesn't fix it.

### Resolution — Rename the Office Registry Key

1. Press **Windows + R** → type `regedit`
2. Navigate to:
   ```
   HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\
   ```
3. Right-click the **Office** key → **Rename** → change it to `Office.old`
4. Restart the computer

Outlook will recreate the Office registry keys fresh on next launch, resolving the disconnected state.

---

## 16. Sent Emails Save to Shared Mailbox Sent Items (Not User's)

### Symptom

When a user sends from a shared mailbox, the sent email appears in the user's own **Sent Items** rather than the shared mailbox's **Sent Items**.

### Resolution

```powershell
Connect-ExchangeOnline

# For emails sent AS the shared mailbox
Set-Mailbox <SharedMailboxName> -MessageCopyForSentAsEnabled $True

# For emails sent ON BEHALF OF the shared mailbox
Set-Mailbox <SharedMailboxName> -MessageCopyForSendOnBehalfEnabled $True

# Enable both at once
Set-Mailbox <SharedMailboxName> `
    -MessageCopyForSendOnBehalfEnabled $true `
    -MessageCopyForSentAsEnabled $true
```

---

## 17. Desktop Outlook Cannot Encrypt — OWA Works Fine

See [docs/13-email-encryption.md — Section 5](13-email-encryption.md#5-desktop-outlook-cannot-encrypt--owa-works-fine) for the full resolution.

**Quick fix:**

```powershell
Connect-AIPService
Get-AipServiceOnboardingControlPolicy
Set-AipServiceOnboardingControlPolicy -UseRmsUserLicense $False -Scope All
```

Allow time to propagate, then restart the user's computer and retest.

---

## 18. Email Recall Shows as Pending

### Symptom

The cloud-based message recall feature shows the status as **Pending** indefinitely.

### Root Cause

The tenant has **Barracuda** or another third-party security filter configured. When messages are routed through a third-party first, cloud-based recall cannot track the message and will report **invalid information** or remain **Pending**.

> Message recall only works **within the tenant** when no third-party services are involved in mail routing.

### Resolution

1. Check for third-party connectors in Exchange Admin Center → **Mail flow → Connectors**
2. Request an **extended message trace** for the recalled message — confirm whether it was routed through the third party
3. Inform the customer: recall cannot function when Barracuda or similar tools intercept outbound mail

**Key takeaway:** Always check mail flow when investigating recall issues — watch for third-party connector involvement.

**Reference:** [Work with Cloud-based Message Recall — Microsoft Learn](https://learn.microsoft.com/en-us/exchange/recipients-in-exchange-online/recall-messages)

---

## 19. Encrypted Emails Not Opening (Outlook 2019)

### Symptom

External encrypted emails fail to open with:
> "Sorry, but we are having trouble signing you in."

### Resolution

Install the **Microsoft Azure Information Protection** client:
```
https://www.microsoft.com/en-us/download/details.aspx?id=53018
```

See [docs/13-email-encryption.md — Section 3](13-email-encryption.md#3-encrypted-emails-from-outside-org-not-opening-in-outlook-2019) for full details.

---

## 20. Outlook "No Network Connection" (Error 2603)

### Symptom

Outlook displays error **2603 — No Network Connection**. Network reset and `ipconfig /flushdns` do not resolve it.

### Resolution

Reset Internet Explorer / WinInet settings:

1. Press **Windows + R**
2. Type `RunDll32.exe InetCpl.cpl,ResetIEtoDefaults`
3. Press **Enter** and apply the reset

This fixes corrupted WinInet settings that Outlook relies on for connectivity.

---

## 21. Outlook Cannot Print Emails

### Symptom

Sending an email thread to the printer from Outlook fails.

### Resolution — Method 1: Save and Reopen

1. Double-click the email to open it in a new window
2. Go to **File → Save As** → save as **Outlook Message Format - Unicode** (default)
3. Navigate to the saved file in **File Explorer**
4. Double-click to open → go to **File → Print**

### Resolution — Method 2: Save as HTML

1. In the open email, go to **File → Save As → HTML format**
2. Open the `.html` file in a browser
3. Print from the browser

---

## 22. Outlook Bookings App Not Working

### Diagnostic Script

```powershell
Set-ExecutionPolicy RemoteSigned

Install-Module ExchangeOnlineManagement -Verbose -Force
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Start a transcript to capture diagnostics
Start-Transcript -Path "C:\transcripts\bookings-diagnostic.txt" -NoClobber

$formatenumerationlimit = -1

# Check org-wide EWS and Bookings configuration
Get-OrganizationConfig | FL *EWS*,*Book*

# Check the affected user's CAS mailbox settings
$ImpactedUser = Get-Mailbox user@contoso.com
$ImpactedUser | Get-CasMailbox | FL *EWS*,OWAMailboxPolicy

# Check the OWA Mailbox Policy for Bookings settings
Get-OwaMailboxPolicy -Identity $ImpactedUser.OWAMailboxPolicy

Stop-Transcript
```

**Reference:** [Bookings in Outlook — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/bookings/bookings-in-outlook)

---

## Key Cmdlets Reference

| Cmdlet / Command | Purpose |
|------------------|---------|
| `outlook.exe /safe` | Launch Outlook in Safe Mode |
| `outlook.exe /cleanrules` | Remove all Outlook rules |
| `outlook.exe /resetnavpane` | Reset Navigation Pane |
| `outlook.exe /manageprofile` | Open Outlook profile manager |
| `Set-Mailbox -MessageCopyForSentAsEnabled` | Copy sent-as emails to shared mailbox Sent Items |
| `Set-CalendarProcessing -ProcessExternalMeetingMessages` | Allow room to accept external bookings |
| `Set-InboundConnector -TreatMessagesAsInternal` | Treat third-party routed mail as internal |
| `RunDll32.exe InetCpl.cpl,ResetIEtoDefaults` | Reset WinInet to fix connectivity errors |
| `Start-ADSyncSyncCycle -PolicyType Delta` | Trigger Azure AD Connect delta sync |
