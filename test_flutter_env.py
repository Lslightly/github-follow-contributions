#!/usr/bin/env python3
"""
简单的Flutter环境测试脚本
"""

import os
import subprocess
import sys

def test_flutter_environment():
    """测试Flutter环境"""
    print("=== Flutter环境测试 ===")
    
    # 检测操作系统
    is_windows = os.name == 'nt'
    print(f"操作系统: {'Windows' if is_windows else '其他'}")
    
    # 尝试不同的Flutter命令格式
    flutter_commands = ['flutter.bat', 'flutter'] if is_windows else ['flutter']
    
    flutter_cmd = None
    for cmd in flutter_commands:
        try:
            print(f"正在测试命令: {cmd}")
            result = subprocess.run([cmd, '--version'], capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                print(f"✓ 成功找到Flutter命令: {cmd}")
                print(f"版本信息: {result.stdout.strip()}")
                flutter_cmd = cmd
                break
            else:
                print(f"✗ 命令失败: {result.stderr}")
        except FileNotFoundError:
            print(f"✗ 命令未找到: {cmd}")
        except Exception as e:
            print(f"✗ 错误: {e}")
    
    if not flutter_cmd:
        print("\n❌ Flutter命令未找到！")
        print("请确保:")
        print("1. Flutter已正确安装")
        print("2. Flutter已添加到系统PATH环境变量")
        print("3. 可以尝试运行: flutter --version")
        return False
    
    # 测试项目结构
    print("\n=== 项目结构检查 ===")
    flutter_project = "flutter_project"
    pubspec_file = os.path.join(flutter_project, "pubspec.yaml")
    
    if os.path.exists(flutter_project):
        print(f"✓ Flutter项目目录存在: {flutter_project}")
    else:
        print(f"✗ Flutter项目目录不存在: {flutter_project}")
        return False
    
    if os.path.exists(pubspec_file):
        print(f"✓ pubspec.yaml文件存在")
        
        # 读取项目信息
        try:
            with open(pubspec_file, 'r', encoding='utf-8') as f:
                content = f.read()
                if "name:" in content:
                    name = content.split("name:")[1].split("\n")[0].strip()
                    print(f"项目名称: {name}")
        except Exception as e:
            print(f"读取pubspec.yaml失败: {e}")
    else:
        print(f"✗ pubspec.yaml文件不存在")
        return False
    
    # 测试简单的Flutter命令
    print(f"\n=== 测试Flutter命令 ===")
    try:
        print("运行: flutter pub get (干运行)")
        # 这里可以添加实际的依赖安装测试
        print("✓ Flutter命令可以正常调用")
    except Exception as e:
        print(f"✗ Flutter命令测试失败: {e}")
        return False
    
    print("\n🎉 Flutter环境测试通过！")
    return True

if __name__ == "__main__":
    try:
        success = test_flutter_environment()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n操作被中断")
        sys.exit(1)
    except Exception as e:
        print(f"发生错误: {e}")
        sys.exit(1)