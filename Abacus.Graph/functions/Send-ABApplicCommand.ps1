function Send-ABApplicCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [int]$System = 1,

        [Parameter(Mandatory = $true)]
        [int]$Tcc,

        # Command IDs: 45=barrier open, 46=barrier close, 51=TCC in service,
        # 52=TCC out of service, 81=TCC reset, 83=barrier in service,
        # 84=barrier out of service, 137=activate I/O-check, 138=deactivate I/O-check,
        # 139=activate blacklist-check, 140=deactivate blacklist-check
        [Parameter(Mandatory = $true)]
        [int]$Command,

        [int]$Parameter1 = 0,
        [int]$Parameter2 = 0,
        [int]$Parameter3 = 0,
        [int]$Parameter4 = 0,
        [int]$Parameter5 = 0,
        [int]$Parameter6 = 0,
        [int]$Parameter7 = 0
    )

    if ($PSCmdlet.ShouldProcess("Terminal $Tcc (System $System)", "SendApplicCommand command=$Command")) {
        $result = Invoke-ABRequest -Service 'ServiceSystem' -Method 'sendApplicCommand' -Body @{
            System     = $System
            Tcc        = $Tcc
            command    = $Command
            Parameter1 = $Parameter1
            Parameter2 = $Parameter2
            Parameter3 = $Parameter3
            Parameter4 = $Parameter4
            Parameter5 = $Parameter5
            Parameter6 = $Parameter6
            Parameter7 = $Parameter7
        }

        return $result
    }
}
