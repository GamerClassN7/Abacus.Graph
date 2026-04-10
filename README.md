# Abacus.Graph
![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)

![](https://img.shields.io/gitea/v/tag/JonatanRek/AbacusPS?gitea_url=https://git.steelants.cz&sort=date)
![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/Abacus.Graph)
![Gitea last commit](https://img.shields.io/gitea/last-commit/JonatanRek/AbacusPS?gitea_url=https://git.steelants.cz)

Small yet powerful module for communication with Abacus/DESIGNA parking system over its WebService API from environment of PowerShell 7+.

### Connect to Service
```powershell
Install-Module Abacus.Graph -AllowPrerelease -Force
Import-Module Abacus.Graph

# create a SecureString first for -Password
$pw = ConvertTo-SecureString 'mypassword' -AsPlainText -Force

# call the function
Connect-AB -Uri 'http://abacus-server/abacus' -Username 'admin' -Password $pw
```

### Disconnect
```powershell
Disconnect-AB
```

---

## Cards

### Search cards (vehicles currently inside)

```powershell
# By licence plate (wildcard %)
Get-ABCards -Plate '%ABC%'

# By carrier number
Get-ABCards -Carrier '015364' -OnlyInsideCarpark $false

# By owner name
Get-ABCards -PersonName 'Novak'
```

#### Example output

```
id                 : 4217
owner_first_name   : Jan
owner_last_name    : Novák
price_name         : Permanent
valid_from         : 2025-01-01T00:00:00
valid_to           : 2026-12-31T23:59:59
last_usage         : 2026-04-09T08:14:22
last_plate         : 1AB2345
last_country_code  : CZ
applic_id_last_use : 3
time_coding        : 0
card_carrier       : 0153640001
carpark_id         : 1
```

### Move card virtually (check in / check out)

```powershell
# Manually — direction 1 = in, 0 = out
Move-ABCardVirtually -CardCarrier '0153640001' -CarparkId 1 -Direction 1

# Pipeline from Get-ABCards — CarparkId and CardCarrier bind automatically
Get-ABCards -Plate '%ABC%' | Move-ABCardVirtually -Direction 0

# By short card number
Move-ABCardVirtually -ShortCardNr '015364' -CarparkId 1 -Direction 1

# Preview without executing (-WhatIf)
Get-ABCards -Plate '%ABC%' | Move-ABCardVirtually -Direction 1 -WhatIf
```

---

## Terminals (Applic)

### List all terminals

```powershell
Get-ABApplic
```

#### Example output

```
ID   UId    Name          Type  Active  CarparkUId
--   ---    ----          ----  ------  ----------
3    A3F1   Entry Gate 1  1     True    C1
5    A5B2   Exit Gate 1   1     True    C1
```

### Get terminal state

```powershell
# Single terminal
Get-ABApplicState -Tcc 3

# Pipeline from Get-ABApplic
Get-ABApplic | Get-ABApplicState

# Only online terminals
Get-ABApplic | Get-ABApplicState | Where-Object IsOnline -eq $true
```

#### Example output

```
TccNo          : 3
InService      : True
IsOnline       : True
IsBarrierUp    : False
IsBarrierOn    : True
...
```

### Send command to terminal

```powershell
# Open barrier (command 45)
Send-ABApplicCommand -Tcc 3 -Command 45

# Close barrier (command 46)
Send-ABApplicCommand -Tcc 3 -Command 46

# Preview without executing (-WhatIf)
Send-ABApplicCommand -Tcc 3 -Command 45 -WhatIf
```

Command reference:

| Command | Action                        |
|---------|-------------------------------|
| 45      | Barrier open                  |
| 46      | Barrier close                 |
| 51      | TCC in service                |
| 52      | TCC out of service            |
| 81      | TCC reset                     |
| 83      | Barrier in service            |
| 84      | Barrier out of service        |
| 137     | Activate I/O-check            |
| 138     | Deactivate I/O-check          |
| 139     | Activate blacklist-check      |
| 140     | Deactivate blacklist-check    |

---

## Carpark counters

```powershell
Get-ABCarparkCounter -CarparkNo 1
```

#### Example output

```
MaxCarparkFull                       : 500
CurrentCarparkFullTotal              : 312
CurrentShortTermParker               : 87
CurrentSeasonParkerWithReservation   : 225
...
```

---

## Info

- [DESIGNA Abacus Parking System](https://www.designa.com)
