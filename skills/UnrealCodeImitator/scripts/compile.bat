@echo off
REM Unreal Engine compile script (BAT version)
REM Purpose: Automatically build Unreal plugins/projects and collect build logs
REM Now supports: Project-level config (.codebuddy\.UnrealCodeImitator\config.json) with auto engine detection
REM Usage: compile.bat [BuildConfiguration]
REM   BuildConfiguration: DebugGame, Development (default), or Shipping

setlocal enabledelayedexpansion

REM ===== COLOR DEFINITION =====
for /F %%A in ('copy /Z "%~f0" nul') do set "BS=%%A"

REM ===== INITIALIZE VARIABLES =====
set "SKILL_PATH=%~dp0"
set "SKILL_ROOT=%SKILL_PATH%.."
set "PROJECT_CONFIG_DIR=%CD%\.codebuddy\.UnrealCodeImitator"
set "PROJECT_CONFIG_FILE=%PROJECT_CONFIG_DIR%\config.json"
set "CONFIG_MANAGER=%SKILL_PATH%ps\config_manager.ps1"
set "DETECT_ENGINE=%SKILL_PATH%detect_engine.bat"
set "LOG_DIR=%PROJECT_CONFIG_DIR%\build_logs"
set "TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "COMPILE_LOG=%LOG_DIR%\compile_%TIMESTAMP%.log"
set "ERROR_LOG=%LOG_DIR%\errors_%TIMESTAMP%.txt"
set "LATEST_ERROR_LOG=%LOG_DIR%\latest_errors.txt"

REM ===== PARSE COMMAND LINE ARGUMENTS =====
set "BUILD_CONFIGURATION=Development"
if not "%~1"=="" (
    set "BUILD_CONFIGURATION=%~1"
)

REM ===== CREATE LOG DIRECTORY =====
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM ===== DISPLAY HEADER =====
echo.
echo ========================================
echo  Unreal Engine Compile Script (BAT)
echo ========================================
echo.
echo [Info] Build Configuration: %BUILD_CONFIGURATION%
echo [Info] Workspace: %CD%
echo.

REM ===== READ ENGINE PATH (Project-level config priority) =====
echo [1] Reading engine path...

set "UNREAL_PATH="
set "CONFIG_PROJECT_PATH="
set "CONFIG_UPROJECT_FILE="

REM Priority 1: Project-level config (.unrealcodeimitator.json in current directory)
if exist "%PROJECT_CONFIG_FILE%" (
    echo [Info] Found project config: %PROJECT_CONFIG_FILE%
    
    REM Validate config using PowerShell
    for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$result = & '%CONFIG_MANAGER%' -Action 'validate' -ConfigPath '%PROJECT_CONFIG_FILE%' | ConvertFrom-Json; if ($result.Valid) { Write-Output $result.EnginePath } else { Write-Output 'INVALID' }"`) do (
        set "VALIDATE_RESULT=%%A"
    )
    
    if "!VALIDATE_RESULT!"=="INVALID" (
        echo [Warning] Project config is invalid, will re-detect...
        goto :AUTO_DETECT
    )
    
    if not "!VALIDATE_RESULT!"=="" (
        set "UNREAL_PATH=!VALIDATE_RESULT!"
        echo [OK] Engine path from project config: !UNREAL_PATH!
        
        REM Also read project path and uproject file
        for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%PROJECT_CONFIG_FILE%' -Raw | ConvertFrom-Json; Write-Output $json.projectPath"`) do (
            set "CONFIG_PROJECT_PATH=%%A"
        )
        for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%PROJECT_CONFIG_FILE%' -Raw | ConvertFrom-Json; Write-Output $json.uprojectFile"`) do (
            set "CONFIG_UPROJECT_FILE=%%A"
        )
        
        goto :ENGINE_PATH_READY
    )
)

:AUTO_DETECT
REM Priority 2: Auto-detect engine path
echo [Info] Project config not found or invalid, starting auto-detection...

if not exist "%DETECT_ENGINE%" (
    echo [Warning] Auto-detect script not found: %DETECT_ENGINE%
    goto :FALLBACK_GLOBAL_CONFIG
)

call "%DETECT_ENGINE%" "%CD%"
if %ERRORLEVEL% neq 0 (
    echo [Warning] Auto-detection failed, falling back to global config...
    goto :FALLBACK_GLOBAL_CONFIG
)

REM Re-read the newly created project config
if exist "%PROJECT_CONFIG_FILE%" (
    for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%PROJECT_CONFIG_FILE%' -Raw | ConvertFrom-Json; Write-Output $json.enginePath"`) do (
        set "UNREAL_PATH=%%A"
    )
    for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%PROJECT_CONFIG_FILE%' -Raw | ConvertFrom-Json; Write-Output $json.projectPath"`) do (
        set "CONFIG_PROJECT_PATH=%%A"
    )
    for /f "usebackq delims=" %%A in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$json = Get-Content '%PROJECT_CONFIG_FILE%' -Raw | ConvertFrom-Json; Write-Output $json.uprojectFile"`) do (
        set "CONFIG_UPROJECT_FILE=%%A"
    )
    
    if not "!UNREAL_PATH!"=="" (
        echo [OK] Engine path from auto-detection: !UNREAL_PATH!
        goto :ENGINE_PATH_READY
    )
)

:FALLBACK_GLOBAL_CONFIG
REM Auto-detection failed, show error
echo [Error] Auto-detection failed and no project config found.
echo [Hint] Please ensure you are in a valid Unreal project/plugin directory.
echo [Hint] Or manually run: %DETECT_ENGINE%
exit /b 1

:ENGINE_PATH_READY
echo.
echo [Info] Using Unreal Engine path: !UNREAL_PATH!

REM ===== VALIDATE UNREAL PATH =====
if not exist "!UNREAL_PATH!" (
    echo [Error] Unreal Engine path does not exist: !UNREAL_PATH!
    echo [Hint] Please run detect_engine.bat to re-detect, or check your config
    exit /b 1
)

echo [OK] Unreal Engine path validation passed

REM ===== DETECT UNREAL VERSION =====
set "UE_VERSION_FILE=!UNREAL_PATH!\Engine\Build\Build.version"
if exist "!UE_VERSION_FILE!" (
    for /f "tokens=2 delims=:" %%A in ('findstr /R "\"MajorVersion\"" "!UE_VERSION_FILE!"') do (
        set "UE_MAJOR=%%A"
    )
    for /f "tokens=2 delims=:" %%A in ('findstr /R "\"MinorVersion\"" "!UE_VERSION_FILE!"') do (
        set "UE_MINOR=%%A"
    )
    set "UE_MAJOR=!UE_MAJOR:,=!"
    set "UE_MINOR=!UE_MINOR:,=!"
    set "UE_MAJOR=!UE_MAJOR: =!"
    set "UE_MINOR=!UE_MINOR: =!"
    echo [Info] Detected Unreal version: !UE_MAJOR!.!UE_MINOR!
) else (
    echo [Warning] Could not detect Unreal version, will continue build
)
echo.

REM ===== SET PROJECT PATH =====
set "PROJECT_PATH="
set "UPROJECT_PATH="

REM Use project path from config if available
if not "!CONFIG_PROJECT_PATH!"=="" (
    set "PROJECT_PATH=!CONFIG_PROJECT_PATH!"
    if not "!CONFIG_UPROJECT_FILE!"=="" (
        set "UPROJECT_PATH=!PROJECT_PATH!\!CONFIG_UPROJECT_FILE!"
    )
)

REM If not from config, try to find .uproject
if not defined UPROJECT_PATH (
    REM 1) Try current working directory
    pushd "%CD%"
    for %%F in (*.uproject) do (
        if not defined UPROJECT_PATH (
            set "UPROJECT_PATH=%CD%\%%F"
            set "PROJECT_PATH=%CD%"
        )
    )
    popd
)

REM 2) Try parent directory (common when workspace is a plugin folder)
if not defined UPROJECT_PATH (
    pushd "%CD%\.."
    for %%F in (*.uproject) do (
        if not defined UPROJECT_PATH (
            set "UPROJECT_PATH=%CD%\%%F"
            set "PROJECT_PATH=%CD%"
        )
    )
    popd
)

REM 3) Try grandparent directory (for deeper plugin structures)
if not defined UPROJECT_PATH (
    pushd "%CD%\..\.."
    for %%F in (*.uproject) do (
        if not defined UPROJECT_PATH (
            set "UPROJECT_PATH=%CD%\%%F"
            set "PROJECT_PATH=%CD%"
        )
    )
    popd
)

if not defined UPROJECT_PATH (
    echo [Error] Project file not found
    echo [Hint] Please run this script from your Unreal project or plugin folder
    exit /b 1
)

if not exist "!UPROJECT_PATH!" (
    echo [Error] Project file not found: !UPROJECT_PATH!
    exit /b 1
)

for %%F in ("!UPROJECT_PATH!") do set "PROJECT_NAME=%%~nF"
set "TARGET_NAME=!PROJECT_NAME!Editor"

echo [2] Project path: !PROJECT_PATH!
echo [2] Project file: !UPROJECT_PATH!
echo [2] Target    : !TARGET_NAME!
echo.

REM ===== VALIDATE BUILD TOOL =====
set "UBT_DLL=!UNREAL_PATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll"
if not exist "!UBT_DLL!" (
    echo [Error] UnrealBuildTool not found: !UBT_DLL!
    echo [Hint] Please make sure Unreal Engine is installed correctly
    exit /b 1
)

echo [3] Build tool validation passed

REM ===== DETECT VISUAL STUDIO PATH =====
echo [4] Detecting Visual Studio...

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VS_PATH="

if exist "!VSWHERE!" (
    for /f "delims=" %%A in ('"%VSWHERE%" -latest -property installationPath 2^>nul') do (
        set "VS_PATH=%%A"
    )
)

if defined VS_PATH (
    echo [OK] Detected Visual Studio path: !VS_PATH!
    
    REM Verify MSBuild
    set "MSBUILD_PATH=!VS_PATH!\MSBuild\Current\Bin\MSBuild.exe"
    if exist "!MSBUILD_PATH!" (
        echo [OK] MSBuild validation passed
    ) else (
        echo [Warning] MSBuild not found, will continue build
    )
) else (
    echo [Warning] Could not automatically detect Visual Studio path
    echo [Hint] If build fails, please make sure Visual Studio is installed correctly
)
echo.

REM ===== BUILD PARAMETERS =====
set "PLUGIN_NAME=AncientBuilding"
set "PLUGIN_PATH=!PROJECT_PATH!\Plugins\BuildingEditor\!PLUGIN_NAME!\!PLUGIN_NAME!.uplugin"
set "OUTPUT_PATH=!PROJECT_PATH!\Plugins\BuildingEditor\!PLUGIN_NAME!\Binaries"

echo [5] Start build...
echo [Info] Plugin: !PLUGIN_NAME!
echo [Info] Build Configuration: %BUILD_CONFIGURATION%
echo [Info] Unreal version: !UE_MAJOR!.!UE_MINOR!
if defined VS_PATH (
    echo [Info] Visual Studio: !VS_PATH!
)
echo [Info] Log file: %COMPILE_LOG%
echo [Info] Running UnrealBuildTool... this may take a while; console output will be quiet while compiling.
echo [Info] (Optional) In another PowerShell, run:  Get-Content '%COMPILE_LOG%' -Wait  to watch live progress.
echo.

REM ===== RUN BUILD =====
pushd "!PROJECT_PATH!"
dotnet "!UBT_DLL!" ^
    !TARGET_NAME! ^
    Win64 ^
    %BUILD_CONFIGURATION% ^
    -Project="!UPROJECT_PATH!" ^
    -WaitMutex ^
    -FromMsBuild ^
    -architecture=x64 ^
    > "%COMPILE_LOG%" 2>&1
set "COMPILE_RESULT=!ERRORLEVEL!"
popd

REM ===== ANALYZE BUILD RESULT =====
echo [6] Analyzing build result...

set "ERROR_COUNT=0"
set "WARNING_COUNT=0"
set "LIVE_CODING_ACTIVE=0"

REM Count real errors - use find command to avoid FINDSTR line length limit
REM Match patterns: ": error ", ": error:", "fatal error"
for /f %%A in ('type "%COMPILE_LOG%" 2^>nul ^| find /I /C ": error"') do set "ERROR_COUNT=%%A"

REM Count real warnings - match patterns like ": warning "
for /f %%A in ('type "%COMPILE_LOG%" 2^>nul ^| find /I /C ": warning"') do set "WARNING_COUNT=%%A"

rem Detect special case: Live Coding blocking builds
type "%COMPILE_LOG%" 2>nul | find /I "Unable to build while Live Coding is active" >nul 2>&1
if not errorlevel 1 set "LIVE_CODING_ACTIVE=1"

REM ===== GENERATE ERROR SUMMARY =====
echo.
echo [7] Generating error summary...

set "BUILD_RESULT_TEXT=Build result: Failed"
if !COMPILE_RESULT! equ 0 set "BUILD_RESULT_TEXT=Build result: Success"

> "%ERROR_LOG%" echo ==== Build summary [%TIMESTAMP%] ====
>>"%ERROR_LOG%" echo.
>>"%ERROR_LOG%" echo !BUILD_RESULT_TEXT!
>>"%ERROR_LOG%" echo Build Configuration: %BUILD_CONFIGURATION%
>>"%ERROR_LOG%" echo.
>>"%ERROR_LOG%" echo [Error and warning statistics]
>>"%ERROR_LOG%" echo Errors: !ERROR_COUNT!
>>"%ERROR_LOG%" echo Warnings: !WARNING_COUNT!
>>"%ERROR_LOG%" echo.

rem Special hint when Live Coding blocks the build (no explicit "error" lines)
if !LIVE_CODING_ACTIVE! equ 1 (
    >>"%ERROR_LOG%" echo [Hint]
    >>"%ERROR_LOG%" echo Build was blocked because Live Coding is active.
    >>"%ERROR_LOG%" echo Please close the editor/game, or press Ctrl+Alt+F11 to disable Live Coding, then run compile.bat again.
    >>"%ERROR_LOG%" echo.
)

>>"%ERROR_LOG%" echo [Full log]
>>"%ERROR_LOG%" echo See: %COMPILE_LOG%
>>"%ERROR_LOG%" echo.

if !ERROR_COUNT! gtr 0 (
    >>"%ERROR_LOG%" echo [Error details]
    >>"%ERROR_LOG%" echo The following lines are extracted from the build log ^(see full log for more details^):
    type "%COMPILE_LOG%" 2>nul | find /I ": error" >>"%ERROR_LOG%"
)

REM Copy to latest error log
copy /Y "%ERROR_LOG%" "%LATEST_ERROR_LOG%" > nul

REM ===== OUTPUT RESULT =====
echo.
echo ========================================
if !COMPILE_RESULT! equ 0 (
    echo  BUILD SUCCEEDED
) else (
    echo  BUILD FAILED
)
echo ========================================
echo.
echo Configuration: %BUILD_CONFIGURATION%
echo Build log   : %COMPILE_LOG%
echo Error report: %ERROR_LOG%
echo.
echo Errors  : !ERROR_COUNT!
echo Warnings: !WARNING_COUNT!
echo.

if !ERROR_COUNT! gtr 0 (
    echo ----------------------------------------
    echo Found !ERROR_COUNT! build errors
    echo ----------------------------------------
    echo.
    echo Please send the content of the following file to the LLM:
    echo File path: %ERROR_LOG%
    echo.
)

echo Build finished
echo.

REM Return build result
exit /b !COMPILE_RESULT!
