@echo off
echo.
echo ================================================
echo GitHub Follow Contributions - Flutter Web构建
echo ================================================
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: Python未安装或不在PATH中
    echo 请先安装Python并添加到系统PATH
    pause
    exit /b 1
)

echo 正在构建Flutter Web版本...
echo.

REM 运行构建脚本
python build_flutter_web_final.py

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo 🎉 构建成功！
    echo ================================================
    echo.
    echo 构建输出:
    echo 📁 flutter_project\build\web\
    echo 📄 入口文件: index.html
    echo.
    echo 要查看构建结果:
    echo 1. 打开 flutter_project\build\web\index.html
    echo 2. 或使用本地服务器运行
    echo.
) else (
    echo.
    echo ❌ 构建失败，请检查错误信息
    echo.
)

pause