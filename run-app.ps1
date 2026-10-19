param([string]$Device = 'chrome', [int]$Port = 8767)
$ErrorActionPreference = 'Stop'
Push-Location -LiteralPath $PSScriptRoot
try {
    $localFlutter = Join-Path $PSScriptRoot '../../work/flutter/bin/flutter.bat'
    $installedFlutter = Get-Command flutter -ErrorAction SilentlyContinue
    if ($installedFlutter) {
        $flutterCommand = $installedFlutter.Source
    } elseif (Test-Path -LiteralPath $localFlutter) {
        $flutterCommand = (Resolve-Path -LiteralPath $localFlutter).Path
    } else {
        throw 'Install Flutter and add its bin folder to PATH: https://docs.flutter.dev/install/manual'
    }
    & $flutterCommand pub get
    if ($LASTEXITCODE -ne 0) { throw 'Flutter dependency setup failed.' }
    if ($Device -in @('chrome', 'edge', 'web-server')) {
        & $flutterCommand run -d $Device --web-hostname 127.0.0.1 --web-port $Port
    } else {
        & $flutterCommand run -d $Device
    }
} finally {
    Pop-Location
}
