param(
    [Parameter(Mandatory=$false)]
    [string]$ExePath,
    
    [Parameter(Mandatory=$false)]
    [string]$Arguments = "",
    
    [Parameter(Mandatory=$false)]
    [int]$TimeoutMinutes = 0
)

function Execute-AndWaitForClose {
    param(
        [string]$Path,
        [string]$Args,
        [int]$Timeout
    )
    
    try {
        # Check if the executable exists
        if (-not (Test-Path $Path)) {
            Write-Error "Executable not found: $Path"
            return $false
        }
        
        Write-Host "Starting process: $Path $Args" -ForegroundColor Green
        
        # Start the process and capture the process object
        if ($Args) {
            $process = Start-Process -FilePath $Path -ArgumentList $Args -PassThru
        } else {
            $process = Start-Process -FilePath $Path -PassThru
        }
        
        if ($process) {
            $processId = $process.Id
            Write-Host "Process started with PID: $processId" -ForegroundColor Yellow
            
            # Set up timeout if specified
            $startTime = Get-Date
            $timeoutReached = $false
            
            # Wait for the process to exit
            Write-Host "Waiting for process to complete..." -ForegroundColor Cyan
            
            while (-not $process.HasExited) {
                Start-Sleep -Seconds 1
                
                # Check timeout if specified
                if ($Timeout -gt 0) {
                    $elapsedMinutes = ((Get-Date) - $startTime).TotalMinutes
                    if ($elapsedMinutes -ge $Timeout) {
                        $timeoutReached = $true
                        break
                    }
                }
                
                # Refresh process status
                try {
                    $process.Refresh()
                } catch {
                    # Process might have already exited
                    break
                }
            }
            
            if ($timeoutReached) {
                Write-Warning "Timeout reached ($Timeout minutes). Process may still be running."
                Write-Host "Process PID $processId status: " -NoNewline
                try {
                    $runningProcess = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($runningProcess) {
                        Write-Host "Still Running" -ForegroundColor Red
                        return $false
                    } else {
                        Write-Host "Completed" -ForegroundColor Green
                        return $true
                    }
                } catch {
                    Write-Host "Completed" -ForegroundColor Green
                    return $true
                }
            } else {
                Write-Host "Process PID $processId has completed successfully." -ForegroundColor Green
                
                # Get exit code if available
                try {
                    $exitCode = $process.ExitCode
                    Write-Host "Exit Code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Yellow" })
                } catch {
                    Write-Host "Exit code not available." -ForegroundColor Gray
                }
                
                return $true
            }
        } else {
            Write-Error "Failed to start process: $Path"
            return $false
        }
        
    } catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
$ExePath = "C:\Program Files\Notepad++\notepad++.exe"
Write-Host "=== PowerShell EXE Executor and PID Monitor ===" -ForegroundColor Magenta
Write-Host "Executable: $ExePath" -ForegroundColor White
if ($Arguments) {
    Write-Host "Arguments: $Arguments" -ForegroundColor White
}
if ($TimeoutMinutes -gt 0) {
    Write-Host "Timeout: $TimeoutMinutes minutes" -ForegroundColor White
}
Write-Host ""

$success = Execute-AndWaitForClose -Path $ExePath -Args $Arguments -Timeout $TimeoutMinutes

if ($success) {
    Write-Host "`nExecution completed successfully." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nExecution failed or timed out." -ForegroundColor Red
    exit 1
}