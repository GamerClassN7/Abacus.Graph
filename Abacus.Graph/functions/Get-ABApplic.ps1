function Get-ABApplic {
    $result = Invoke-ABRequest -Service 'ServiceSystem' -Method 'getApplicList'
    if ($null -eq $result) { return $null }

    $raw = $result.ArrayOfApplicData.ApplicData
    if ($null -eq $raw) { return @() }
    if ($raw -isnot [System.Array]) { $raw = @($raw) }

    return $raw | ForEach-Object {
        [PSCustomObject]@{
            ID         = [int]$_.ID
            UId        = $_.UId
            Name       = $_.Name
            Type       = [int]$_.Type
            Active     = [bool]$_.Active
            CarparkUId = $_.CarparkUId
        }
    }
}
