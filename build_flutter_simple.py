#!/usr/bin/env python3
"""
Flutter Migration Build Helper
简化版构建脚本，专门为GitHub Follow Contributions项目迁移设计
"""

import os
import sys
import subprocess
import shutil
import json
from pathlib import Path
from datetime import datetime

class FlutterBuildHelper:
    def __init__(self):
        self.flutter_project = Path("flutter_project")
        self.public_dir = Path("public")
        self.assets_dir = self.flutter_project / "assets"
        
    def print_status(self, message, status="info"):
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
    
    def run_flutter_command(self, cmd, cwd=None):
        """运行Flutter命令"""
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd or self.flutter_project,
                check=True,
                capture_output=True,
                text=True,
                encoding='utf-8'
            )
            return True, result.stdout
        except subprocess.CalledProcessError as e:
            return False, e.stderr
        except FileNotFoundError:
            return False, "Flutter命令未找到，请确保Flutter已安装并在PATH中"
    
    def check_environment(self):
        """检查环境"""
        self.print_status("检查Flutter环境...", "info")
        
        # 检查Flutter是否安装
        success, output = self.run_flutter_command(["flutter", "--version"], cwd=".")
        if not success:
            self.print_status(f"Flutter环境检查失败: {output}", "error")
            return False
        
        self.print_status(f"Flutter已安装: {output.strip()}", "success")
        
        # 检查项目结构
        if not self.flutter_project.exists():
            self.print_status("flutter_project目录不存在", "error")
            return False
        
        pubspec_path = self.flutter_project / "pubspec.yaml"
        if not pubspec_path.exists():
            self.print_status("pubspec.yaml文件不存在", "error")
            return False
        
        self.print_status("环境检查通过！", "success")
        return True
    
    def prepare_assets(self):
        """准备资源文件"""
        self.print_status("准备Flutter资源文件...", "info")
        
        # 创建assets目录
        self.assets_dir.mkdir(exist_ok=True)
        
        # 检查events.json是否存在
        events_source = self.public_dir / "events.json"
        if not events_source.exists():
            self.print_status("events.json不存在，尝试生成...", "warning")
            success = self.generate_events_data()
            if not success:
                return False
        
        # 复制events.json到assets目录
        events_dest = self.assets_dir / "events.json"
        shutil.copy2(events_source, events_dest)
        self.print_status("资源文件准备完成！", "success")
        return True
    
    def generate_events_data(self):
        """运行main.py生成数据"""
        self.print_status("运行main.py生成事件数据...", "info")
        
        try:
            result = subprocess.run(
                [sys.executable, "main.py"],
                check=True,
                capture_output=True,
                text=True,
                encoding='utf-8'
            )
            
            if result.returncode == 0:
                self.print_status("事件数据生成成功！", "success")
                return True
            else:
                self.print_status(f"事件数据生成失败: {result.stderr}", "error")
                return False
                
        except Exception as e:
            self.print_status(f"运行main.py时出错: {e}", "error")
            return False
    
    def install_dependencies(self):
        """安装依赖"""
        self.print_status("安装Flutter依赖...", "info")
        
        success, output = self.run_flutter_command(["flutter", "pub", "get"])
        if success:
            self.print_status("依赖安装成功！", "success")
            return True
        else:
            self.print_status(f"依赖安装失败: {output}", "error")
            return False
    
    def build_web(self, release=True):
        """构建Web版本"""
        mode = "release" if release else "debug"
        self.print_status(f"构建Web版本 ({mode}模式)...", "info")
        
        success, output = self.run_flutter_command([
            "flutter", "build", "web", f"--{mode}"
        ])
        
        if success:
            self.print_status("Web构建成功！", "success")
            self.print_status("输出目录: flutter_project/build/web/", "info")
            return True
        else:
            self.print_status(f"Web构建失败: {output}", "error")
            return False
    
    def build_android(self, release=True):
        """构建Android版本"""
        mode = "release" if release else "debug"
        self.print_status(f"构建Android版本 ({mode}模式)...", "info")
        
        success, output = self.run_flutter_command([
            "flutter", "build", "apk", f"--{mode}"
        ])
        
        if success:
            self.print_status("Android构建成功！", "success")
            self.print_status("APK输出: flutter_project/build/app/outputs/flutter-apk/", "info")
            return True
        else:
            self.print_status(f"Android构建失败: {output}", "error")
            return False
    
    def clean_build(self):
        """清理构建缓存"""
        self.print_status("清理构建缓存...", "info")
        
        success, output = self.run_flutter_command(["flutter", "clean"])
        if success:
            self.print_status("构建缓存清理成功！", "success")
            return True
        else:
            self.print_status(f"清理失败: {output}", "error")
            return False
    
    def show_project_info(self):
        """显示项目信息"""
        self.print_status("\n=== GitHub Follow Contributions 项目信息 ===", "header")
        
        # 检查Vue前端
        vue_files = ["frontend/App.vue", "frontend/main.js", "index.html"]
        vue_exists = all(Path(f).exists() for f in vue_files)
        
        # 检查Flutter项目
        flutter_files = [
            "flutter_project/pubspec.yaml",
            "flutter_project/lib/main.dart",
            "flutter_project/web/index.html"
        ]
        flutter_exists = all(Path(f).exists() for f in flutter_files)
        
        # 检查数据文件
        events_exists = (self.public_dir / "events.json").exists()
        
        self.print_status(f"Vue前端: {'✓' if vue_exists else '✗'}", "success" if vue_exists else "warning")
        self.print_status(f"Flutter项目: {'✓' if flutter_exists else '✗'}", "success" if flutter_exists else "warning")
        self.print_status(f"事件数据: {'✓' if events_exists else '✗'}", "success" if events_exists else "warning")
        
        if flutter_exists:
            pubspec_path = self.flutter_project / "pubspec.yaml"
            try:
                with open(pubspec_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if "name:" in content:
                        name = content.split("name:")[1].split("\n")[0].strip()
                        self.print_status(f"Flutter项目名称: {name}", "info")
            except:
                pass
        
        self.print_status("=" * 50, "header")
    
    def run_full_build(self, platform="all", release=True, clean=False):
        """运行完整构建流程"""
        self.print_status(f"\n开始构建流程 - 平台: {platform}, 模式: {'release' if release else 'debug'}", "header")
        
        # 显示项目信息
        self.show_project_info()
        
        # 检查环境
        if not self.check_environment():
            return False
        
        # 清理构建缓存（可选）
        if clean:
            if not self.clean_build():
                return False
        
        # 准备资源文件
        if not self.prepare_assets():
            return False
        
        # 安装依赖
        if not self.install_dependencies():
            return False
        
        # 构建
        success = True
        if platform in ["web", "all"]:
            success = success and self.build_web(release)
        
        if platform in ["android", "all"]:
            success = success and self.build_android(release)
        
        if success:
            self.print_status("\n🎉 构建完成！", "success")
            self.print_status(f"构建时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", "info")
            
            if platform in ["web", "all"]:
                self.print_status("Web构建输出: flutter_project/build/web/", "info")
            
            if platform in ["android", "all"]:
                self.print_status("APK输出: flutter_project/build/app/outputs/flutter-apk/", "info")
        else:
            self.print_status("\n❌ 构建失败！", "error")
        
        return success

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="GitHub Follow Contributions Flutter迁移构建助手",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  python build_flutter_simple.py                    # 构建所有平台
  python build_flutter_simple.py --platform web     # 仅构建Web
  python build_flutter_simple.py --platform android --clean  # 清理并构建Android
  python build_flutter_simple.py --debug            # 调试模式构建
  python build_flutter_simple.py --info             # 显示项目信息
        """
    )
    
    parser.add_argument(
        "--platform",
        choices=["web", "android", "all"],
        default="all",
        help="目标平台 (默认: all)"
    )
    
    parser.add_argument(
        "--clean",
        action="store_true",
        help="构建前清理缓存"
    )
    
    parser.add_argument(
        "--debug",
        action="store_true",
        help="调试模式 (默认: release)"
    )
    
    parser.add_argument(
        "--info",
        action="store_true",
        help="仅显示项目信息"
    )
    
    parser.add_argument(
        "--skip-events",
        action="store_true",
        help="跳过事件数据处理"
    )
    
    args = parser.parse_args()
    
    # 打印标题
    print("\n" + "="*60)
    print("GitHub Follow Contributions Flutter迁移构建助手")
    print("="*60)
    
    helper = FlutterBuildHelper()
    
    if args.info:
        helper.show_project_info()
        return 0
    
    # 运行构建
    success = helper.run_full_build(
        platform=args.platform,
        release=not args.debug,
        clean=args.clean
    )
    
    return 0 if success else 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\n操作被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n发生错误: {e}")
        sys.exit(1)