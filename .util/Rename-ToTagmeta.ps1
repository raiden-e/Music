function Rename-ToTagMeta {
    [Alias("rtt")]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $FilePath
    )

    if($FilePath -isnot [System.IO.FileInfo]){
        $FilePath = Get-Item $FilePath
    }
    if(!$global:TagLibLoaded){
        Add-Type -Path "$PSScriptRoot\TagLibSharp.dll"
        $global:TagLibLoaded = $true
    }

    $tags = [TagLib.File]::Create($FilePath.FullName)
    $mime = $tags.MimeType.Split("/")[-1]
    $NewName = "$($tags.Tag.Artists -join ', ') - $($tags.Tag.Title).$mime"

    Rename-Item -LiteralPath $FilePath.FullName -NewName $NewName
}