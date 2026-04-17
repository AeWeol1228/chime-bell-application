$buildTime = Get-Date -Format 'yyyy-MM-dd HH:mm'
$content = "class BuildInfo {
  static const String buildTime = `"$buildTime`";
}
"
Set-Content -Path "lib/build_info.dart" -Value $content
Write-Host "✅ Build time updated to $buildTime"
Write-Host "🚀 Starting Flutter build..."
flutter build apk
