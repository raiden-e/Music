function Import-Playlist {
    [Alias("ipl")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$Link,
        $Folder = "$env:OneDrive\Music",
        [Parameter()][Alias("t")][switch]$test
    )

    $link = $link.Trim() -replace "\?si=.*", ""
    if ($link -match "^[a-zA-Z0-9]{22}$") {
        $link = "https://open.spotify.com/playlist/$link"
    } elseif ($link -notmatch "https://open.spotify.com/playlist/.*") {
        Write-Error "Invalid Link"
        return
    }

    Write-Host "Importing $link"

    $oldHome = $pwd
    $autofy = Get-Item "$HOME\source\autofy"
    if (!$autofy) {
        Write-Error "autofy not found"
        return
    }

    Set-Location $autofy.FullName
    if (!(Test-Path "$($autofy.FullName)\venv\Scripts\activate.ps1")) {
        $host.UI.WriteErrorLine("No virtual environment. Please see GitHub -> config")
        return
    }
    ."$($autofy.FullName)\venv\Scripts\activate.ps1"

    Write-Verbose "python LocalizePlaylist.py -f ""$Folder"" -p ""$Link"""
    if ($test) {
        python LocalizePlaylist.py -f """$Folder""" -p """$Link""" -t
    } else {
        python LocalizePlaylist.py -f """$Folder""" -p """$Link"""
    }
    Set-Location $oldHome
}
