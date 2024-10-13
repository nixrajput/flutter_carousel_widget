# Security Policy

## Supported Versions

The following versions of the `flutter_carousel_widget` package are currently being supported with security updates:

| Version | Supported          |
|---------|--------------------|
| 3.x.x   | :white_check_mark: |
| 2.x.x   | :white_check_mark: |
| 1.x.x   | :x:                |

If you are using an older, unsupported version, we recommend upgrading to the latest version to benefit from security fixes.

## Reporting a Vulnerability

We take security issues seriously. If you discover any security vulnerabilities or potential issues in the carousel widget package, please report them to us privately to allow us to investigate and address the issue before it is publicly disclosed.

### To report a vulnerability:

- **Email:** [`nkr.nikhil.nkr@gmail.com`, `nixlab.in@gmail.com`]
- **Subject:** Security Issue in FlutterCarouselWidget Package
- **Information to include:**
    - A description of the vulnerability
    - Steps to reproduce (if applicable)
    - The impact of the vulnerability
    - Any potential fixes or patches

Please **do not** publicly disclose security vulnerabilities until we have confirmed and addressed them. We will work quickly to investigate and fix the issue.

### Response Time:

We aim to respond to vulnerability reports within **48 hours** and will work closely with you to understand and resolve the issue as quickly as possible.

## Security Best Practices

When using the Flutter carousel widget package in your project, consider the following security best practices:

1. **Keep the package up to date:**  
   Always use the latest version of the carousel widget package to ensure you have the most recent security fixes and updates.

2. **Review dependencies:**  
   Ensure that all other dependencies in your project are up-to-date and free from vulnerabilities. Use tools like `pub outdated` to identify and update outdated packages.

3. **Input Validation:**  
   When using dynamic content (e.g., image URLs, widgets) with the carousel, validate and sanitize any external data to prevent potential attacks like XSS or injection attacks.

4. **User Interaction:**  
   Ensure that user interaction with the carousel widget (e.g., gestures, swipes) does not open the door for unintended behavior or exploits.

## Patching and Updates

We commit to regularly reviewing and updating the package with necessary security patches. Critical security vulnerabilities will be patched and released as soon as possible. If a critical fix is required, we will:

- Prioritize the vulnerability fix
- Release a patch version immediately
- Notify users through the release notes and the changelog

---

By adhering to these guidelines, you help ensure a more secure experience when using the `flutter_carousel_widget` package.