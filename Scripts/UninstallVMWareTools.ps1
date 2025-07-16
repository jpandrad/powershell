########################################
### VMware Tools Uninstaller Script  ###
########################################
# Description : This script attempts to uninstall VMware Tools using multiple methods
param(
    [switch]$Force,
    [switch]$Quiet,
    [switch]$WhatIf
)

# Requires Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires Administrator privileges. Please run as Administrator."
    exit 1
}

Write-Host "VMware Tools Uninstaller Script" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Function to log messages
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Function to check if VMware Tools is installed
function Test-VMwareToolsInstalled {
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    ) 
    foreach ($path in $registryPaths) {
        $programs = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        $vmwareTools = $programs | Where-Object { $_.DisplayName -like "*VMware Tools*" }
        if ($vmwareTools) {
            return $vmwareTools
        }
    }
    return $null
}

# Function to stop VMware services
function Stop-VMwareServices {
    Write-Log "Stopping VMware services..."
    
    $vmwareServices = @(
        "VMTools",
        "VmToolsd", 
        "VMwareToolsService",
        "vm3dservice",
        "VMUSBArbService"
    )
    
    foreach ($service in $vmwareServices) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -eq "Running") {
                if (!$WhatIf) {
                    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                    Write-Log "Stopped service: $service" -Level "SUCCESS"
                } else {
                    Write-Log "Would stop service: $service" -Level "INFO"
                }
            }
        } catch {
            Write-Log "Could not stop service $service`: $($_.Exception.Message)" -Level "WARN"
        }
    }
}

# Function to uninstall using Windows Installer
function Uninstall-UsingMSI {
    param($VMwareToolsInfo)
    
    Write-Log "Attempting MSI uninstall..."
    
    $uninstallString = $VMwareToolsInfo.UninstallString
    if ($uninstallString -match "msiexec") {
        # Extract product code from uninstall string
        $productCode = $null
        if ($uninstallString -match "\{[A-F0-9\-]+\}") {
            $productCode = $matches[0]
        }
        
        if ($productCode) {
            $arguments = "/x $productCode /qn"
            if ($Force) {
                $arguments += " /forcerestart"
            }
            
            if (!$WhatIf) {
                Write-Log "Executing: msiexec $arguments"
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
                
                if ($process.ExitCode -eq 0) {
                    Write-Log "MSI uninstall completed successfully" -Level "SUCCESS"
                    return $true
                } else {
                    Write-Log "MSI uninstall failed with exit code: $($process.ExitCode)" -Level "ERROR"
                    return $false
                }
            } else {
                Write-Log "Would execute: msiexec $arguments"
                return $true
            }
        }
    }
    return $false
}

# Function to uninstall using setup.exe
function Uninstall-UsingSetup {
    Write-Log "Attempting setup.exe uninstall..."
    
    $setupPaths = @(
        "${env:ProgramFiles}\VMware\VMware Tools\setup64.exe",
        "${env:ProgramFiles(x86)}\VMware\VMware Tools\setup.exe",
        "${env:ProgramFiles}\VMware\VMware Tools\setup.exe"
    )
    
    foreach ($setupPath in $setupPaths) {
        if (Test-Path $setupPath) {
            $arguments = "/S /v/qn"
            if ($Force) {
                $arguments += " /v/forcerestart"
            }
            
            if (!$WhatIf) {
                Write-Log "Executing: $setupPath $arguments"
                $process = Start-Process -FilePath $setupPath -ArgumentList $arguments -Wait -PassThru
                
                if ($process.ExitCode -eq 0) {
                    Write-Log "Setup.exe uninstall completed successfully" -Level "SUCCESS"
                    return $true
                } else {
                    Write-Log "Setup.exe uninstall failed with exit code: $($process.ExitCode)" -Level "ERROR"
                }
            } else {
                Write-Log "Would execute: $setupPath $arguments"
                return $true
            }
        }
    }
    return $false
}

# Function to clean up remaining files and registry entries
function Remove-VMwareRemnants {
    Write-Log "Cleaning up remaining VMware Tools files and registry entries..."
    
    # File paths to remove
    $pathsToRemove = @(
        "${env:ProgramFiles}\VMware",
        "${env:ProgramFiles(x86)}\VMware",
        "${env:ProgramData}\VMware"
    )
    
    foreach ($path in $pathsToRemove) {
        if (Test-Path $path) {
            try {
                if (!$WhatIf) {
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Log "Removed directory: $path" -Level "SUCCESS"
                } else {
                    Write-Log "Would remove directory: $path"
                }
            } catch {
                Write-Log "Could not remove $path`: $($_.Exception.Message)" -Level "WARN"
            }
        }
    }
    
    # Registry keys to remove
    $registryKeys = @(
        "HKLM:\SOFTWARE\VMware, Inc.",
        "HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.",
        "HKLM:\SYSTEM\CurrentControlSet\Services\VMTools",
        "HKLM:\SYSTEM\CurrentControlSet\Services\VmToolsd",
        "HKLM:\SYSTEM\CurrentControlSet\Services\vm3dservice"
    )
    
    foreach ($key in $registryKeys) {
        if (Test-Path $key) {
            try {
                if (!$WhatIf) {
                    Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Log "Removed registry key: $key" -Level "SUCCESS"
                } else {
                    Write-Log "Would remove registry key: $key"
                }
            } catch {
                Write-Log "Could not remove registry key $key`: $($_.Exception.Message)" -Level "WARN"
            }
        }
    }
}

# Main execution
try {
    # Check if VMware Tools is installed
    $vmwareTools = Test-VMwareToolsInstalled
    if (-not $vmwareTools) {
        Write-Log "VMware Tools does not appear to be installed" -Level "WARN"
        exit 0
    }
    
    Write-Log "Found VMware Tools: $($vmwareTools.DisplayName) $($vmwareTools.DisplayVersion)"
    
    if ($WhatIf) {
        Write-Log "Running in WhatIf mode - no changes will be made" -Level "INFO"
    }
    
    # Stop VMware services
    Stop-VMwareServices
    
    # Attempt uninstall using MSI first
    $msiSuccess = Uninstall-UsingMSI -VMwareToolsInfo $vmwareTools
    
    # If MSI failed, try setup.exe
    if (-not $msiSuccess) {
        $setupSuccess = Uninstall-UsingSetup
        if (-not $setupSuccess) {
            Write-Log "Both MSI and setup.exe uninstall methods failed" -Level "ERROR"
        }
    }
    
    # Clean up remaining files and registry entries
    if ($Force -or $msiSuccess -or $setupSuccess) {
        Remove-VMwareRemnants
    }
    
    # Final verification
    Start-Sleep -Seconds 2
    $remainingTools = Test-VMwareToolsInstalled
    if (-not $remainingTools) {
        Write-Log "VMware Tools has been successfully uninstalled" -Level "SUCCESS"
    } else {
        Write-Log "VMware Tools may still be partially installed. Manual cleanup may be required." -Level "WARN"
    }
    
    if (-not $WhatIf) {
        Write-Log "Uninstall process completed. A system restart is recommended." -Level "INFO"
    }
    
} catch {
    Write-Log "An error occurred during uninstallation: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}