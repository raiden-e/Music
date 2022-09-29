function Convert-Music {
    # Converts Audiofile to another (e.g. flac to m4a)
    [Alias("cm")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,
        [Parameter(Mandatory)]
        [ValidateSet("mp3", "m4a", "flac")]
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

    $ffmpeg = Get-Item "$PSScriptRoot\ffmpeg.exe" -ErrorAction SilentlyContinue
    if (!$ffmpeg) {
        . "$PSScriptRoot\Update-FFMPEG.ps1"
        $ffmpeg = Update-FFMPEG -PassThru
    }

    $output = [IO.Path]::Combine($InputObject.Directory, "$($InputObject.BaseName).$Format")

    $ffmpegArguments = "-hide_banner", "-i", "'$($InputObject.FullName)'"
    if ($Artwork) {
        $Artwork = Get-Item $Artwork -ErrorAction SilentlyContinue
        if ($Artwork -isnot [IO.FileInfo]) {
            Write-Warning "Not a file: $Artwork"
        } else {
            $ffmpegArguments += "-i", "'$($Artwork.FullName)'", "-map", "0", "-map", "1", "-disposition:v:1", "attached_pic"
        }
    }

    $ffmpegArguments += "-b:a", "${Bitrate}000"

    if ($artist -or $title -or $album) {
        if ($artist) {
            $ffmpegArguments += "-metadata", "artist=""$($artist -join "/")"""
        }
        if ($title) {
            $ffmpegArguments += "-metadata", "title=""$title"""
        }
        if($album){
            $ffmpegArguments += "-metadata", "album=""$album"""
        }
    }

    $ffmpegArguments += """$output""", "-y"
    $ffmpegArguments = $ffmpegArguments -join " "

    Write-Verbose "Executing: {$ffmpeg $ffmpegArguments}"
    Invoke-Expression "$ffmpeg $ffmpegArguments"
}