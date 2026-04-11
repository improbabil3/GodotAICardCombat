param(
    [Parameter(Mandatory=$true)][string]$Version
)

Write-Host "Creating release $Version"
git add -A
try { git commit -m "chore(release): $Version" } catch { }
git tag -a "v$Version" -m "Release $Version"
git push origin HEAD
git push origin "v$Version"

if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh release create "v$Version" --title "v$Version" --notes-file CHANGELOG.md
} else {
    Write-Host "gh CLI not found; create a release via GitHub web UI or install gh: https://cli.github.com/"
}
