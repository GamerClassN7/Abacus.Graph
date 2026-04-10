function Invoke-ABRequest {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ServiceOperation', 'ServiceSystem')]
        [string]$Service,

        [Parameter(Mandatory = $true)]
        [string]$Method,

        [hashtable]$Body = @{}
    )

    if (-not $script:isConnected) {
        Write-Error "No active connection. Call Connect-AB first."
        return $null
    }

    $url = "$script:Uri/$Service.asmx/$Method"

    $fullBody = @{
        user = $script:Username
        pwd  = $script:Password
    }
    foreach ($key in $Body.Keys) {
        $fullBody[$key] = $Body[$key]
    }

    $encodedBody = ($fullBody.GetEnumerator() | ForEach-Object {
        "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString([string]$_.Value))"
    }) -join '&'

    try {
        return Invoke-RestMethod -Uri $url -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $encodedBody
    }
    catch {
        Write-Error ("Invoke-ABRequest to {0} failed: {1}" -f $url, $_)
        return $null
    }
}
