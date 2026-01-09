@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ============================================
echo   PackAI Sync Tool
echo   Sync commands/rules/skills to project dirs
echo ============================================
echo(

:: 获取脚本所在目录（源目录）
set "SOURCE_DIR=%~dp0"
set "SOURCE_DIR=%SOURCE_DIR:~0,-1%"

:: 配置文件路径
set "CONFIG_FILE=%SOURCE_DIR%\config\sync_project_paths.txt"

:: 检查配置文件是否存在
if not exist "%CONFIG_FILE%" (
    echo [Error] Config file not found: %CONFIG_FILE%
    echo [Tip] Add project paths to config\sync_project_paths.txt
    pause
    exit /b 1
)

echo [Info] Source: %SOURCE_DIR%
echo [Info] Config: %CONFIG_FILE%
echo(

:: 计数器
set "SUCCESS_COUNT=0"
set "SKIP_COUNT=0"
set "SKIPPED_DIRS="

:: 逐行读取配置文件
for /f "usebackq tokens=* delims=" %%a in ("%CONFIG_FILE%") do (
    set "LINE=%%a"
    
    :: 跳过空行
    if "!LINE!"=="" (
        rem 空行跳过
    ) else (
        :: 跳过注释行（以 # 开头）
        set "FIRST_CHAR=!LINE:~0,1!"
        if "!FIRST_CHAR!"=="#" (
            rem 注释行跳过
        ) else (
            :: 处理目标目录
            set "TARGET_DIR=!LINE!"
            
            echo ----------------------------------------
            echo [处理] !TARGET_DIR!
            
            :: 检查目标目录是否存在
            if not exist "!TARGET_DIR!" (
                echo [Skip] Dir not found: !TARGET_DIR!
                set /a SKIP_COUNT+=1
                set "SKIPPED_DIRS=!SKIPPED_DIRS!!TARGET_DIR!|"
            ) else (
                :: 同步 commands 目录
                if exist "%SOURCE_DIR%\commands" (
                    xcopy "%SOURCE_DIR%\commands" "!TARGET_DIR!\commands\" /E /I /Y /Q >nul 2>&1
                    echo [Sync] commands
                )
                
                :: 同步 rules 目录
                if exist "%SOURCE_DIR%\rules" (
                    xcopy "%SOURCE_DIR%\rules" "!TARGET_DIR!\rules\" /E /I /Y /Q >nul 2>&1
                    echo [Sync] rules
                )
                
                :: 同步 skills 目录
                if exist "%SOURCE_DIR%\skills" (
                    xcopy "%SOURCE_DIR%\skills" "!TARGET_DIR!\skills\" /E /I /Y /Q >nul 2>&1
                    echo [Sync] skills
                )
                
                echo [Done] !TARGET_DIR!
                set /a SUCCESS_COUNT+=1
            )
        )
    )
)

echo(
echo ============================================
echo   Sync completed!
echo   Success: !SUCCESS_COUNT! dirs
echo   Skipped: !SKIP_COUNT! dirs
if not "!SKIPPED_DIRS!"=="" (
    echo(
    echo   Skipped directories:
    for %%d in ("!SKIPPED_DIRS:|=" "!") do (
        if not "%%~d"=="" echo     - %%~d
    )
)
echo ============================================
pause
