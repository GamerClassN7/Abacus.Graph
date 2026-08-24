function Set-ABCarparkCounter {
    <#
    .SYNOPSIS
        Sets carpark counter values via the Abacus/DESIGNA setCarparkCounter endpoint.

    .DESCRIPTION
        Wraps ServiceSystem/setCarparkCounter. Any counter parameter left at its
        default (-1) is not sent as a change - the server keeps its current value.
        Passing 0 explicitly zeroes that counter out.
        Source: PM_ABACUS_WebService_Interface, 5.10 setCarparkCounter().

    .EXAMPLE
        # Set only ShortTermParker, leave every other counter unchanged
        Set-ABCarparkCounter -CarparkNo 0 -ShortTermParker 70

    .OUTPUTS
        [bool] - $true if the server confirmed the update, $false on failure
        (no connection, HTTP error, or setCarparkCounterResult = false).
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param (
        [int]$System = 0,

        [Parameter(Mandatory = $true)]
        [int]$CarparkNo,

        [int]$MaxCarparkFullWithoutReservation = -1,
        [int]$MaxCarparkFullWithReservation = -1,
        [int]$ShortTermParker = -1,
        [int]$SeasonParkerWithReservation = -1,
        [int]$SeasonParkerWithoutReservation = -1,
        [int]$DebitCardWithReservation = -1,
        [int]$DebitCardWithoutReservation = -1,
        [int]$CongressTicketWithReservation = -1,
        [int]$CongressTicketWithoutReservation = -1
    )

    if ($PSCmdlet.ShouldProcess("Carpark $CarparkNo (System $System)", "SetCarparkCounter")) {
        $result = Invoke-ABRequest -Service 'ServiceSystem' -Method 'setCarparkCounter' -Body @{
            system                           = $System
            carparkNo                        = $CarparkNo
            maxCarparkFullWithoutReservation = $MaxCarparkFullWithoutReservation
            maxCarparkFullWithReservation    = $MaxCarparkFullWithReservation
            shortTermParker                  = $ShortTermParker
            seasonParkerWithReservation      = $SeasonParkerWithReservation
            seasonParkerWithoutReservation   = $SeasonParkerWithoutReservation
            debitCardWithReservation         = $DebitCardWithReservation
            debitCardWithoutReservation      = $DebitCardWithoutReservation
            congressTicketWithReservation    = $CongressTicketWithReservation
            congressTicketWithoutReservation = $CongressTicketWithoutReservation
        }
        if ($null -eq $result) { return $false }

        $value = $result
        if ($value -is [System.Xml.XmlDocument]) { $value = $value.DocumentElement.InnerText }
        elseif ($value -is [System.Xml.XmlElement]) { $value = $value.InnerText }
        return [System.Convert]::ToBoolean([string]$value)
    }
}
