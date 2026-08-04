function Get-ABCommandId {
    <#
    .SYNOPSIS
        Translates a command name to its Abacus/DESIGNA telegram command id.

    .DESCRIPTION
        Command ids used by Send-ABApplicCommand -Command.
        Source: Designa_Tcc\BFR_TCC\DEF\TELEGRAM.DEF

    .EXAMPLE
        Send-ABApplicCommand -Tcc 20 -Command (Get-ABCommandId -Name 'barrier_open')
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name
    )

    begin {
        $commandIds = @{
            'barrier_open'                 = 45
            'barrier_close'                = 46
            'tcc_in_service'               = 51
            'tcc_out_of_service'           = 52
            'tcc_reset'                    = 81
            'barrier_in_service'           = 83
            'barrier_out_service'          = 84
            'io_check_on'                  = 137
            'io_check_off'                 = 138
            'blacklist_check_on'           = 139
            'blacklist_check_off'          = 140
            'set_lane_counters'            = 849
            # "Activate passage without control" -> ApplicStateData.IsAutoBarrierOn
            # Not listed in the TELEGRAM.DEF table, verified on the exit terminal.
            'passage_without_control_on'   = 664
            'passage_without_control_off'  = 665
        }
    }

    process {
        $key = $Name.Trim().ToLowerInvariant()

        if (-not $commandIds.ContainsKey($key)) {
            throw "Unknown command '$Name'. Supported: $(($commandIds.Keys | Sort-Object) -join ', ')"
        }

        return [int]$commandIds[$key]
    }
}
