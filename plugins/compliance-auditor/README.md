# Compliance Auditor Plugin

Comprehensive compliance auditing tools for app policies, privacy, terms of service, DMCA, community guidelines, and App Store compliance.

## Features

### Commands

- **apple-compliance** - Audit app for Apple App Store Review Guidelines compliance
- **privacy-audit** - Audit privacy policy for GDPR, CCPA/CPRA compliance
- **terms-audit** - Audit terms of service for clarity and legal compliance
- **dmca-audit** - Audit DMCA/copyright policy for 17 U.S.C. § 512 compliance
- **guidelines-audit** - Audit community guidelines for clarity and completeness
- **policy-cohesion** - Audit all policy documents together for consistency
- **welcome-screen-audit** - Audit auth screens against modern UX best practices
- **modal-audit** - Audit modal components for consistency

## Installation

Add to your Claude Code plugins:

```bash
claude plugins add compliance-auditor
```

## Usage

### App Store Compliance
```
/apple-compliance
```

Audits your app against Apple's App Store Review Guidelines, checking:
- Safety requirements (UGC moderation, reporting)
- Performance (stability, metadata accuracy)
- Business (IAP, subscriptions)
- Design (HIG, accessibility)
- Legal & Privacy (permissions, privacy labels)

### Privacy Policy
```
/privacy-audit
```

Audits privacy policy for:
- GDPR compliance
- CPRA/CCPA compliance
- BIPA compliance (if biometrics used)
- Transparency and language quality
- User rights coverage

### Terms of Service
```
/terms-audit
```

Audits ToS for:
- Clarity and enforceability
- Fairness and balance
- Legal compliance (US, EU)
- Missing or ambiguous sections

### DMCA Policy
```
/dmca-audit
```

Audits DMCA policy for:
- Statutory requirements under 17 U.S.C. § 512
- Designated agent information
- Takedown/counter-notification procedures
- Repeat infringer policy

### Community Guidelines
```
/guidelines-audit
```

Audits community guidelines for:
- Clarity and user understanding
- Completeness of behavioral standards
- Consistency with other policies

### Policy Cohesion
```
/policy-cohesion
```

Audits all policy documents together for:
- Terminology consistency
- Tone alignment
- Redundancy detection
- Cross-reference completeness

### Welcome Screen
```
/welcome-screen-audit
```

Audits authentication flows for:
- Identity-first authentication pattern
- OAuth button compliance
- Visual hierarchy
- Security best practices

### Modal Audit
```
/modal-audit
```

Audits all modal components for:
- Close button consistency
- Cancel button usage
- Button styling standards
