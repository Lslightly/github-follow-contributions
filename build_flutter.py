#!/usr/bin/env python3
"""
GitHub Follow Contributions - Flutter Build Script
Python version for building Flutter project for web and Android platforms
"""

import os
import sys
import subprocess
import shutil
import argparse
from datetime import datetime
from pathlib import Path
from typing import Optional, List

class Colors:
    """ANSI color codes for terminal output"""
    SUCCESS = '\033[92m'
    ERROR = '\033[91m'
    WARNING = '\033[93m'
    INFO = '\033[94m'
    MAGENTA = '\033[95m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_colored(message: str, color: str = Colors.INFO):
    """Print colored message to terminal"""
    print(f"{color}{message}{Colors.ENDC}")

def run_command(command: List[str], cwd: Optional[str] = None, check: bool = True) -> subprocess.CompletedProcess:
    """Run a command and return the result"""
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            check=check,
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        return result
    except subprocess.CalledProcessError as e:
        print_colored(f"Command failed: {' '.join(command)}", Colors.ERROR)
        print_colored(f"Error: {e.stderr}", Colors.ERROR)
        if check:
            raise
        return e
    except FileNotFoundError as e:
        print_colored(f"Command not found: {command[0]}", Colors.ERROR)
        raise

def check_flutter_environment() -> bool:
    """Check if Flutter is properly installed and configured"""
    print_colored("Checking Flutter environment...", Colors.INFO)
    
    try:
        # Check if flutter is available
        result = run_command(["flutter", "--version"], check=False)
        if result.returncode != 0:
            print_colored("Flutter is not installed or not in PATH", Colors.ERROR)
            print_colored("Please install Flutter and add it to your PATH", Colors.ERROR)
            return False
        
        print_colored(f"Flutter is installed: {result.stdout.strip()}", Colors.SUCCESS)
        
        # Check if we're in the right directory
        flutter_project_path = Path("flutter_project")
        pubspec_path = flutter_project_path / "pubspec.yaml"
        
        if not pubspec_path.exists():
            print_colored(f"pubspec.yaml not found in {flutter_project_path}", Colors.ERROR)
            print_colored("Please ensure you're in the correct project directory", Colors.ERROR)
            return False
        
        print_colored("Flutter environment check passed!", Colors.SUCCESS)
        return True
        
    except Exception as e:
        print_colored(f"Error checking Flutter environment: {e}", Colors.ERROR)
        return False

def copy_events_data() -> bool:
    """Copy events.json to Flutter assets directory"""
    print_colored("Copying events.json data to Flutter assets...", Colors.INFO)
    
    source_path = Path("public/events.json")
    flutter_project_path = Path("flutter_project")
    assets_dir = flutter_project_path / "assets"
    dest_path = assets_dir / "events.json"
    
    if source_path.exists():
        # Create assets directory if it doesn't exist
        assets_dir.mkdir(exist_ok=True)
        
        shutil.copy2(source_path, dest_path)
        print_colored("events.json copied to Flutter assets!", Colors.SUCCESS)
        return True
    else:
        print_colored(f"Warning: events.json not found at {source_path}", Colors.WARNING)
        print_colored("Please run main.py to generate the events data first", Colors.WARNING)
        return False

def install_dependencies() -> bool:
    """Install Flutter dependencies"""
    print_colored("Installing Flutter dependencies...", Colors.INFO)
    
    try:
        flutter_project_path = Path("flutter_project")
        result = run_command(["flutter", "pub", "get"], cwd=str(flutter_project_path))
        
        if result.returncode == 0:
            print_colored("Dependencies installed successfully!", Colors.SUCCESS)
            return True
        else:
            print_colored("Failed to install dependencies", Colors.ERROR)
            return False
            
    except Exception as e:
        print_colored(f"Error installing dependencies: {e}", Colors.ERROR)
        return False

def clean_build_artifacts() -> bool:
    """Clean Flutter build artifacts"""
    print_colored("Cleaning build artifacts...", Colors.INFO)
    
    try:
        flutter_project_path = Path("flutter_project")
        result = run_command(["flutter", "clean"], cwd=str(flutter_project_path))
        
        if result.returncode == 0:
            print_colored("Build artifacts cleaned successfully!", Colors.SUCCESS)
            return True
        else:
            print_colored("Failed to clean build artifacts", Colors.ERROR)
            return False
            
    except Exception as e:
        print_colored(f"Error cleaning build artifacts: {e}", Colors.ERROR)
        return False

def build_web(build_mode: str = "release") -> bool:
    """Build Flutter for web"""
    print_colored(f"Building for web ({build_mode} mode)...", Colors.INFO)
    
    try:
        flutter_project_path = Path("flutter_project")
        result = run_command(["flutter", "build", "web", f"--{build_mode}"], cwd=str(flutter_project_path))
        
        if result.returncode == 0:
            print_colored("Web build completed successfully!", Colors.SUCCESS)
            print_colored("Web build output: flutter_project/build/web/", Colors.INFO)
            return True
        else:
            print_colored("Web build failed", Colors.ERROR)
            return False
            
    except Exception as e:
        print_colored(f"Error building for web: {e}", Colors.ERROR)
        return False

def build_android(build_mode: str = "release") -> bool:
    """Build Flutter for Android"""
    print_colored(f"Building for Android ({build_mode} mode)...", Colors.INFO)
    
    try:
        flutter_project_path = Path("flutter_project")
        result = run_command(["flutter", "build", "apk", f"--{build_mode}"], cwd=str(flutter_project_path))
        
        if result.returncode == 0:
            print_colored("Android build completed successfully!", Colors.SUCCESS)
            print_colored("Android APK output: flutter_project/build/app/outputs/flutter-apk/", Colors.INFO)
            return True
        else:
            print_colored("Android build failed", Colors.ERROR)
            return False
            
    except Exception as e:
        print_colored(f"Error building for Android: {e}", Colors.ERROR)
        return False

def generate_events_data() -> bool:
    """Generate events.json by running main.py"""
    print_colored("Generating events data by running main.py...", Colors.INFO)
    
    try:
        result = run_command([sys.executable, "main.py"])
        
        if result.returncode == 0:
            print_colored("Events data generated successfully!", Colors.SUCCESS)
            return True
        else:
            print_colored("Failed to generate events data", Colors.ERROR)
            return False
            
    except Exception as e:
        print_colored(f"Error generating events data: {e}", Colors.ERROR)
        return False

def show_build_summary(platform: str, build_mode: str, timestamp: str):
    """Show build summary"""
    print_colored("\nBuild Summary:", Colors.INFO)
    print_colored("=================", Colors.INFO)
    print_colored(f"Platform: {platform}", Colors.INFO)
    print_colored(f"Build Mode: {build_mode}", Colors.INFO)
    print_colored(f"Timestamp: {timestamp}", Colors.INFO)
    print_colored("")
    
    if platform in ["all", "web"]:
        print_colored("Web build output: flutter_project/build/web/", Colors.INFO)
    
    if platform in ["all", "android"]:
        print_colored("Android APK output: flutter_project/build/app/outputs/flutter-apk/", Colors.INFO)

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="GitHub Follow Contributions - Flutter Build Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python build_flutter.py                    # Build for all platforms
  python build_flutter.py --platform web     # Build for web only
  python build_flutter.py --platform android --clean  # Clean and build Android
  python build_flutter.py --debug            # Build in debug mode
        """
    )
    
    parser.add_argument(
        "--platform",
        choices=["web", "android", "all"],
        default="all",
        help="Build for specific platform (default: all)"
    )
    
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Clean build artifacts before building"
    )
    
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Build in debug mode (default: release)"
    )
    
    parser.add_argument(
        "--skip-events",
        action="store_true",
        help="Skip events.json generation/copying"
    )
    
    args = parser.parse_args()
    
    # Print header
    print_colored("GitHub Follow Contributions Flutter Build Script", Colors.MAGENTA)
    print_colored("=================================================", Colors.MAGENTA)
    
    # Configuration
    build_mode = "debug" if args.debug else "release"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Check Flutter environment
    if not check_flutter_environment():
        return 1
    
    # Handle events.json
    events_source = Path("public/events.json")
    if not args.skip_events:
        if not events_source.exists():
            print_colored("events.json not found. Do you want to generate it? (y/n):", Colors.WARNING)
            response = input().strip().lower()
            if response == 'y':
                if not generate_events_data():
                    return 1
            else:
                print_colored("Skipping events.json generation", Colors.WARNING)
        
        # Copy events data to Flutter assets
        if not copy_events_data():
            print_colored("Continuing without events data...", Colors.WARNING)
    
    # Clean build artifacts if requested
    if args.clean:
        if not clean_build_artifacts():
            return 1
    
    # Install dependencies
    if not install_dependencies():
        return 1
    
    # Build based on platform
    success = True
    
    try:
        if args.platform == "web":
            success = build_web(build_mode)
        elif args.platform == "android":
            success = build_android(build_mode)
        elif args.platform == "all":
            success = build_web(build_mode) and build_android(build_mode)
        
        if success:
            show_build_summary(args.platform, build_mode, timestamp)
            print_colored("Build process completed successfully!", Colors.SUCCESS)
            return 0
        else:
            print_colored("Build process failed!", Colors.ERROR)
            return 1
            
    except KeyboardInterrupt:
        print_colored("\nBuild process interrupted by user", Colors.WARNING)
        return 1
    except Exception as e:
        print_colored(f"Build process failed: {e}", Colors.ERROR)
        return 1

if __name__ == "__main__":
    sys.exit(main())