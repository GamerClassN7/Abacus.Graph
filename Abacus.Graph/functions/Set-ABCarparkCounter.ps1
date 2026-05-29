function Set-ABCarparkCounter {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [int]$System = 1,

        [Parameter(Mandatory = $true)]
        [int]$CarparkNo,

        [System.Nullable[int]]$MaxCarparkFullWithoutReservation = $null,
        [System.Nullable[int]]$MaxCarparkFullWithReservation = $null,
        [System.Nullable[int]]$ShortTermParker = $null,
        [System.Nullable[int]]$SeasonParkerWithReservation = $null,
        [System.Nullable[int]]$SeasonParkerWithoutReservation = $null,
        [System.Nullable[int]]$DebitCardWithReservation = $null,
        [System.Nullable[int]]$DebitCardWithoutReservation = $null,
        [System.Nullable[int]]$CongressTicketWithReservation = $null,
        [System.Nullable[int]]$CongressTicketWithoutReservation = $null
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
