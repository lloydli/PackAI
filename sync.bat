@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ============================================
echo   PackAI 同步工具
echo   将 commands、rules、skills 同步到目标目录
echo ============================================
echo.

:: 获取脚本所在目录（源目录）
set "SOURCE_DIR=%~dp0"
set "SOURCE_DIR=%SOURCE_DIR:~0,-1%"

:: 提示用户输入目标配置目录
set /p "TARGET_DIR=请输入目标配置目录路径 (例如: C:\MyProject\.codebuddy): "

:: 检查用户是否输入
if "%TARGET_DIR%"=="" (
    echo [错误] 未输入目标目录，退出。
    pause
    exit /b 1
)

:: 检查目标目录是否存在
if not exist "%TARGET_DIR%" (
    echo [警告] 目标目录不存在: %TARGET_DIR%
    set /p "CREATE_DIR=是否创建该目录? (Y/N): "
    if /i "!CREATE_DIR!"=="Y" (
        mkdir "%TARGET_DIR%"
        echo [信息] 已创建目录: %TARGET_DIR%
    ) else (
        echo [信息] 已取消操作。
        pause
        exit /b 0
    )
)

echo.
echo [信息] 源目录: %SOURCE_DIR%
echo [信息] 目标目录: %TARGET_DIR%
echo.

:: 同步 commands 目录
if exist "%SOURCE_DIR%\commands" (
    echo [同步] commands ...
    xcopy "%SOURCE_DIR%\commands" "%TARGET_DIR%\commands\" /E /I /Y /Q
    echo [完成] commands 同步成功
) else (
    echo [跳过] commands 目录不存在
)

:: 同步 rules 目录
if exist "%SOURCE_DIR%\rules" (
    echo [同步] rules ...
    xcopy "%SOURCE_DIR%\rules" "%TARGET_DIR%\rules\" /E /I /Y /Q
    echo [完成] rules 同步成功
) else (
    echo [跳过] rules 目录不存在
)

:: 同步 skills 目录
if exist "%SOURCE_DIR%\skills" (
    echo [同步] skills ...
    xcopy "%SOURCE_DIR%\skills" "%TARGET_DIR%\skills\" /E /I /Y /Q
    echo [完成] skills 同步成功
) else (
    echo [跳过] skills 目录不存在
)

echo.
echo ============================================
echo   同步完成!
echo ============================================
pause
