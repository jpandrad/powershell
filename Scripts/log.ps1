function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile = "C:\Temp\output.log"
    )

    # Check directory
    $logDir = Split-Path $LogFile -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    # Show the message
    Write-Host $Message

    # Create a timestamp and write in the log file
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

# EXAMPLE
Write-Log -Message "Starting execution..."
Get-Process | Where-Object { $_.Path -eq "C:\Program Files\Notepad++\notepad++.exe" } | Stop-Process -Force
Write-Log -Message "Finished execution..."