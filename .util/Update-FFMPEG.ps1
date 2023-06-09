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
    $link = ($web.assets.browser_download_url | ? {$_ -like "*ffmpeg-n*-latest-win64-lgpl*" -and $_ -notlike "*shared*" })[-1]

    Invoke-WebRequest $link -UseBasicParsing -OutFile "$PSScriptRoot\ffmpeg.zip"

    Add-Type -Assembly System.IO.Compression.FileSystem
    try {
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
