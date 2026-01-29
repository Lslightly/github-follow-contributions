#!/usr/bin/env python3
"""
Flutter Web构建脚本 - 最终版
忽略编码警告，专注于Web构建
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

def run_command(cmd, cwd=None):
    """运行命令（忽略编码问题）"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='ignore',  # 忽略编码错误
            timeout=300  # 5分钟超时
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def main():
    """主函数"""
    print_status("GitHub Follow Contributions Flutter Web构建", "header")
    print_status("="*50, "header")
    
    # 检查项目结构
    flutter_project = Path("flutter_project")
    if not flutter_project.exists():
        print_status("❌ flutter_project目录不存在", "error")
        return 1
    
    # 检查events.json
    events_file = Path("public/events.json")
    if not events_file.exists():
        print_status("⚠️  events.json不存在，正在生成...", "warning")
        try:
            subprocess.run([sys.executable, "main.py"], check=True, timeout=60)
            if not events_file.exists():
                print_status("❌ events.json生成失败", "error")
                return 1
        except Exception as e:
            print_status(f"❌ 生成失败: {e}", "error")
            return 1
    
    # 复制资源文件
    assets_dir = flutter_project / "assets"
    assets_dir.mkdir(exist_ok=True)
    shutil.copy2(events_file, assets_dir / "events.json")
    print_status("✓ 资源文件准备完成", "success")
    
    # 安装依赖
    print_status("\n📦 安装Flutter依赖...")
    success, stdout, stderr = run_command("flutter pub get", cwd=str(flutter_project))
    if success:
        print_status("✓ 依赖安装成功", "success")
    else:
        print_status(f"❌ 依赖安装失败: {stderr}", "error")
        return 1
    
    # 构建Web版本
    print_status("\n🌐 构建Web版本...")
    success, stdout, stderr = run_command("flutter build web --release", cwd=str(flutter_project))
    if success:
        print_status("✓ Web构建成功！", "success")
        
        # 检查构建结果
        web_dir = flutter_project / "build" / "web"
        if web_dir.exists():
            html_file = web_dir / "index.html"
            if html_file.exists():
                print_status(f"✓ 入口文件生成成功: {html_file}", "success")
            
            # 统计文件数量
            file_count = len(list(web_dir.glob("*")))
            print_status(f"✓ 共生成 {file_count} 个文件", "success")
    else:
        print_status(f"❌ Web构建失败: {stderr}", "error")
        return 1
    
    # 完成信息
    print_status("\n" + "="*50, "header")
    print_status("🎉 构建完成！", "success")
    print_status(f"⏰ 完成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", "info")
    print_status("📁 构建输出:", "info")
    print_status("  📄 入口: flutter_project/build/web/index.html", "info")
    print_status("  📂 目录: flutter_project/build/web/", "info")
    print_status("="*50, "header")
    
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print_status("\n操作被中断", "warning")
        sys.exit(1)
    except Exception as e:
        print_status(f"发生错误: {e}", "error")
        sys.exit(1)