#!/usr/bin/env python3
"""
Flutter构建脚本 - 最终修复版
解决Windows上的编码和命令检测问题
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path
from datetime import datetime

def check_flutter_cmd():
    """检测Flutter命令"""
    print("正在检测Flutter命令...")
    
    # Windows系统下优先使用flutter.bat
    if os.name == 'nt':
        candidates = ['flutter.bat', 'flutter.cmd', 'flutter']
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
                print(f"✓ 找到Flutter命令: {cmd}")
                return cmd
        except Exception as e:
            print(f"测试 {cmd} 失败: {e}")
            continue
    
    return None

def run_flutter_command(cmd_list, cwd=None):
    """运行Flutter命令"""
    flutter_cmd = check_flutter_cmd()
    if not flutter_cmd:
        print("❌ Flutter命令未找到！")
        return False, "Flutter未安装或不在PATH中"
    
    # 替换命令
    if cmd_list[0] == "flutter":
        cmd_list[0] = flutter_cmd
    
    # 构建完整命令字符串
    full_cmd = " ".join(cmd_list)
    
    try:
        result = subprocess.run(
            full_cmd,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace',
            timeout=120
        )
        
        if result.returncode == 0:
            return True, result.stdout
        else:
            return False, result.stderr
            
    except Exception as e:
        return False, str(e)

def main():
    """主函数 - 简化版本"""
    print("\n" + "="*60)
    print("GitHub Follow Contributions Flutter构建工具")
    print("="*60)
    
    # 检查项目结构
    flutter_project = Path("flutter_project")
    if not flutter_project.exists():
        print("❌ flutter_project目录不存在")
        return 1
    
    pubspec_file = flutter_project / "pubspec.yaml"
    if not pubspec_file.exists():
        print("❌ pubspec.yaml文件不存在")
        return 1
    
    # 检查events.json
    events_file = Path("public/events.json")
    if not events_file.exists():
        print("⚠️  events.json不存在，尝试生成...")
        try:
            subprocess.run([sys.executable, "main.py"], check=True, timeout=60)
            if events_file.exists():
                print("✓ events.json生成成功")
            else:
                print("❌ events.json生成失败")
                return 1
        except Exception as e:
            print(f"❌ 生成events.json失败: {e}")
            return 1
    
    # 复制events.json到assets
    assets_dir = flutter_project / "assets"
    assets_dir.mkdir(exist_ok=True)
    shutil.copy2(events_file, assets_dir / "events.json")
    print("✓ events.json已复制到Flutter assets")
    
    # 安装依赖
    print("\n📦 安装Flutter依赖...")
    success, output = run_flutter_command(["flutter", "pub", "get"], cwd=str(flutter_project))
    if success:
        print("✓ 依赖安装成功")
    else:
        print(f"❌ 依赖安装失败: {output}")
        return 1
    
    # 构建Web版本
    print("\n🌐 构建Web版本...")
    success, output = run_flutter_command(["flutter", "build", "web", "--release"], cwd=str(flutter_project))
    if success:
        print("✓ Web构建成功")
        print("📁 输出目录: flutter_project/build/web/")
    else:
        print(f"❌ Web构建失败: {output}")
        return 1
    
    # 构建Android版本
    print("\n📱 构建Android版本...")
    success, output = run_flutter_command(["flutter", "build", "apk", "--release"], cwd=str(flutter_project))
    if success:
        print("✓ Android构建成功")
        print("📁 APK输出: flutter_project/build/app/outputs/flutter-apk/")
    else:
        print(f"❌ Android构建失败: {output}")
        return 1
    
    print("\n🎉 构建完成！")
    print(f"完成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n操作被中断")
        sys.exit(1)
    except Exception as e:
        print(f"发生错误: {e}")
        sys.exit(1)