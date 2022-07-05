function Import-Playlist {
    [Alias("ipl")]
    [CmdletBinding()]
    param (
        $Link
    )

    $oldHome = $pwd
    $autofy = Get-Item "$HOME\source\autofy"

    pip install -U pip virtualenv
    Set-Location $autofy.FullName
    python -m virtualenv venv
    ."$($autofy.FullName)\venv\Scripts\activate.ps1"
    pip install -U autopep8 pylint
    pip install -U -r .\requirements.txt

    python LocalizePlaylist.py """$PSScriptRoot""" """$Link"""
    Set-Location $oldHome
}
