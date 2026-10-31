param(
    [string]$Track = "internal",
    [string]$PackageName = "com.sthitaprajna.app",
    [string]$AabPath = "release_builds\Sthitaprajna-v1.0.1-signed.aab"
)

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "🚀 Publishing Sthitaprajna to Google Play ($Track)..." -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

if (!(Test-Path $AabPath)) {
    Write-Host "❌ AAB file not found at: $AabPath" -ForegroundColor Red
    exit 1
}

node tool\play_publisher\publish.js $AabPath $PackageName $Track

