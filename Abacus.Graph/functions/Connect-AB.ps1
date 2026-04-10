function Connect-AB {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [SecureString]$Password
    )

    $plainPassword = $Password | ConvertFrom-SecureString -AsPlainText

    # Verify connectivity via alive() before marking as connected.
    # Direct Invoke-RestMethod call — cannot go through Invoke-ABRequest yet
    # because it requires $script:isConnected = $true (chicken-and-egg).
    $testUrl  = "$($Uri.TrimEnd('/'))/ServiceSystem.asmx/alive"
    $testBody = "time=$([System.Uri]::EscapeDataString([datetime]::Now.ToString('o')))" +
                "&user=$([System.Uri]::EscapeDataString($Username))" +
                "&pwd=$([System.Uri]::EscapeDataString($plainPassword))"
    try {
        Invoke-RestMethod -Uri $testUrl -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $testBody | Out-Null
    }
    catch {
        Write-Error "Connect-AB: Cannot reach Abacus server at '$Uri': $_"
        return $null
    }

    $script:Uri         = $Uri.TrimEnd('/')
    $script:Username    = $Username
    $script:Password    = $plainPassword   # stored as plain string — API requires plaintext in every POST
    $script:isConnected = $true
}
