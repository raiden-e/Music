function Convert-Music {
    [Alias("cm")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,
        [Parameter(Mandatory)]
        [ValidateSet("mp3", "m4a")]
        $Format,
        $Artwork,
        $Bitrate = 320
    )

    $InputObject = Get-Item $InputObject
    if ($InputObject -isnot [System.IO.FileInfo]) {
        throw "Not a File"
    }
    if (($InputObject.Extension).ToLower() -notin (".mp3", ".m4a", ".ogg", ".wav", ".flac")) {
        throw "Not an audio file"
    }

    if (($InputObject.Extension).ToLower() -in (".mp3", ".m4a", ".ogg")) {
        Write-Warning "Converting from a lossy format into another is SUPER lossy!"
    }

    # if (!$global:TagLibLoaded) {
    #     Add-Type -Path "$PSScriptRoot\TagLibSharp.dll"
    #     $global:TagLibLoaded = $true
    # }

    $ffmpeg = Get-Item "$PSScriptRoot\ffmpeg.exe" -ErrorAction SilentlyContinue
    if (!$ffmpeg) {
        . "$PSScriptRoot\Update-FFMPEG.ps1"
        $ffmpeg = Update-FFMPEG -PassThru
    }

    $output = [IO.Path]::Combine($InputObject.Directory, "$($InputObject.BaseName).$Format")

    $arg = "-hide_banner -i '$($in.FullName)'"
    if ($Artwork) {
        $Artwork = Get-Item $Artwork -ErrorAction SilentlyContinue
        if ($Artwork -isnot [IO.FileInfo]) {
            Write-Warning "Not a file: $Artwork"
        } else {
            $arg += " -i '$($Artwork.FullName)' -map 0 -map 1 -disposition:v:1 attached_pic"
        }
    }
    $arg += " -b:a ${Bitrate}000 "

    if ($artist -or $title -or $album) {
        if ($artist) {
            $arg += " -metadata artist="""
            foreach ($a in $artist) {
                $arg += "$a/"
            }
            $arg = $arg.TrimEnd("/")
            $arg += '"'
        }
        if ($title) {
            $arg += " -metadata title=""$title"""
        }
        if($album){
            $arg += " -metadata album=""$album"""
        }
    }

    $arg += " ""$outputFileName"" -y"

    $rc = Start-Process $
}