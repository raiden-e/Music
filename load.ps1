[CmdletBinding()]
param (
    [switch]$Force
)

if ($MyInvocation.InvocationName -ne ".") {
    Write-Warning "To Export functions to your session, you need to dot source scripts! "
}
if ($Force -or !$global:TagLibLoaded) {
    if (Test-Path "$PSScriptRoot\.util" -PathType Container) {
        Add-Type -Path "$PSScriptRoot\.util\TagLibSharp.dll"
    } else {
        Add-Type -Path  "$PSScriptRoot\TagLibSharp.dll"
    }
    $global:TagLibLoaded = $true
}
Write-Host "Loading scripts"
$scripts = Get-ChildItem -Path "$PSScriptRoot\.util" -File -Filter "*.ps1" | Where-Object { $_.FullName -ne $PSCommandPath }

$scripts | ForEach-Object { Write-Verbose "Loading $_"; . ($_.FullName) }

Write-Host "Done" -ForegroundColor Green