# GitHub Follow Contributions - Flutter Build Script
# This script builds the Flutter project for both web and Android platforms

param(
    [string]$Platform = "all",
    [switch]$Clean = $false,
    [switch]$Release = $true,
    [switch]$Help = $false
)

function Show-Help {
    Write-Host "GitHub Follow Contributions Flutter Build Script"
    Write-Host ""
    Write-Host "Usage: .\build_flutter.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Platform <platform>  Build for specific platform: 'web', 'android', or 'all' (default: all)"
    Write-Host "  -Clean               Clean build artifacts before building"
    Write-Host "  -Release             Build in release mode (default: true)"
    Write-Host "  -Help                Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build_flutter.ps1                    # Build for all platforms"
    Write-Host "  .\build_flutter.ps1 -Platform web     # Build for web only"
    Write-Host "  .\build_flutter.ps1 -Platform android -Clean  # Clean and build Android"
}

if ($Help) {
    Show-Help
    exit 0
}

# Configuration
$FlutterProjectPath = "flutter_project"
$BuildMode = if ($Release) { "release" } else { "debug" }
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Colors for output
$Colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color)
    Write-Host $Message -ForegroundColor $Colors[$Color]
}

function Test-FlutterEnvironment {
    Write-ColorOutput "Checking Flutter environment..." "Info"
    
    # Check if flutter is available
    try {
        $flutterVersion = flutter --version
        Write-ColorOutput "Flutter is installed: $flutterVersion" "Success"
    }
    catch {
        Write-ColorOutput "Flutter is not installed or not in PATH" "Error"
        Write-ColorOutput "Please install Flutter and add it to your PATH" "Error"
        exit 1
    }
    
    # Check if in Flutter project directory
    if (-not (Test-Path "$FlutterProjectPath\pubspec.yaml")) {
        Write-ColorOutput "pubspec.yaml not found in $FlutterProjectPath" "Error"
        Write-ColorOutput "Please ensure you're in the correct project directory" "Error"
        exit 1
    }
    
    Write-ColorOutput "Flutter environment check passed!" "Success"
}

function Install-Dependencies {
    Write-ColorOutput "Installing Flutter dependencies..." "Info"
    
    Push-Location $FlutterProjectPath
    try {
        flutter pub get
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install dependencies"
        }
        Write-ColorOutput "Dependencies installed successfully!" "Success"
    }
    catch {
        Write-ColorOutput "Failed to install dependencies: $_" "Error"
        Pop-Location
        exit 1
    }
    Pop-Location
}

function Clean-BuildArtifacts {
    Write-ColorOutput "Cleaning build artifacts..." "Info"
    
    Push-Location $FlutterProjectPath
    try {
        flutter clean
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to clean build artifacts"
        }
        Write-ColorOutput "Build artifacts cleaned successfully!" "Success"
    }
    catch {
        Write-ColorOutput "Failed to clean build artifacts: $_" "Error"
        Pop-Location
        exit 1
    }
    Pop-Location
}

function Build-Web {
    Write-ColorOutput "Building for web ($BuildMode mode)..." "Info"
    
    Push-Location $FlutterProjectPath
    try {
        $buildCommand = "flutter build web --$BuildMode"
        Write-ColorOutput "Executing: $buildCommand" "Info"
        
        Invoke-Expression $buildCommand
        if ($LASTEXITCODE -ne 0) {
            throw "Web build failed"
        }
        
        Write-ColorOutput "Web build completed successfully!" "Success"
        Write-ColorOutput "Web build output: build\web\" "Info"
    }
    catch {
        Write-ColorOutput "Web build failed: $_" "Error"
        Pop-Location
        exit 1
    }
    Pop-Location
}

function Build-Android {
    Write-ColorOutput "Building for Android ($BuildMode mode)..." "Info"
    
    Push-Location $FlutterProjectPath
    try {
        $buildCommand = "flutter build apk --$BuildMode"
        Write-ColorOutput "Executing: $buildCommand" "Info"
        
        Invoke-Expression $buildCommand
        if ($LASTEXITCODE -ne 0) {
            throw "Android build failed"
        }
        
        Write-ColorOutput "Android build completed successfully!" "Success"
        Write-ColorOutput "Android APK output: build\app\outputs\flutter-apk\" "Info"
    }
    catch {
        Write-ColorOutput "Android build failed: $_" "Error"
        Pop-Location
        exit 1
    }
    Pop-Location
}

function Copy-EventsData {
    Write-ColorOutput "Copying events.json data to Flutter assets..." "Info"
    
    $sourcePath = "public\events.json"
    $destPath = "$FlutterProjectPath\assets\events.json"
    
    if (Test-Path $sourcePath) {
        # Create assets directory if it doesn't exist
        $assetsDir = "$FlutterProjectPath\assets"
        if (-not (Test-Path $assetsDir)) {
            New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
        }
        
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-ColorOutput "events.json copied to Flutter assets!" "Success"
    }
    else {
        Write-ColorOutput "Warning: events.json not found at $sourcePath" "Warning"
        Write-ColorOutput "Please run main.py to generate the events data first" "Warning"
    }
}

function Show-BuildSummary {
    Write-ColorOutput "`nBuild Summary:" "Info"
    Write-ColorOutput "=================" "Info"
    Write-ColorOutput "Platform: $Platform" "Info"
    Write-ColorOutput "Build Mode: $BuildMode" "Info"
    Write-ColorOutput "Timestamp: $Timestamp" "Info"
    Write-ColorOutput ""
    
    if ($Platform -eq "all" -or $Platform -eq "web") {
        Write-ColorOutput "Web build output: flutter_project\build\web\" "Info"
    }
    
    if ($Platform -eq "all" -or $Platform -eq "android") {
        Write-ColorOutput "Android APK output: flutter_project\build\app\outputs\flutter-apk\" "Info"
    }
}

# Main execution
Write-Host "GitHub Follow Contributions Flutter Build Script" -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta

# Check if we should run main.py first
if (-not (Test-Path "public\events.json")) {
    Write-ColorOutput "events.json not found. Do you want to run main.py to generate it? (Y/N)" "Warning"
    $response = Read-Host
    if ($response -eq "Y" -or $response -eq "y") {
        Write-ColorOutput "Running main.py to generate events data..." "Info"
        python main.py
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "Failed to generate events data" "Error"
            exit 1
        }
    }
}

# Execute build process
try {
    Test-FlutterEnvironment
    Copy-EventsData
    
    if ($Clean) {
        Clean-BuildArtifacts
    }
    
    Install-Dependencies
    
    switch ($Platform.ToLower()) {
        "web" {
            Build-Web
        }
        "android" {
            Build-Android
        }
        "all" {
            Build-Web
            Build-Android
        }
        default {
            Write-ColorOutput "Invalid platform: $Platform" "Error"
            Write-ColorOutput "Valid options: web, android, all" "Error"
            exit 1
        }
    }
    
    Show-BuildSummary
    Write-ColorOutput "Build process completed successfully!" "Success"
}
catch {
    Write-ColorOutput "Build process failed: $_" "Error"
    exit 1
}