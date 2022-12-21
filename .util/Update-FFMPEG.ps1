function Update-FFMPEG {
    [Alias("uf")]
    [CmdletBinding()]
    param (
        [switch]$PassThru,
        [switch]$Force
    )

    if (!$Force -and ("ffmpeg.exe" -in (Get-ChildItem $PSScriptRoot).Name)) {
        return
    }

    $web = Invoke-RestMethod "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
    $link = ($web.assets | ? { $_.name -like "*ffmpeg-n*-latest-win64-lgpl*" -and $_.Name -notlike "*shared*" })[-1].browser_download_url

    Invoke-WebRequest $link -UseBasicParsing -OutFile "$PSScriptRoot\ffmpeg.zip"

    try {
        Add-Type -Assembly System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead("$PSScriptRoot\ffmpeg.zip")
        $zippedFile = $zip.entries | ? { $_.name -eq "ffmpeg.exe" }
        [IO.Compression.ZipFileExtensions]::ExtractToFile($zippedFile, "$PSScriptRoot\ffmpeg.exe", $true)
    } finally {
        $zip.Dispose()
    }
    Remove-Item "$PSScriptRoot\ffmpeg.zip"

    if ($PassThru) {
        return Get-Item "$PSScriptRoot\ffmpeg.exe"
    }
}
