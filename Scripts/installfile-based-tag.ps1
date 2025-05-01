##################################
### Install List of Softwares  ###
##################################
# Description : Script for install a list of the Softwares based on tags
# Created by: Joao Paulo de Andrade
function installSoftwares {
param (
    [string]$Path
)
    Write-Host "Installing $Path ..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"$Path`" /quiet /norestart" -Wait
    Write-Host "Instalação de $Path concluída.`n"
}

# AWS Parameter to filter tag
$instanceId = Get-EC2InstanceMetadata -Category instanceId
$tags = Get-EC2Tag -Filter @{Name="resource-id";Values="$instanceId"}
$installationType = ($tag | Where-Object {$_.key -eq 'Application'}).value

# Define lists
$python = @(
    "D:\temp\softwares\python2.msi",
    "D:\temp\softwares\python3.msi",
    "D:\temp\softwares\python2.msi"
)

$dotNet = @(
    "D:\temp\softwares\visualstudio.msi",
    "D:\temp\softwares\setup.msi"
)
switch ($installationType.ToLower()) {
    "hicode" {
        $softwareList = $python
    }
    "lowcode" {
        $softwareList = $dotNet
    }
    default {
        Write-Host "Invalid Option!"
        exit
    }
}

# Install Softwares
foreach ($software in $softwareList) {
    if (Test-Path $software) {
        installSoftwares -Path $software
    } else {
        Write-Host "File $software not Found!"
    }
}

Write-Host "Softwares has been installed!"