function Optimize-Playlist {
    [Alias("opl")]
    [CmdletBinding()]
    param (
        $FilePath,
        [switch]$URIDecode
    )

    $bruh = Get-Content $FilePath -Raw

    if ($URIDecode) {
        $bruh = [uri]::UnescapeDataString($bruh)
    } else {
        foreach ($rule in (
        ('%C3', 'Ã'),
        ('%20', ' '),
        ('%5C', "/"),
        ("%2C", ","),
        ('%AA', 'ª')
            )) {
            $bruh = $bruh -replace $rule[0], $rule[1]
        }
    }

    Write-Verbose $bruh
    Set-Content -Path $FilePath -Value $bruh
}