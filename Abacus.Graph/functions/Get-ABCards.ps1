function Get-ABCards {
    param (
        [string]$Plate = '',
        [string]$Carrier = '',
        [string]$PersonName = '',
        [bool]$OnlyInsideCarpark = $true
    )

    if ([string]::IsNullOrWhiteSpace($Plate) -and
        [string]::IsNullOrWhiteSpace($Carrier) -and
        [string]::IsNullOrWhiteSpace($PersonName)) {
        Write-Error "Get-ABCards: At least one filter (Plate, Carrier or PersonName) must be specified to avoid oversized response."
        return $null
    }

    $result = Invoke-ABRequest -Service 'ServiceOperation' -Method 'getCardsByWildcardSearch' -Body @{
        plate                  = $Plate
        carrier                = $Carrier
        personName             = $PersonName
        onlyCardsInsideCarpark = $OnlyInsideCarpark.ToString().ToLower()
    }
    if ($null -eq $result) { return $null }

    $raw = $result.ArrayOfCardData.CardData
    if ($null -eq $raw) { return @() }
    if ($raw -isnot [System.Array]) { $raw = @($raw) }

    return $raw | ForEach-Object {
        $primaryCarrier = ''
        if ($_.CardCarriers -and $_.CardCarriers.CardCarrierData) {
            $carriers = $_.CardCarriers.CardCarrierData
            if ($carriers -isnot [System.Array]) { $carriers = @($carriers) }
            if ($carriers.Count -gt 0) { $primaryCarrier = $carriers[0].CardCarrierNrId }
        }

        [PSCustomObject]@{
            id                 = $_.ID
            owner_first_name   = $_.Person.FirstName
            owner_last_name    = $_.Person.LastName
            price_name         = $_.Price.Name
            valid_from         = $_.TimeValidFrom
            valid_to           = $_.TimeValidTo
            last_usage         = $_.TimeLastUsage
            last_plate         = $_.LastLicensePlate
            last_country_code  = $_.LastCountryCode
            applic_id_last_use = $_.ApplicIDLastUsage
            time_coding        = $_.TimeCoding
            card_carrier       = $primaryCarrier
            carpark_id         = [int]$_.Carpark.ID
        }
    }
}
