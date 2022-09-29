function Search-Tag {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Path,
        $Search,
        [switch]$Regex,
        [switch]$Force
    )

    $File = Get-Item -LiteralPath $Path

    if (!($File)) {
        Write-Warning "Bruh: $Path"
        return
    }
    if ($Force -or !$global:TagLibLoaded) {
        if (Test-Path "$PSScriptRoot\.util" -PathType Container) {
            Add-Type -Path "$PSScriptRoot\.util\TagLibSharp.dll"
        } else {
            Add-Type -Path  "$PSScriptRoot\TagLibSharp.dll"
        }
        $global:TagLibLoaded = $true
    }
    $song = [TagLib.File]::Create($File.FullName)
    $Tags = ($song.Tag | Get-Member | Where-Object { $_.Definition -like "string*" -and $_.name -ne "ToString" } | ForEach-Object { $song.tag.$($_.name) })

    $match = { $_ -like $Search }
    if ($Regex) { $match = { $_ -match $Search } }

    if ($Tags | Where-Object $match) {
        return $song
    }

    return $null
}