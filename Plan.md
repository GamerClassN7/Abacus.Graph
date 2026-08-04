# Plán: Vytvoření AbacusPS (Abacus.Graph) modulu + update AbacusAPIBridge

## Kontext
AbacusAPIBridge momentálně volá Abacus WebService přímo z `app.ps1` bez žádného PS modulu. Cílem je extrahovat logiku do samostatného PS modulu `Abacus.Graph` (analogie `Cityline.Graph` z CitilinePS) a AbacusAPIBridge upravit tak, aby modul importoval — stejný pattern jako CitilineAPIBridge.

---

## Část 1: AbacusPS — vytvoření modulu `Abacus.Graph`

### Struktura souborů k vytvoření

```
/home/jonatanrek/WORK/_GIT/AbacusPS/
└── Abacus.Graph/
    ├── Abacus.Graph.psd1          # Manifest modulu
    ├── Abacus.Graph.psm1          # Root loader (identický pattern jako Abacus.Graph.psm1)
    └── functions/
        ├── Connect-AB.ps1
        ├── Disconnect-AB.ps1
        ├── Invoke-ABRequest.ps1
        ├── Get-ABApplic.ps1
        ├── Get-ABApplicState.ps1
        ├── Get-ABCards.ps1
        ├── Send-ABApplicCommand.ps1
        ├── Move-ABCardVirtually.ps1
        └── Get-ABCarparkCounter.ps1
```

### Abacus.Graph.psm1
Identický se `Abacus.Graph/Abacus.Graph.psm1` — načte všechny `.ps1` z `functions/`, přeskočí `dev_*` a `dep_*`, exportuje funkce.

Scope proměnné modulu:
- `$script:Uri` — base URL (`http://.../AbacusWebService`)
- `$script:Username` — Abacus user
- `$script:Password` — Abacus heslo (plain string — API to vyžaduje v HTTP POST)
- `$script:isConnected` — Bool

### Abacus.Graph.psd1
Kopie struktury z `Abacus.Graph.psd1` s:
- `RootModule = 'Abacus.Graph.psm1'`
- `GUID` = nový
- `Author = 'JonatanRek'`
- `Description` = 'Module for communication with Abacus/DESIGNA parking system WebService'
- `PowerShellVersion = '7.0'`
- `ProcessorArchitecture = 'Amd64'`
- `RequiredModules = @()` — žádné závislosti (není potřeba PowerHTML, API vrací XML)
- `FunctionsToExport = @('<FunctionsToExport>')` — placeholder pro publish.ps1

### Funkce modulu

#### `Connect-AB.ps1`
```powershell
function Connect-AB {
    param([string]$Uri, [string]$Username, [string]$Password)
    $script:Uri = $Uri
    $script:Username = $Username
    $script:Password = $Password
    $script:isConnected = $true
}
```
Na rozdíl od `Connect-CG` **nenavazuje HTTP session** (Abacus je stateless — každý request obsahuje user+pwd). Volitelně ověří konektivitu přes `alive()`.

#### `Disconnect-AB.ps1`
```powershell
function Disconnect-AB {
    $script:Uri = ''; $script:Username = ''; $script:Password = ''
    $script:isConnected = $false
}
```

#### `Invoke-ABRequest.ps1`
Wrapper pro HTTP POST na Abacus WebService. Automaticky přidá `user` a `pwd` z script scope.
```powershell
function Invoke-ABRequest {
    param(
        [string]$Service,   # 'ServiceOperation' nebo 'ServiceSystem'
        [string]$Method,    # název metody, např. 'getCardsByWildcardSearch'
        [hashtable]$Body = @{}
    )
    # Sestaví URL: $script:Uri + '/' + $Service + '.asmx/' + $Method
    # Přidá user/pwd do Body
    # Zavolá Invoke-RestMethod -Method POST -ContentType 'application/x-www-form-urlencoded'
    # URL-enkóduje hodnoty (stejný pattern jako stávající Invoke-AbacusRequest v app.ps1)
}
```

#### `Get-ABApplic.ps1`
Wraps `ServiceSystem.asmx/getApplicList` — vrátí seznam terminálů (bariéry, vjezdy, výjezdy).
```powershell
function Get-ABApplic { ... }
# Signature: List<ApplicData> getApplicList(string user, string pwd)
```

#### `Get-ABApplicState.ps1`
Wraps `ServiceSystem.asmx/getApplicState` — stav konkrétního terminálu (IsBarrierOn, IsBarrierUp, IsOnline atd.).
Podporuje pipeline z `Get-ABApplic` — `ApplicData.ID` se mapuje na `-Tcc` přes `ValueFromPipelineByPropertyName`.
```powershell
function Get-ABApplicState {
    [CmdletBinding()]
    param(
        [int]$System = 1,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('ID')]
        [int]$Tcc
    )
    process { ... }   # process block nutný pro pipeline zpracování
}
# Použití: Get-ABApplic | Get-ABApplicState
# Signature: ApplicStateData getApplicState(string user, string pwd, int System, int Tcc)
```

#### `Get-ABCards.ps1`
Wraps `ServiceOperation.asmx/getCardsByWildcardSearch` — extrahuje logiku z aktuálního app.ps1.

> **Poznámka k paginaci:** API nepodporuje server-side paginaci (v dokumentaci není žádná stránkovaná varianta). `getCardsByWildcardSearch` vrátí vždy celý výsledek. WinOperate stránkuje pouze na UI úrovni. Dotaz bez filtrů může vrátit příliš velkou odpověď → funkce **odmítne volání pokud jsou všechny filtry prázdné** (`Write-Error` + `return $null`).

```powershell
function Get-ABCards {
    param(
        [string]$Plate = '',
        [string]$Carrier = '',
        [string]$PersonName = '',
        [bool]$OnlyInsideCarpark = $true
    )
    # Guard: alespoň jeden filtr musí být neprázdný
    if ([string]::IsNullOrWhiteSpace($Plate) -and
        [string]::IsNullOrWhiteSpace($Carrier) -and
        [string]::IsNullOrWhiteSpace($PersonName)) {
        Write-Error "Get-ABCards: At least one filter (Plate, Carrier or PersonName) must be specified to avoid oversized response."
        return $null
    }
    # ... POST na getCardsByWildcardSearch, vrátí PSCustomObject[] s card_carrier property
}
# Vrátí pole PSCustomObject s: id, owner_first_name, owner_last_name, price_name,
#   valid_from, valid_to, last_usage, last_plate, last_country_code,
#   applic_id_last_use, time_coding, card_carrier (primární CardCarrierNrId)
```

#### `Send-ABApplicCommand.ps1`
Wraps `ServiceSystem.asmx/sendApplicCommand` — otevření/zavření bariéry a další příkazy.
```powershell
function Send-ABApplicCommand {
    param(
        [int]$System = 1,
        [int]$Tcc,
        [int]$Command,         # 45=open, 46=close, 51=in service, 52=out of service, ...
        [int]$Parameter1 = 0,
        [int]$Parameter2 = 0,
        [int]$Parameter3 = 0,
        [int]$Parameter4 = 0,
        [int]$Parameter5 = 0,
        [int]$Parameter6 = 0,
        [int]$Parameter7 = 0
    )
    ...
}
# Return 0 = success
```

#### `Move-ABCardVirtually.ps1`
Wraps `ServiceOperation.asmx/moveCardVirtuallyByCarrier` — přesune kartu virtuálně dovnitř/ven z parkoviště.
Podporuje pipeline z `Get-ABCards` — `card_carrier` property z výstupu `Get-ABCards` se mapuje na `-CardCarrier`.
```powershell
function Move-ABCardVirtually {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CardCarrier,          # z Get-ABCards output: 'card_carrier'
        [Parameter(Mandatory)]
        [int]$CarparkId,
        [int]$Direction                # Dle docs: 0=out, 1=in — plain int (bez ValidateSet) pro případ nezdokumentovaných hodnot
    )
    process { ... }
}
# Použití: Get-ABCards -Plate '%ABC%' | Move-ABCardVirtually -CarparkId 1 -Direction 1
# Signature: moveCardVirtuallyByCarrier(user, pwd, cardCarrier, carparkId, direction)
```

`Get-ABCards` musí ve výstupu obsahovat vlastnost `card_carrier` (primární CardCarrierNrId z CardCarriers[0]).

#### `Get-ABCarparkCounter.ps1`
Wraps `ServiceSystem.asmx/getCarparkCounter` — počty obsazených míst.
```powershell
function Get-ABCarparkCounter {
    param([int]$System = 1, [int]$CarparkNo)
    ...
}
```

---

## Část 2: AbacusAPIBridge — update `docker/app.ps1`

### Soubor: `/home/jonatanrek/WORK/_GIT/AbacusAPIBridge/docker/app.ps1`

Změny:
1. **Na začátek přidat** `Import-Module Abacus.Graph`
2. **Odstranit** inline funkce `Convert-ToPragueTime`, `Set-WebResponse`, `Invoke-AbacusRequest` — ty zůstávají v bridgi (Convert-ToPragueTime a Set-WebResponse jsou bridge-specifické, ne součást modulu)
3. **Přidat inicializaci modulu** — zavolat `Connect-AB` s hodnotami z `$config.abacus`
4. **Nahradit volání** `Invoke-AbacusRequest -Path '/ServiceOperation.asmx/getCardsByWildcardSearch'` za `Get-ABCards`
5. **Nahradit volání** `Invoke-RestMethod ... /ServiceSystem.asmx/sendApplicCommand` za `Send-ABApplicCommand`

Výsledná struktura `app.ps1`:
```powershell
Import-Module Abacus.Graph

# ... Set-WebResponse, Convert-ToPragueTime zůstávají (bridge-specifické) ...

$config = Get-Content -Path "$PSScriptRoot/config.json" | ConvertFrom-Json
Connect-AB -Uri $config.abacus.base_url -Username $config.abacus.username -Password $config.abacus.password

# HTTP server loop — endpointy volají funkce modulu
```

---

## Kritické soubory

| Soubor | Akce |
|--------|------|
| `/home/jonatanrek/WORK/_GIT/AbacusPS/Abacus.Graph/Abacus.Graph.psm1` | Vytvořit |
| `/home/jonatanrek/WORK/_GIT/AbacusPS/Abacus.Graph/Abacus.Graph.psd1` | Vytvořit |
| `/home/jonatanrek/WORK/_GIT/AbacusPS/Abacus.Graph/functions/*.ps1` | Vytvořit (8 funkcí) |
| `/home/jonatanrek/WORK/_GIT/AbacusAPIBridge/docker/app.ps1` | Upravit |
| `/home/jonatanrek/WORK/_GIT/AbacusPS/.scripts/publish.ps1` | Zachovat beze změny (již připraveno) |

---

## Ověření

1. Spustit `Import-Module ./AbacusPS/Abacus.Graph/Abacus.Graph.psd1` — ověřit že se načte bez chyb
2. Zavolat `Connect-AB`, pak `Get-ABApplic` — ověřit odpověď ze serveru
3. Spustit AbacusAPIBridge Docker container — ověřit že `GET /abacus/cards` a `POST /gate/open` fungují
4. Porovnat chování s původním `app.ps1` — výstupy musí být identické
