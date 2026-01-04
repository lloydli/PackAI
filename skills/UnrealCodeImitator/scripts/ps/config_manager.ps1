# config_manager.ps1
# Configuration file read/write management
# Manages project-level .unrealcodeimitator.json config file

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("read", "write", "validate")]
    [string]$Action,
    
    [string]$ConfigPath,
    [string]$EnginePath,
    [string]$ProjectPath,
    [string]$UProjectFile,
    [string]$SceneType
)

$LogPrefix = "[ConfigManager]"

function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    $color = switch ($Level) {
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Success" { "Green" }
        default { "White" }
    }
    Write-Host "$LogPrefix [$Level] $Message" -ForegroundColor $color
}

# Read config file
function Read-Config {
    param([string]$ConfigPath)
    
    if (-not (Test-Path $ConfigPath)) {
        return @{
            Success = $false
            Error = "Config file not found"
            Data = $null
        }
    }
    
    try {
        $content = Get-Content -Path $ConfigPath -Raw -Encoding UTF8
        $config = $content | ConvertFrom-Json
        
        return @{
            Success = $true
            Error = $null
            Data = $config
        }
    }
    catch {
        return @{
            Success = $false
            Error = "Failed to parse config file: $_"
            Data = $null
        }
    }
}

# Write config file (complete config with all settings)
function Write-Config {
    param(
        [string]$ConfigPath,
        [string]$EnginePath,
        [string]$ProjectPath,
        [string]$UProjectFile,
        [string]$SceneType
    )
    
    # Ensure parent directory exists
    $configDir = Split-Path -Parent $ConfigPath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    $config = [ordered]@{
        version = "1.0"
        detectedAt = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        
        # Engine and project info (auto-detected)
        enginePath = $EnginePath
        projectPath = $ProjectPath
        uprojectFile = $UProjectFile
        sceneType = $SceneType
        
        # Search settings
        searchDepth = 5
        focusModules = @("Core", "CoreUObject", "Engine", "UnrealEd", "Slate", "SlateCore", "Plugins")
        includePrivate = $true
        
        # Code search patterns
        codeSearchPatterns = [ordered]@{
            classDef = "class\s+\w+"
            functionDef = "(?:void|bool|int32|FString|UObject\*|AActor\*)\s+\w+\s*\("
            macros = "#define\s+\w+"
            templates = "template\s*<"
            interfaces = "class\s+\w+\s*:\s*public\s+I\w+"
        }
        
        # Exclude patterns
        excludePatterns = @(
            "*.generated.cpp",
            "*.generated.h",
            "**/Tests/**",
            "**/ThirdParty/**",
            "**/Intermediate/**"
        )
        
        # Output format settings
        outputFormat = [ordered]@{
            includeComments = $true
            includeSourceLocation = $true
            codeStyle = "Unreal"
            generateFramework = $true
        }
        
        # UE5 knowledge base settings
        ue5KnowledgeBase = [ordered]@{
            enabled = $true
            searchPriority = "first"
            categories = @("API", "Samples", "Tutorials", "Best Practices", "Migration Guides", "Feature Overview")
        }
        
        # Search strategy
        searchStrategy = [ordered]@{
            tier1_ue5kb = [ordered]@{
                enabled = $true
                priority = 1
                description = "UE5 Official Knowledge Base"
                timeout = 5000
            }
            tier2_network = [ordered]@{
                enabled = $true
                priority = 2
                description = "Network Search"
                timeout = 10000
            }
            tier3_source = [ordered]@{
                enabled = $true
                priority = 3
                description = "Unreal Source Analysis"
                timeout = 15000
            }
        }
        
        # Compilation settings
        compilation = [ordered]@{
            defaultMode = "Development"
            availableModes = @("DebugGame", "Development")
            modeAliases = [ordered]@{
                "compile_G" = "DebugGame"
                "compile_V" = "Development"
            }
            description = [ordered]@{
                DebugGame = "DebugGame Editor - Debug game code mode"
                Development = "Development Editor - Default compile mode"
            }
            notes = "Compiling Editor target, config parameter will be combined with Editor"
        }
    }
    
    try {
        $json = $config | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $ConfigPath -Encoding UTF8 -Force
        
        Write-Log "Config file saved: $ConfigPath" -Level "Success"
        
        return @{
            Success = $true
            Error = $null
            Path = $ConfigPath
        }
    }
    catch {
        Write-Log "Failed to write config file: $_" -Level "Error"
        return @{
            Success = $false
            Error = "Failed to write config file: $_"
            Path = $null
        }
    }
}

# Validate config file engine path
function Validate-Config {
    param([string]$ConfigPath)
    
    $readResult = Read-Config -ConfigPath $ConfigPath
    
    if (-not $readResult.Success) {
        return @{
            Valid = $false
            Error = $readResult.Error
            EnginePath = $null
        }
    }
    
    $enginePath = $readResult.Data.enginePath
    
    if ([string]::IsNullOrEmpty($enginePath)) {
        return @{
            Valid = $false
            Error = "enginePath is empty in config"
            EnginePath = $null
        }
    }
    
    # Validate engine path exists
    if (-not (Test-Path $enginePath)) {
        return @{
            Valid = $false
            Error = "Engine path does not exist: $enginePath"
            EnginePath = $null
        }
    }
    
    # Validate it's a valid engine directory (check Build.version)
    $buildVersionPath = Join-Path $enginePath "Engine\Build\Build.version"
    if (-not (Test-Path $buildVersionPath)) {
        return @{
            Valid = $false
            Error = "Invalid engine directory (missing Engine/Build/Build.version): $enginePath"
            EnginePath = $null
        }
    }
    
    Write-Log "Config validation passed: $enginePath" -Level "Success"
    
    return @{
        Valid = $true
        Error = $null
        EnginePath = $enginePath
        ProjectPath = $readResult.Data.projectPath
        UProjectFile = $readResult.Data.uprojectFile
        SceneType = $readResult.Data.sceneType
    }
}

# Execute action
$result = switch ($Action) {
    "read" {
        Read-Config -ConfigPath $ConfigPath
    }
    "write" {
        Write-Config -ConfigPath $ConfigPath -EnginePath $EnginePath -ProjectPath $ProjectPath -UProjectFile $UProjectFile -SceneType $SceneType
    }
    "validate" {
        Validate-Config -ConfigPath $ConfigPath
    }
}

# Output result as JSON
$result | ConvertTo-Json -Compress
