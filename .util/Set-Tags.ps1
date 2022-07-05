function Set-Tags {
    [Alias("st")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $FolderPath,
        [Parameter(Mandatory)]
        [string]$Tag
    )

    $Folder = Get-Item $FolderPath
    if ($Folder -isnot [System.IO.DirectoryInfo]) {
        Write-Error "Not a folder"
        return
    }
    if (!$global:TagLibLoaded) {
        Add-Type -Path "$PSScriptRoot\TagLibSharp.dll" -ErrorAction Stop
        $global:TagLibLoaded = $true
    }

    $Tag = ($Tag -replace '\/\*', '' -replace '\*\/', '' -replace "\s{2,}", " ").Trim() # sanitize

    foreach ($item in (Get-ChildItem $Foler -File)) {
        if ($item.Extension -notin (".mp3", ".flac", ".m4a")) {
            continue
        }

        Write-Host "Setting tag: $item, $Tag"
        $song = [TagLib.File]::Create($item.FullName)
        if ( $song.Tag.Comments -match "\/\*.*\*\/") {
            # insert into rekordbox tag
            $song.Tag.Comments = ($song.Tag.Comments).Insert(($song.Tag.Comments).indexOf("/* ") + 3, "$Tag / ")
        } else {
            $song.Tag.Comments = $Tag
        }
        $song.save()
    }
}