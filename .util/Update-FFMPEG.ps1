function Update-FFMPEG {
    [Alias("uf")]
    [CmdletBinding()]
    param (
        [switch]$PassThru
    )

    if ("ffmpeg.exe" -in (Get-ChildItem $PSScriptRoot).Name) {
        return
    }

    $web = Invoke-WebRequest -UseBasicParsing "https://github.com/BtbN/FFmpeg-Builds/releases/tag/latest"
    $relativeLink = ($web.links | Where-Object { $_ -like "*ffmpeg-n5.0-latest-win64-lgpl-5.0*" }).href

    Invoke-WebRequest "https://github.com/$relativeLink" -UseBasicParsing -OutFile "$PSScriptRoot\ffmpeg.exe"
    # unzip

    if ($PassThru) {
        return Get-Item "$PSScriptRoot\ffmpeg.exe"
    }
}
