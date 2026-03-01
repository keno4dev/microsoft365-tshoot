# Generating Exchange Online Usage Reports

> **Category:** Exchange Online, Reporting, Mailbox Statistics, Microsoft Graph Reporting API  
> **Applies to:** Exchange Online, Microsoft 365, EXO PowerShell V2+

---

## Table of Contents

1. [Mailbox Statistics — All Mailboxes](#1-mailbox-statistics--all-mailboxes)
2. [Inactive Mailboxes Report](#2-inactive-mailboxes-report)
3. [Mail Traffic — Top Senders and Recipients](#3-mail-traffic--top-senders-and-recipients)
4. [Microsoft 365 Group Members Report](#4-microsoft-365-group-members-report)
5. [Additional Reporting Cmdlets](#5-additional-reporting-cmdlets)
6. [Deprecation Notice — Classic Reporting Cmdlets](#6-deprecation-notice--classic-reporting-cmdlets)
7. [Microsoft Graph Reporting API (Modern)](#7-microsoft-graph-reporting-api-modern)

---

## Prerequisites

```powershell
# Install Exchange Online PowerShell module
Install-Module ExchangeOnlineManagement -Force

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName admin@contoso.com
```

---

## 1. Mailbox Statistics — All Mailboxes

Retrieve storage usage, item count, and last logon time for every mailbox:

```powershell
Get-Mailbox -ResultSize Unlimited |
    Get-MailboxStatistics |
    Select-Object DisplayName,
                  TotalItemSize,
                  ItemCount,
                  LastLogonTime,
                  MailboxTypeDetail
```

### Export to CSV

```powershell
Get-Mailbox -ResultSize Unlimited |
    Get-MailboxStatistics |
    Select-Object DisplayName, TotalItemSize, ItemCount, LastLogonTime |
    Export-Csv -Path "C:\Reports\MailboxStats.csv" -NoTypeInformation
```

**Reference:** [Get-MailboxStatistics — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/exchange/get-mailboxstatistics)

---

## 2. Inactive Mailboxes Report

Find mailboxes that have **not been logged into within the last 30 days**:

```powershell
$DaysInactive = 30
$Threshold    = ([DateTime]::Now).AddDays(-$DaysInactive)

Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited |
    Get-MailboxStatistics |
    Where-Object { $_.LastLogonTime -lt $Threshold } |
    Select-Object DisplayName, LastLogonTime, TotalItemSize, ItemCount |
    Sort-Object LastLogonTime |
    Format-Table -AutoSize
```

### Export Report

```powershell
$DaysInactive = 30
$Threshold    = ([DateTime]::Now).AddDays(-$DaysInactive)

Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited |
    Get-MailboxStatistics |
    Where-Object { $_.LastLogonTime -lt $Threshold } |
    Select-Object DisplayName, LastLogonTime, TotalItemSize, ItemCount |
    Sort-Object LastLogonTime |
    Export-Csv -Path "C:\Reports\InactiveMailboxes.csv" -NoTypeInformation

Write-Host "Report saved to C:\Reports\InactiveMailboxes.csv"
```

> **Note:** `LastLogonTime` is `$null` for newly created or never-used mailboxes. Filter accordingly:
> ```powershell
> Where-Object { $_.LastLogonTime -ne $null -and $_.LastLogonTime -lt $Threshold }
> ```

---

## 3. Mail Traffic — Top Senders and Recipients

`Get-MailTrafficTopReport` returns top sender/recipient statistics for the tenant.

```powershell
# Top email senders in the last 7 days
Get-MailTrafficTopReport -Direction Outbound -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)

# Top email recipients in the last 7 days
Get-MailTrafficTopReport -Direction Inbound -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
```

> **Deprecation note:** This cmdlet was deprecated in January 2018. Use the **Microsoft Graph Reporting API** for current data. See [Section 7](#7-microsoft-graph-reporting-api-modern).

**Reference:** [Get-MailTrafficTopReport — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/exchange/get-mailtraffictopreport)

---

## 4. Microsoft 365 Group Members Report

The following function retrieves all members from every Microsoft 365 (Unified) Group in the tenant:

```powershell
function Get-AllO365GroupMembers {
    <#
    .SYNOPSIS
        Returns all members of all Microsoft 365 Groups.
    .DESCRIPTION
        Iterates over every Unified Group in the tenant and retrieves
        members via Get-UnifiedGroupLinks -LinkType Members.
    .OUTPUTS
        PSObject with GroupName, GroupEmail, MemberDisplayName, MemberEmail
    #>

    $AllGroups  = Get-UnifiedGroup -ResultSize Unlimited
    $OutputList = [System.Collections.Generic.List[PSObject]]::new()

    foreach ($Group in $AllGroups) {
        $Members = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members

        foreach ($Member in $Members) {
            $OutputList.Add([PSCustomObject]@{
                GroupName          = $Group.DisplayName
                GroupEmail         = $Group.PrimarySmtpAddress
                MemberDisplayName  = $Member.DisplayName
                MemberEmail        = $Member.PrimarySmtpAddress
            })
        }
    }

    return $OutputList
}

# Usage
$Report = Get-AllO365GroupMembers
$Report | Export-Csv -Path "C:\Reports\O365GroupMembers.csv" -NoTypeInformation
Write-Host "Total members across all groups: $($Report.Count)"
```

**Reference:** [Get-UnifiedGroupLinks — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/exchange/get-unifiedgrouplinks)

---

## 5. Additional Reporting Cmdlets

| Cmdlet | Purpose |
|--------|---------|
| `Get-MailboxFolderStatistics` | Per-folder item count and size within a mailbox |
| `Get-RecipientStatisticsReport` | Message count by recipient |
| `Get-TransportRule` | List all transport rules (mail flow rules) |
| `Get-MessageTrace` | Trace messages by sender/recipient within 10 days |
| `Get-MessageTraceDetail` | Detailed delivery events for a specific traced message |
| `Get-MobileDeviceStatistics` | Mobile device sync statistics |
| `Get-SharingPolicy` | Federated sharing policies in place |

### Mailbox Folder Statistics

```powershell
Get-MailboxFolderStatistics -Identity user@contoso.com |
    Select-Object FolderPath, ItemsInFolder, FolderSize |
    Sort-Object FolderSize -Descending |
    Select-Object -First 10
```

### Message Trace (Last 24 Hours)

```powershell
Get-MessageTrace `
    -SenderAddress sender@contoso.com `
    -StartDate (Get-Date).AddDays(-1) `
    -EndDate   (Get-Date) |
    Select-Object Received, SenderAddress, RecipientAddress, Subject, Status
```

---

## 6. Deprecation Notice — Classic Reporting Cmdlets

> **Most EXO usage-reporting cmdlets were deprecated in January 2018.**
>
> The following cmdlets are deprecated or have limited data:
> - `Get-MailTrafficTopReport`
> - `Get-MailTrafficSummaryReport`
> - `Get-MailDetailTransportRuleReport`
> - `Get-RecipientStatisticsReport`
>
> These have been replaced by the **Microsoft 365 Admin Center** usage dashboards and the **Microsoft Graph Reporting API**.

**Reference:** [Email activity reports (deprecated)](https://learn.microsoft.com/en-us/exchange/monitoring/mail-flow-reports/mfr-email-activity-report)

---

## 7. Microsoft Graph Reporting API (Modern)

Use the **Graph PowerShell** module for up-to-date usage and activity reports.

### Install and Connect

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Connect-MgGraph -Scopes "Reports.Read.All"
```

### Mailbox Usage Report (Last 7 Days)

```powershell
# Returns a CSV download URL
Get-MgReportEmailActivityUserDetail -Period D7 -OutFile "C:\Reports\EmailActivity.csv"
```

### Available Report Commands

| Cmdlet | Report |
|--------|--------|
| `Get-MgReportEmailActivityUserDetail` | Per-user email activity |
| `Get-MgReportEmailActivityCount` | Tenant-wide email send/receive/read counts |
| `Get-MgReportMailboxUsageDetail` | Per-mailbox storage and quota |
| `Get-MgReportMailboxUsageMailboxCount` | Total active/inactive mailboxes |
| `Get-MgReportOffice365GroupsActivityDetail` | Microsoft 365 Groups activity |

### List Available Reports via REST

```powershell
$Response = Invoke-MgGraphRequest -Method GET `
    "https://graph.microsoft.com/v1.0/reports/getEmailActivityUserDetail(period='D7')"
$Response.Content | Out-File "C:\Reports\EmailActivity.csv"
```

**Reference:** [Microsoft Graph Reports API — Microsoft Learn](https://learn.microsoft.com/en-us/graph/api/resources/report?view=graph-rest-1.0)
