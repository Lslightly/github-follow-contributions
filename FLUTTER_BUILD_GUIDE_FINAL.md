# Flutter构建脚本使用说明（最终版）

## 🚀 快速开始

### 最简单的Web构建方法：
```bash
# 一键构建Web版本（推荐）
python build_flutter_web_final.py

# 或者双击运行（Windows）
build_web.bat
```

构建完成后，打开 `flutter_project/build/web/index.html` 即可查看结果。

## 📋 可用脚本

### 1. 🔥 build_flutter_web_final.py（推荐）
**最简单的Web构建脚本，解决Windows编码问题**
```bash
# 一键构建Web版本
python build_flutter_web_final.py
```

### 2. build_web.bat（Windows）
Windows用户可以直接双击运行，自动构建Web版本

### 3. build_flutter.py（完整版）
原始完整版，支持更多选项和平台
```bash
# 查看帮助
python build_flutter.py --help

# 构建所有平台
python build_flutter.py

# 仅构建Web
python build_flutter.py --platform web

# 仅构建Android
python build_flutter.py --platform android
```

## 📁 构建输出

- **Web版本**: `flutter_project/build/web/`
  - 入口文件: `flutter_project/build/web/index.html`
- **Android APK**: `flutter_project/build/app/outputs/flutter-apk/`

## ⚠️ 常见问题

### Flutter命令未找到
```bash
# 检查Flutter是否安装
flutter --version

# 如果命令不存在，请安装Flutter并添加到PATH
# 下载地址: https://flutter.dev/docs/get-started/install
```

### events.json不存在
脚本会自动生成，也可以手动运行：
```bash
python main.py
```

### Android构建失败
由于Flutter版本兼容性问题，建议优先使用Web构建：
```bash
python build_flutter_web_final.py
```

## 🎯 推荐流程

### 对于Web迁移：
```bash
# 第1步：构建Web版本（最简单）
python build_flutter_web_final.py

# 第2步：查看结果
# 打开 flutter_project/build/web/index.html
```

### 对于完整测试：
```bash
# 使用完整版进行高级构建
python build_flutter.py --platform web
```

## 🎉 成功标志

构建成功时你会看到：
```
✓ Web构建成功！
📁 输出目录: flutter_project/build/web/
🎉 构建完成！
```

然后你就可以：
1. 打开 `flutter_project/build/web/index.html` 查看Flutter Web应用
2. 或者将整个 `flutter_project/build/web/` 目录部署到Web服务器