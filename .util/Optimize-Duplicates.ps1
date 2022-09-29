function Optimize-Duplicates {
    [Alias("dedup")]
    [CmdletBinding()]
    param (
        [switch]$delete
    )

    Clear-Host
    $global:fg = $false
    function Get-Color {
        $global:fg = !$global:fg
        if ($global:fg) { return "Cyan" } else { return "White" }
    }
    $groups = Get-ChildItem -File -Recurse | Group-Object Length | Where-Object { $_.count -gt 1 }

    if ($groups.Count -eq 0) {
        Write-Host "No Duplicates!" -ForegroundColor Green
        return
    }

    if ($delete) {
        foreach ($group in $groups) {
            Clear-Host
            $filenames = @($group.Group.FullName | Out-GridView -Title 'Choose a file' -PassThru)

            Write-Host "Not Deleting: $filenames"
        }
    } else {
        foreach ($group in $groups) {
            $host.UI.RawUI.ForegroundColor = Get-Color
            $group.GROUP.FULLNAME
        }
    }

    Write-Host "Remember that CCleaner does this also, and kinda good"
    Write-Host "Also AllDups ist great too"
    Write-Host "Groups: $($groups.Count)"
}
