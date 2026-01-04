# detect_engine.ps1
# Engine path detection core logic
# Supports three scenarios: project plugin, engine plugin, engine source project

param(
    [string]$WorkspacePath = (Get-Location).Path,
    [int]$MaxDepth = 10
)

# Log prefix
$LogPrefix = "[DetectEngine]"

function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    # Output to stderr to avoid mixing with JSON result
    [Console]::Error.WriteLine("$LogPrefix [$Level] $Message")
}

# Find .uproject file by searching upward
function Find-UProjectFile {
    param([string]$StartPath, [int]$MaxDepth = 10)
    
    $currentPath = $StartPath
    $depth = 0
    
    while ($depth -lt $MaxDepth) {
        $uprojectFiles = Get-ChildItem -Path $currentPath -Filter "*.uproject" -File -ErrorAction SilentlyContinue
        if ($uprojectFiles) {
            return $uprojectFiles[0].FullName
        }
        
        $parentPath = Split-Path -Parent $currentPath
        if ([string]::IsNullOrEmpty($parentPath) -or $parentPath -eq $currentPath) {
            break
        }
        $currentPath = $parentPath
        $depth++
    }
    
    return $null
}

# Find Engine/Build/Build.version file by searching upward (engine root marker)
function Find-EngineRootByBuildVersion {
    param([string]$StartPath, [int]$MaxDepth = 10)
    
    $currentPath = $StartPath
    $depth = 0
    
    while ($depth -lt $MaxDepth) {
        $buildVersionPath = Join-Path $currentPath "Engine\Build\Build.version"
        if (Test-Path $buildVersionPath) {
            return $currentPath
        }
        
        $parentPath = Split-Path -Parent $currentPath
        if ([string]::IsNullOrEmpty($parentPath) -or $parentPath -eq $currentPath) {
            break
        }
        $currentPath = $parentPath
        $depth++
    }
    
    return $null
}

# Parse EngineAssociation from .uproject file
function Get-EngineAssociation {
    param([string]$UProjectPath)
    
    try {
        $content = Get-Content -Path $UProjectPath -Raw -Encoding UTF8
        $json = $content | ConvertFrom-Json
        return $json.EngineAssociation
    }
    catch {
        Write-Log "Failed to parse .uproject file: $_" -Level "Error"
        return $null
    }
}

# Get engine path from LauncherInstalled.dat (Epic Games Launcher installed engines)
function Get-EnginePathFromLauncher {
    param([string]$EngineAssociation)
    
    # Try multiple possible locations
    $possiblePaths = @(
        (Join-Path $env:ProgramData "Epic\UnrealEngineLauncher\LauncherInstalled.dat"),
        (Join-Path $env:LOCALAPPDATA "UnrealEngineLauncher\LauncherInstalled.dat"),
        (Join-Path $env:LOCALAPPDATA "EpicGamesLauncher\Saved\Config\Windows\LauncherInstalled.dat")
    )
    
    $launcherDat = $null
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $launcherDat = $path
            break
        }
    }
    
    if (-not $launcherDat) {
        Write-Log "LauncherInstalled.dat not found, searched: $($possiblePaths -join ', ')" -Level "Warning"
        return $null
    }
    
    Write-Log "Found LauncherInstalled.dat: $launcherDat"
    
    try {
        $content = Get-Content -Path $launcherDat -Raw -Encoding UTF8
        $json = $content | ConvertFrom-Json
        
        $appName = "UE_$EngineAssociation"
        foreach ($item in $json.InstallationList) {
            if ($item.AppName -eq $appName) {
                return $item.InstallLocation
            }
        }
    }
    catch {
        Write-Log "Failed to parse LauncherInstalled.dat: $_" -Level "Error"
    }
    
    return $null
}

# Get engine path from Windows registry (source-built or manually registered engines)
function Get-EnginePathFromRegistry {
    param([string]$EngineAssociation)
    
    $regPath = "HKCU:\SOFTWARE\Epic Games\Unreal Engine\Builds"
    
    if (-not (Test-Path $regPath)) {
        Write-Log "Registry path does not exist: $regPath" -Level "Warning"
        return $null
    }
    
    try {
        $regValue = Get-ItemProperty -Path $regPath -Name $EngineAssociation -ErrorAction SilentlyContinue
        if ($regValue) {
            return $regValue.$EngineAssociation
        }
    }
    catch {
        Write-Log "Failed to read registry: $_" -Level "Warning"
    }
    
    return $null
}

# Get engine path from EngineAssociation
function Get-EnginePathFromAssociation {
    param([string]$EngineAssociation)
    
    if ([string]::IsNullOrEmpty($EngineAssociation)) {
        return $null
    }
    
    Write-Log "EngineAssociation: $EngineAssociation"
    
    # Try Launcher installation list first
    $enginePath = Get-EnginePathFromLauncher -EngineAssociation $EngineAssociation
    if ($enginePath -and (Test-Path $enginePath)) {
        Write-Log "Found engine path from Launcher: $enginePath" -Level "Success"
        return $enginePath
    }
    
    # Try registry (GUID format for source-built engines)
    $enginePath = Get-EnginePathFromRegistry -EngineAssociation $EngineAssociation
    if ($enginePath -and (Test-Path $enginePath)) {
        Write-Log "Found engine path from registry: $enginePath" -Level "Success"
        return $enginePath
    }
    
    return $null
}

# Main detection function
function Detect-EnginePath {
    param([string]$WorkspacePath, [int]$MaxDepth = 10)
    
    $result = @{
        EnginePath = $null
        ProjectPath = $null
        UProjectFile = $null
        SceneType = $null
        Success = $false
    }
    
    Write-Log "Starting engine path detection..."
    Write-Log "Workspace: $WorkspacePath"
    
    # Scenario 1: Find .uproject file (project plugin scenario)
    Write-Log "Searching for .uproject file..."
    $uprojectPath = Find-UProjectFile -StartPath $WorkspacePath -MaxDepth $MaxDepth
    
    if ($uprojectPath) {
        Write-Log "Found .uproject: $uprojectPath" -Level "Success"
        
        $result.UProjectFile = Split-Path -Leaf $uprojectPath
        $result.ProjectPath = Split-Path -Parent $uprojectPath
        
        $engineAssociation = Get-EngineAssociation -UProjectPath $uprojectPath
        $enginePath = Get-EnginePathFromAssociation -EngineAssociation $engineAssociation
        
        if ($enginePath) {
            $result.EnginePath = $enginePath
            $result.SceneType = "project_plugin"
            $result.Success = $true
            Write-Log "Detection complete - Scenario: project_plugin" -Level "Success"
            return $result
        }
        else {
            Write-Log "Could not get engine path from EngineAssociation, trying other methods..." -Level "Warning"
        }
    }
    
    # Scenario 2/3: Find Engine/Build/Build.version by searching upward (engine plugin or source scenario)
    Write-Log "Searching for Engine/Build/Build.version..."
    $engineRoot = Find-EngineRootByBuildVersion -StartPath $WorkspacePath -MaxDepth $MaxDepth
    
    if ($engineRoot) {
        Write-Log "Found engine root: $engineRoot" -Level "Success"
        
        $result.EnginePath = $engineRoot
        $result.SceneType = "engine_plugin_or_source"
        $result.Success = $true
        
        # Keep project info if found earlier
        if ($uprojectPath) {
            $result.ProjectPath = Split-Path -Parent $uprojectPath
            $result.UProjectFile = Split-Path -Leaf $uprojectPath
        }
        
        Write-Log "Detection complete - Scenario: engine_plugin_or_source" -Level "Success"
        return $result
    }
    
    Write-Log "Failed to detect engine path" -Level "Error"
    return $result
}

# Execute detection
$detectResult = Detect-EnginePath -WorkspacePath $WorkspacePath -MaxDepth $MaxDepth

# Output result as JSON (for BAT script parsing)
$detectResult | ConvertTo-Json -Compress
