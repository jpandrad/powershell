#########################################
### Uninstall Program via PowerShell  ###
#########################################
# Description : Powershell script to uninstall a program
# Created by: Joao Paulo de Andrade

# Put the program name to uninstall
$programName = "AWS Command Line Interface v2"

try {
    $uninstallProgram = Get-WmiObject -Classname Win32_Product | Where-Object Name -Match $programName
    if ($uninstallProgram -eq $null){
        Write-Output "$programName not found!"
        exit 0
    }
    $uninstallProgram.Uninstall()
    Write-Output "$programName has been removed."
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}