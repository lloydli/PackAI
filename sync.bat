@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ============================================
echo   PackAI 同步工具
echo   将 commands、rules、skills、mcp.json
echo   同步到用户目录下的 .codebuddy
echo ============================================
echo.

:: 获取脚本所在目录（源目录）
set "SOURCE_DIR=%~dp0"
set "SOURCE_DIR=%SOURCE_DIR:~0,-1%"

:: 设置目标目录为用户目录下的 .codebuddy
set "TARGET_DIR=%USERPROFILE%\.codebuddy"

:: 检查目标目录是否存在，不存在则自动创建
if not exist "%TARGET_DIR%" (
    echo [信息] 目标目录不存在，正在创建: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
    echo [完成] 目录已创建
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

:: 同步 mcp.json 文件
if exist "%SOURCE_DIR%\mcp.json" (
    echo [同步] mcp.json ...
    copy /Y "%SOURCE_DIR%\mcp.json" "%TARGET_DIR%\mcp.json" >nul
    echo [完成] mcp.json 同步成功
) else (
    echo [跳过] mcp.json 文件不存在
)

echo.
echo ============================================
echo   同步完成!
echo ============================================
pause
