function Optimize-Songs {
    [Alias("os")]
    [CmdletBinding()]
    param (
        [Parameter()]
        $Path = $pwd
    )
    $ErrorActionPreference = "Stop"
    if (!$global:TagLibLoaded) {
        Add-Type -Path "$PSScriptRoot\TagLibSharp.dll"
        $global:TagLibLoaded = $true
    }

    # $nonTagLibrules = (
    #     ( ',', ' &' ),
    #     ( ' [xX] ', ' & ' ),
    #     ( '\(\d\)', '' ),
    #     ( '–', '-' ),
    #     ( '_' , " " ),
    #     ( '\s{2,}', ' ' )
    # )

    $escape = [regex]::Escape('\/:*?"<>|')
    $fileRules = (
        ("[$escape]", ' '),
        ( '\s{2,}', ' ' )
    )

    $extentions = ".mp3", ".flac", ".m4a", ".ogg", ".wav"
    # $noNums = "!§$%&=;_-.,^°+~@€{}[]()´`#`'``"
    # $all = '0123456789' + $noNums
    foreach ($file in Get-ChildItem -r -File -Path $Path | Where-Object { $_.Extension -in $extentions }) {
        $song = [TagLib.File]::Create($file.FullName)
        $newName = ($song.Tag.Artists -replace "\s*&\s*", ", ") -join ", "
        $newName += " - " + $song.Tag.Title + $file.Extension
        foreach ($rule in $fileRules) {
            $newName = $newName -replace $rule[0], $rule[1]
        }
        if ($file.name -eq $newName) {
            Write-Host "Skipping: $newName" -ForegroundColor Green
            continue
        }
        Write-Host "Renaming: " -NoNewline
        Write-Host ("{0,-90}" -f $file.Name) -NoNewline -ForegroundColor Magenta
        Write-Host " → " -NoNewline
        Write-Host $newName -ForegroundColor Cyan

        Rename-Item -LiteralPath $file.FullName -NewName $newName
    }
}