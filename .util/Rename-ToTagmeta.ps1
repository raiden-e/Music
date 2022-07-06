function Rename-ToTagMeta {
    [Alias("rtt")]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $FilePath
    )

    if ($FilePath -isnot [System.IO.FileInfo]) {
        $FilePath = Get-Item -LiteralPath $FilePath
    }
    if (!$global:TagLibLoaded) {
        Add-Type -Path "$PSScriptRoot\TagLibSharp.dll"
        $global:TagLibLoaded = $true
    }

    try {
        Write-Verbose "Creating $FilePath"
        $tags = [TagLib.File]::Create($FilePath.FullName)
    } catch {
        throw $_
    }
    $mime = $tags.MimeType.Split("/")[-1]
    if (!$tags.Tag.Artists) {
        Write-Warning "No artists: {$FilePath}"
        return
    }
    if (!$tags.Tag.Title) {
        Write-Warning "No Title: {$FilePath}"
        return
    }
    $NewName = "$($tags.Tag.Artists -join ', ') - $($tags.Tag.Title).$mime"

    $NewName = $NewName.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    Rename-Item -LiteralPath $FilePath.FullName -NewName $NewName
}