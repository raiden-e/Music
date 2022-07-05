[CmdletBinding()]
param ()

Write-Host "Loading scripts"
$scripts = Get-ChildItem -Path "$PSScriptRoot\.util" -File -Filter "*.ps1"| Where-Object { $_.FullName -ne $PSCommandPath }
$scripts
$scripts | ForEach-Object { Write-Verbose "Loading $_"; . "$($_.FullName)" }