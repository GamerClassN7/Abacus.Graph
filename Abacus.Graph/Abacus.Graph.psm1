# MODULE FUNCTIONS INIT
$functions = @()
Get-ChildItem -Path "$(Split-Path $script:MyInvocation.MyCommand.Path)\functions\*" -Recurse -File -Filter '*.ps1' |
Where-object -Filter { -not $_.Name.StartsWith("dev_") } |
Where-object -Filter { -not $_.Name.StartsWith("dep_") } |
ForEach-Object {
    . $_.FullName
    $functions += $_.BaseName
}

# MODULE INFO
$Script:version = (Test-ModuleManifest $PSScriptRoot\Abacus.Graph.psd1 -Verbose).Version
Export-ModuleMember -Function $functions

# MODULE VARIABLES
$script:Uri = ''
$script:Username = ''
$script:Password = ''
$script:isConnected = $false
