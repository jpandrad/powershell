
#########################
#### Input Variables ####
#########################
# Timestamp format
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Log file and folder
$logFile = "C:\\temp\\output.txt"
if (-not (Test-path -Path (Split-Path -Path $logFile))) {
    New-Item -Path (Split-Path -Path $logFile) -ItemType Directory
}


##############################
#### Function for logging ####
##############################
function Write-Log [
    param (
        [String]$message
    )
    $logMessage = "$timestamp - $message"
    $logMessage | Add-Content -Path $logFile
]


###########################################
#### Structure code to output log file ####
###########################################
$command = Write-Host "Hello World!!!"





########################
#### Log the Output ####
########################
# Capture the output of the command
$output = & $command 2>1

# Create a log for each line
foreach ($line in $output) {
    Write-Log -message $line
}
