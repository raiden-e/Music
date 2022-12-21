
function Complete-Tags {
    [Alias("ct")]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $FilePath
    )
    function Sanitize {
        param (
            [Parameter(ValueFromPipeline, Mandatory)]
            $InputObject
        )

        $rules = (
            ( ' [xX] ', ' & ' ),
            ( '\(\d\)', '' ), # In case of copy: (0)
            ( '–', '-' ),
            ( '_' , " " ),
            ("[$([regex]::Escape('\/*?<>|'))]", ' '),
            ("[$([regex]::Escape(':"'))]", ''),
            ( '\s{2,}', ' ' )
        )

        foreach ($rule in $rules) {
            $InputObject = $InputObject -replace $rule[0], $rule[1]
        }
        return $InputObject
    }

    if ($FilePath -isnot [System.IO.FileInfo]) {
        $FilePath = Get-Item $FilePath
    }
    if (!$global:TagLibLoaded) {
        Add-Type -Path "$PSScriptRoot\TagLibSharp.dll"
        $global:TagLibLoaded = $true
    }

    $filename = $FilePath.BaseName

    if ($filename -notmatch "(.*)-(.*)") {
        Write-Warning "Bruh what's this? {$filename}"
        return
    }
    $artists = ($Matches[1] -split "&" -split ",").trim() | Sanitize
    $title = $Matches[2].Trim() | Sanitize

    $tags = [TagLib.File]::Create($FilePath.FullName)
    $edited = $false
    if (!$tags.Tag.Title -or $Force) {
        $tags.Tag.Title = $title
        $edited = $true
    }
    if (!$tags.Tag.Artists -or $Force) {
        $tags.Tag.Artists = $artists
        $edited = $true
    }
    if ($edited) {
        $tags.Save()
    }
}