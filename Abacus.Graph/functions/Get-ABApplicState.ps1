function Get-ABApplicState {
    [CmdletBinding()]
    param (
        [int]$System = 1,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ID')]
        [int]$Tcc
    )

    process {
        $result = Invoke-ABRequest -Service 'ServiceSystem' -Method 'getApplicState' -Body @{
            System = $System
            Tcc    = $Tcc
        }
        if ($null -eq $result) { return $null }

        $s = $result.ApplicStateData
        [PSCustomObject]@{
            SystemNo              = [int]$s.SystemNo
            TccNo                 = [int]$s.TccNo
            InService             = [int]$s.InService
            IsOnline              = [int]$s.IsOnline
            IsBarrierOn           = [int]$s.IsBarrierOn
            IsBlacklistCheckOn    = [int]$s.IsBlacklistCheckOn
            IsIoCheckOn           = [int]$s.IsIoCheckOn
            IsBarrierUp           = [int]$s.IsBarrierUp
            IsLoopVon             = [int]$s.IsLoopVon
            IsPaperLack           = [int]$s.IsPaperLack
            IsCoinCassetteFull    = [int]$s.IsCoinCassetteFull
            IsBankNoteCassetteFull = [int]$s.IsBankNoteCassetteFull
            IsLprDaemonOffline    = [int]$s.IsLprDaemonOffline
        }
    }
}
