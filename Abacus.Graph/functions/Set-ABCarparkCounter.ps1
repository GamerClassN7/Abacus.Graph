function Set-ABCarparkCounter {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [int]$System = 0,

        [Parameter(Mandatory = $true)]
        [int]$CarparkNo,

        [int]$MaxCarparkFullWithoutReservation = 0,
        [int]$MaxCarparkFullWithReservation = 0,
        [int]$ShortTermParker = 0,
        [int]$SeasonParkerWithReservation = 0,
        [int]$SeasonParkerWithoutReservation = 0,
        [int]$DebitCardWithReservation = 0,
        [int]$DebitCardWithoutReservation = 0,
        [int]$CongressTicketWithReservation = 0,
        [int]$CongressTicketWithoutReservation = 0
    )

    if ($PSCmdlet.ShouldProcess("Carpark $CarparkNo (System $System)", "SetCarparkCounter")) {
        return Invoke-ABRequest -Service 'ServiceSystem' -Method 'setCarparkCounter' -Body @{
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
    }
}
