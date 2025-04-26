######################################
### Run EXE File using Parameters  ###
######################################
# Description : Run EXE File using Parameters
# Created by: Joao Paulo de Andrade
param(
    [string]$Mensagem
)

# Set path and exec file
$pathFile = "C:\temp\runexe.ps1"

try {
    if (Test-Path $pathFile) {
        Start-Process -FilePath $pathFile -ArgumentList $Mensagem
    } else {
        Write-Host "File $pathFile not found!"
        exit 1
    }
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}