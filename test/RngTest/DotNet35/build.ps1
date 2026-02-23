<# .SYNOPSIS Build script for cpp project on Windows using MSVC.
    .DESCRIPTION - Initializes MSVC environment
                 - Builds target
#>
param(
    [ValidateSet("Debug","Release")]
    [string]$buildType = "Release"
)

$vsBuildToolInstallPath = "D:\Program\Microsoft Visual Studio\2022\Community"
if (-not (Test-Path $vsBuildToolInstallPath)) {
    Write-Error "Microsoft Visual Studio BuildTools not found at: $vsBuildToolInstallPath"
    exit 1
}
$devShellModule = Join-Path $vsBuildToolInstallPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
if (-not (Test-Path $devShellModule)) {
    Write-Error "Microsoft.VisualStudio.DevShell.dll not found"
    exit 1
}
Import-Module $devShellModule
Enter-VsDevShell -VsInstallPath $vsBuildToolInstallPath -Arch amd64 -SkipAutomaticLocation
$buildDir = "build"
if (Test-Path $buildDir) {
    Remove-Item -Path $buildDir -Recurse -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}
cmake -S . -B "$buildDir" -G "Ninja" -DCMAKE_BUILD_TYPE="$buildType" -DCMAKE_INSTALL_PREFIX="$PSScriptRoot"
cmake --build $buildDir
cmake --install $buildDir