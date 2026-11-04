<#
.SYNOPSIS
  Install AI Builder - Build Copies for the current Windows user.
.DESCRIPTION
  Copies the prebuilt Windows application into LocalAppData without administrator
  access, creates Desktop and Start Menu shortcuts, and opens the app.
  Re-running upgrades the application while keeping its portable-mode data.
#>
[CmdletBinding()]
param([switch]$NoLaunch)

$ErrorActionPreference = 'Stop'
$source = $PSScriptRoot
$sourceExe = Join-Path $source 'AI-Builder.exe'
if (-not (Test-Path -LiteralPath $sourceExe -PathType Leaf)) {
    throw 'AI-Builder.exe is missing. First extract the entire GitHub download, then run Install-AI-Builder.cmd from the extracted folder.'
}

$localPrograms = Join-Path $env:LOCALAPPDATA 'Programs'
$installDir = Join-Path $localPrograms 'AI Builder - Build Copies'
$destinationExe = Join-Path $installDir 'AI-Builder.exe'
$desktop = [Environment]::GetFolderPath('DesktopDirectory')
$startMenu = [Environment]::GetFolderPath('Programs')
if ([string]::IsNullOrWhiteSpace($desktop) -or [string]::IsNullOrWhiteSpace($startMenu)) {
    throw 'Windows could not locate your Desktop or Start Menu folders.'
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
# Copy the whole release folder, except an existing portable settings folder.
# This preserves settings from an earlier installation during upgrades.
foreach ($entry in Get-ChildItem -LiteralPath $source -Force) {
    if ($entry.Name -in @('CraftAnythingData', 'AI-Builder-Data')) { continue }
    if ($entry.FullName -eq $installDir) { continue }
    Copy-Item -LiteralPath $entry.FullName -Destination $installDir -Recurse -Force
}

if (-not (Test-Path -LiteralPath $destinationExe -PathType Leaf)) {
    throw 'Installation did not create AI-Builder.exe.'
}

$wsh = New-Object -ComObject WScript.Shell
function New-AIBuilderShortcut([string]$shortcutPath) {
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $destinationExe
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Description = 'AI Builder - Build Copies'
    # Use the icon embedded in the program.
    $shortcut.IconLocation = "$destinationExe,0"
    $shortcut.Save()
}
New-AIBuilderShortcut (Join-Path $desktop 'AI Builder - Build Copies.lnk')
New-AIBuilderShortcut (Join-Path $startMenu 'AI Builder - Build Copies.lnk')

Write-Host 'AI Builder installed successfully.' -ForegroundColor Green
Write-Host "Desktop shortcut: $(Join-Path $desktop 'AI Builder - Build Copies.lnk')"
Write-Host "Installed app:    $destinationExe"
if (-not $NoLaunch) {
    Start-Process -FilePath $destinationExe -WorkingDirectory $installDir
}
