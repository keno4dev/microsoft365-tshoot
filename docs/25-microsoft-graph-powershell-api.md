# Microsoft Graph PowerShell API

> **Category:** Microsoft Graph, PowerShell, Microsoft Teams, Identity, Authorization Policies  
> **Applies to:** Microsoft Graph SDK, Microsoft Graph Beta, Teams Shifts, Sign-In Policies, Microsoft 365

---

## Table of Contents

1. [Overview — Microsoft Graph PowerShell SDK](#1-overview--microsoft-graph-powershell-sdk)
2. [Graph Explorer (Browser-Based Testing)](#2-graph-explorer-browser-based-testing)
3. [Teams Shifts via Microsoft Graph](#3-teams-shifts-via-microsoft-graph)
4. [Identity and Sign-In Authorization Policies](#4-identity-and-sign-in-authorization-policies)
5. [Common Graph Scopes Reference](#5-common-graph-scopes-reference)
6. [Running Raw Graph API Calls from PowerShell](#6-running-raw-graph-api-calls-from-powershell)

---

## 1. Overview — Microsoft Graph PowerShell SDK

The **Microsoft Graph PowerShell SDK** replaces the legacy `MSOnline` and `AzureAD` modules. It provides access to nearly all Microsoft 365 workloads (Exchange, Teams, SharePoint, Identity, Compliance, etc.) through a unified API surface.

### Install the Core SDK

```powershell
# Full SDK (all modules — large, ~150 sub-modules)
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Or install only the modules you need (recommended for CI/CD pipelines)
Install-Module Microsoft.Graph.Users    -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Groups   -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Teams    -Scope CurrentUser -Force
```

### Connect

```powershell
# Interactive browser login
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All"

# Verify connection
Get-MgContext
```

### Disconnect

```powershell
Disconnect-MgGraph
```

**Reference:** [Microsoft Graph PowerShell SDK overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)

---

## 2. Graph Explorer (Browser-Based Testing)

Before scripting, test Graph API calls interactively in the browser:

**URL:** [https://developer.microsoft.com/en-us/graph/graph-explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)

Graph Explorer allows you to:
- Run GET/POST/PATCH/DELETE requests against your own tenant
- Browse sample queries for every workload
- Copy the working query directly into SDK calls
- Test permission scopes before requesting admin consent

> **Best practice:** Always validate your Graph query in Graph Explorer first before embedding it in a PowerShell script or automation pipeline.

---

## 3. Teams Shifts via Microsoft Graph

**Shifts** is the scheduling feature in Microsoft Teams. The Graph Beta API exposes the full Shifts schema.

### REST Endpoint

```
GET /teams/{teamId}/schedule/shifts
```

Example URL:
```
https://graph.microsoft.com/v1.0/teams/d747dc60-9745-439c-8e09-e588cd240ea5/schedule/shifts
```

### PowerShell — Get Shifts for a Team

```powershell
# Install the Beta Teams module
Install-Module Microsoft.Graph.Beta.Teams -Scope CurrentUser -Force -Verbose
Import-Module Microsoft.Graph.Beta.Teams

# Connect with required scopes
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Schedule.Read.All"

# Step 1: Find the Team's GroupId
Get-Team | Select-Object DisplayName, GroupId

# Step 2: Retrieve shifts for the team
$TeamId = "d747dc60-9745-439c-8e09-e588cd240ea5"   # Replace with your actual TeamId
$Shifts = Get-MgBetaTeamScheduleShift -TeamId $TeamId

$Shifts | Select-Object Id, @{N="Start";E={$_.SharedShift.StartDateTime}},
                              @{N="End";E={$_.SharedShift.EndDateTime}},
                              @{N="UserId";E={$_.UserId}}
```

### Get TeamId via PowerShell

```powershell
Connect-MicrosoftTeams
Get-Team | Select-Object DisplayName, GroupId | Sort-Object DisplayName
```

**Reference:**  
- [GET /teams/{teamId}/schedule/shifts](https://learn.microsoft.com/en-us/graph/api/schedule-list-shifts)  
- [Microsoft.Graph.Beta.Teams module](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.beta.teams/)

---

## 4. Identity and Sign-In Authorization Policies

The **Authorization Policy** in Azure AD / Entra ID controls tenant-wide settings like user consent, guest access behaviour, and self-service sign-up.

### Install and Import

```powershell
Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force -Verbose
Import-Module Microsoft.Graph.Identity.SignIns
```

### Connect with Required Scope

```powershell
Connect-MgGraph -Scopes "User.Read.All", "Policy.Read.All"
```

### Read the Authorization Policy

```powershell
Get-MgPolicyAuthorizationPolicy | Format-List *
```

### Key Properties to Review

| Property | Description |
|----------|-------------|
| `AllowInvitesFrom` | Who can invite external users (admins only, members, all users) |
| `AllowedToSignUpEmailBasedSubscriptions` | Whether users can self-sign-up for free services |
| `AllowedToUseSSPR` | Whether self-service password reset is enabled |
| `DefaultUserRolePermissions` | What a standard member can do (create apps, groups, tenants) |
| `GuestUserRoleId` | Guest permission level (restricted vs member-equivalent) |

### Restrict Guest Permissions (Example)

```powershell
# Set guest user permissions to most-restricted (guest access level)
Update-MgPolicyAuthorizationPolicy -AllowInvitesFrom "adminsAndGuestInviters"
```

**Reference:** [Authorization Policy — Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/authorizationpolicy-get)

---

## 5. Common Graph Scopes Reference

| Scope | Access Level | Use Case |
|-------|-------------|----------|
| `User.Read.All` | Application/Delegated | Read all users in the directory |
| `User.ReadWrite.All` | Application/Delegated | Create/update/delete users |
| `Group.Read.All` | Application/Delegated | Read all groups including M365 groups |
| `Group.ReadWrite.All` | Application/Delegated | Create/manage groups |
| `Mail.Send` | Application/Delegated | Send email as any user |
| `Mail.ReadWrite` | Application/Delegated | Read and write mailbox |
| `Calendars.ReadWrite` | Delegated | Manage calendar events |
| `Schedule.Read.All` | Application/Delegated | Read Teams Shifts schedules |
| `Schedule.ReadWrite.All` | Application/Delegated | Write Teams Shifts data |
| `Policy.Read.All` | Application/Delegated | Read Azure AD policies |
| `Reports.Read.All` | Application/Delegated | Read M365 usage reports |
| `AuditLog.Read.All` | Application | Read Azure AD audit logs |

> **Admin consent:** Application-level permissions require an admin to grant consent at the tenant level. Delegated permissions are granted per user.

---

## 6. Running Raw Graph API Calls from PowerShell

When the PowerShell SDK module for a specific endpoint is not available, call the REST API directly via `Invoke-MgGraphRequest`:

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# GET request
$Response = Invoke-MgGraphRequest -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/users?`$select=displayName,userPrincipalName,assignedLicenses"

$Response.value | Select-Object displayName, userPrincipalName

# POST request (example: send a message)
$Body = @{
    message = @{
        subject = "Test"
        body = @{ contentType = "Text"; content = "Hello" }
        toRecipients = @( @{ emailAddress = @{ address = "user@contoso.com" } } )
    }
} | ConvertTo-Json -Depth 10

Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/users/sender@contoso.com/sendMail" `
    -Body $Body `
    -ContentType "application/json"
```

**References:**
- [Microsoft Graph API reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
- [Microsoft Graph PowerShell SDK — authentication](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands)
