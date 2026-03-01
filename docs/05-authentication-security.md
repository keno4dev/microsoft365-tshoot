# Authentication & Security

> **Category:** Authentication, Identity, Security  
> **Applies to:** Exchange Online, Azure AD / Entra ID, Microsoft 365

---

## 1. Modern Authentication vs. Legacy Authentication

| Feature | Modern Auth (OAuth 2.0) | Legacy Auth (Basic Auth) |
|---------|:---:|:---:|
| MFA Support | ✅ Yes | ❌ No |
| Conditional Access | ✅ Yes | ❌ No |
| Deprecated by Microsoft? | No | ✅ Yes (Oct 2022) |
| Supported Protocols | MAPI/HTTP, EWS, OWA, ActiveSync | POP, IMAP, SMTP AUTH, RPC |

> **Microsoft announcement:** As of **October 1, 2022**, Microsoft permanently disabled Basic Authentication for Exchange Online across all tenants (except SMTP AUTH).

---

## 2. Check Modern Authentication Status

```powershell
Connect-ExchangeOnline

# View current OAuth2 / Modern Auth state
Get-OrganizationConfig | Format-Table Name, OAuth* -AutoSize
```

---

## 3. Enable / Disable Modern Authentication

### Enable Modern Auth (Outlook 2013+)

```powershell
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
```

### Force Basic Auth (legacy clients only — not recommended)

```powershell
Set-OrganizationConfig -OAuth2ClientProfileEnabled $false
```

---

## 4. Legacy Authentication — Security Defaults

When **Security Defaults** are enabled in your tenant, all requests using legacy protocols are **automatically blocked**.

### Affected Legacy Protocols

- Microsoft Office 2013 and older
- POP3, IMAP, SMTP AUTH
- Exchange ActiveSync (basic auth variant)

### References

- [Security Defaults — Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults)
- [Block Legacy Authentication — Conditional Access](https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/block-legacy-authentication)
- [Deprecation of Basic Auth in Exchange Online](https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/deprecation-of-basic-authentication-exchange-online)

---

## 5. Re-enable Basic Auth for POP / IMAP (via Authentication Policy)

> Use this only if explicitly required by a legacy third-party application that cannot be upgraded.

```powershell
# Re-enable Basic Auth for POP and IMAP on a specific policy
Set-AuthenticationPolicy -Identity "<Policy Name>" -AllowBasicAuthPop -AllowBasicAuthImap

# Force token refresh immediately (otherwise waits for expiry)
Set-User -Identity "user@contoso.com" -STSRefreshTokensValidFrom $([System.DateTime]::UtcNow)
```

---

## 6. POP3 Error — "Message corrupted" / Non-success Response

### Symptom

```
PopCmdResp: -ERR Message corrupted
Non-success POP3 response status line
Failed to fetch POP3 email
```

### Root Cause

This is typically caused by **Basic Authentication being disabled** for POP3. Since October 2022, Microsoft disabled Basic Auth for Exchange Online. Third-party apps using POP3 with Basic Auth will fail.

### Resolution Options

1. **Migrate the application to Modern Authentication** (recommended).
2. **Use SMTP2GO or another third-party relay** to avoid touching the M365 tenant security posture.
3. If unavoidable, create an authentication policy to re-enable Basic Auth for POP only (see section 5 above).

> **Note on POP3 behavior:** POP3 downloads emails to the local device and removes them from the server. This means emails are only accessible on the machine they were downloaded to — not across devices.

---

## 7. Multifactor Authentication (MFA) Troubleshooting

### User Not Receiving MFA Codes

A user who is **blocked** in MFA will not receive authentication requests. The block automatically expires after **90 days**.

### Resolution — Unblock a User

```
Azure Active Directory Admin Center
  → All Services
  → MFA
  → Block / Unblock Users
  → Find the user → Click "Unblock"
```

> Alternatively, use the Azure AD portal: `portal.azure.com → Azure Active Directory → Security → MFA → Block/Unblock users`

---

## 8. Users Being Deleted via PowerShell (Security Incident)

### Symptom

Users are being deleted automatically by PowerShell commands without any admin knowingly initiating them.

### Resolution

> **This action may be malicious.**

Immediate steps:

1. **Change passwords** for all Global Admin accounts immediately.
2. **Enable MFA** for all privileged users (Global Admin, Exchange Admin, User Admin, etc.).
3. Review **Audit Logs** in the Microsoft 365 Compliance Center for unauthorized activity.
4. Review **Risk Sign-in events** in Entra ID → Security → Risky sign-ins.
5. Consider enabling **Privileged Identity Management (PIM)** if Entra ID P2 is available.

```powershell
# Review recent deletions in audit log
Search-UnifiedAuditLog -Operations "Delete user" -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
```

---

## 9. User Cannot Log In to Account

### Resolution Steps

1. Open the browser in **Incognito mode** and navigate to `portal.microsoft.com`.
2. Attempt to sign in — if successful, the issue is browser cache/cookie related.
3. Clear the browser cache if needed.
4. If the account requires a license, assign one:
   - Navigate to: `Microsoft 365 Admin Center → Users → Active Users → [Username] → Licenses and Apps → Select a license → Save`

---

## 10. DLP Rule Exceptions — Keyword in Subject Line

### Symptom
DLP exception options (e.g., keyword-based exceptions on email subject) are available in one tenant but not another.

### Resolution

```
Exchange Admin Center
  → Compliance
  → Data Loss Prevention (DLP)
  → Select the policy → Edit
  → Choose locations
  → Turn OFF "Teams chat and channel messages" if not required
  → Re-check available exception conditions
```

> Disabling Teams chat from the DLP scope may re-expose subject-based exception filters in some configurations.

---

## References

- [Security Defaults](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults)
- [Block Legacy Authentication with Conditional Access](https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/block-legacy-authentication)
- [Deprecation of Basic Auth — Exchange Online](https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/deprecation-of-basic-authentication-exchange-online)
- [MFA Deployment Guide](https://learn.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-getstarted)
- [Privileged Identity Management](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure)
