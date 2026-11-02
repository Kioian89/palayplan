# Security Policy

## Supported Versions

We provide security updates and patches for the following versions of PalayPlan:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1.0 | :x:                |

---

## Reporting a Vulnerability

The PalayPlan team takes the security of our application and the privacy of our farmers and users very seriously.

If you believe you have discovered a security vulnerability in PalayPlan (including mobile authentication, backend APIs, or local offline caching), please report it responsibly:

1. **Do not** report security vulnerabilities through public GitHub issues or discussions.
2. Email the maintainer directly at **anonymousdri544@gmail.com** with the subject line: `[SECURITY] PalayPlan Vulnerability Report`.
3. Include detailed steps to reproduce the issue, potential impact, and your suggested mitigation if available.

### What You Can Expect:
- **Acknowledgment**: You will receive an acknowledgment within 48 hours of receipt.
- **Assessment**: We will investigate and assess the vulnerability severity.
- **Resolution & Fix**: We will work on a patch and notify you before deploying the fix.
- **Credit**: We will gladly credit you in our release notes for responsible disclosure upon request.

---

## Farmer Data Privacy Commitment

PalayPlan is designed with privacy and offline independence at its core:
- Field coordinates and crop schedule dates are stored locally on the farmer's device (`SharedPreferences`).
- No farm location or harvest yield data is sold, monetized, or shared with third-party advertisers.
- OpenStreetMap and Zoom Earth integrations operate via client-side rendering without storing farmer identity on map tile servers.

