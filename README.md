# AUR Incident Audit

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A small, read-only audit script for Arch Linux users to quickly assess whether they may have been affected by the June 2026 AUR supply-chain incident.

## What it does

The script:

* Downloads the published list of affected AUR packages.
* Compares the list against currently installed AUR packages.
* Scans common AUR helper caches (`yay`, `paru`, `pikaur`, `aura`) for known malicious package names.
* Reviews pacman activity during the reported incident window.
* Produces a concise summary for manual review.

The script **does not modify your system**, remove packages, or perform any automatic remediation.

## Why this exists

In June 2026, multiple AUR packages were temporarily modified to include malicious dependencies as part of a supply-chain attack. Arch Linux maintainers published a list of known affected packages, while noting that the list might not be exhaustive.

This project was created to provide a simple first-pass audit that helps users quickly determine whether further investigation may be necessary.

## Features

* Read-only operation
* No root privileges required
* Works with Arch Linux and Arch-based distributions
* Supports multiple AUR helpers
* Uses standard system utilities
* Fast and lightweight
* Safe to run on production systems

## Requirements

* Arch Linux or an Arch-based distribution
* `pacman`
* Either:

  * `curl`, or
  * `wget`

## Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/aur-incident-audit.git
cd aur-incident-audit
```

Make the script executable:

```bash
chmod +x aur-incident-audit.sh
```

## Usage

Run the audit:

```bash
./aur-incident-audit.sh
```

Example output:

```text
== AUR Incident Audit ==

[1/5] Collecting installed AUR packages...
[2/5] Downloading affected package list...
[3/5] Parsing affected package names...
[4/5] Comparing with installed AUR packages...

No installed AUR packages matched the downloaded affected list.

[5/5] Scanning common AUR helper caches...

Done.
```

## How it Works

The script performs several checks:

### 1. Installed AUR Package Audit

Retrieves all currently installed AUR packages using:

```bash
pacman -Qqm
```

and compares them against the published list of affected packages.

### 2. Build Cache Inspection

Searches common AUR helper caches for known malicious dependency names, including:

* `atomic-lockfile`
* `js-digest`
* `lockfile-js`

Supported helper caches:

* `~/.cache/yay`
* `~/.cache/paru`
* `~/.cache/pikaur`
* `~/.cache/aura`

### 3. Historical Package Activity Review

Reviews package installation and upgrade activity during the reported incident period to help identify potentially relevant package operations.

## Interpreting Results

### No Matches Found

If:

* No installed packages match the affected list
* No suspicious dependency names are found in helper caches

then you are likely unaffected by the known indicators associated with the incident.

### Matches Found

If packages are reported:

1. Review package information:

```bash
pacman -Qi <package>
```

2. Inspect the PKGBUILD:

```bash
yay -G <package>
```

or

```bash
paru -G <package>
```

3. Determine whether removal, rebuilding, or further investigation is appropriate.

## Limitations

This tool has important limitations:

* Relies on publicly available indicators and package lists.
* Cannot guarantee detection of all compromised packages.
* Cannot determine whether malicious code executed successfully.
* Cannot perform forensic analysis.
* May not detect future variants of similar attacks.
* Should be considered a triage and assessment tool.

## Security Recommendations

If you believe you installed or built a compromised package during the affected period:

* Rotate SSH keys if exposure is possible.
* Revoke and regenerate API tokens.
* Review GitHub, GitLab, cloud provider, npm, and CI/CD credentials.
* Review shell history and recent system activity.
* Consider rebuilding affected environments from trusted sources.
* Perform a more thorough security review.

## Disclaimer

This tool is intended for informational and auditing purposes only.

It performs a limited set of checks based on publicly available information and known indicators associated with the June 2026 AUR supply-chain incident.

The absence of warnings or matches does **not** guarantee that a system is uncompromised. Likewise, a reported match does **not** necessarily indicate successful compromise.

This utility is a triage tool, not a forensic analysis tool.

The software is provided "as is", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and noninfringement.

The authors are not affiliated with the Arch Linux project and cannot guarantee detection of all affected systems, malicious packages, or future variants of similar attacks.

Always perform your own investigation before taking remediation actions.
