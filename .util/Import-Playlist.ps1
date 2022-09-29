function Import-Playlist {
    [Alias("ipl")]
    [CmdletBinding()]
    param (
        $Link,
        $Folder = "$env:OneDrive\Music"
    )

    $oldHome = $pwd
    $autofy = Get-Item "$HOME\source\autofy"

    $null = pip install -U pip virtualenv
    Set-Location $autofy.FullName
    $null = python -m virtualenv venv
    ."$($autofy.FullName)\venv\Scripts\activate.ps1"
    pip install -U autopep8 pylint
    pip install -U -r .\requirements.txt

    Write-Verbose "python LocalizePlaylist.py -f ""$Folder"" -p ""$Link"""
    python LocalizePlaylist.py -f """$Folder""" -p """$Link"""
    Set-Location $oldHome
}
