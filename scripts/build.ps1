<# .SYNOPSIS Build script for dsp_seed_search on Windows using MSVC.
    .DESCRIPTION - Initializes MSVC environment
                 - Builds project 
                 - Installs only the seed_search target
#>
param(
    [ValidateSet("Debug","Release")]
    [string]$buildType = "Release"
)

$vsBuildToolInstallPath = "D:\Program\Microsoft Visual Studio\2022\Community"
if (-not (Test-Path $vsBuildToolInstallPath)) {
    Write-Error "Visual Studio BuildTools not found at: $vsBuildToolInstallPath"
    exit 1
}
$devShellModule = Join-Path $vsBuildToolInstallPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
if (-not (Test-Path $devShellModule)) {
    Write-Error "Microsoft.VisualStudio.DevShell.dll not found"
    exit 1
}
Import-Module $devShellModule
Enter-VsDevShell -VsInstallPath $vsBuildToolInstallPath -Arch amd64 -SkipAutomaticLocation

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Resolve-Path "$scriptDir\.."
$buildDir = Join-Path $projectRoot "build"
if (-Not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}
$installDir = Join-Path $projectRoot "output"
if (-Not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

cmake -S "$projectRoot" -B "$buildDir" -G "Ninja" -DCMAKE_BUILD_TYPE="$buildType" -DCMAKE_INSTALL_PREFIX="$installDir"
cmake --build $buildDir --target all
cmake --install $buildDir --component seed_search --verbose