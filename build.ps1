param (
    [string]$device = "",
    [switch]$run = $false
)

$buildTime = Get-Date -Format 'yyyy-MM-dd HH:mm'
$content = "class BuildInfo {
  static const String buildTime = `"$buildTime`";
}
"
Set-Content -Path "lib/build_info.dart" -Value $content -Encoding UTF8
Write-Host "✅ Build info updated: $buildTime"

if ($run) {
    if ($device -ne "") {
        Write-Host "🚀 Running on device: $device"
        flutter run --release -d $device
    } else {
        Write-Host "🚀 Running on default device..."
        flutter run --release
    }
} else {
    Write-Host "📦 Building APK..."
    flutter build apk
}
