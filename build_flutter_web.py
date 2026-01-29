#!/usr/bin/env python3
"""
Flutter Web构建脚本 - 简化版
专注于Web平台构建，解决Windows编码问题
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path
from datetime import datetime

def print_status(message, status="info"):
    """打印状态信息"""
    colors = {
        "success": "\033[92m",
        "error": "\033[91m",
        "warning": "\033[93m",
        "info": "\033[94m",
        "header": "\033[95m"
    }
    color = colors.get(status, colors["info"])
    print(f"{color}{message}\033[0m")

def find_flutter_command():
    """找到正确的Flutter命令"""
    if os.name == 'nt':  # Windows
        candidates = ['flutter.bat', 'flutter']
    else:
        candidates = ['flutter']
    
    for cmd in candidates:
        try:
            # 使用shell=True避免编码问题
            result = subprocess.run(
                f"{cmd} --version",
                shell=True,
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                return cmd
        except Exception:
            continue
    
    return None

def run_flutter_command(cmd_list, cwd=None):
    """运行Flutter命令"""
    flutter_cmd = find_flutter_command()
    if not flutter_cmd:
        return False, "Flutter命令未找到"
    
    # 构建完整命令
    cmd_list[0] = flutter_cmd
    full_cmd = " ".join(cmd_list)
    
    try:
        result = subprocess.run(
            full_cmd,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=300  # 5分钟超时
        )
        
        if result.returncode == 0:
            return True, result.stdout
        else:
            return False, result.stderr
            
    except Exception as e:
        return False, str(e)

def prepare_environment():
    """准备构建环境"""
    print_status("准备Flutter Web构建环境...", "header")
    
    # 检查Flutter命令
    flutter_cmd = find_flutter_command()
    if not flutter_cmd:
        print_status("❌ Flutter命令未找到！请确保Flutter已安装并在PATH中", "error")
        return False
    
    print_status(f"✓ 找到Flutter命令: {flutter_cmd}", "success")
    
    # 检查项目结构
    flutter_project = Path("flutter_project")
    if not flutter_project.exists():
        print_status("❌ flutter_project目录不存在", "error")
        return False
    
    pubspec_file = flutter_project / "pubspec.yaml"
    if not pubspec_file.exists():
        print_status("❌ pubspec.yaml文件不存在", "error")
        return False
    
    print_status("✓ Flutter项目结构正常", "success")
    return True

def prepare_assets():
    """准备资源文件"""
    print_status("\n📁 准备资源文件...")
    
    # 检查events.json
    events_file = Path("public/events.json")
    if not events_file.exists():
        print_status("⚠️ events.json不存在，尝试生成...", "warning")
        try:
            subprocess.run([sys.executable, "main.py"], check=True, timeout=60)
            if not events_file.exists():
                print_status("❌ events.json生成失败", "error")
                return False
        except Exception as e:
            print_status(f"❌ 生成events.json失败: {e}", "error")
            return False
    
    # 复制到assets目录
    assets_dir = Path("flutter_project/assets")
    assets_dir.mkdir(exist_ok=True)
    shutil.copy2(events_file, assets_dir / "events.json")
    print_status("✓ events.json已复制到Flutter assets", "success")
    return True

def install_dependencies():
    """安装Flutter依赖"""
    print_status("\n📦 安装Flutter依赖...")
    
    success, output = run_flutter_command(["flutter", "pub", "get"], cwd="flutter_project")
    if success:
        print_status("✓ Flutter依赖安装成功", "success")
        return True
    else:
        print_status(f"❌ Flutter依赖安装失败: {output}", "error")
        return False

def build_web(release=True):
    """构建Web版本"""
    mode = "release" if release else "debug"
    print_status(f"\n🌐 构建Web版本 ({mode}模式)...")
    
    success, output = run_flutter_command(["flutter", "build", "web", f"--{mode}"], cwd="flutter_project")
    if success:
        print_status("✓ Web构建成功！", "success")
        print_status("📁 输出目录: flutter_project/build/web/", "info")
        
        # 显示构建结果
        web_build_dir = Path("flutter_project/build/web")
        if web_build_dir.exists():
            files = list(web_build_dir.glob("*.html")) + list(web_build_dir.glob("*.js"))
            if files:
                print_status(f"✓ 生成文件数量: {len(files)}个", "success")
        
        return True
    else:
        print_status(f"❌ Web构建失败: {output}", "error")
        return False

def show_summary():
    """显示构建摘要"""
    print_status("\n" + "="*50, "header")
    print_status("🎉 Flutter Web构建完成！", "success")
    print_status(f"完成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", "info")
    print_status("📁 构建输出:", "info")
    print_status("  • Web文件: flutter_project/build/web/", "info")
    print_status("  • 入口文件: flutter_project/build/web/index.html", "info")
    print_status("="*50, "header")

def main():
    """主函数"""
    print_status("GitHub Follow Contributions Flutter Web构建工具", "header")
    print_status("="*60, "header")
    
    # 1. 准备环境
    if not prepare_environment():
        return 1
    
    # 2. 准备资源文件
    if not prepare_assets():
        return 1
    
    # 3. 安装依赖
    if not install_dependencies():
        return 1
    
    # 4. 构建Web版本
    if not build_web(release=True):
        return 1
    
    # 5. 显示摘要
    show_summary()
    
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print_status("\n操作被用户中断", "warning")
        sys.exit(1)
    except Exception as e:
        print_status(f"发生错误: {e}", "error")
        sys.exit(1)