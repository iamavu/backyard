#androinit - script to install android emulator automagically

# Status message functions
function Write-StatusMessage {
    param (
        [string]$Message,
        [string]$Status = "INFO"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $statusColor = switch ($Status) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "ERROR"   { "Red" }
        "WARNING" { "Yellow" }
        default   { "White" }
    }
    
    Write-Host "[$timestamp] " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$Status] " -NoNewline -ForegroundColor $statusColor
    Write-Host $Message
}

function Update-EnvVariable {
    param (
        [string]$Name,
        [string]$Value,
        [System.EnvironmentVariableTarget]$Target
    )
    
    try {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
        Set-Item -Path "env:$Name" -Value $Value
        Write-StatusMessage "Updated $Name environment variable for $Target" "SUCCESS"
    }
    catch {
        Write-StatusMessage "Failed to update $Name environment variable: $_" "ERROR"
    }
}

function Update-PathVariable {
    param (
        [string[]]$NewPaths,
        [System.EnvironmentVariableTarget]$Target
    )
    
    try {
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", $Target)
        $pathsToAdd = @()
        
        foreach ($path in $NewPaths) {
            if ($currentPath -notlike "*$path*") {
                $pathsToAdd += $path
            }
        }
        
        if ($pathsToAdd.Count -gt 0) {
            $newPath = $currentPath + [System.IO.Path]::PathSeparator + ($pathsToAdd -join [System.IO.Path]::PathSeparator)
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, $Target)
            $env:Path = $newPath
            Write-StatusMessage "Updated PATH variable for $Target" "SUCCESS"
        }
    }
    catch {
        Write-StatusMessage "Failed to update PATH variable: $_" "ERROR"
    }
}

# Check if Java is installed
Write-StatusMessage "Checking Java installation..." "INFO"
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-StatusMessage "Java is not installed or not available in your PATH." "ERROR"
    Write-StatusMessage "Please install Java and add it to your PATH to run this script" "ERROR"
    Exit 1
}
Write-StatusMessage "Java installation found" "SUCCESS"

# Get the latest download URL
Write-StatusMessage "Fetching latest Android Studio download URL..." "INFO"
$studioURL = "https://developer.android.com/studio"
$webClient = New-Object System.Net.WebClient
$content = $webClient.DownloadString($studioURL)
$downloadURL = $content | Select-String -Pattern "https://dl.google.com/android/repository/commandlinetools-win-[0-9]+_latest.zip" | Select-Object -First 1 | ForEach-Object { $_.Matches.Value }

# Set up directories
$toolsDir = "$env:USERPROFILE\Android\Sdk"
$cmdlineToolsDir = "$toolsDir\cmdline-tools"
$latestDir = "$cmdlineToolsDir\latest"
$androidSdkRoot = $toolsDir
$platformToolsDir = "$androidSdkRoot\platform-tools"
$cmdlineBinDir = "$LatestDir\bin"

# Create directories if necessary
Write-StatusMessage "Creating necessary directories..." "INFO"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
New-Item -ItemType Directory -Force -Path $LatestDir | Out-Null
Write-StatusMessage "Directories created successfully" "SUCCESS"

# Download the file
$zipFile = "$toolsDir\commandlinetools.zip"
Write-StatusMessage "Downloading Android SDK tools from: $downloadUrl" "INFO"
Start-BitsTransfer -Source $downloadUrl -Destination $zipFile -DisplayName "Android SDK Tools" -Description "Downloading Android SDK Command Line Tools"

# Extract the zip file
Write-StatusMessage "Extracting SDK tools to $toolsDir" "INFO"
Expand-Archive -Path $zipFile -DestinationPath $toolsDir -Force
Remove-Item $zipFile
Write-StatusMessage "Extraction completed" "SUCCESS"

# Move files
Get-ChildItem -Path "$toolsDir\cmdline-tools" -Exclude "latest" | Move-Item -Destination $latestDir -Force

# Update environment variables for user
Write-StatusMessage "Updating environment variables..." "INFO"
$target = [System.EnvironmentVariableTarget]::User
Update-EnvVariable -Name "ANDROID_SDK_ROOT" -Value $AndroidSdkRoot -Target $target
Update-EnvVariable -Name "ANDROID_HOME" -Value $AndroidSdkRoot -Target $target
$pathsToAdd = @(
    "$AndroidSdkRoot\cmdline-tools\latest\bin",
    "$AndroidSdkRoot\emulator",
    "$AndroidSdkRoot\platform-tools"
)
Update-PathVariable -NewPaths $pathsToAdd -Target $target

# Download platform-tools using sdkmanager
Write-StatusMessage "Downloading platform-tools using sdkmanager..." "INFO"
$sdkManagerProcess = Start-Process -FilePath "$cmdlineBinDir\sdkmanager.bat" -ArgumentList "platform-tools" -NoNewWindow -Wait -PassThru

# List available system images
Write-StatusMessage "Listing available system images..." "INFO"
Start-Process -FilePath "$CmdlineBinDir\sdkmanager.bat" -ArgumentList "--list" -NoNewWindow -Wait | Select-String "system-images"

Write-Host "`nPlease enter the system image you want to download" -ForegroundColor Yellow
Write-Host "Example: " -NoNewline
Write-Host "system-images;android-33;google_apis;x86_64" -ForegroundColor Cyan
$image = Read-Host "System image"

# Download system image
Write-StatusMessage "Downloading system image: $image" "INFO"
$imageProcess = Start-Process -FilePath "$CmdlineBinDir\sdkmanager.bat" -ArgumentList "`"$image`"" -NoNewWindow -Wait -PassThru

# Download platform files
$androidVersion = $image | Select-String -Pattern "android-[0-9]+" | Select-Object -First 1 | ForEach-Object { $_.Matches.Value }
Write-StatusMessage "Detected Android version: $androidVersion. Downloading platform files..." "INFO"
$platformProcess = Start-Process -FilePath "$CmdlineBinDir\sdkmanager.bat" -ArgumentList "`"platforms;$androidVersion`"" -NoNewWindow -Wait -PassThru

# Create AVD
Write-Host "`nPlease name your Android Virtual Device (AVD)" -ForegroundColor Yellow
Write-Host "Press Enter to use 'default'" -ForegroundColor DarkGray
$avdName = Read-Host "AVD Name"
if (-not $avdName) {
    $avdName = "default"
}

Write-StatusMessage "Creating an AVD with the name: $avdName" "INFO"
$avdProcess = Start-Process -FilePath "$CmdlineBinDir\avdmanager.bat" -ArgumentList "create avd -n `"$avdName`" -k `"$image`" --device `"pixel`"" -NoNewWindow -Wait -PassThru

# Finale
Write-StatusMessage "Setup completed successfully!" "SUCCESS"
Write-StatusMessage "Please restart your terminal to ensure all environment variables are properly loaded" "WARNING"
Write-Host "`nTo launch your emulator, use the following command:" -ForegroundColor Yellow
Write-Host "emulator '@$avdName' OR emulator -avd $avdName" -ForegroundColor Cyan
