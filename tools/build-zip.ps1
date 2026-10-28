# Builds Scales-<Version>.zip for a manual CurseForge upload, with the same exclusions as .pkgmeta.
# Usage: powershell -ExecutionPolicy Bypass -File tools\build-zip.ps1   (run from anywhere)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$version = ((Get-Content (Join-Path $root "Scales.toc")) -match '^## Version:')[0] -replace '^## Version:\s*', ''
$exclude = @(".git", ".github", ".claude", "docs", "tools", "CLAUDE.md", "VEROEFFENTLICHEN.md", "README.md", ".luacheckrc",
  ".pkgmeta", ".gitignore")

$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("scales-build-" + [guid]::NewGuid())
$dest = Join-Path $stage "Scales"
New-Item -ItemType Directory -Force $dest | Out-Null
Get-ChildItem $root -Force | Where-Object { $exclude -notcontains $_.Name -and $_.Extension -ne ".zip" } |
  ForEach-Object { Copy-Item $_.FullName $dest -Recurse }

$zip = Join-Path $root "Scales-$version.zip"
if (Test-Path $zip) { Remove-Item $zip }
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
# Entries are added one by one with "/" separators; Windows PowerShell 5.1 would otherwise write "\",
# which CurseForge and some unzip tools do not treat as folders.
$archive = [System.IO.Compression.ZipFile]::Open($zip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  Get-ChildItem $stage -Recurse -File | ForEach-Object {
    $entry = $_.FullName.Substring($stage.Length + 1) -replace '\\', '/'
    [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $entry)
  }
} finally { $archive.Dispose() }
Remove-Item $stage -Recurse -Force
"Built $zip"
