#Requires -Version 7.2

Import-Module "$PSScriptRoot\..\getargs.ps1" -Force

$sopts = 'ivhd:'
$lopts = @('install', "verbose")

$opts, $rems, $err = getargs $args $sopts $lopts


Write-Host "remains  :"
$rems | Out-String


Write-Host "opts  :"
$opts | Out-String


Write-Host "err  :"
$err | Out-String