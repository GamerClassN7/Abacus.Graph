function Move-ABCardVirtually {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByCarrier')]
    param (
        # ByCarrier: binds from 'card_carrier' property in Get-ABCards output
        [Parameter(Mandatory = $true, ParameterSetName = 'ByCarrier', ValueFromPipelineByPropertyName = $true)]
        [Alias('card_carrier')]
        [string]$CardCarrier,

        # ByShortCardNr: short representation e.g. '015364' (015 = TccNo)
        [Parameter(Mandatory = $true, ParameterSetName = 'ByShortCardNr')]
        [string]$ShortCardNr,

        # Binds from 'carpark_id' property in Get-ABCards output
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('carpark_id')]
        [int]$CarparkId,

        # 0=out, 1=in (per API docs)
        [Parameter(Mandatory = $true)]
        [int]$Direction
    )

    process {
        $target = if ($PSCmdlet.ParameterSetName -eq 'ByCarrier') { $CardCarrier } else { $ShortCardNr }

        if ($PSCmdlet.ShouldProcess("Card '$target' in carpark $CarparkId", "MoveCardVirtually direction=$Direction")) {
            if ($PSCmdlet.ParameterSetName -eq 'ByCarrier') {
                Invoke-ABRequest -Service 'ServiceOperation' -Method 'moveCardVirtuallyByCarrier' -Body @{
                    cardCarrier = $CardCarrier
                    carparkId   = $CarparkId
                    direction   = $Direction
                }
            } else {
                Invoke-ABRequest -Service 'ServiceOperation' -Method 'moveCardVirtuallyByShortCardNr' -Body @{
                    shortCardNr = $ShortCardNr
                    carparkId   = $CarparkId
                    direction   = $Direction
                }
            }
        }
    }
}
