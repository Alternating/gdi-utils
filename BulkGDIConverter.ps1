param (
    [string]$SourcePath,
    [string]$DestPath,
    [string]$GdiUtilsPath
)

# Basic path checks
if (-not (Test-Path $SourcePath)) {
    Write-Host "Error: Source path doesn't exist"
    exit
}

if (-not (Test-Path $DestPath)) {
    Write-Host "Creating destination directory..."
    New-Item -Path $DestPath -ItemType Directory -Force
}

if (-not (Test-Path $GdiUtilsPath)) {
    Write-Host "Error: GDI-utils path doesn't exist"
    exit
}

# Create log file
$logPath = Join-Path $DestPath "conversion_log.txt"
"GDI Conversion started at $(Get-Date)" | Out-File $logPath

# Get source folders
$folders = Get-ChildItem $SourcePath -Directory
Write-Host "Found $($folders.Count) folders to process"
"Found $($folders.Count) folders to process" | Out-File $logPath -Append

$processed = 0
$skipped = 0

# Process each folder
foreach ($folder in $folders) {
    $name = $folder.Name
    Write-Host "Checking $name"
    
    $targetDir = Join-Path $DestPath $name
    
    # Skip if exists
    if (Test-Path $targetDir) {
        Write-Host "Skipping $name - already exists"
        "Skipped: $name - already exists" | Out-File $logPath -Append
        $skipped++
        continue
    }
    
    # Find GDI file
    $gdiFile = Get-ChildItem $folder.FullName -Filter "*.gdi" -File | Select-Object -First 1
    
    if (-not $gdiFile) {
        Write-Host "No GDI file in $name - skipping"
        "Skipped: $name - no GDI file" | Out-File $logPath -Append
        $skipped++
        continue
    }
    
    # Create temp dir
    $tempDir = Join-Path $DestPath "temp_process"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item $tempDir -ItemType Directory -Force
    
    # Run conversion
    Write-Host "Processing $name..."
    "Processing: $name" | Out-File $logPath -Append
    
    $gdiFilePath = $gdiFile.FullName
    Write-Host "Running: node $GdiUtilsPath $gdiFilePath 0 $tempDir"
    
    & node $GdiUtilsPath $gdiFilePath 0 $tempDir
    
    # Check result
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error processing $name"
        "Error: $name - process failed" | Out-File $logPath -Append
        continue
    }
    
    # Create destination folder
    New-Item $targetDir -ItemType Directory -Force
    
    # Move files
    Get-ChildItem $tempDir | ForEach-Object {
        Move-Item $_.FullName $targetDir
    }
    
    # Cleanup
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    
    Write-Host "Completed $name"
    "Completed: $name" | Out-File $logPath -Append
    $processed++
}

# Run optimizer if available
$optimizerPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "gdiopt-v2.exe"
if (Test-Path $optimizerPath) {
    Write-Host "Running optimizer..."
    "Running optimizer" | Out-File $logPath -Append
    & $optimizerPath "$DestPath/"
}

# Summary
"Conversion completed at $(Get-Date)" | Out-File $logPath -Append
"Processed: $processed" | Out-File $logPath -Append
"Skipped: $skipped" | Out-File $logPath -Append

Write-Host "Conversion completed!"
Write-Host "Processed: $processed"
Write-Host "Skipped: $skipped"

# Sound notification based on success or failure
Write-Host "Playing completion sound..."
try {
    Add-Type -AssemblyName System.Windows.Forms
    
    # Determine which sound to play based on errors
    if ($processed -gt 0 -and $LASTEXITCODE -eq 0) {
        # Success - play chimes
        $soundPath = "C:\Windows\Media\chimes.wav"
        Write-Host "Process successful - playing success sound"
    } else {
        # Error or nothing processed - play chord
        $soundPath = "C:\Windows\Media\chord.wav"
        Write-Host "Process had errors or nothing processed - playing error sound"
    }
    
    # Play the appropriate sound
    if (Test-Path $soundPath) {
        (New-Object Media.SoundPlayer $soundPath).PlaySync()
    } else {
        # Fallback to system sounds if file not found
        if ($processed -gt 0 -and $LASTEXITCODE -eq 0) {
            [System.Media.SystemSounds]::Asterisk.Play()
        } else {
            [System.Media.SystemSounds]::Exclamation.Play()
        }
    }
} catch {
    Write-Host "Could not play notification sound: $_"
}