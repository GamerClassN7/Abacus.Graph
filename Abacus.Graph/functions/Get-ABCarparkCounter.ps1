function Get-ABCarparkCounter {
    param (
        [int]$System = 1,

        [Parameter(Mandatory = $true)]
        [int]$CarparkNo
    )

    $result = Invoke-ABRequest -Service 'ServiceSystem' -Method 'getCarparkCounter' -Body @{
        system    = $System
        carparkNo = $CarparkNo
    }
    if ($null -eq $result) { return $null }

    $c = $result.CarparkCounterData
    [PSCustomObject]@{
        CarparkUId                              = $c.CarparkUId
        MaxCarparkFull                          = [int]$c.MaxCarparkFull
        MaxCarparkFullWithReservation           = [int]$c.MaxCarparkFullWithReservation
        CurrentCarparkFullTotal                 = [int]$c.CurrentCarparkFullTotal
        CurrentCarparkFullWithReservation       = [int]$c.CurrentCarparkFullWithReservation
        CurrentCarparkFullWithoutReservation    = [int]$c.CurrentCarparkFullWithoutReservation
        CurrentShortTermParker                  = [int]$c.CurrentShortTermParker
        CurrentSeasonParkerWithReservation      = [int]$c.CurrentSeasonParkerWithReservation
        CurrentSeasonParkerWithoutReservation   = [int]$c.CurrentSeasonParkerWithoutReservation
        CurrentDebitCardWithReservation         = [int]$c.CurrentDebitCardWithReservation
        CurrentDebitCardWithoutReservation      = [int]$c.CurrentDebitCardWithoutReservation
        CurrentCongressTicketWithReservation    = [int]$c.CurrentCongressTicketWithReservation
        CurrentCongressTicketWithoutReservation = [int]$c.CurrentCongressTicketWithoutReservation
    }
}
