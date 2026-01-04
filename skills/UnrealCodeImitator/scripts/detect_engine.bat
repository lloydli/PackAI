@echo off
REM detect_engine.bat
REM Engine path detection entry script
REM Detects engine path and creates/updates project-level config: .codebuddy\.UnrealCodeImitator\config.json
REM Usage: detect_engine.bat [WorkspacePath]

setlocal enabledelayedexpansion

REM ===== Initialize variables =====
set "SCRIPT_PATH=%~dp0"
set "PS_SCRIPT=%SCRIPT_PATH%ps\detect_engine.ps1"
set "CONFIG_MANAGER=%SCRIPT_PATH%ps\config_manager.ps1"

REM Workspace: use parameter if provided, otherwise use current directory
if not "%~1"=="" (
    set "WORKSPACE_PATH=%~1"
) else (
    set "WORKSPACE_PATH=%CD%"
)

set "CONFIG_FILE=%WORKSPACE_PATH%\.codebuddy\.UnrealCodeImitator\config.json"
set "TEMP_RESULT=%TEMP%\detect_engine_result_%RANDOM%.json"

echo.
echo ========================================
echo  Unreal Engine Path Detector
echo ========================================
echo.
echo [Info] Workspace: %WORKSPACE_PATH%
echo [Info] Config file: %CONFIG_FILE%
echo.

REM ===== Check if PowerShell script exists =====
if not exist "%PS_SCRIPT%" (
    echo [Error] PowerShell script not found: %PS_SCRIPT%
    exit /b 1
)

REM ===== Execute engine detection =====
echo [1] Detecting engine path...

REM Execute PowerShell script, stderr shows logs, stdout saves JSON result
powershell -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%" -WorkspacePath "%WORKSPACE_PATH%" > "%TEMP_RESULT%"

if %ERRORLEVEL% neq 0 (
    echo [Error] Engine detection failed
    if exist "%TEMP_RESULT%" type "%TEMP_RESULT%"
    del "%TEMP_RESULT%" 2>nul
    exit /b 1
)

REM ===== Parse detection result =====
echo [2] Parsing detection result...

REM Use PowerShell to parse JSON result and extract fields
for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%TEMP_RESULT%' -Raw | ConvertFrom-Json; if ($json.Success) { Write-Output $json.EnginePath } else { Write-Output 'FAILED' }"`) do (
    set "ENGINE_PATH=%%A"
)

if "!ENGINE_PATH!"=="FAILED" (
    echo [Error] Engine detection failed - could not find engine path
    if exist "%TEMP_RESULT%" type "%TEMP_RESULT%"
    del "%TEMP_RESULT%" 2>nul
    exit /b 1
)

if "!ENGINE_PATH!"=="" (
    echo [Error] Engine path is empty
    del "%TEMP_RESULT%" 2>nul
    exit /b 1
)

echo [OK] Detected engine path: !ENGINE_PATH!

REM Extract other fields
for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%TEMP_RESULT%' -Raw | ConvertFrom-Json; Write-Output $json.ProjectPath"`) do (
    set "PROJECT_PATH=%%A"
)

for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%TEMP_RESULT%' -Raw | ConvertFrom-Json; Write-Output $json.UProjectFile"`) do (
    set "UPROJECT_FILE=%%A"
)

for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%TEMP_RESULT%' -Raw | ConvertFrom-Json; Write-Output $json.SceneType"`) do (
    set "SCENE_TYPE=%%A"
)

del "%TEMP_RESULT%" 2>nul

echo [Info] Project path: !PROJECT_PATH!
echo [Info] UProject file: !UPROJECT_FILE!
echo [Info] Scene type: !SCENE_TYPE!
echo.

REM ===== Write config file =====
echo [3] Writing config file...

powershell -ExecutionPolicy Bypass -NoProfile -File "%CONFIG_MANAGER%" -Action "write" -ConfigPath "%CONFIG_FILE%" -EnginePath "!ENGINE_PATH!" -ProjectPath "!PROJECT_PATH!" -UProjectFile "!UPROJECT_FILE!" -SceneType "!SCENE_TYPE!"

if %ERRORLEVEL% neq 0 (
    echo [Error] Failed to write config file
    exit /b 1
)

echo.
echo ========================================
echo  Detection Complete
echo ========================================
echo.
echo Engine Path: !ENGINE_PATH!
echo Config File: %CONFIG_FILE%
echo.

REM Output engine path for caller
echo ENGINE_PATH=!ENGINE_PATH!

exit /b 0
