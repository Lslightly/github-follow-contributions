@echo off
echo.
echo ================================================
echo GitHub Follow Contributions Flutter构建工具
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

REM 显示菜单
echo 请选择构建选项:
echo 1. 构建所有平台 (Web + Android)
echo 2. 仅构建Web版本
echo 3. 仅构建Android版本
echo 4. 清理并重新构建所有平台
echo 5. 显示项目信息
echo 6. 退出
echo.

set /p choice=请输入选项编号 (1-6): 

if "%choice%"=="1" (
    echo 正在构建所有平台...
    python build_flutter_simple.py --platform all
) else if "%choice%"=="2" (
    echo 正在构建Web版本...
    python build_flutter_simple.py --platform web
) else if "%choice%"=="3" (
    echo 正在构建Android版本...
    python build_flutter_simple.py --platform android
) else if "%choice%"=="4" (
    echo 正在清理并重新构建所有平台...
    python build_flutter_simple.py --platform all --clean
) else if "%choice%"=="5" (
    python build_flutter_simple.py --info
) else if "%choice%"=="6" (
    echo 退出构建工具
    exit /b 0
) else (
    echo 无效的选项，请重新运行并输入1-6之间的数字
    pause
    exit /b 1
)

echo.
echo 构建完成！
echo.
echo 输出目录:
echo - Web版本: flutter_project\build\web\
echo - Android APK: flutter_project\build\app\outputs\flutter-apk\
echo.
pause