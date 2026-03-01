# Microsoft 365 Troubleshooting Knowledge Base

> A curated reference repository built from real-world case resolutions during my tenure as a **Technical Support Engineer at Microsoft**, specializing in the **Microsoft 365 SaaS** platform — with a strong focus on Exchange Online, Identity, Compliance, Teams and SharePoint Online.

---

## 🛑 Try Self-Help First — Before Contacting Microsoft Support

> **This repository exists so you can resolve your Microsoft 365 issue yourself — quickly, without waiting in a support queue.**
>
> All documented resolutions align with standard Microsoft Support procedures. Search the [Quick Reference table](#-quick-reference-by-symptom) below for your symptom, follow the steps, and validate the fix before escalating.
>
> **If self-remediation is unsuccessful**, or if the issue requires tenant-level intervention, account recovery, or billing changes — Microsoft 365 subscribers are entitled to **free technical support**. See [doc 26 — Contacting Microsoft Support](docs/26-contacting-microsoft-support.md) for all contact methods, phone numbers, the Quick Assist remote tool, and guidance on what to prepare before you call.
>
> ⏱️ Most issues in this knowledge base can be self-resolved in under 15 minutes.

---

## 📂 Repository Structure

| # | Category | File |
|---|----------|------|
| 1 | Exchange Online Connectivity | [01-exchange-online-connectivity.md](docs/01-exchange-online-connectivity.md) |
| 2 | Mailbox Management | [02-mailbox-management.md](docs/02-mailbox-management.md) |
| 3 | Mail Flow & SMTP | [03-mail-flow-smtp.md](docs/03-mail-flow-smtp.md) |
| 4 | Email Tracking & Read Status | [04-email-tracking-read-status.md](docs/04-email-tracking-read-status.md) |
| 5 | Authentication & Security | [05-authentication-security.md](docs/05-authentication-security.md) |
| 6 | User Management | [06-user-management.md](docs/06-user-management.md) |
| 7 | Distribution Groups & Shared Mailboxes | [07-distribution-groups-shared-mailboxes.md](docs/07-distribution-groups-shared-mailboxes.md) |
| 8 | Compliance, eDiscovery & Retention | [08-compliance-ediscovery.md](docs/08-compliance-ediscovery.md) |
| 9 | GAL & Offline Address Book | [09-gal-oab.md](docs/09-gal-oab.md) |
| 10 | Outlook & OWA Issues | [10-outlook-owa.md](docs/10-outlook-owa.md) |
| 11 | Microsoft 365 Groups & Teams | [11-m365-groups-teams.md](docs/11-m365-groups-teams.md) |
| 12 | Calendar Issues & Resolutions | [12-calendar-issues-resolutions.md](docs/12-calendar-issues-resolutions.md) |
| 13 | Email Encryption & IRM | [13-email-encryption.md](docs/13-email-encryption.md) |
| 14 | M365 Licensing Issues | [14-m365-licensing-issues.md](docs/14-m365-licensing-issues.md) |
| 15 | Mailbox Archive Issues | [15-mailbox-archive-issues.md](docs/15-mailbox-archive-issues.md) |
| 16 | Outlook Issues & Resolutions | [16-outlook-issues-resolutions.md](docs/16-outlook-issues-resolutions.md) |
| 17 | Security & Compliance in Exchange | [17-security-compliance-exchange.md](docs/17-security-compliance-exchange.md) |
| 18 | Exchange Online Mailbox Auditing | [18-exchange-mailbox-auditing.md](docs/18-exchange-mailbox-auditing.md) |
| 19 | Audit Log Configuration | [19-audit-log-configuration.md](docs/19-audit-log-configuration.md) |
| 20 | Bulk Password Change for Migration | [20-bulk-password-change-migration.md](docs/20-bulk-password-change-migration.md) |
| 21 | Enterprise Best Practices — Azure AD / Entra ID | [21-enterprise-best-practices-azuread-entraid.md](docs/21-enterprise-best-practices-azuread-entraid.md) |
| 22 | General Guide for Running PowerShell Scripts | [22-general-guide-powershell-scripts.md](docs/22-general-guide-powershell-scripts.md) |
| 23 | Generating Exchange Online Usage Reports | [23-generating-exo-usage-reports.md](docs/23-generating-exo-usage-reports.md) |
| 24 | Sending Email via PowerShell | [24-sending-email-via-powershell.md](docs/24-sending-email-via-powershell.md) |
| 25 | Microsoft Graph PowerShell API | [25-microsoft-graph-powershell-api.md](docs/25-microsoft-graph-powershell-api.md) |
| 26 | Contacting Microsoft Support | [26-contacting-microsoft-support.md](docs/26-contacting-microsoft-support.md) |
| 27 | Integrating Google Workspace with Microsoft 365 | [27-integrate-google-workspace-m365.md](docs/27-integrate-google-workspace-m365.md) |
| 28 | Customer Service Foundation | [28-customer-service-foundation.md](docs/28-customer-service-foundation.md) |
| 29 | Microsoft Teams — Issues and Resolutions | [29-microsoft-teams-issues.md](docs/29-microsoft-teams-issues.md) |
| 30 | OneDrive — Issues and Resolutions | [30-onedrive-issues.md](docs/30-onedrive-issues.md) |
| 31 | SharePoint Online Administration | [31-sharepoint-online.md](docs/31-sharepoint-online.md) |
| 32 | PowerShell Scripts | [scripts/](scripts/) |

---

## 🔍 Quick Reference by Symptom

| Symptom / Issue | Where to Look |
|-----------------|---------------|
| Cannot connect to Exchange Online PowerShell | [01 - Connectivity](docs/01-exchange-online-connectivity.md) |
| Mailbox size limit, quota errors | [02 - Mailbox Management](docs/02-mailbox-management.md) |
| Email sent but not received / NDR | [03 - Mail Flow & SMTP](docs/03-mail-flow-smtp.md) |
| SMTP AUTH errors, legacy TLS issues | [03 - Mail Flow & SMTP](docs/03-mail-flow-smtp.md) |
| Who read my email? | [04 - Email Tracking](docs/04-email-tracking-read-status.md) |
| MFA not working / user blocked | [05 - Authentication & Security](docs/05-authentication-security.md) |
| Legacy auth / Basic Auth / POP3 / IMAP errors | [05 - Authentication & Security](docs/05-authentication-security.md) |
| Deleted user recovery / permanent delete | [06 - User Management](docs/06-user-management.md) |
| Bulk domain change for users | [06 - User Management](docs/06-user-management.md) |
| Distribution group audit / shared mailbox permissions | [07 - Groups & Shared Mailboxes](docs/07-distribution-groups-shared-mailboxes.md) |
| Delete emails without notifying attendees | [08 - Compliance & eDiscovery](docs/08-compliance-ediscovery.md) |
| Retention policies | [08 - Compliance & eDiscovery](docs/08-compliance-ediscovery.md) |
| GAL / OAB not updating | [09 - GAL & OAB](docs/09-gal-oab.md) |
| Outlook signature, OWA redirect, auto-reply | [10 - Outlook & OWA](docs/10-outlook-owa.md) |
| M365 Group not showing in Outlook | [11 - M365 Groups & Teams](docs/11-m365-groups-teams.md) |
| Calendar invites going to wrong user | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Meeting room allows double bookings | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Calendar change notifications going to Deleted Items | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Corrupted calendar delegation / cannot accept invites | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Cancel all meetings for a departing user | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Repeating meeting invitations sent daily | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Share org-wide calendar with all users | [12 - Calendar Issues](docs/12-calendar-issues-resolutions.md) |
| Cannot open encrypted email from external sender (Outlook 2019) | [13 - Email Encryption](docs/13-email-encryption.md) |
| Desktop Outlook cannot encrypt — OWA works fine | [13 - Email Encryption](docs/13-email-encryption.md) |
| "Your machine isn't setup for IRM" error | [13 - Email Encryption](docs/13-email-encryption.md) |
| S/MIME certificate not found error in OWA | [13 - Email Encryption](docs/13-email-encryption.md) |
| Shared mailbox cannot open / send encrypted email | [13 - Email Encryption](docs/13-email-encryption.md) |
| IRM Protect button missing in Outlook / OWA | [13 - Email Encryption](docs/13-email-encryption.md) |
| Enable IRM / AIP for Exchange Online tenant | [13 - Email Encryption](docs/13-email-encryption.md) |
| How many devices can access a shared mailbox? | [14 - M365 Licensing](docs/14-m365-licensing-issues.md) |
| Bulk assign / remove licenses via PowerShell | [14 - M365 Licensing](docs/14-m365-licensing-issues.md) |
| Office 5-device limit confusion | [14 - M365 Licensing](docs/14-m365-licensing-issues.md) |
| Recoverable Items quota exceeded / 554 5.2.0 error | [15 - Mailbox Archive](docs/15-mailbox-archive-issues.md) |
| Archive mailbox not moving items / Managed Folder Assistant | [15 - Mailbox Archive](docs/15-mailbox-archive-issues.md) |
| Enable auto-expanding archive | [15 - Mailbox Archive](docs/15-mailbox-archive-issues.md) |
| Start-ManagedFolderAssistant RPC error | [15 - Mailbox Archive](docs/15-mailbox-archive-issues.md) |
| Litigation hold setup and bulk operations | [15 - Mailbox Archive](docs/15-mailbox-archive-issues.md) |
| Outlook hangs / slow to open emails | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Outlook not showing new emails (desktop only) | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Outlook connectivity test failing / ADAL WAM errors | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Outlook prompting for password repeatedly | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Outlook shows Disconnected — profile reset needed | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Sent emails saving to user's Sent Items instead of shared mailbox | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Outlook creates 100,000+ contacts automatically | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Outlook 500 Unexpected Error in EAC / OWA | [16 - Outlook Issues](docs/16-outlook-issues-resolutions.md) |
| Compromised account — tenant blocked from sending email | [17 - Security & Compliance](docs/17-security-compliance-exchange.md) |
| Configure DKIM for a custom domain | [17 - Security & Compliance](docs/17-security-compliance-exchange.md) |
| Quarantined email stuck as "Needs review" | [17 - Security & Compliance](docs/17-security-compliance-exchange.md) |
| SMTP legacy device cannot authenticate (Security Defaults) | [17 - Security & Compliance](docs/17-security-compliance-exchange.md) |
| Cannot delete retention policy in Microsoft Purview | [17 - Security & Compliance](docs/17-security-compliance-exchange.md) |
| Skip spam filtering for specific domains from same IP | [17 - Security & Compliance](docs/17-security-compliance-exchange.md) |
| Enable mailbox audit logging for all users | [18 - Mailbox Auditing](docs/18-exchange-mailbox-auditing.md) |
| Who accessed a mailbox? Non-owner access report | [18 - Mailbox Auditing](docs/18-exchange-mailbox-auditing.md) |
| Export mailbox audit logs | [18 - Mailbox Auditing](docs/18-exchange-mailbox-auditing.md) |
| Search Unified Audit Log via PowerShell | [18 - Mailbox Auditing](docs/18-exchange-mailbox-auditing.md) |
| Cannot open audit log XML export in OWA | [19 - Audit Log Config](docs/19-audit-log-configuration.md) |
| Grant user access to mailbox audit logs via Purview | [19 - Audit Log Config](docs/19-audit-log-configuration.md) |
| Default audit logging behaviour in Exchange Online | [19 - Audit Log Config](docs/19-audit-log-configuration.md) |
| Admin audit log — who made changes to mailboxes? | [19 - Audit Log Config](docs/19-audit-log-configuration.md) |
| Bulk reset passwords before migration | [20 - Bulk Password Change](docs/20-bulk-password-change-migration.md) |
| Force password change on next sign-in for all users | [20 - Bulk Password Change](docs/20-bulk-password-change-migration.md) |
| Reset passwords from CSV via PowerShell | [20 - Bulk Password Change](docs/20-bulk-password-change-migration.md) |
| Reset passwords using Microsoft Graph (modern) | [20 - Bulk Password Change](docs/20-bulk-password-change-migration.md) |
| Azure AD Connect ImmutableId mismatch | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Soft-match vs hard-match AD Connect user | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Hard-match on-premises AD user to cloud Azure AD user | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| UPN soft-match not working — ImmutableId blocking | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Distribution group not syncing to Microsoft 365 | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Attribute Editor tab missing in ADUC | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Required ports for Active Directory communication | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| FSMO role query and transfer commands | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Uninstall / reinstall Azure AD Connect manually | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| AD Connect sync error — no-start-ma / dll-exception | [21 - Azure AD Best Practices](docs/21-enterprise-best-practices-azuread-entraid.md) |
| Set-ExecutionPolicy for PowerShell scripts | [22 - PowerShell Guide](docs/22-general-guide-powershell-scripts.md) |
| Install MSOnline / Microsoft Graph / Teams modules | [22 - PowerShell Guide](docs/22-general-guide-powershell-scripts.md) |
| Log PowerShell session output to file | [22 - PowerShell Guide](docs/22-general-guide-powershell-scripts.md) |
| Diagnose Teams Auto Attendant via PowerShell | [22 - PowerShell Guide](docs/22-general-guide-powershell-scripts.md) |
| Get mailbox storage statistics for all users | [23 - EXO Usage Reports](docs/23-generating-exo-usage-reports.md) |
| Find mailboxes inactive for 30+ days | [23 - EXO Usage Reports](docs/23-generating-exo-usage-reports.md) |
| Export all Microsoft 365 Group members to CSV | [23 - EXO Usage Reports](docs/23-generating-exo-usage-reports.md) |
| Get top email senders / recipients | [23 - EXO Usage Reports](docs/23-generating-exo-usage-reports.md) |
| EXO reporting cmdlets deprecated — use Graph instead | [23 - EXO Usage Reports](docs/23-generating-exo-usage-reports.md) |
| Send email from PowerShell script | [24 - Sending Email via PS](docs/24-sending-email-via-powershell.md) |
| SMTP AUTH error 5.7.57 from PowerShell | [24 - Sending Email via PS](docs/24-sending-email-via-powershell.md) |
| Send-MailMessage deprecated — modern alternative | [24 - Sending Email via PS](docs/24-sending-email-via-powershell.md) |
| Send email with attachment, CC, BCC via PowerShell | [24 - Sending Email via PS](docs/24-sending-email-via-powershell.md) |
| Send HTML email from PowerShell | [24 - Sending Email via PS](docs/24-sending-email-via-powershell.md) |
| Send email without user credentials (app registration) | [24 - Sending Email via PS](docs/24-sending-email-via-powershell.md) |
| Get Teams Shifts schedule via Graph API | [25 - Microsoft Graph API](docs/25-microsoft-graph-powershell-api.md) |
| Install Microsoft.Graph.Beta.Teams module | [25 - Microsoft Graph API](docs/25-microsoft-graph-powershell-api.md) |
| Read Azure AD Authorization Policy via Graph | [25 - Microsoft Graph API](docs/25-microsoft-graph-powershell-api.md) |
| Run raw Graph REST queries from PowerShell | [25 - Microsoft Graph API](docs/25-microsoft-graph-powershell-api.md) |
| Common Microsoft Graph permission scopes reference | [25 - Microsoft Graph API](docs/25-microsoft-graph-powershell-api.md) |
| How to contact Microsoft Support for M365 | [26 - Contacting MSFT Support](docs/26-contacting-microsoft-support.md) |
| Microsoft Support phone numbers by country | [26 - Contacting MSFT Support](docs/26-contacting-microsoft-support.md) |
| Open a service request in the M365 Admin Center | [26 - Contacting MSFT Support](docs/26-contacting-microsoft-support.md) |
| Quick Assist — remote support tool for Windows | [26 - Contacting MSFT Support](docs/26-contacting-microsoft-support.md) |
| What to prepare before calling Microsoft Support | [26 - Contacting MSFT Support](docs/26-contacting-microsoft-support.md) |
| Both Google Workspace and Microsoft 365 on same domain | [27 - Google + M365 Coexistence](docs/27-integrate-google-workspace-m365.md) |
| SPF record for both Google and Microsoft | [27 - Google + M365 Coexistence](docs/27-integrate-google-workspace-m365.md) |
| DKIM records for two email providers | [27 - Google + M365 Coexistence](docs/27-integrate-google-workspace-m365.md) |
| Forward email from Google to Microsoft (or vice versa) | [27 - Google + M365 Coexistence](docs/27-integrate-google-workspace-m365.md) |
| Google Calendar interop with Microsoft Teams | [27 - Google + M365 Coexistence](docs/27-integrate-google-workspace-m365.md) |
| Handling abusive or frustrated support customers | [28 - Customer Service](docs/28-customer-service-foundation.md) |
| Ownership language vs deflected language | [28 - Customer Service](docs/28-customer-service-foundation.md) |
| Active listening techniques for support | [28 - Customer Service](docs/28-customer-service-foundation.md) |
| Managing customer expectations on resolution timelines | [28 - Customer Service](docs/28-customer-service-foundation.md) |
| Enable Enterprise Voice for Teams user | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Assign calling plan or direct routing phone number | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Cannot add guest user to Teams private channel | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Cannot send attachments in Microsoft Teams | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Clear Microsoft Teams cache on Windows | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Cannot open PowerPoint file from Teams | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Collect Teams diagnostic logs | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Display name not updated in Teams after Admin Center change | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Disable channel creation for all Teams | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Guest users cannot join Townhall meetings | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| Microsoft Store missing or not opening on Windows | [29 - Teams Issues](docs/29-microsoft-teams-issues.md) |
| OneDrive not setting up on Windows desktop | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| OneDrive sync client reset and clean reinstall | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| Collect OneDrive sync logs for troubleshooting | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| OneDrive sync paused — storage full | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| Files stuck uploading in OneDrive | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| OneDrive Known Folder Move setup | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| OneDrive storage usage report for all users (admin) | [30 - OneDrive Issues](docs/30-onedrive-issues.md) |
| Connect to SharePoint Online via PowerShell | [31 - SharePoint Online](docs/31-sharepoint-online.md) |
| Change the SharePoint tenant domain name | [31 - SharePoint Online](docs/31-sharepoint-online.md) |
| Change a SharePoint site URL | [31 - SharePoint Online](docs/31-sharepoint-online.md) |
| Replace the SharePoint root site with a new intranet | [31 - SharePoint Online](docs/31-sharepoint-online.md) |
| SharePoint site storage quota management | [31 - SharePoint Online](docs/31-sharepoint-online.md) |
| List all SharePoint sites over a storage threshold | [31 - SharePoint Online](docs/31-sharepoint-online.md) |

---

## 🛠️ Prerequisites

All PowerShell-based resolutions in this repo assume:

```powershell
# Execution Policy
Set-ExecutionPolicy RemoteSigned

# TLS 1.2 enforcement
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Core modules
Install-Module MSOnline
Install-Module ExchangeOnlineManagement
Install-Module Microsoft.Graph
Install-Module Microsoft.Graph.Beta
```

---

## 📜 Disclaimers

### Content and Accuracy

All resolutions are based on real case work completed during employment as a Technical Support Engineer at Microsoft. Company names, UPNs, tenant IDs, and other identifiers in code samples have been anonymized or replaced with generic placeholders (e.g., `user@contoso.com`, `contoso.onmicrosoft.com`).

> The information in this repository is provided **as-is**, without warranty of any kind. While every effort has been made to ensure accuracy, Microsoft 365 services, PowerShell modules, and API endpoints change over time. **Always validate against current Microsoft documentation before applying any fix in a production environment.**

### Not a Substitute for Official Support

> This repository is a **self-help resource** — it is not affiliated with, endorsed by, or a substitute for official Microsoft Support. If a fix in this repository does not resolve your issue, or if you are unsure whether a step is appropriate for your environment, **contact Microsoft Support** before proceeding. See [doc 26](docs/26-contacting-microsoft-support.md) for contact methods.
>
> Microsoft 365 business subscribers receive **free technical support** as part of their subscription. Use it.

### Registry and PowerShell Warning

> ⚠️ Some resolutions in this repository involve **registry edits**, **Active Directory schema changes (ADSI Edit)**, **tenant-level PowerShell commands**, and **DNS record modifications**. These operations can cause irreversible changes or service disruption if applied incorrectly.
>
> **Always back up Active Directory, export relevant registry keys, and test in a non-production environment before applying to production.** When in doubt, open a support ticket with Microsoft and share the relevant doc from this repository with the support engineer.

### Deprecation Notice

> Several cmdlets and modules referenced in this repository are **deprecated** by Microsoft:
> - `MSOnline` module (`Connect-MsolService`) — deprecated March 2024
> - `AzureAD` module (`Connect-AzureAD`) — deprecated March 2024
> - `Send-MailMessage` cmdlet — deprecated (no modern auth support)
> - `Get-MailTrafficTopReport` and related reporting cmdlets — deprecated January 2018
>
> Deprecated cmdlets may continue to function for a period after their deprecation date, but should not be used in new scripts. Migrate to **Microsoft Graph PowerShell** (`Microsoft.Graph` module) for all new automation.

### Microsoft Docs Reference

> **Official Microsoft documentation:** https://learn.microsoft.com/en-us/microsoft-365/  
> **Microsoft 365 Service Health Dashboard:** https://admin.microsoft.com (sign in → Health → Service health)  
> **Microsoft Graph API reference:** https://learn.microsoft.com/en-us/graph/api/overview