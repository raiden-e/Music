[CmdletBinding()]
param (
    [switch]$Force,
    [switch]$help
)

if ($Force -or !$global:TagLibLoaded) {
    if (Test-Path "$PSScriptRoot\.util" -PathType Container) {
        Add-Type -Path "$PSScriptRoot\.util\TagLibSharp.dll"
    } else {
        Add-Type -Path "$PSScriptRoot\TagLibSharp.dll"
    }
    $global:TagLibLoaded = $true
}
Write-Host "Loading scripts"
$scripts = Get-ChildItem -Path "$PSScriptRoot\.util" -File -Filter "*.ps1" | Where-Object { $_.FullName -ne $PSCommandPath }

$scripts | ForEach-Object { Write-Verbose "Loading $_"; . ($_.FullName) }

if ($MyInvocation.InvocationName -ne ".") {
    Write-Host
    Write-Warning "To Export functions to your session, you need to dot source scripts!"
}
Write-Host "Done" -ForegroundColor Green

if ($help) {
    Write-Host "Available functions:"
    $scripts | ForEach-Object { Write-Host ("  " + $_.BaseName) }
}