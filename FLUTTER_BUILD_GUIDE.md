# Flutter构建脚本使用说明

## 概述
这个Python脚本用于构建GitHub Follow Contributions项目的Flutter版本，支持Web和Android平台。

## 环境要求
- Python 3.6+
- Flutter SDK (已配置在系统PATH中)
- 项目结构保持完整（flutter_project目录等）

## 脚本列表

### 1. build_flutter.py (完整版)
功能最全的构建脚本，支持详细的错误处理和日志输出。

```bash
# 基本用法
python build_flutter.py                    # 构建所有平台
python build_flutter.py --platform web     # 仅构建Web
python build_flutter.py --platform android # 仅构建Android

# 高级选项
python build_flutter.py --clean              # 清理后构建
python build_flutter.py --debug              # 调试模式
python build_flutter.py --skip-events        # 跳过事件数据处理
```

### 2. build_flutter_simple.py (简化版)
更适合日常使用的简化版本，中文界面，更友好的输出。

```bash
# 基本用法
python build_flutter_simple.py                    # 构建所有平台
python build_flutter_simple.py --platform web     # 仅构建Web
python build_flutter_simple.py --platform android # 仅构建Android

# 其他选项
python build_flutter_simple.py --clean            # 清理后构建
python build_flutter_simple.py --debug              # 调试模式
python build_flutter_simple.py --info               # 显示项目信息
```

### 3. build_flutter.bat (Windows批处理)
Windows用户可以直接双击运行，提供图形化菜单选择。

## 构建流程

1. **环境检查**: 验证Flutter安装和项目结构
2. **数据准备**: 复制events.json到Flutter assets目录
3. **依赖安装**: 运行`flutter pub get`
4. **平台构建**: 根据选择构建Web和/或Android

## 输出目录

- **Web版本**: `flutter_project/build/web/`
- **Android APK**: `flutter_project/build/app/outputs/flutter-apk/`

## 常见问题

### 1. events.json不存在
脚本会自动询问是否运行main.py生成数据，或者可以使用`--skip-events`跳过。

### 2. Flutter命令未找到
请确保Flutter SDK已安装并添加到系统PATH环境变量中。

### 3. 构建失败
- 检查网络连接（需要下载依赖）
- 运行`--clean`选项清理缓存后重试
- 查看错误输出信息

### 4. Web构建后页面空白
- 确保events.json文件存在且格式正确
- 检查浏览器控制台错误信息
- 确认构建输出文件完整

## 迁移状态检查

运行以下命令查看当前项目迁移状态：
```bash
python build_flutter_simple.py --info
```

这会显示：
- Vue前端文件状态
- Flutter项目结构完整性
- 事件数据文件状态
- Flutter项目名称

## 快速开始

对于首次使用，建议按以下步骤操作：

1. 检查项目状态：
   ```bash
   python build_flutter_simple.py --info
   ```

2. 构建Web版本（测试用）：
   ```bash
   python build_flutter_simple.py --platform web --debug
   ```

3. 如果一切正常，构建所有平台：
   ```bash
   python build_flutter_simple.py
   ```

4. Windows用户可以直接双击`build_flutter.bat`使用图形界面。

## 注意事项

- 构建前确保`main.py`可以正常运行（数据生成）
- Web构建输出可以直接部署到静态文件服务器
- Android构建生成的是APK文件，可以安装到Android设备
- 建议在构建前备份重要数据