# Microsoft 365 Troubleshooting Knowledge Base

> A curated reference repository built from real-world case resolutions during my tenure as a **Technical Support Engineer at Microsoft**, specializing in the **Microsoft 365 SaaS** platform — with a strong focus on Exchange Online, Identity, Compliance, and Power Platform.

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
| 19 | PowerShell Scripts | [scripts/](scripts/) |

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

## 📜 Disclaimer

All resolutions are based on real case work. Company names, UPNs, and identifiers in code samples have been anonymized or replaced with generic placeholders (e.g., `user@contoso.com`).

> **Microsoft Docs Reference:** https://learn.microsoft.com/en-us/microsoft-365/