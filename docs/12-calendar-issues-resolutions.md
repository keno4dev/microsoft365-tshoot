# Calendar Issues & Resolutions

> **Category:** Calendar, Scheduling, Meetings, Room Mailboxes  
> **Applies to:** Exchange Online, Outlook, Outlook on the Web (OWA), Microsoft 365

---

## Table of Contents

1. [Disable Calendar for a Private Group Mailbox](#1-disable-calendar-for-a-private-group-mailbox)
2. [Calendar Event Change Notifications Going to Deleted Items](#2-calendar-event-change-notifications-going-to-deleted-items)
3. [Calendar Invites Routing to the Wrong User](#3-calendar-invites-routing-to-the-wrong-user)
4. [Missing Notifications When a Delegate Edits a Calendar](#4-missing-notifications-when-a-delegate-edits-a-calendar)
5. [Delegate Cannot Edit, Delete, or See Calendar Updates](#5-delegate-cannot-edit-delete-or-see-calendar-updates)
6. [Changing the Calendar Booking Window in Advance (Room Mailboxes)](#6-changing-the-calendar-booking-window-in-advance-room-mailboxes)
7. [Repeating Meeting Invitations Being Sent Daily](#7-repeating-meeting-invitations-being-sent-daily)
8. [Create and Share a Calendar with All Users in the Organization](#8-create-and-share-a-calendar-with-all-users-in-the-organization)
9. [Delete Calendar Events Without Notifying Attendees](#9-delete-calendar-events-without-notifying-attendees)
10. [Meeting Room Allows Double Bookings](#10-meeting-room-allows-double-bookings)
11. [Share All Users' Calendars with Each Other (Org-Wide)](#11-share-all-users-calendars-with-each-other-org-wide)
12. [User Unable to Accept Calendar Invites (Corrupted Delegation)](#12-user-unable-to-accept-calendar-invites-corrupted-delegation)
13. [Show Meeting Details in a Room Mailbox Calendar](#13-show-meeting-details-in-a-room-mailbox-calendar)
14. [Cancel All Organized Meetings for a Departing User](#14-cancel-all-organized-meetings-for-a-departing-user)

---

## 1. Disable Calendar for a Private Group Mailbox

### Symptom
A private Microsoft 365 Group (e.g., `emporiaallstaff@contoso.onmicrosoft.com`) is actively used for email. The administrator wants to **disable the calendar portion** of the group or restrict calendar access.

### Resolution

This is achieved by creating a custom **OWA Mailbox Policy** with the calendar disabled, then applying it to the target mailbox.

```powershell
# Step 1 — Create a new OWA Mailbox Policy
New-OwaMailboxPolicy -Name "Disable Calendar Policy"

# Step 2 — Disable the Calendar feature on the policy
Set-OwaMailboxPolicy -Identity "Disable Calendar Policy" -CalendarEnabled $false

# Step 3 — Apply the policy to the target mailbox
Set-CASMailbox -Identity "emporiaallstaff@contoso.onmicrosoft.com" -OwaMailboxPolicy "Disable Calendar Policy"
```

> **Note:** This disables the calendar **in Outlook on the Web (OWA)** for that mailbox. The Outlook desktop client has its own settings and may not be affected.

**References:**
- [Set-OwaMailboxPolicy — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/set-owamailboxpolicy?view=exchange-ps)
- [New-OwaMailboxPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/new-owamailboxpolicy?view=exchange-ps)

---

## 2. Calendar Event Change Notifications Going to Deleted Items

### Symptom
Multiple users report that when an organizer makes a change to, or attaches files to, an existing calendar event, the **change notification email is sent directly to Deleted Items** in Outlook rather than the Inbox.

This behaviour is controlled by the `VisibleMeetingUpdateProperties` org-level setting.

### Diagnose

```powershell
Get-OrganizationConfig | Select VisibleMeetingUpdateProperties
```

### Resolution

```powershell
# Set to AllProperties so all meeting change notifications are delivered to the Inbox
Set-OrganizationConfig -VisibleMeetingUpdateProperties AllProperties
```

### `VisibleMeetingUpdateProperties` Values

| Value | Behaviour |
|-------|-----------|
| `None` | No meeting updates generate Inbox notifications — all silently update the calendar item |
| `Subject` | Only subject changes generate a visible notification |
| `Location` | Only location changes generate a visible notification |
| `AllProperties` | All changes generate a visible notification delivered to the Inbox |

> **Reference:** [Set-OrganizationConfig — VisibleMeetingUpdateProperties](https://learn.microsoft.com/en-us/powershell/module/exchange/set-organizationconfig?view=exchange-ps)

---

## 3. Calendar Invites Routing to the Wrong User

### Symptom
Calendar invites sent to `sandi@contoso.com` are being delivered to `melissa@contoso.com` instead. Disabling the "Send As" permission did not resolve it.

### Root Cause
The issue was traced to a **delegated calendar access** setting in the user's OWA configuration. Melissa had delegate access configured on Sandi's mailbox, causing calendar invites to be forwarded or redirected.

### Resolution

1. Log in to **Outlook on the Web (OWA)** as the affected user (`sandi@contoso.com`).
2. Navigate to: `Settings → Calendar → Shared Calendars`.
3. Under **Delegated Calendars**, review all delegates.
4. Remove `melissa@contoso.com` from the delegate list or adjust the delegation permissions to remove forwarding/invite-receiving rights.

#### Verify Delegate Settings via PowerShell

```powershell
# Check current calendar folder permissions
Get-MailboxFolderPermission -Identity "sandi@contoso.com:\Calendar"

# Remove a delegate entirely
Remove-MailboxFolderPermission -Identity "sandi@contoso.com:\Calendar" -User "melissa@contoso.com"
```

---

## 4. Missing Notifications When a Delegate Edits a Calendar

### Symptom
User A and User B have **Edit** access to each other's calendars. When User B updates User A's calendar, User A gets a notification. However, User A editing User B's calendar does **not** trigger a notification for User B.

This often indicates corrupted or inconsistent delegate permissions.

### Resolution

Reset the delegate user collection on the affected calendar:

```powershell
Remove-MailboxFolderPermission -Identity "userB@contoso.com:\Calendar" -ResetDelegateUserCollection
```

> **Warning:** This removes **all** existing delegate settings on the calendar. You will need to re-add delegates and re-configure their permissions after running this command.

#### Re-add Delegate After Reset

```powershell
# Re-add with Editor access
Add-MailboxFolderPermission -Identity "userB@contoso.com:\Calendar" -User "userA@contoso.com" -AccessRights Editor
```

**Reference:**
- [Remove-MailboxFolderPermission](https://learn.microsoft.com/en-us/powershell/module/exchange/remove-mailboxfolderpermission?view=exchange-ps)

---

## 5. Delegate Cannot Edit, Delete, or See Calendar Updates

### Symptom
`BrandiH@contoso.org` granted edit permission on her calendar to a co-worker. The co-worker:
- Cannot create calendar events for Brandi
- Cannot edit or delete calendar events (including their own created events)
- Cannot see calendar updates from Brandi

### Root Cause — Recoverable Items Folder at 100 GB Limit

This is a non-obvious root cause. Investigation revealed:
- The **Recoverable Items folder** was at its **100 GB limit**
- A **Discovery Hold** was consuming **99.3 GB**
- The user had been **migrated from on-premises Exchange** with all content
- The user was on an **org-wide hold**

When the Recoverable Items folder is full, **write operations on the mailbox are blocked** — this includes calendar create, edit, and delete operations.

### Impact of Recoverable Items Nearing Capacity

```
Recoverable Items ──────────────────────── 100 GB (limit)
  ├── Deletions folder
  ├── Versions (from holds)       ─── ~99.3 GB (Discovery Hold)
  └── Purges

Result: All write operations to the mailbox are blocked, including calendar changes.
```

### Resolution Steps

1. **Enable the Mailbox Archive** to allow the Recoverable Items content to be moved.
2. **Create a Retention Tag and Policy** targeting the Recoverable Items folder (see [Compliance & eDiscovery doc](08-compliance-ediscovery.md)).
3. **Apply the policy** and run `Start-ManagedFolderAssistant` to move aged items to the archive.

```powershell
# Enable In-Place Archive for the user
Enable-Mailbox -Identity "BrandiH@contoso.org" -Archive

# Trigger Managed Folder Assistant to process the mailbox
Start-ManagedFolderAssistant -Identity "BrandiH@contoso.org"

# Check current folder sizes
Get-MailboxFolderStatistics -Identity "BrandiH@contoso.org" -FolderScope RecoverableItems |
    Select FolderPath, FolderSize, ItemsInFolder
```

> **Reference:** [Recoverable Items folder in Exchange Online](https://learn.microsoft.com/en-us/exchange/security-and-compliance/recoverable-items-folder/recoverable-items-folder)

---

## 6. Changing the Calendar Booking Window in Advance (Room Mailboxes)

### Symptom
Administrators need to change the **maximum advance booking window** for a room or resource mailbox — for example, from the default 180 days to 1080 days.

### Resolution

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline

# Set the booking window to 1080 days (~3 years)
Set-CalendarProcessing -Identity "room@contoso.com" -BookingWindowInDays 1080

# Verify the change
Get-CalendarProcessing -Identity "room@contoso.com" | Select BookingWindowInDays
```

### Common `Set-CalendarProcessing` Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `BookingWindowInDays` | Max days in advance a booking can be made | `1080` |
| `MaximumDurationInMinutes` | Maximum meeting duration allowed | `480` (8 hours) |
| `AllowConflicts` | Allow overlapping bookings | `$true` / `$false` |
| `AutomateProcessing` | Auto-accept or manual | `AutoAccept` |
| `AllRequestOutOfPolicy` | Allow requests outside policy | `$true` / `$false` |

**Reference:**
- [Set-CalendarProcessing — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/set-calendarprocessing?view=exchange-ps)

---

## 7. Repeating Meeting Invitations Being Sent Daily

### Symptom
A user created a **recurring daily calendar event** with a Webex meeting attached. Every day, all recipients are receiving the invite again from the organizer's email address — even those who already accepted or declined. Recipients are receiving **involuntary daily spam** from the invite.

### Root Cause
This is typically caused by a misconfigured recurrence in the calendar item, or a third-party integration (e.g., Webex) regenerating and resending the invite on each recurrence.

### Resolution — Delete the Calendar Items via Compliance Search

#### Required Roles
- `eDiscovery Manager` or `Compliance Search` role (to create and run searches)
- `Organization Management` or `Search And Purge` role (to delete content)

#### Step-by-Step

**Step 1 — Load module and connect**

```powershell
Import-Module ExchangeOnlineManagement
Connect-IPPSSession -UserPrincipalName admin@contoso.com
```

**Step 2 — Create the Content Search**

```powershell
# Search by subject across all mailboxes
$Search = New-ComplianceSearch `
    -Name "Calendar Items to Purge" `
    -ExchangeLocation All `
    -ContentMatchQuery '(Subject:"Daily Ops/Mx Briefing")'

# Or search by sender AND subject
$Search = New-ComplianceSearch `
    -Name "Calendar Items to Purge" `
    -ExchangeLocation All `
    -ContentMatchQuery '(From:user@contoso.com) AND (Subject:"Update your account information")'

# Or search by received date range
$Search = New-ComplianceSearch `
    -Name "Calendar Items to Purge" `
    -ExchangeLocation All `
    -ContentMatchQuery '(Received:4/13/2016..4/14/2016) AND (Subject:"Action required")'
```

**Step 3 — Start the Search**

```powershell
Start-ComplianceSearch -Identity $Search.Identity
```

**Step 4 — Purge the Matched Content**

```powershell
# Soft Delete (moves to Recoverable Items — can be recovered within 14 days)
New-ComplianceSearchAction -SearchName "Calendar Items to Purge" -Purge -PurgeType SoftDelete

# Hard Delete (permanently removes from database — cannot be recovered)
New-ComplianceSearchAction -SearchName "Calendar Items to Purge" -Purge -PurgeType HardDelete
```

> **Tip:** If the purge action appears to expire or time out in large tenants, use a loop to retry:
> ```powershell
> while ($true) {
>     New-ComplianceSearchAction -SearchName "Calendar Items to Purge" -Purge -PurgeType SoftDelete -Confirm:$false
>     Write-Host "Waiting for next attempt..."
>     Start-Sleep -Seconds 5
> }
> ```
> **Note:** Stop the loop (`Ctrl+C`) once items are confirmed deleted.

**Step 5 — Track Progress**

```powershell
Get-ComplianceSearchAction | Format-List
```

**Step 6 — Disconnect**

```powershell
Disconnect-ExchangeOnline -Confirm:$false
```

> ⚠️ **Important:** The admin account running the purge cmdlets must have a **license assigned**, otherwise items will not be deleted.

**References:**
- [Search for and delete email messages — Microsoft Purview](https://learn.microsoft.com/en-us/purview/ediscovery-search-for-and-delete-email-messages)
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps)
- [New-ComplianceSearch](https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancesearch?view=exchange-ps)

---

## 8. Create and Share a Calendar with All Users in the Organization

### Overview

The recommended approach for a true **organization-wide shared calendar** is to use a **Shared Mailbox** as the calendar host, then distribute a subscribe link.

### Steps

#### Step 1 — Create a Shared Mailbox

```powershell
New-Mailbox -Shared -Name "Company Calendar" -DisplayName "Company Calendar" -Alias "companycalendar"
```

Or via the **Microsoft 365 Admin Center**:
`Admin Center → Teams & Groups → Shared mailboxes → Add a shared mailbox`

#### Step 2 — Grant Full Access to Calendar Editors

```powershell
Add-MailboxPermission -Identity "companycalendar@contoso.com" -User "editor@contoso.com" -AccessRights FullAccess -InheritanceType All
```

#### Step 3 — Publish the Calendar (OWA)

1. Log in to **OWA** as the shared mailbox (or access it via your account if you have Full Access)
2. Navigate to: `Settings (⚙) → Calendar → Shared calendars`
3. Under **Publish a calendar**, select **Calendar** and choose the sharing level
4. Click **Publish** and copy the generated **HTML** or **ICS link**

```
Sharing levels available:
  ┌─────────────────────────────────────────────────────────┐
  │  "Can view when I'm busy"                                │
  │  "Can view titles and locations"                         │
  │  "Can view all details"            ← Recommended         │
  └─────────────────────────────────────────────────────────┘
```

#### Step 4 — Recipients Subscribe to the Calendar

1. In **OWA**, click **Add calendar** → **Subscribe from web**
2. Paste the ICS link, assign a name and color
3. Click **Import**

> **Note:** The subscribed calendar is visible in **Outlook Desktop** and **OWA**. Microsoft Teams loads only the **default personal calendar** — it does not surface subscribed shared calendars natively.

#### Step 5 — Add the Calendar to a Microsoft Teams Channel (Optional)

1. Copy the calendar's shared URL
2. Open **Microsoft Teams** → Select the target **Team and Channel**
3. Click **+ Add a tab** → Select **Website**
4. Enter a tab name and paste the calendar URL
5. Click **Save**

---

## 9. Delete Calendar Events Without Notifying Attendees

> See the full guide in [08 — Compliance, eDiscovery & Retention](08-compliance-ediscovery.md) for the complete step-by-step workflow.

### Quick Reference

```powershell
Import-Module ExchangeOnlineManagement

# Connect to Security & Compliance
Connect-IPPSSession -UserPrincipalName admin@contoso.com

# Step 3: Create search targeting the calendar item
New-ComplianceSearch `
    -Name "DeleteCalEvent" `
    -ExchangeLocation "organizer@contoso.com" `
    -ContentMatchQuery 'Subject:"Weekly All Hands" kind:meetings' `
    -LogLevel Full

# Step 4: Start the search
Start-ComplianceSearch -Identity "DeleteCalEvent"

# Step 5: Hard delete matched events
New-ComplianceSearchAction -SearchName "DeleteCalEvent" -Purge -PurgeType HardDelete

# Step 6: Track deletion progress
Get-ComplianceSearchAction -Identity "DeleteCalEvent_Purge" | Format-List

# Step 7: Disconnect
Disconnect-ExchangeOnline -Confirm:$false
```

> **Deprecated alternative** (for reference only — `Search-Mailbox` is retired):
> ```powershell
> Search-Mailbox -Identity "user@contoso.com" `
>     -SearchQuery 'kind:meetings AND Subject:"meeting title"' `
>     -DeleteContent
> ```

**References:**
- [Search-Mailbox cmdlet fails](https://learn.microsoft.com/en-us/exchange/troubleshoot/compliance/search-mailbox-cmdlet-fails)
- [New-ComplianceSearch](https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancesearch?view=exchange-ps)

---

## 10. Meeting Room Allows Double Bookings

### Symptom
A meeting room resource mailbox accepts overlapping bookings — users can reserve it for two different meetings at the same time.

### Resolution

```powershell
Connect-ExchangeOnline

# Disable conflict bookings
Set-CalendarProcessing -Identity "room@contoso.com" -AllowConflicts $false

# Also prevent out-of-policy requests from being auto-approved
Get-CalendarProcessing -Identity "room@contoso.com" | Set-CalendarProcessing -AllRequestOutOfPolicy $false

# Verify settings
Get-CalendarProcessing -Identity "room@contoso.com" |
    Select AllowConflicts, AllRequestOutOfPolicy, AutomateProcessing
```

### Room Mailbox Booking Policy Reference

| Setting | Recommended Value | Description |
|---------|:-----------------:|-------------|
| `AllowConflicts` | `$false` | Rejects bookings that overlap with existing accepted bookings |
| `AutomateProcessing` | `AutoAccept` | Automatically accepts/declines based on policy |
| `AllRequestOutOfPolicy` | `$false` | Prevents bookings that violate booking policy from auto-accepting |
| `BookingWindowInDays` | `180` (default) or higher | Max days in advance the room can be booked |

**References:**
- [You can still reserve a meeting room even if it is reserved — Exchange Troubleshoot](https://learn.microsoft.com/en-us/exchange/troubleshoot/calendars/you-still-can-reserve-a-meeting-room-even-if-it-is-reserved)
- [Set-CalendarProcessing](https://learn.microsoft.com/en-us/powershell/module/exchange/set-calendarprocessing?view=exchange-ps)

---

## 11. Share All Users' Calendars with Each Other (Org-Wide)

### Scenario
As an administrator, you want all users in the organization to be able to view each other's detailed calendar items — not just free/busy information.

### Method 1 — Set Default Access to Reviewer (Detailed View)

`Reviewer` access allows internal users to **read all calendar event details** (subject, location, attendees, notes).

```powershell
Connect-ExchangeOnline

# Apply Reviewer access to ALL user mailboxes' default calendar permission
Get-Mailbox -RecipientTypeDetails UserMailbox | ForEach-Object {
    Set-MailboxFolderPermission `
        -Identity ($_.UserPrincipalName + ":\calendar") `
        -User Default `
        -AccessRights Reviewer
}
```

### Method 2 — Alternate Syntax (Alias-based)

```powershell
foreach ($user in Get-Mailbox -RecipientTypeDetails UserMailbox) {
    Set-MailboxFolderPermission `
        -Identity ($user.Alias + ":\calendar") `
        -User Default `
        -AccessRights Reviewer
}
```

### Calendar Permission Levels Reference

```
AvailabilityOnly  → Free/busy time only
LimitedDetails    → Free/busy + Subject + Location
Reviewer          → View all details (read-only)
Author            → View + Create own events
Editor            → View + Create + Edit all events
Owner             → Full control including permissions management
```

> **New users:** The `Default` user setting applies to all users including new ones joining the organization — changes apply automatically.

**Reference:**
- [Set-MailboxFolderPermission](https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxfolderpermission?view=exchange-ps)

---

## 12. User Unable to Accept Calendar Invites (Corrupted Delegation)

### Symptom
A user cannot accept calendar invites in Outlook. Investigation reveals that the user's **calendar delegation is corrupted**.

### Resolution

```powershell
Set-ExecutionPolicy RemoteSigned

Install-Module ExchangeOnlineManagement -Verbose -Force
Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

# Reset the delegate collection — clears all corrupted delegate state
Remove-MailboxFolderPermission -Identity "user@contoso.com:\Calendar" -ResetDelegateUserCollection

# Verify current calendar folder state
Get-MailboxCalendarFolder -Identity "user@contoso.com:\Calendar"
```

> **Note:** `-ResetDelegateUserCollection` removes all delegates from the calendar. Re-add any needed delegates using `Add-MailboxFolderPermission` after running this command.

#### Re-add a Delegate

```powershell
Add-MailboxFolderPermission `
    -Identity "user@contoso.com:\Calendar" `
    -User "delegate@contoso.com" `
    -AccessRights Editor
```

**References:**
- [Remove-MailboxFolderPermission](https://learn.microsoft.com/en-us/powershell/module/exchange/remove-mailboxfolderpermission?view=exchange-ps)
- [Get-MailboxCalendarFolder](https://learn.microsoft.com/en-us/powershell/module/exchange/get-mailboxcalendarfolder?view=exchange-ps)

---

## 13. Show Meeting Details in a Room Mailbox Calendar

### Symptom
When viewing a **room mailbox calendar**, attendees or delegates only see blocks of "Busy" time without any meeting details (no subject, no organizer).

### Resolution

By default, room mailbox calendars show minimal detail. You can configure them to display **subject, organizer, and all meeting details**.

```powershell
Connect-ExchangeOnline

# Step 1 — Confirm the mailbox is a room mailbox
Get-EXOMailbox -RecipientTypeDetails RoomMailbox | Select DisplayName, PrimarySmtpAddress

# Step 2 — Set the default calendar permission to LimitedDetails (Subject + Location)
Set-MailboxFolderPermission `
    -Identity "roomname@contoso.com:\calendar" `
    -User Default `
    -AccessRights LimitedDetails

# Step 3 — Configure calendar processing to show organizer and preserve subject
Set-CalendarProcessing `
    -Identity "roomname@contoso.com" `
    -AddOrganizerToSubject $true `
    -DeleteComments $false `
    -DeleteSubject $false
```

### What These Parameters Do

| Parameter | Value | Effect |
|-----------|-------|--------|
| `AddOrganizerToSubject` | `$true` | Prepends the organizer's name to the meeting subject |
| `DeleteComments` | `$false` | Preserves the meeting body/notes in the room calendar |
| `DeleteSubject` | `$false` | Preserves the original meeting subject |
| `AccessRights LimitedDetails` | — | Shows subject + location to anyone viewing the calendar |

> **Reference:** [Show meeting details of a Room Mailbox in Office 365](https://lazyadmin.nl/office-365/show-details-room-mailbox-meetings-in-its-calendar-in-office-365/)

---

## 14. Cancel All Organized Meetings for a Departing User

### Scenario
A user has left the organization suddenly or is going on extended leave. You need to cancel all their **upcoming organized meetings** to prevent attendees from showing up to orphaned meetings.

### Cancel All Future Meetings

```powershell
Connect-ExchangeOnline

# Cancel all future meetings organized by this user (starting today)
Remove-CalendarEvents -Identity "departinguser@contoso.com" -CancelOrganizedMeetings

# Preview what will be cancelled before executing (add -WhatIf)
Remove-CalendarEvents -Identity "departinguser@contoso.com" -CancelOrganizedMeetings -WhatIf
```

### Cancel Meetings Within a Specific Date Range

```powershell
# Cancel meetings starting from Aug 1, 2024 for the next 90 days
Remove-CalendarEvents `
    -Identity "departinguser@contoso.com" `
    -CancelOrganizedMeetings `
    -QueryStartDate "2024-08-01" `
    -QueryWindowInDays 90
```

> **Note:** `Remove-CalendarEvents` sends cancellation notices to all attendees. If silent removal is needed, use the Compliance Search purge method (see [Section 9](#9-delete-calendar-events-without-notifying-attendees)).

**References:**
- [Remove-CalendarEvents — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/remove-calendarevents?view=exchange-ps)
- [Office 365 Exchange: Remove-CalendarEvents — Slipstick](https://www.slipstick.com/office-365/office-365-exchangeremove-calendarevents/)

---

## Quick Reference — Key Calendar Cmdlets

| Cmdlet | Purpose |
|--------|---------|
| `New-OwaMailboxPolicy` | Create a new OWA policy |
| `Set-OwaMailboxPolicy -CalendarEnabled $false` | Disable calendar in OWA for a policy |
| `Set-CASMailbox -OwaMailboxPolicy` | Apply OWA policy to a mailbox |
| `Set-OrganizationConfig -VisibleMeetingUpdateProperties AllProperties` | Fix meeting change notifications going to Deleted Items |
| `Set-CalendarProcessing -BookingWindowInDays` | Set how far in advance rooms can be booked |
| `Set-CalendarProcessing -AllowConflicts $false` | Prevent room double bookings |
| `Set-CalendarProcessing -AddOrganizerToSubject $true` | Show organizer in room calendar |
| `Remove-CalendarEvents -CancelOrganizedMeetings` | Cancel all a user's organized meetings |
| `Remove-MailboxFolderPermission -ResetDelegateUserCollection` | Fix corrupted calendar delegation |
| `Set-MailboxFolderPermission -User Default -AccessRights Reviewer` | Grant all users read access to a calendar |
| `New-ComplianceSearch` | Search for calendar items to delete |
| `New-ComplianceSearchAction -Purge -PurgeType HardDelete` | Permanently purge matched calendar items |
| `Get-MailboxFolderStatistics -FolderScope RecoverableItems` | Check Recoverable Items folder size |
| `Enable-Mailbox -Archive` | Enable the archive mailbox |

---

## References

- [Set-CalendarProcessing — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/exchange/set-calendarprocessing?view=exchange-ps)
- [Remove-CalendarEvents](https://learn.microsoft.com/en-us/powershell/module/exchange/remove-calendarevents?view=exchange-ps)
- [Set-MailboxFolderPermission](https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxfolderpermission?view=exchange-ps)
- [Remove-MailboxFolderPermission](https://learn.microsoft.com/en-us/powershell/module/exchange/remove-mailboxfolderpermission?view=exchange-ps)
- [Recoverable Items Folder in Exchange Online](https://learn.microsoft.com/en-us/exchange/security-and-compliance/recoverable-items-folder/recoverable-items-folder)
- [New-OwaMailboxPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/new-owamailboxpolicy?view=exchange-ps)
- [Set-OrganizationConfig](https://learn.microsoft.com/en-us/powershell/module/exchange/set-organizationconfig?view=exchange-ps)
- [Search for and delete email messages — Microsoft Purview](https://learn.microsoft.com/en-us/purview/ediscovery-search-for-and-delete-email-messages)
