# Active Directory Lab

A self-directed Active Directory / Windows Server lab, built on a Windows
Server 2022 domain controller running in VirtualBox, as part of a
sysadmin-focused learning path. This repo documents hands-on work across
domain design, user/group administration, Group Policy, DNS, and PowerShell
automation, including the real debugging process behind each one, not just
the finished configuration.

## Contents

| Section | What it covers |
|---|---|
| [01 - Domain Design](docs/01-domain-design.md) | Domain/OU structure, plus a design exercise on structuring AD for a company acquisition scenario (domains vs. trees vs. forests) |
| [02 - Users and Groups](docs/02-users-and-groups.md) | Security vs. Distribution groups, group scope, and a non-obvious SID-persistence edge case |
| [03 - Group Policy](docs/03-group-policy.md) | GPO inheritance, Block Inheritance, and why Enforced is designed to override it |
| [04 - DNS Troubleshooting](docs/04-dns-troubleshooting.md) | A real diagnostic case: DNS timeouts traced to a documented AD DS synchronization dependency, via Event Viewer logs |
| [05 - PowerShell Automation](docs/05-powershell-automation.md) | `New-EmployeeAccounts.ps1`: bulk AD user creation from CSV, and five real bugs found and fixed through deliberate edge-case testing |

## The script

[`New-EmployeeAccounts.ps1`](New-EmployeeAccounts.ps1) — reads a CSV of new
employees and creates AD accounts automatically, with input validation,
automatic collision handling for both usernames and display names, and
full logging. See [Section 5](docs/05-powershell-automation.md) for the
debugging story behind it.

## Environment

- Windows Server 2022 (Evaluation), domain controller (`lab.local`)
- VirtualBox, NAT networking
- PowerShell + the Active Directory module