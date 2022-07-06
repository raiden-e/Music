[CmdletBinding()]
param ()

if ($MyInvocation.InvocationName -ne ".") {
    Write-Warning "To Export functions to your session, you need to dot source scripts! "
}
Write-Host "Loading scripts"
$scripts = Get-ChildItem -Path "$PSScriptRoot\.util" -File -Filter "*.ps1" | Where-Object { $_.FullName -ne $PSCommandPath }

$scripts | ForEach-Object { Write-Verbose "Loading $_"; . ($_.FullName) }

Write-Host "Done" -ForegroundColor Green